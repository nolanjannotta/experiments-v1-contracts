// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {OnchainArtExperiments} from "../src/OnchainArtExperiments.sol";
import {NotSquiggles} from "../src/ArtGenerators/NotSquiggles.sol";
import {IArtGenerator} from "../src/interfaces.sol";

contract Mint is Script {

    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("BASE_TEST_PRIVATE_KEY"));

        
        OnchainArtExperiments art = OnchainArtExperiments(payable(vm.envAddress("CURRENT_ART_ADDRESS")));
        for(uint i=0; i<100; i++) {
            art.mint(2);
        }




        // vm.stopBroadcast();

    }
}
