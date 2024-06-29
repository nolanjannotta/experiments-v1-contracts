// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {OnchainArtExperiments} from "../src/OnchainArtExperiments.sol";
import {NotSquiggles} from "../src/ArtGenerators/NotSquiggles.sol";
import {Panels} from "../src/ArtGenerators/Panels.sol";
import {IArtGenerator} from "../src/interfaces.sol";
// import {ScriptHelpers} from "./ScriptHelpers.s.sol";

contract SetPrice is Script {

    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("BASE_TEST_PRIVATE_KEY"));

        
        OnchainArtExperiments art = OnchainArtExperiments(payable(vm.envAddress("CURRENT_ART_ADDRESS")));        

        // art.setPrice(2, 50 ether);
        art.setRoyalty(1, 500);



        vm.stopBroadcast();

    }
}
