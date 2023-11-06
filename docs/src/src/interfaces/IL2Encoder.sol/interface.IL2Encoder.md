# IL2Encoder
[Git Source](https://github.com/greenchaincapital/GreenBondV2/blob/51a1807f93a4bb92129f4cca023d319c78973c0c/src/interfaces/IL2Encoder.sol)

**Author:**
Aave

Defines the basic extension interface for an L2 Aave Encoder.


## Functions
### encodeSupplyParams


```solidity
function encodeSupplyParams(address asset, uint256 amount, uint16 referralCode) external view returns (bytes32);
```

### encodeSupplyWithPermit


```solidity
function encodeSupplyWithPermit(address asset, uint256 amount, uint16 referralCode, uint256 deadline, uint8 permitV, bytes32 permitR, bytes32 permitS)
    external
    view
    returns (bytes32, bytes32, bytes32);
```

### encodeWithdrawParams


```solidity
function encodeWithdrawParams(address asset, uint256 amount) external view returns (bytes32);
```

