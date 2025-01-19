//SPDX_License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {ZiaratToken} from "../src/ziaratToken.sol";

contract DeployZiaratToken is Script {
    ZiaratToken ziaratToken;
    uint256 totalSupply = 1_000_000_000;

    function run() external returns (ZiaratToken) {
        vm.startBroadcast();
        ziaratToken = new ZiaratToken(totalSupply);
        vm.stopBroadcast();
        return ziaratToken;
    }
}
