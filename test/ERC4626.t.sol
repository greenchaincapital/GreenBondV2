// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {GreenBondV2} from "src/GreenBondV2.sol";

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address to, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address from, address to, uint amount) external returns (bool);
}

interface IERC4626 is IERC20 {
    event Deposit(address indexed caller, address indexed owner, uint assets, uint shares);
    event Withdraw(address indexed caller, address indexed receiver, address indexed owner, uint assets, uint shares);
    function asset() external view returns (address assetTokenAddress);
    function totalAssets() external view returns (uint totalManagedAssets);
    function convertToShares(uint assets) external view returns (uint shares);
    function convertToAssets(uint shares) external view returns (uint assets);
    function maxDeposit(address receiver) external view returns (uint maxAssets);
    function previewDeposit(uint assets) external view returns (uint shares);
    function deposit(uint assets, address receiver) external returns (uint shares);
    function maxMint(address receiver) external view returns (uint maxShares);
    function previewMint(uint shares) external view returns (uint assets);
    function mint(uint shares, address receiver) external returns (uint assets);
    function maxWithdraw(address owner) external view returns (uint maxAssets);
    function previewWithdraw(uint assets) external view returns (uint shares);
    function withdraw(uint assets, address receiver, address owner) external returns (uint shares);
    function maxRedeem(address owner) external view returns (uint maxShares);
    function previewRedeem(uint shares) external view returns (uint assets);
    function redeem(uint shares, address receiver, address owner) external returns (uint assets);
}

contract ERC4626Test is Test {
    using stdStorage for StdStorage;

    GreenBondV2 public bond;
    address public gov;

    address internal _underlying_;
    address internal _vault_;

    bool internal _vaultMayBeEmpty;
    bool internal _unlimitedAmount;

    function setUp() public {
        bond = new GreenBondV2();
        gov = tx.origin;
        _underlying_ = address(bond.asset());
        _vault_ = address(bond);
        _vaultMayBeEmpty = true;
        _unlimitedAmount = false;
    }

    function writeTokenBalance(address who, address token, uint256 amt) internal {
        stdstore.target(token).sig(ERC20(token).balanceOf.selector).with_key(who).checked_write(amt);
    }

    //
    // asset
    //

    // asset
    // "MUST NOT revert."
    function test_asset() public view {
        IERC4626(_vault_).asset();
    }

    // totalAssets
    // "MUST NOT revert."
    function test_totalAssets() public view {
        IERC4626(_vault_).totalAssets();
    }

    //
    // convert
    //

    // convertToShares
    // "MUST NOT show any variations depending on the caller."
    function test_convertToShares(uint assets) public {
        uint res1 = bond.convertToShares(assets); // "MAY revert due to integer overflow caused by an unreasonably large input."
        assertEq(res1, assets);
    }

    // convertToAssets
    // "MUST NOT show any variations depending on the caller."
    function test_convertToAssets(uint shares) public {
        uint res1 = bond.convertToAssets(shares); // "MAY revert due to integer overflow caused by an unreasonably large input."
        assertEq(res1, shares);
    }

    //
    // deposit
    //

    // maxDeposit
    // "MUST NOT revert."
    function test_maxDeposit() public view {
        IERC4626(_vault_).maxDeposit(address(this));
    }

    // previewDeposit
    // "MUST return as close to and no more than the exact amount of Vault
    // shares that would be minted in a deposit call in the same transaction.
    // I.e. deposit should return the same or more shares as previewDeposit if
    // called in the same transaction."
    function test_previewDeposit(uint assets) public {
        vm.assume(assets>0);
        vm.assume(assets<20000000000000);
        writeTokenBalance(address(this), _underlying_, assets);
        ERC20(_underlying_).approve(_vault_, assets);
        uint sharesPreview = bond.previewDeposit(assets); // "MAY revert due to other conditions that would also cause deposit to revert."
        uint sharesActual = bond.deposit(assets, address(this));
        assertGe(sharesActual, sharesPreview);
    }

    // deposit
    function test_deposit(uint assets) public {
        vm.assume(assets>0);
        vm.assume(assets<20000000000000);
        writeTokenBalance(address(this), _underlying_, assets);
        ERC20(_underlying_).approve(_vault_, assets);
        uint oldCallerAsset = IERC20(_underlying_).balanceOf(address(this));
        uint oldReceiverShare = IERC20(_vault_).balanceOf(address(this));

        uint shares = bond.deposit(assets, address(this));

        uint newCallerAsset = IERC20(_underlying_).balanceOf(address(this));
        uint newReceiverShare = IERC20(_vault_).balanceOf(address(this));

        assertEq(newCallerAsset, oldCallerAsset - assets);
        assertEq(newReceiverShare, oldReceiverShare + shares);
    }

    //
    // mint
    //

    // maxMint
    // "MUST NOT revert."
    function test_maxMint() public view {
        IERC4626(_vault_).maxMint(address(this));
    }

    // previewMint
    // "MUST return as close to and no fewer than the exact amount of assets
    // that would be deposited in a mint call in the same transaction. I.e. mint
    // should return the same or fewer assets as previewMint if called in the
    // same transaction."
    function test_previewMint(uint shares) public {
        vm.assume(shares>0);
        vm.assume(shares<20000000000000);
        writeTokenBalance(address(this), _underlying_, bond.convertToAssets(shares));
        ERC20(_underlying_).approve(_vault_, bond.convertToAssets(shares));
        uint assetsPreview = bond.previewMint(shares);
        uint assetsActual = bond.mint(shares, address(this));
        assertLe(assetsActual, assetsPreview);
    }

    // mint
    function test_mint(uint shares) public {
        vm.assume(shares>0);
        vm.assume(shares<20000000000000);
        writeTokenBalance(address(this), _underlying_, bond.convertToAssets(shares));
        ERC20(_underlying_).approve(_vault_, bond.convertToAssets(shares));
        uint oldCallerAsset = IERC20(_underlying_).balanceOf(address(this));
        uint oldReceiverShare = IERC20(_vault_).balanceOf(address(this));

        uint assets = bond.mint(shares, address(this));

        uint newCallerAsset = IERC20(_underlying_).balanceOf(address(this));
        uint newReceiverShare = IERC20(_vault_).balanceOf(address(this));

        assertEq(newCallerAsset, oldCallerAsset - assets);
        assertEq(newReceiverShare, oldReceiverShare + shares);
    }

    //
    // withdraw
    //

    // maxWithdraw
    // "MUST NOT revert."
    // NOTE: some implementations failed due to arithmetic overflow
    function test_maxWithdraw() public view {
        IERC4626(_vault_).maxWithdraw(address(this));
    }

    // previewWithdraw
    // "MUST return as close to and no fewer than the exact amount of Vault
    // shares that would be burned in a withdraw call in the same transaction.
    // I.e. withdraw should return the same or fewer shares as previewWithdraw
    // if called in the same transaction."
    function test_previewWithdraw(uint assets) public view {
        bond.previewWithdraw(assets);
    }


    //
    // redeem
    //

    // maxRedeem
    // "MUST NOT revert."
    function test_maxRedeem() public view {
        IERC4626(_vault_).maxRedeem(address(this));
    }

    // previewRedeem
    // "MUST return as close to and no more than the exact amount of assets that
    // would be withdrawn in a redeem call in the same transaction. I.e. redeem
    // should return the same or more assets as previewRedeem if called in the
    // same transaction."
    function test_previewRedeem(uint shares) public view {
        bond.previewRedeem(shares);
    }

    //
    // round trip properties
    //

    // redeem(deposit(a)) <= a
    function test_RT_deposit_redeem(uint assets) public {
        vm.assume(assets>0);
        vm.assume(assets<20000000000000);
        writeTokenBalance(address(this), _underlying_, assets);
        ERC20(_underlying_).approve(_vault_, assets);
        uint shares = bond.deposit(assets, address(this));
        vm.warp(block.timestamp + 365 days);
        uint assets2 = bond.redeem(shares, address(this), address(this));
        assertGe(assets2, assets);  // rewards earned
    }

    // s = deposit(a)
    // s' = withdraw(a)
    // s' >= s
    function test_RT_deposit_withdraw(uint assets) public {
        vm.assume(assets>0);
        vm.assume(assets<20000000000000);
        writeTokenBalance(address(this), _underlying_, assets);
        ERC20(_underlying_).approve(_vault_, assets);
        uint shares1 = bond.deposit(assets, address(this));
        vm.warp(block.timestamp + 365 days);
        uint shares2 = bond.withdraw(assets, address(this), address(this));
        assertLe(shares2, shares1);
    }

    // withdraw(mint(s)) >= s
    function test_RT_mint_withdraw(uint shares) public {
        vm.assume(shares>0);
        vm.assume(shares<20000000000000);
        writeTokenBalance(address(this), _underlying_, bond.convertToAssets(shares));
        ERC20(_underlying_).approve(_vault_, bond.convertToAssets(shares));
        uint assets = bond.mint(shares, address(this));
        vm.warp(block.timestamp + 365 days);
        uint shares2 = bond.withdraw(assets, address(this), address(this));
        assertLe(shares2, shares);
    }

    // a = mint(s)
    // a' = redeem(s)
    // a' <= a
    function test_RT_mint_redeem(uint shares) public {
        vm.assume(shares>0);
        vm.assume(shares<20000000000000);
        writeTokenBalance(address(this), _underlying_, bond.convertToAssets(shares));
        ERC20(_underlying_).approve(_vault_, bond.convertToAssets(shares));
        uint assets1 = bond.mint(shares, address(this));
        vm.warp(block.timestamp + 365 days);
        uint assets2 = bond.redeem(shares, address(this), address(this));
        assertGe(assets2, assets1);
    }

   
}
