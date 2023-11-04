// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.19;

import { IL2Pool } from "./interfaces/IL2Pool.sol";
import { IL2Encoder } from "./interfaces/IL2Encoder.sol";
import { ERC20 } from "solmate/tokens/ERC20.sol";
import { ERC4626 } from "solmate/mixins/ERC4626.sol";
import { SafeTransferLib } from "solmate/utils/SafeTransferLib.sol";

/// @title GreenBondV2
/// @notice ERC4626 Vault on Arbitrum, wth USDT as asset and Aave as passive income lockup.
///         Active income is earned through project payouts, financed by deployed assets.
///         Time weighted asset lockup period of 3-6 months applies to enable the above.
/// @author @sandybradley
contract GreenBondV2 is ERC4626 {
    using SafeTransferLib for ERC20;

    /*//////////////////////////////////////////////////////////////
                               CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @notice USDT on arbitrum
    ERC20 internal constant ASSET = ERC20(0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9);
    /// @notice aUSDT on arbitrum
    ERC20 public constant AAVE_ASSET = ERC20(0x6ab707Aca953eDAeFBc4fD23bA73294241490620);
    /// @notice Aave pool on arbitrum (proxy)
    IL2Pool public constant POOL = IL2Pool(0x794a61358D6845594F94dc1DB02A252b5b4814aD);
    /// @notice Aave encoder on arbitrum
    IL2Encoder public constant ENCODER = IL2Encoder(0x9abADECD08572e0eA5aF4d47A9C7984a5AA503dC);

    /*//////////////////////////////////////////////////////////////
                               GLOBALS
    //////////////////////////////////////////////////////////////*/

    /// @notice Deposit lockup time, default 3 months
    uint64 public LOCKUP = 3 * 30 days;
    /// @notice Transient tokens deployed to project (~ 6 months lock-up)
    uint256 public DEPLOYED_ASSETS;
    /// @notice Total assets deployed to projects
    uint256 public TOTAL_DEPLOYED_ASSETS;
    /// @notice Total assets paid by projects
    uint256 public TOTAL_REPAID_ASSETS;
    /// @notice Governance addresses
    mapping(address => bool) public GOV;
    /// @notice Time weighted average lockup time per address
    mapping(address => uint256) public depositTimestamps;
    // internal global variables
    uint256 public projectCount;
    mapping(uint256 => Project) public projects;
    mapping(address => uint256) internal rewards;
    mapping(address => uint256) internal lastClaimTimestamps;

    /*//////////////////////////////////////////////////////////////
                                 CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor() ERC4626(ASSET, "GreenBondV2", "gBOND2") {
        // approve Aave pool max spend of USDT from this address to save gas on supply calls
        ASSET.approve(address(POOL), type(uint256).max);
        GOV[tx.origin] = true; // CREATE2 deployment requires tx.origin
    }

    /*//////////////////////////////////////////////////////////////
                                 GOVERNANCE
    //////////////////////////////////////////////////////////////*/

    function _govCheck() internal view {
        if (!GOV[msg.sender]) revert Unauthorized();
    }

    function changeLockup(uint64 newLockup) external {
        _govCheck();
        LOCKUP = newLockup;
    }

    function addGov(address newGov) external {
        _govCheck();
        GOV[newGov] = true;
        emit GovernorAdded(newGov);
    }

    function removeGov(address oldGov) external {
        _govCheck();
        if (msg.sender == oldGov) revert Unauthorized();
        GOV[oldGov] = false;
        emit GovernorRemoved(oldGov);
    }

    function recoverToken(address token, address receiver, uint256 tokenAmount) external {
        _govCheck();
        ERC20(token).safeTransfer(receiver, tokenAmount);
    }

    /*//////////////////////////////////////////////////////////////
                                PROJECTS
    //////////////////////////////////////////////////////////////*/

    struct Project {
        bool isActive;
        bool isCompleted;
        address admin;
        uint128 totalAssetsSupplied;
        uint128 totalAssetsRepaid;
        string projectName;
        string masterAgreement;
    }

    function registerProject(address projectAdmin, string calldata projectName) external returns (uint256) {
        _govCheck();
        if (projectAdmin == address(0)) revert ZeroAddress();

        Project memory project;
        project.admin = projectAdmin;
        project.projectName = projectName;

        unchecked {
            ++projectCount;
        }

        projects[projectCount] = project;

        emit ProjectRegistered(projectCount);

        return projectCount;
    }

    function linkProjectAgreement(uint256 projectId, string calldata masterAgreement) external {
        _govCheck();
        projects[projectId].masterAgreement = masterAgreement;
    }

    function completeProject(uint256 projectId) external {
        _govCheck();
        if (projects[projectId].totalAssetsRepaid > projects[projectId].totalAssetsSupplied) {
            projects[projectId].isCompleted = true;
        }
    }

    function payProject(uint256 assets, uint256 projectId) external {
        _govCheck();
        if (projectId > projectCount) revert NotProject();
        if (AAVE_ASSET.balanceOf(address(this)) < assets) revert InsufficientLiquidity();
        if (!projects[projectId].isActive) {
            projects[projectId].isActive = true;
        }
        projects[projectId].totalAssetsSupplied += uint128(assets);

        beforeWithdraw(assets, 0);

        unchecked {
            DEPLOYED_ASSETS += assets;
            TOTAL_DEPLOYED_ASSETS += assets;
        }

        emit PaidProject(projects[projectId].admin, assets, projectId);

        ASSET.safeTransfer(projects[projectId].admin, assets);
    }

    function receiveIncome(uint256 assets, uint256 projectId) external {
        ASSET.safeTransferFrom(msg.sender, address(this), assets);
        afterDeposit(assets, 0);
        projects[projectId].totalAssetsRepaid += uint128(assets);
        unchecked {
            TOTAL_REPAID_ASSETS += assets;
        }
        if (assets > DEPLOYED_ASSETS) {
            DEPLOYED_ASSETS = 0;
        } else {
            unchecked {
                DEPLOYED_ASSETS -= assets;
            }
        }
        emit ReceivedIncome(msg.sender, assets, projectId);
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function totalAssets() public view virtual override returns (uint256) {
        // Aave asset has a 1:1 ratio with underlying asset
        // Fetch latest balance of principal + interest from Aave
        return AAVE_ASSET.balanceOf(address(this)) + DEPLOYED_ASSETS;
    }

    function deposit(uint256 assets, address receiver) public virtual override returns (uint256 shares) {
        // Set the deposit timestamp for the user
        _updateDepositTimestamp(receiver, convertToShares(assets));
        shares = super.deposit(assets, receiver);
    }

    function mint(uint256 shares, address receiver) public virtual override returns (uint256 assets) {
        // Set the deposit timestamp for the user
        _updateDepositTimestamp(receiver, shares);
        assets = super.mint(shares, receiver);
    }

    function withdraw(uint256 assets, address receiver, address owner) public virtual override returns (uint256 shares) {
        if (block.timestamp < depositTimestamps[owner] + LOCKUP) revert InsufficientLockupTime();
        shares = super.withdraw(assets, receiver, owner);
    }

    function redeem(uint256 shares, address receiver, address owner) public virtual override returns (uint256 assets) {
        if (block.timestamp < depositTimestamps[owner] + LOCKUP) revert InsufficientLockupTime();
        assets = super.redeem(shares, receiver, owner);
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool success) {
        _updateDepositTimestamp(to, amount);
        success = super.transfer(to, amount);
        _updateTransferTimestamp(msg.sender, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool success) {
        _updateDepositTimestamp(to, amount);
        success = super.transferFrom(from, to, amount);
        _updateTransferTimestamp(from, amount);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function beforeWithdraw(uint256 assets, uint256) internal virtual override {
        if (AAVE_ASSET.balanceOf(address(this)) < assets) revert InsufficientLiquidity();
        // Withdraw underlying asset from Aave
        bytes32 args = ENCODER.encodeWithdrawParams(address(ASSET), assets);
        POOL.withdraw(args);
    }

    function afterDeposit(uint256 assets, uint256) internal virtual override {
        // Deposit underlying asset to Aave
        bytes32 args = ENCODER.encodeSupplyParams(address(ASSET), assets, 0);
        POOL.supply(args);
    }

    function _updateDepositTimestamp(address account, uint256 shares) internal {
        // Set the deposit timestamp for the user
        uint256 prevBalance = balanceOf[account];
        uint256 lastDeposit = depositTimestamps[account];
        if (prevBalance == 0 || lastDeposit == 0) {
            depositTimestamps[account] = block.timestamp;
        } else {
            // multiple deposits, so weight timestamp by amounts
            unchecked {
                depositTimestamps[account] = lastDeposit + (block.timestamp - lastDeposit) * shares / (prevBalance + shares);
            }
        }
    }

    function _updateTransferTimestamp(address account, uint256 shares) internal {
        // Set the transfer timestamp for the user
        uint256 newBalance = balanceOf[account];
        uint256 lastDeposit = depositTimestamps[account];
        if (newBalance == 0 || lastDeposit < (block.timestamp - lastDeposit)) {
            depositTimestamps[account] = 0;
        } else {
            // multiple deposits, so weight timestamp by amounts
            unchecked {
                depositTimestamps[account] = lastDeposit - (block.timestamp - lastDeposit) * shares / (newBalance + shares);
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event GovernorAdded(address newGov);
    event GovernorRemoved(address oldGov);
    event PaidProject(address admin, uint256 amount, uint256 projectId);
    event ReceivedIncome(address indexed sender, uint256 assets, uint256 projectId);
    event ProjectRegistered(uint256 indexed project);

    /*//////////////////////////////////////////////////////////////
                               ERRORS
    //////////////////////////////////////////////////////////////*/

    error InsufficientAsset();
    error InsufficientLiquidity();
    error InsufficientBalance();
    error InsufficientAllowance();
    error UnknownToken();
    error ZeroShares();
    error ZeroAmount();
    error ZeroAddress();
    error Overflow();
    error IdenticalAddresses();
    error InsufficientLockupTime();
    error Unauthorized();
    error NotProject();
}
