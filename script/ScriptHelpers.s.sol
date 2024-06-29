//  // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import "forge-std/Script.sol";
// import {OnchainArtExperiments} from "../src/OnchainArtExperiments.sol";
// import {NotSquiggles} from "../src/ArtGenerators/NotSquiggles.sol";
// import {Panels} from "../src/ArtGenerators/Panels.sol";
// import {BlackAndWhite} from "../src/ArtGenerators/BlackAndWhite.sol";
// import {Signatures} from "../src/ArtGenerators/Signatures.sol";
// import {RectangularClock} from "../src/ArtGenerators/RectangularClock.sol";
// import {TreeSketch} from "../src/ArtGenerators/TreeSketch.sol";
// import {WhereDoYouDrawTheLine} from "../src/ArtGenerators/WhereDoYouDrawTheLine.sol";

// import {IArtGenerator} from "../src/interfaces.sol";

// contract ScriptHelpers is Script {

//     function createNotSquiggles(OnchainArtExperiments art) internal returns (uint edition) {
//         NotSquiggles notSquiggles = new NotSquiggles();
//         string memory name = "not squiggles"; 
//         string memory description = "definitely not squiggles.";
//         uint supply = 150; 
//         // IArtGenerator artGenerator = IArtGenerator(notSquiggles);
//         edition = art.createNewEdition(name, description, supply, address(notSquiggles));

//     }

//     function createPanels(OnchainArtExperiments art) internal returns (uint edition) {
//         Panels panels = new Panels();
//         string memory name = "panels"; 
//         string memory description = "the sophomore edition. Recursive panels based on a simple set of rules.";
//         uint supply = 100; 
//         // IArtGenerator artGenerator = IArtGenerator(panels);
//         edition = art.createNewEdition(name, description, supply, address(panels));

//     }

//     function createTreeSketch(OnchainArtExperiments art) internal returns (uint edition) {
//         TreeSketch treeSketch = new TreeSketch();
//         string memory name = "tree sketch"; 
//         string memory description = "an attempt to create a 'hand drawn' or 'sketched' look. In this case, of a tree.";
//         uint supply = 200; 
//         // IArtGenerator artGenerator = IArtGenerator(treeSketch);
//         edition = art.createNewEdition(name, description, supply, address(treeSketch));

//     }


//     function createSignatures(OnchainArtExperiments art) internal returns (uint edition) {
//         Signatures signatures = new Signatures();
//         string memory name = "signatures"; 
//         string memory description = "Simple, minimal, cool. The inaugural edition of this whole experiment thing.";
//         uint supply = 200; 
//         // IArtGenerator artGenerator = IArtGenerator(signatures);
//         edition = art.createNewEdition(name, description, supply, address(signatures));

//     }
//     function createRectangularClock(OnchainArtExperiments art) internal returns (uint edition) {
//         RectangularClock clock = new RectangularClock();
//         string memory name = "rectangular clock"; 
//         string memory description = "A 'utility token.' Uses block.timestamp and SVG animation to keep and display accurate time.";
//         uint supply = 100; 
//         // IArtGenerator artGenerator = IArtGenerator(clock);
//         edition = art.createNewEdition(name, description, supply, address(clock));

//     }

//      function createWhereDoYouDrawTheLine(OnchainArtExperiments art) internal returns (uint edition) {
//         WhereDoYouDrawTheLine wdydtl = new WhereDoYouDrawTheLine();
//         string memory name = "Where do you draw the line?"; 
//         string memory description = "where do you draw the line?";
//         uint supply = 150; 
//         // IArtGenerator artGenerator = IArtGenerator(wdydtl);
//         edition = art.createNewEdition(name, description, supply, address(wdydtl));

//     }


//     function createBlackAndWhite(OnchainArtExperiments art) internal returns (uint edition) {
//         BlackAndWhite blackAndWhite = new BlackAndWhite();
//         string memory name = "Black and white"; 
//         string memory description = "just black and white";
//         uint supply = 100; 
//         // IArtGenerator artGenerator = IArtGenerator(blackAndWhite);
//         edition = art.createNewEdition(name, description, supply, address(blackAndWhite));

//     }


// }