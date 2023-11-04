// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script, console2 } from "forge-std/Script.sol";
import { GreenBondV2 } from "src/GreenBondV2.sol";

contract DeployScript is Script {
    function setUp() public { }

    function run() public {
        vm.startBroadcast();
        new GreenBondV2();
        vm.stopBroadcast();
    }
}
