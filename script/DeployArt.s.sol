// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {OnchainArtExperiments} from "../src/OnchainArtExperiments.sol";


contract DeployArt is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("BASE_DEPLOY_KEY"));

        
        OnchainArtExperiments art = new OnchainArtExperiments();
        console.log(address(art));

        vm.stopBroadcast();

    }
}
