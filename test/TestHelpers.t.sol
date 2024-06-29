// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {OnchainArtExperiments} from "../src/OnchainArtExperiments.sol";
import {IArtGenerator} from "../src/interfaces.sol";
import {Attributes, Edition} from "../src/structs.sol";
import {Signatures} from "../src/ArtGenerators/Signatures.sol";
import {NotSquiggles} from "../src/ArtGenerators/NotSquiggles.sol";
import {Panels} from "../src/ArtGenerators/Panels.sol";
import {BlackAndWhite} from "../src/ArtGenerators/BlackAndWhite.sol";
// import {Clock} from "../src/ArtGenerators/Clock.sol";
import {RectangularClock} from "../src/ArtGenerators/RectangularClock.sol";
import {Banner} from "../src/ArtGenerators/Banner.sol";
import {Window} from "../src/ArtGenerators/Window.sol";
import {TreeSketch} from "../src/ArtGenerators/TreeSketch.sol";
import {WhereDoYouDrawTheLine} from "../src/ArtGenerators/WhereDoYouDrawTheLine.sol";
// import {BlankCanvas} from "../src/ArtGenerators/BlankCanvas.sol";
import {WFC1} from "../src/ArtGenerators/WFC1.sol";
import {ColoringBook} from "../src/ArtGenerators/ColoringBook.sol";

contract TestHelpers is Test {

    OnchainArtExperiments art;
    Signatures signatureGenerator;
    NotSquiggles notSquigglesGenerator;
    Panels panelsGenerator;
    BlackAndWhite blackAndWhiteGenerator;
    // Clock clockGenerator;
    RectangularClock rectangularClockGenerator;
    Banner bannerGenerator;
    Window windowGenerator;
    TreeSketch treeSketchGenerator;
    WhereDoYouDrawTheLine whereDoYouDrawTheLineGenerator;
    WFC1 wfc1Generator;
    // BlankCanvas blankCanvasGenerator;
    ColoringBook colorBookGenerator;


    address public ARTIST = address(123456789);

    function setUp() public {
        art = new OnchainArtExperiments();

    

    }
    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function createColoringBook() public returns (Edition memory edition) {
        ColoringBook colorBookGenerator = new ColoringBook();
        uint editionId = art.createNewEdition("Coloring Book", "Coloring Book", 200, address(colorBookGenerator), ARTIST, "Nolan");
        edition = art.getEdition(editionId);
        assertEq(edition.name, "Coloring Book");
        assertEq(edition.description, "Coloring Book");
        assertEq(edition.supply, 200);
        // createNewEdition also mints 10% of supply to owner

        // assertEq(edition.counter, edition.supply/20);
        assertEq(address(edition.artGenerator), address(colorBookGenerator));
    }

    function createSignatures() public returns(Edition memory edition) {
        signatureGenerator = new Signatures();
        uint editionId = art.createNewEdition("signatures", "description", 1000, address(signatureGenerator), ARTIST, "Nolan");
        vm.prank(ARTIST);
        art.setMintStatus(editionId, true);

        edition = art.getEdition(editionId);
        assertEq(edition.name, "signatures");
        assertEq(edition.description, "description");
        assertEq(edition.supply, 1000);
        assertEq(address(edition.artGenerator), address(signatureGenerator));
    }
        function createWhereDoYouDrawTheLine() public returns(Edition memory edition) {
        whereDoYouDrawTheLineGenerator = new WhereDoYouDrawTheLine();
        uint editionId = art.createNewEdition("Where do you draw the line?", "where do you drw the line?", 150, address(whereDoYouDrawTheLineGenerator), ARTIST, "Nolan");
        vm.prank(ARTIST);

        art.setMintStatus(editionId, true);
        edition = art.getEdition(editionId);
        assertEq(edition.name, "Where do you draw the line?");
        assertEq(edition.description, "where do you drw the line?");
        assertEq(edition.supply, 150);
        // createNewEdition also mints 10% of supply to owner
        // assertEq(edition.counter, edition.supply/20);
        assertEq(address(edition.artGenerator), address(whereDoYouDrawTheLineGenerator));

        // for(uint i=1; i<=edition.supply/20; i++) {
        //   assertEq(art.ownerOf(editionId * 1_000_000 + i), address(this));
  
        // }


    }






    function createNotSquiggles() public returns(Edition memory edition) {
        string memory description = "This is not a Squiggle. This is not affiliated with or curated by Art Blocks. This is merely an onchain experiment and an homage to one of my favorite collections.";
        notSquigglesGenerator = new NotSquiggles();
        uint editionId = art.createNewEdition("not-a-squiggle", description, 1000, address(notSquigglesGenerator), ARTIST, "Nolan");
        vm.prank(ARTIST);
        edition = art.getEdition(editionId);
        assertEq(edition.name, "not-a-squiggle");
        assertEq(edition.description, description);
        assertEq(edition.supply, 1000);
        // createNewEdition also mints 5% of supply to owner
        // assertEq(edition.counter, edition.supply/20);
        assertEq(address(edition.artGenerator), address(notSquigglesGenerator));

        // for(uint i=1; i<=edition.supply/20; i++) {
        //   assertEq(art.ownerOf(editionId * 1_000_000 + i), address(this));
  
        // }

        
    }

    function createPanels() public returns(Edition memory edition) {
        panelsGenerator = new Panels();
        uint editionId = art.createNewEdition("panels", "description", 1000, address(panelsGenerator), ARTIST, "Nolan");
        vm.prank(ARTIST);
        art.setMintStatus(editionId, true);

        edition = art.getEdition(editionId);
        assertEq(edition.name, "panels");
        assertEq(edition.description, "description");
        assertEq(edition.supply, 1000);
        // createNewEdition also mints 10% of supply to owner
        // assertEq(edition.counter, edition.supply/20);
        assertEq(address(edition.artGenerator), address(panelsGenerator));

        // for(uint i=1; i<=edition.supply/20; i++) {
        //   assertEq(art.ownerOf(editionId * 1_000_000 + i), address(this));
  
        // }


        
    }
    // function createBlankCanvas() public returns(Edition memory edition) {
    //     blankCanvasGenerator = new BlankCanvas();
        
    //     uint editionId = art.createNewEdition("Blank Canvas", "a blank canvas for artists.", 1000, address(blankCanvasGenerator), msg.sender);
    //     edition = art.getEdition(editionId);
    //     assertEq(edition.name, "Blank Canvas");
    //     assertEq(edition.description, "a blank canvas for artists.");
    //     assertEq(edition.supply, 1000);
    //     // createNewEdition also mints 10% of supply to owner
    //     // assertEq(edition.counter, edition.supply/20);
    //     assertEq(address(edition.artGenerator), address(blankCanvasGenerator));

    //     // for(uint i=1; i<=edition.supply/20; i++) {
    //     //   assertEq(art.ownerOf(editionId * 1_000_000 + i), address(this));
  
    //     // }


    // } 

    function createBlackAndWhite() public returns(Edition memory edition) {
        blackAndWhiteGenerator = new BlackAndWhite();
        uint editionId = art.createNewEdition("black and white", "black and white description", 1000, address(blackAndWhiteGenerator), ARTIST, "Nolan");
        vm.prank(ARTIST);
        art.setMintStatus(editionId, true); 
        edition = art.getEdition(editionId);
        assertEq(edition.name, "black and white");
        assertEq(edition.description, "black and white description");
        assertEq(edition.supply, 1000);
        // createNewEdition also mints 10% of supply to owner
        // assertEq(edition.counter, edition.supply/20);
        assertEq(address(edition.artGenerator), address(blackAndWhiteGenerator));

        // for(uint i=1; i<=edition.supply/20; i++) {
        //   assertEq(art.ownerOf(editionId * 1_000_000 + i), address(this));
  
        // }

        
    }

    // function createClock() public returns(Edition memory edition) {
    //     clockGenerator = new Clock();
    //     uint editionId = art.createNewEdition("clock", "clock description", 1000, IArtGenerator(clockGenerator));
    //     edition = art.getEdition(editionId);
    //     assertEq(edition.name, "clock");
    //     assertEq(edition.description, "clock description");
    //     assertEq(edition.supply, 1000);
    //     // createNewEdition also mints 10% of supply to owner
        // assertEq(edition.counter, edition.supply/20);
    //     assertEq(address(edition.artGenerator), address(clockGenerator));

    //     for(uint i=1; i<=edition.supply/20; i++) {
    //       assertEq(art.ownerOf(editionId * 1_000_000 + i), address(this));
  
    //     }
        
        
    // }

    function createRectangularClock() public returns(Edition memory edition) {
        vm.warp(1711244233);
        
        rectangularClockGenerator = new RectangularClock();
        uint editionId = art.createNewEdition("Rectangular Clock", "Rectangular Clock description", 1000, address(rectangularClockGenerator), ARTIST, "Nolan");
        vm.prank(ARTIST);
        art.setMintStatus(editionId, true); 
        edition = art.getEdition(editionId);
        assertEq(edition.name, "Rectangular Clock");
        assertEq(edition.description, "Rectangular Clock description");
        assertEq(edition.supply, 1000);
        // createNewEdition also mints 10% of supply to owner
        // assertEq(edition.counter, edition.supply/20);
        assertEq(address(edition.artGenerator), address(rectangularClockGenerator));


        // for(uint i=1; i<=edition.supply/20; i++) {
        //   assertEq(art.ownerOf(editionId * 1_000_000 + i), address(this));
  
        // }
        
    }

    function createBanner() public returns(Edition memory edition) {
        vm.warp(1707501167);
        
        bannerGenerator = new Banner();
        uint editionId = art.createNewEdition("Banner", "banner description", 1000, address(bannerGenerator), ARTIST, "Nolan");
        vm.prank(ARTIST);
        art.setMintStatus(editionId, true); 
        edition = art.getEdition(editionId);
        assertEq(edition.name, "Banner");
        assertEq(edition.description, "banner description");
        assertEq(edition.supply, 1000);
        // createNewEdition also mints 10% of supply to owner
        // assertEq(edition.counter, edition.supply/20);
        assertEq(address(edition.artGenerator), address(bannerGenerator));


        // for(uint i=1; i<=edition.supply/20; i++) {
        //   assertEq(art.ownerOf(editionId * 1_000_000 + i), address(this));
  
        // }
        

    }

    function createwindow() public returns(Edition memory edition) {
        

        windowGenerator = new Window();
        uint editionId = art.createNewEdition("window", "window description", 1000, address(windowGenerator), ARTIST, "Nolan");
        edition = art.getEdition(editionId);
        assertEq(edition.name, "window");
        assertEq(edition.description, "window description");
        assertEq(edition.supply, 1000);
        // createNewEdition also mints 10% of supply to owner
        // assertEq(edition.counter, edition.supply/20);
        assertEq(address(edition.artGenerator), address(windowGenerator));


        // for(uint i=1; i<=edition.supply/20; i++) {
        //   assertEq(art.ownerOf(editionId * 1_000_000 + i), address(this));
  
        // }
    }


    function createTreeSketch() public returns(Edition memory edition) {
        
        treeSketchGenerator = new TreeSketch();
        uint editionId = art.createNewEdition("Tree Generator", "tree sketch", 200, address(treeSketchGenerator), ARTIST, "Nolan");
        edition = art.getEdition(editionId);
        assertEq(edition.name, "Tree Generator");
        assertEq(edition.description, "tree sketch");
        assertEq(edition.supply, 200);
        // createNewEdition also mints 10% of supply to owner

        // assertEq(edition.counter, edition.supply/20);
        assertEq(address(edition.artGenerator), address(treeSketchGenerator));


        // for(uint i=1; i<=edition.supply/20; i++) {
        //   assertEq(art.ownerOf(editionId * 1_000_000 + i), address(this));
  
        // }
    }

    function createWFC1() public returns(Edition memory edition) {
        
        wfc1Generator = new WFC1();
        uint editionId = art.createNewEdition("WFC1", "WFC1", 200, address(wfc1Generator), ARTIST, "Nolan");
        edition = art.getEdition(editionId);
        assertEq(edition.name, "WFC1");
        assertEq(edition.description, "WFC1");
        assertEq(edition.supply, 200);
        // createNewEdition also mints 10% of supply to owner

        // assertEq(edition.counter, edition.supply/20);
        assertEq(address(edition.artGenerator), address(wfc1Generator));


        // for(uint i=1; i<=edition.supply/20; i++) {
        //   assertEq(art.ownerOf(editionId * 1_000_000 + i), address(this));
  
        // }
    }




    

}
