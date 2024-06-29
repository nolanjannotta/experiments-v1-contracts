 // SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {OnchainArtExperiments} from "../src/OnchainArtExperiments.sol";
import {NotSquiggles} from "../src/ArtGenerators/NotSquiggles.sol";
import {Panels} from "../src/ArtGenerators/Panels.sol";
import {BlackAndWhite} from "../src/ArtGenerators/BlackAndWhite.sol";
import {Signatures} from "../src/ArtGenerators/Signatures.sol";
import {RectangularClock} from "../src/ArtGenerators/RectangularClock.sol";
import {TreeSketch} from "../src/ArtGenerators/TreeSketch.sol";
import {WhereDoYouDrawTheLine} from "../src/ArtGenerators/WhereDoYouDrawTheLine.sol";

import {IArtGenerator} from "../src/interfaces.sol";


// struct Generator {
//         string name;
//         string description;
//         address generator;
//         uint supply;
//     }

// function deployAndConnect(Generator memory self, OnchainArtExperiments art) returns(uint id) {

//     IArtGenerator generator = IArtGenerator(self.generator);
//     id = art.createNewEdition(self.name, self.description, self.supply, address(generator));
//     return id;

// }


abstract contract GeneratorFactory {




    function createNotSquiggles(OnchainArtExperiments art, address artist) internal returns (uint edition) {
        NotSquiggles notSquiggles = new NotSquiggles();
        string memory name = "not squiggles"; 
        string memory description = "definitely not squiggles.";
        uint supply = 150; 
        edition = art.createNewEdition(name, description, supply, address(notSquiggles),artist, "");

    }

    function createPanels(OnchainArtExperiments art, address artist) internal returns (uint edition) {
        // Panels panels = new Panels();
        string memory name = "panels"; 
        string memory description = "Recursive panels based on a simple set of rules.";
        uint supply = 3000; 
        edition = art.createNewEdition(name, description, supply, 0x9Bf8218fA93Bc99944537674AffE3101243F85c4, artist, "Nolan");

    }

    function createTreeSketch(OnchainArtExperiments art, address artist) internal returns (uint edition) {
        TreeSketch treeSketch = new TreeSketch();
        string memory name = "tree sketch"; 
        string memory description = "an attempt to create a 'hand drawn' or 'sketched' look. In this case, of a tree.";
        uint supply = 3000; 
        edition = art.createNewEdition(name, description, supply, address(treeSketch), artist, "Nolan");

    }


    function createSignatures(OnchainArtExperiments art, address artist) internal returns (uint edition) {
        // Signatures signatures = new Signatures();
        string memory name = "signatures"; 
        string memory description = "Simple, minimal, cool. The inaugural edition of this whole experiment thing.";
        uint supply = 1000; 
        edition = art.createNewEdition(name, description, supply, 0x5bAA837d862218E2F82F9600e54DB6007E960d0A, artist, "Nolan");

    }
    function createRectangularClock(OnchainArtExperiments art, address artist) internal returns (uint edition) {
        RectangularClock clock = new RectangularClock();
        string memory name = "Clock"; 
        string memory description = "It's a 'utility token.'";
        uint supply = 2000; 
        edition = art.createNewEdition(name, description, supply, address(clock),artist, "Nolan");

    }

    function createWhereDoYouDrawTheLine(OnchainArtExperiments art, address artist) internal returns (uint edition) {
        WhereDoYouDrawTheLine wdydtl = new WhereDoYouDrawTheLine();
        string memory name = "Where do you draw the line?"; 
        string memory description = "Where do you draw the line?";
        uint supply = 2000; 
        edition = art.createNewEdition(name, description, supply, address(wdydtl),artist, "Nolan");

    }


    function createBlackAndWhite(OnchainArtExperiments art, address artist) internal returns (uint edition) {
        BlackAndWhite blackAndWhite = new BlackAndWhite();
        string memory name = "Black and White"; 
        string memory description = "just black and white";
        uint supply = 2000; 
        // IArtGenerator artGenerator = IArtGenerator(blackAndWhite);
        edition = art.createNewEdition(name, description, supply, address(blackAndWhite),artist, "Nolan");

    }


}