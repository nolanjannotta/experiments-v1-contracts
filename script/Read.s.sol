// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {OnchainArtExperiments} from "../src/OnchainArtExperiments.sol";
import {NotSquiggles} from "../src/ArtGenerators/NotSquiggles.sol";
import {IArtGenerator} from "../src/interfaces.sol";

contract Read is Script {

    function setUp() public {}

    function run() public {
        // vm.startBroadcast(vm.envUint("BASE_TEST_PRIVATE_KEY"));

        
        OnchainArtExperiments art = OnchainArtExperiments(payable(vm.envAddress("CURRENT_ART_ADDRESS")));
        // vm.writeLine("SVGs/tokenURIs/4000010.txt", art.tokenURI(4000010));
        // console.log(art.tokenURI(10_000_001));
        // console.log(art.getEdition(1).mintStatus);
        // art.mint();
        console.log(art.OWNER());

        // console.log(art.supportsInterface(bytes4(0x2a55205a)));



        // vm.stopBroadcast();

    }
}
