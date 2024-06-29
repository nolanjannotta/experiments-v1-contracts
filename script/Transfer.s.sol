// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {OnchainArtExperiments} from "../src/OnchainArtExperiments.sol";
import {NotSquiggles} from "../src/ArtGenerators/NotSquiggles.sol";
import {IArtGenerator} from "../src/interfaces.sol";

contract Transfer is Script {

//     struct Wallet {
//       address addr;
//       uint256 publicKeyX;
//       uint256 publicKeyY;
//       uint256 privateKey;
//   }

        address sender = vm.addr(uint(vm.envUint("BASE_TEST_PRIVATE_KEY")));
        address otherSender = vm.addr(uint(vm.envUint("BASE_TEST_MINTING_KEY")));
        OnchainArtExperiments art = OnchainArtExperiments(payable(vm.envAddress("CURRENT_ART_ADDRESS")));



    function setUp() public {
        
    }

    function run() public {

        vm.startBroadcast(uint(vm.envUint("BASE_TEST_PRIVATE_KEY")));  

        // art.transferFrom(sender, address(123), 2000001);     


        for(uint i=1; i<=100; i++){
                if(art.ownerOf(6000000 + i) == sender) {
                        art.transferFrom(sender, address(uint160(i*123)), 6000000 + i);
                }
                

        }
        
        vm.stopBroadcast();




        // vm.startBroadcast(uint(vm.envUint("BASE_TEST_MINTING_KEY")));
        // art.transferFrom(otherSender, sender, 2000007);
        // vm.stopBroadcast();
        //         vm.startBroadcast(uint(vm.envUint("BASE_TEST_PRIVATE_KEY")));  
        // art.transferFrom(sender, otherSender, 2000007);
        // vm.stopBroadcast();




        // vm.startBroadcast(uint(vm.envUint("BASE_TEST_MINTING_KEY")));
        // art.transferFrom(otherSender, sender, 2000007);
        // vm.stopBroadcast();
        //         vm.startBroadcast(uint(vm.envUint("BASE_TEST_PRIVATE_KEY")));  
        // art.transferFrom(sender, otherSender, 2000007);
        // vm.stopBroadcast();




        // vm.startBroadcast(uint(vm.envUint("BASE_TEST_MINTING_KEY")));
        // art.transferFrom(otherSender, sender, 2000007);
        // vm.stopBroadcast();
        //         vm.startBroadcast(uint(vm.envUint("BASE_TEST_PRIVATE_KEY")));  
        // art.transferFrom(sender, otherSender, 2000007);
        // vm.stopBroadcast();




        // vm.startBroadcast(uint(vm.envUint("BASE_TEST_MINTING_KEY")));
        // art.transferFrom(otherSender, sender, 2000007);
        // vm.stopBroadcast();
        //         vm.startBroadcast(uint(vm.envUint("BASE_TEST_PRIVATE_KEY")));  
        // art.transferFrom(sender, otherSender, 2000007);
        // vm.stopBroadcast();




        // vm.startBroadcast(uint(vm.envUint("BASE_TEST_MINTING_KEY")));
        // art.transferFrom(otherSender, sender, 2000007);
        // vm.stopBroadcast();


    }
}
