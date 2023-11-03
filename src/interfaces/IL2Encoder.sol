// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/**
 * @title IL2Encoder
 * @author Aave
 * @notice Defines the basic extension interface for an L2 Aave Encoder.
 */
interface IL2Encoder {
  function encodeSupplyParams(address asset, uint256 amount, uint16 referralCode) external view returns (bytes32);
  function encodeSupplyWithPermit(address asset, uint256 amount, uint16 referralCode, uint256 deadline, uint8 permitV, bytes32 permitR, bytes32 permitS) external view returns (bytes32, bytes32, bytes32);
  function encodeWithdrawParams(address asset, uint256 amount) external view returns (bytes32);
}