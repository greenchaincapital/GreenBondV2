# GreenBondV2
[Git Source](https://github.com/greenchaincapital/GreenBondV2/blob/51a1807f93a4bb92129f4cca023d319c78973c0c/src/GreenBondV2.sol)

**Inherits:**
ERC4626

**Author:**
@sandybradley

ERC4626 Vault on Arbitrum, wth USDT as asset and Aave as passive income lockup.
Active income is earned through project payouts, financed by deployed assets.
Time weighted asset lockup period of 3-6 months applies to enable the above.


## State Variables
### ASSET
USDT on arbitrum


```solidity
ERC20 internal constant ASSET = ERC20(0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9);
```


### AAVE_ASSET
aUSDT on arbitrum


```solidity
ERC20 public constant AAVE_ASSET = ERC20(0x6ab707Aca953eDAeFBc4fD23bA73294241490620);
```


### POOL
Aave pool on arbitrum (proxy)


```solidity
IL2Pool public constant POOL = IL2Pool(0x794a61358D6845594F94dc1DB02A252b5b4814aD);
```


### ENCODER
Aave encoder on arbitrum


```solidity
IL2Encoder public constant ENCODER = IL2Encoder(0x9abADECD08572e0eA5aF4d47A9C7984a5AA503dC);
```


### LOCKUP
Deposit lockup time, default 3 months


```solidity
uint64 public LOCKUP = 3 * 30 days;
```


### DEPLOYED_ASSETS
Transient tokens deployed to project (~ 6 months lock-up)


```solidity
uint256 public DEPLOYED_ASSETS;
```


### TOTAL_DEPLOYED_ASSETS
Total assets deployed to projects


```solidity
uint256 public TOTAL_DEPLOYED_ASSETS;
```


### TOTAL_REPAID_ASSETS
Total assets paid by projects


```solidity
uint256 public TOTAL_REPAID_ASSETS;
```


### GOV
Governance addresses


```solidity
mapping(address => bool) public GOV;
```


### depositTimestamps
Time weighted average lockup time per address


```solidity
mapping(address => uint256) public depositTimestamps;
```


### projectCount

```solidity
uint256 public projectCount;
```


### projects

```solidity
mapping(uint256 => Project) public projects;
```


### rewards

```solidity
mapping(address => uint256) internal rewards;
```


### lastClaimTimestamps

```solidity
mapping(address => uint256) internal lastClaimTimestamps;
```


## Functions
### constructor


```solidity
constructor() ERC4626(ASSET, "GreenBondV2", "gBOND2");
```

### _govCheck


```solidity
function _govCheck() internal view;
```

### changeLockup


```solidity
function changeLockup(uint64 newLockup) external;
```

### addGov


```solidity
function addGov(address newGov) external;
```

### removeGov


```solidity
function removeGov(address oldGov) external;
```

### recoverToken


```solidity
function recoverToken(address token, address receiver, uint256 tokenAmount) external;
```

### registerProject


```solidity
function registerProject(address projectAdmin, string calldata projectName) external returns (uint256);
```

### linkProjectAgreement


```solidity
function linkProjectAgreement(uint256 projectId, string calldata masterAgreement) external;
```

### completeProject


```solidity
function completeProject(uint256 projectId) external;
```

### payProject


```solidity
function payProject(uint256 assets, uint256 projectId) external;
```

### receiveIncome


```solidity
function receiveIncome(uint256 assets, uint256 projectId) external;
```

### totalAssets


```solidity
function totalAssets() public view virtual override returns (uint256);
```

### deposit


```solidity
function deposit(uint256 assets, address receiver) public virtual override returns (uint256 shares);
```

### mint


```solidity
function mint(uint256 shares, address receiver) public virtual override returns (uint256 assets);
```

### withdraw


```solidity
function withdraw(uint256 assets, address receiver, address owner) public virtual override returns (uint256 shares);
```

### redeem


```solidity
function redeem(uint256 shares, address receiver, address owner) public virtual override returns (uint256 assets);
```

### transfer


```solidity
function transfer(address to, uint256 amount) public virtual override returns (bool success);
```

### transferFrom


```solidity
function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool success);
```

### beforeWithdraw


```solidity
function beforeWithdraw(uint256 assets, uint256) internal virtual override;
```

### afterDeposit


```solidity
function afterDeposit(uint256 assets, uint256) internal virtual override;
```

### _updateDepositTimestamp


```solidity
function _updateDepositTimestamp(address account, uint256 shares) internal;
```

### _updateTransferTimestamp


```solidity
function _updateTransferTimestamp(address account, uint256 shares) internal;
```

## Events
### GovernorAdded

```solidity
event GovernorAdded(address newGov);
```

### GovernorRemoved

```solidity
event GovernorRemoved(address oldGov);
```

### PaidProject

```solidity
event PaidProject(address admin, uint256 amount, uint256 projectId);
```

### ReceivedIncome

```solidity
event ReceivedIncome(address indexed sender, uint256 assets, uint256 projectId);
```

### ProjectRegistered

```solidity
event ProjectRegistered(uint256 indexed project);
```

## Errors
### InsufficientAsset

```solidity
error InsufficientAsset();
```

### InsufficientLiquidity

```solidity
error InsufficientLiquidity();
```

### InsufficientBalance

```solidity
error InsufficientBalance();
```

### InsufficientAllowance

```solidity
error InsufficientAllowance();
```

### UnknownToken

```solidity
error UnknownToken();
```

### ZeroShares

```solidity
error ZeroShares();
```

### ZeroAmount

```solidity
error ZeroAmount();
```

### ZeroAddress

```solidity
error ZeroAddress();
```

### Overflow

```solidity
error Overflow();
```

### IdenticalAddresses

```solidity
error IdenticalAddresses();
```

### InsufficientLockupTime

```solidity
error InsufficientLockupTime();
```

### Unauthorized

```solidity
error Unauthorized();
```

### NotProject

```solidity
error NotProject();
```

## Structs
### Project

```solidity
struct Project {
    bool isActive;
    bool isCompleted;
    address admin;
    uint128 totalAssetsSupplied;
    uint128 totalAssetsRepaid;
    string projectName;
    string masterAgreement;
}
```

