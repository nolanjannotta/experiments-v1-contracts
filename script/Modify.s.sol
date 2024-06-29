// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {OnchainArtExperiments} from "../src/OnchainArtExperiments.sol";
import {NotSquiggles} from "../src/ArtGenerators/NotSquiggles.sol";
import {Panels} from "../src/ArtGenerators/Panels.sol";
import {IArtGenerator} from "../src/interfaces.sol";
// import {ScriptHelpers} from "./ScriptHelpers.s.sol";

contract Modify is Script {

    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("BASE_TEST_PRIVATE_KEY"));

        
        OnchainArtExperiments art = OnchainArtExperiments(payable(vm.envAddress("CURRENT_ART_ADDRESS")));        
        // clock edition #9
        // uint timeZoneOffset, uint negative, uint background, string memory location
        bytes memory data = abi.encode(17,10000003, "");
        

        // bytes memory data = abi.encode(2_000_220);


        art.modify(6000001,  data);

        // console.log(clock);
        // art.mint();






        vm.stopBroadcast();

    }
}
