# IL2Pool
[Git Source](https://github.com/greenchaincapital/GreenBondV2/blob/51a1807f93a4bb92129f4cca023d319c78973c0c/src/interfaces/IL2Pool.sol)

**Author:**
Aave

Defines the basic extension interface for an L2 Aave Pool.


## Functions
### supply

Calldata efficient wrapper of the supply function on behalf of the caller

*the shortenedAmount is cast to 256 bits at decode time, if type(uint128).max the value will be expanded to
type(uint256).max*

*assetId is the index of the asset in the reservesList.*


```solidity
function supply(bytes32 args) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`args`|`bytes32`|Arguments for the supply function packed in one bytes32 96 bits       16 bits         128 bits      16 bits | 0-padding | referralCode | shortenedAmount | assetId ||


### supplyWithPermit

Calldata efficient wrapper of the supplyWithPermit function on behalf of the caller

*the shortenedAmount is cast to 256 bits at decode time, if type(uint128).max the value will be expanded to
type(uint256).max*

*assetId is the index of the asset in the reservesList.*


```solidity
function supplyWithPermit(bytes32 args, bytes32 r, bytes32 s) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`args`|`bytes32`|Arguments for the supply function packed in one bytes32 56 bits    8 bits         32 bits           16 bits         128 bits      16 bits | 0-padding | permitV | shortenedDeadline | referralCode | shortenedAmount | assetId ||
|`r`|`bytes32`|The R parameter of ERC712 permit sig|
|`s`|`bytes32`|The S parameter of ERC712 permit sig|


### withdraw

Calldata efficient wrapper of the withdraw function, withdrawing to the caller

*the shortenedAmount is cast to 256 bits at decode time, if type(uint128).max the value will be expanded to
type(uint256).max*

*assetId is the index of the asset in the reservesList.*


```solidity
function withdraw(bytes32 args) external returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`args`|`bytes32`|Arguments for the withdraw function packed in one bytes32 112 bits       128 bits      16 bits | 0-padding | shortenedAmount | assetId ||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The final amount withdrawn|


