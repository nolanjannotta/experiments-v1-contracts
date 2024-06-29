// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
// import "forge-std/Vm.sol";
import {OnchainArtExperiments} from "../src/OnchainArtExperiments.sol";
import {NotSquiggles} from "../src/ArtGenerators/NotSquiggles.sol";
import {Panels} from "../src/ArtGenerators/Panels.sol";
import {IArtGenerator} from "../src/interfaces.sol";
// import {ScriptHelpers} from "./ScriptHelpers.s.sol";
import {GeneratorFactory} from "./GeneratorFactory.sol";
import {WhereDoYouDrawTheLine} from "../src/ArtGenerators/WhereDoYouDrawTheLine.sol";
import {TreeSketch} from "../src/ArtGenerators/TreeSketch.sol";


contract CreateEdition is GeneratorFactory, Script {

    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("BASE_DEPLOY_KEY")); // switch to ART_GENERATOR_DEPLOYER_KEY

        
        OnchainArtExperiments art = OnchainArtExperiments(payable(vm.envAddress("CURRENT_ART_ADDRESS")));

        // string memory prompt = "you are about to deploy and new generator contract and attach it to the main experiments contract. \n\nbelow are the current generators:\n\n";
        // for(uint i=1; i<=art.EDITION_COUNTER(); i++) {
        //     prompt = string.concat(prompt, vm.toString(i), ". ", art.getEdition(i).name, "\n");
        // }

        uint edition;
                
        // edition = createSignatures(art, 0xB45A1378e9BBa0eA4ca6435544B62fd23806CD0D);
        // art.setMintStatus(edition, true);
        // art.mint(edition);
        // art.mint(edition);
        // art.mint(edition);
        // art.mint(edition);
        // art.mint(edition);
        // edition = createPanels(art, 0xB45A1378e9BBa0eA4ca6435544B62fd23806CD0D);
        // art.setMintStatus(edition, true);
        // art.mint(edition);
        // art.mint(edition);
        // art.mint(edition);
        // art.mint(edition);
        // art.mint(edition);
        // edition = createRectangularClock(art, 0xB45A1378e9BBa0eA4ca6435544B62fd23806CD0D);
        // art.setMintStatus(edition, true);
        // art.mint(edition);
        // art.mint(edition);
        // art.mint(edition);
        // art.mint(edition);
        // art.mint(edition);
        // edition = createWhereDoYouDrawTheLine(art, 0xB45A1378e9BBa0eA4ca6435544B62fd23806CD0D);
        // WhereDoYouDrawTheLine wdydtl = new WhereDoYouDrawTheLine();
        // TreeSketch treeSketch = new TreeSketch();

        // console.log(address(treeSketch));
        // art.setMintStatus(edition, true);
        // art.mint(edition);
        // art.mint(edition);
        // art.mint(edition);
        // art.mint(edition);
        // art.mint(edition);
        // edition = createTreeSketch(art, 0xB45A1378e9BBa0eA4ca6435544B62fd23806CD0D);
        // art.setMintStatus(edition, true);
        // art.mint(edition);
        // art.mint(edition);
        // art.mint(edition);
        // art.mint(edition);
        // art.mint(edition);
        edition = createBlackAndWhite(art, 0xB45A1378e9BBa0eA4ca6435544B62fd23806CD0D);
        // art.setMintStatus(edition, true);
        // art.mint(edition);
        // art.mint(edition);
        // art.mint(edition);
        // art.mint(edition);
        // art.mint(edition);


        // vm.prompt("if you wish to continue, type 'yes' and press enter");


        // prompt = string.concat(prompt, "\n\nverify your script to make sure you are deploying the correct one. \nverify that the name, description and supply is correct as well \n\n\nif you wish to continue, type 'yes' and press enter");

        // string memory success;

        // try vm.prompt(prompt) returns (string memory res) {
        //     if(keccak256(abi.encodePacked(res)) == keccak256(abi.encodePacked("yes"))){

        //         // uint signatures = createSignatures(art);
        //         // uint panels = createPanels(art);
        //         // uint editionId = createRectangularClock(art);
        //         // uint edition = createWhereDoYouDrawTheLine(art);
        //         createTreeSketch(art);
        //         // uint notSuiggles = createNotSquiggles(art);
        //         // createBlackAndWhite(art); //9


        //         success = "success";
                
        //     }
        //     else if(keccak256(abi.encodePacked(res)) == keccak256(abi.encodePacked("no"))){
        //         success = "user aborted tx. exiting...";
                
        //     }
        //     else {
        //         success = "unrecognized input";
        //     }
        // }
        // catch (bytes memory) {
        //     console.log("tx timeout");
            
        // }

        // console.log(success);
        // createTreeSketch(art);
        // uint notSuiggles = createNotSquiggles(art);


        // createBlackAndWhite(art); //9
        
        
        

        // console.log(clock);
        // art.mint();
        // art.setRoyaltyInfo(1, art.owner(), 250);
        // art.setRoyaltyInfo(2, art.owner(), 250);
        // art.setRoyaltyInfo(edition, art.owner(), 777);





        vm.stopBroadcast();

    }
}
