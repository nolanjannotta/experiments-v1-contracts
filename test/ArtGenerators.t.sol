// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {OnchainArtExperiments} from "../src/OnchainArtExperiments.sol";
import {IArtGenerator} from "../src/interfaces.sol";
import {Attributes, Edition} from "../src/structs.sol";

import {LibString} from "../src/Solady/LibString.sol";

import {TestHelpers} from "./TestHelpers.t.sol";



// art generators:
import {Signatures} from "../src/ArtGenerators/Signatures.sol";
import {NotSquiggles} from "../src/ArtGenerators/NotSquiggles.sol";
import {Panels} from "../src/ArtGenerators/Panels.sol";
import {BlackAndWhite} from "../src/ArtGenerators/BlackAndWhite.sol";
// import {Clock} from "../src/ArtGenerators/Clock.sol";
import {RectangularClock} from "../src/ArtGenerators/RectangularClock.sol";
import {TreeSketch} from "../src/ArtGenerators/TreeSketch.sol";
import {Puzzle} from "../src/ArtGenerators/Puzzle.sol";
// import {WhereDoYouDrawTheLine} from "../src/ArtGenerators/WhereDoYouDrawTheLine.sol";
import {WhereDoYouDrawTheLine} from "../src/ArtGenerators/WhereDoYouDrawTheLine.sol";
import {WFC1} from "../src/ArtGenerators/WFC1.sol";
// import {BlankCanvasExample} from "../src/ArtGenerators/blankCanvasExample/BlankCanvasExample.sol";

contract ArtGeneratorsTest is TestHelpers {

    // function testToString() public {
    //     int negIntTest = -123456789;
    //     int posIntTest = 123456789;
    //     uint uintTest = 123456789;
        
    //     // toString(negIntTest); // negInt: 1438, posInt: 1004
    //     // _toString(uintTest); // uint: 938

    //     LibString.toString(uintTest); // negInt: 1037, posInt: 985, uint: 923
    //     // console.log(result);
    // }

    function testAllGenerators() public {
        createSignatures();
        createNotSquiggles();
        createPanels();
        createBlackAndWhite();
        createRectangularClock();
        createTreeSketch();
        // createBanner();

        uint editionCount = art.EDITION_COUNTER();
        for(uint i=1; i<=editionCount; i++ ){
            uint tokenCounter = art.getEdition(i).counter;
            for(uint j=1; j<=tokenCounter; j++) {
                uint tokenId = (i * 1_000_000) + j;
                bool exists = art.exists(tokenId);
                console.log("tokenId: %s, exists: %s", tokenId, exists ? 1 : 0);
                string memory svg = art.getRawSvg(tokenId);
                vm.writeLine(string.concat("SVGs/testAll/",vm.toString(tokenId), ".svg"), svg);
            }


        }

        console.log(art.tokensOfOwner(address(this)).length);

    }


    function testSignatures() public {

        Edition memory signatures = createSignatures();

        for(uint i=0; i<50; i++) {
            art.mint(1);
            // bytes32 seed = keccak256(abi.encode(i + 128376));
            console.log(art.tokenURI(1_000_001 + i));
            // vm.writeLine(string.concat("SVGs/signatures/",vm.toString(i), ".svg"), signatures.artGenerator.getRawSvg(seed));
            (string memory svg) = art.getRawSvg(1_000_001 + i);
            // (, bytes memory plainSignatures) = address(signatures.artGenerator).staticcall(abi.encodeWithSignature("getPlainSignature(bytes32,uint256,uint256)", seed, 900, 900));
            // string memory result = abi.decode(plainSignatures, (string));
            vm.writeLine(string.concat("SVGs/signatures/",vm.toString(i), ".svg"), svg);
            // vm.writeLine(string.concat("SVGs/signatures/plain_signatures/",vm.toString(i), ".svg"), result);
            // console.log(result);
            // console.log("id %s", vm.toString(i));
            // console.log("%s: %s", attributes.keys[0],attributes.values[0]);
            // console.log("%s: %s", attributes.keys[1],attributes.values[1]);
        }


    }


    function testNotSquiggles() public {
        Edition memory notSquiggles = createNotSquiggles();

        // bytes32 seed = keccak256(abi.encode(0));
        // vm.writeLine("SVGs/NotSquiggles/1.svg", notSquiggles.artGenerator.getRawSvg(seed));

        for(uint i=201; i<300; i++) {
            bytes32 seed = keccak256(abi.encode(i+ 123232));
            uint color = uint(seed) % 360000;
            console.log("index: %s, seed: %s, color: %s",i, uint(seed) % 100, color/10);
            vm.writeLine(string.concat("SVGs/NotSquiggles/",vm.toString(i), ".svg"), notSquiggles.artGenerator.getRawSvg(seed));
        }
    }

    function testPanels() public {
        // createSignatures();
        // art.setGlobalSignatureId(1000001);
        // Edition memory panels = createPanels();
        // bytes32 seed = keccak256(abi.encode(123321));
        // // vm.writeLine("SVGs/Panels/1.svg", panels.artGenerator.getRawSvg(seed));


        // for(uint i=0; i<=20; i++) {
        //     console.log("#%s", i);
        //     uint id = art.mint(2);
        //     bytes32 seed = keccak256(abi.encode(i+ 123232));
        //     // art.tokenURI(id);
        //     vm.writeLine(string.concat("SVGs/Panels/",vm.toString(i), ".svg"), art.getDataUri(id));
        // }
        createSignatures();
        for(uint i=0; i<50; i++) {
            art.mint(1);
        }
        createPanels();
        // art.setSignatureId(2, 1_000_001);
        for(uint i=0; i<50; i++) {
            art.mint(2);
        }

        for(uint i=1; i<=50; i++) {
        //   art.setGlobalSignatureId(1_000_000 + i); 
        vm.prank(address(123456789));
        art.setSignatureId(2, 1_000_000 + i);
          vm.writeLine(string.concat("SVGs/Panels/",vm.toString(i), ".svg"), art.getRawSvg(2_000_000 + i)); 

        }

    }

    // function testBlankCanvas() public {
    //     Edition memory blankCanvas = createBlankCanvas();
    //     createSignatures();

    //     BlankCanvasExample blankCanvasExample = new BlankCanvasExample();

    //     bytes32 seed = keccak256(abi.encode(123321));
    //     art.modify(1_000_001, abi.encode(address(blankCanvasExample), 0, 2_000_003, 0));
    //     vm.writeLine("SVGs/BlankCanvas/1.svg", art.getRawSvg(1_000_001));
    // }

    function testRectangularClock() public {
        vm.warp(1711244233);
        createSignatures();

        Edition memory panels = createPanels();
        art.mint(2);

        Edition memory rectangularClock = createRectangularClock();
        art.mint(3);
        // createNotSquiggles();
        
        // current gas = 55885966
        // gas after     50065470
    
        
        // art.mint();

        // uint timeZoneOffset, uint negative, uint background, string memory location
        bytes memory data = abi.encode(23, 2_000_001, "ASasdkjasdhkajdhakjdhass");


        // lets transfer id 1_000_001 to another address, since ownerOf(2_000_001) != ownerOf(1_000_001) it should just skip it
        // art.transferFrom(address(this), address(123), 1_000_001);

        art.modify(3_000_001, data);



        vm.writeLine("SVGs/RectangularClock/1.svg", art.getRawSvg(2_000_001));

        // for(uint i=1; i<100; i++) {
        //     bytes32 seed = keccak256(abi.encode(i+ 123232));
        //     vm.writeLine(string.concat("SVGs/RectangularClock/",vm.toString(i), ".svg"), rectangularClock.artGenerator.getRawSvg(seed));
        // }


    }

    function testColoringBook() public {
        Edition memory coloringBook = createColoringBook();
        bytes32 seed = keccak256(abi.encode(12345));
        vm.writeLine("SVGs/ColoringBook/1.svg", coloringBook.artGenerator.getRawSvg(seed));
    }


    function testBlackAndWhite() public {

        // Edition memory signatures = createSignatures();

        // Edition memory clock = createRectangularClock(); // 1
        // art.mint(1);
        Edition memory signatures = createSignatures(); // 1
        art.mint(1);
        art.mint(1);
        // art.mint(1);
 
        Edition memory panels = createPanels(); // 2
        art.mint(2);

        vm.prank(address(123456789));
        art.setSignatureId(2, 1_000_002);

        Edition memory blackAndWhite = createBlackAndWhite(); // 3
        art.mint(3);

        bytes memory data = abi.encode(2_000_001);

        art.modify(3_000_001, data);

        vm.writeLine("SVGs/BlackAndWhite/1.svg", art.tokenURI(3_000_001));

        // art.modify(3_000_001, abi.encode(1_000_001));

        vm.writeLine("SVGs/BlackAndWhite/2.svg", art.tokenURI(2_000_001));


    }

    function testWindow() public {

        // createwindow();
        
        // bytes memory data = abi.encode(3_000_001);

        // // art.modify(3_000_001, data);

        // vm.writeLine("SVGs/Window/1.svg", art.getRawSvg(1_000_001));


    }



    function testBanner() public {

        createSignatures(); // 1
        art.mint(1);

        createBanner(); // 2
        art.mint(2);

        createPanels(); // 3
        art.mint(3);
        createRectangularClock(); // 4
        art.mint(4);


        // modifying the clock
        bytes memory data = abi.encode(17, 3_000_001, "say whatever.");
        art.modify(4_000_001, data);

        data = abi.encode(
            4_000_001,
            1_000_001,
            3_000_001,
            0,
            0,
            0,
            0,
            0            
            );

        art.modify(2_000_001, data);



        vm.writeLine("SVGs/Banner/1.svg", art.getRawSvg(2_000_001));



    }





    // function testTokenUri() public {
        
    //     createNotSquiggles();
    //     createBlackAndWhite();
    //     createPanels();


    //     vm.prank(address(123));
    //     art.mint();
    //     console.log(art.tokenURI(3_000_001));

    //     for(uint i=1; i<100; i++) {
    //         console.log("#%s", i);
    //         art.mint();

    //         // bytes32 seed = keccak256(abi.encode(i+ 123232));
    //         vm.writeLine(string.concat("SVGs/Panels/",vm.toString(i), ".svg"), art.getRawSvg(3_000_000 + i));

    //         vm.writeLine(string.concat("SVGs/Panels/",vm.toString(i), ".txt"), art.tokenURI(3_000_000 + i));
    //     }


    // }


    function testAttributes() public {
        Edition memory signatures = createSignatures();

        bytes32 seed = keccak256(abi.encode(25));
        (, string memory attributes) = signatures.artGenerator.getRawSvgAndAttributes(seed);
        console.log(attributes);

    }

        // uint startX;
        // uint startY;
        // uint endX;
        // uint endY;
        // uint seed;
        // uint repetitions;



    // before LibString: | getRawSvg                                            | 86690942        | 121686566 | 115438505 | 164361399 | 20      |
    // after             | getRawSvg                                            | 86621740        | 121602706 | 115356812 | 164262109 | 20      |
    // adding unchecked: | getRawSvg                                            | 84006104        | 118433354 | 112271645 | 160493841 | 20      |
    //                   | getRawSvg                                            | 80073904        | 113660094 | 107626613 | 154825384 | 20      |
                    //   | getRawSvg                                            | 80073170        | 113659212 | 107625753 | 154824342 | 20      |
    function testTreeSketch() public {

        TreeSketch treeSketch = new TreeSketch();


        for(uint i=0; i<20; i++) {
            bytes32 seed = keccak256(abi.encode(i+ 123232));
            (string memory svg) = treeSketch.getRawSvg(seed);
            vm.writeLine(string.concat("SVGs/TreeSketch/",vm.toString(i), ".svg"), svg);
            console.log("id %s", vm.toString(i));
        }

        // (string memory sketch, Attributes memory attributes) = treeSketch.sketch(bytes32(uint(98756)));
        // vm.writeLine("SVGs/Sketch/1.svg", sketch);
        // console.log(sketch);



    }


    function testLineLength() public {

        TreeSketch treeSketch = new TreeSketch();

        TreeSketch.LineParams memory params = TreeSketch.LineParams({
            x1: 100,
            y1: 100,
            x2: 234,
            y2: 856,
            seed: 123
            //   reducer: 0,
            //     newY2: 0,
            //     newX2: 0,
            //     segments: 0,
            //     jump: 0
            // deltaX: 0,
            // deltaY: 0
            });
            // params.deltaX = params.x1 < params.x2 ? uint(params.x2 - params.x1) : uint(params.x1 - params.x2);
            // params.deltaY = params.y1 < params.y2 ? uint(params.y2 - params.y1) : uint(params.y1 - params.y2);
            (string memory line) = treeSketch.line(params);
            console.log(line);
    }

    function testLine2() public {
        TreeSketch treeSketch = new TreeSketch();

            TreeSketch.LineParams memory params = TreeSketch.LineParams({
                x1: 234,
                y1: 856,
                x2: 100,
                y2: 100,
                seed: 123
                // reducer: 0,
                // newY2: 0,
                // newX2: 0,
                // segments: 0,
                // jump: 0
                // deltaX: 0,
                // deltaY: 0
                });
                // params.deltaX = params.x1 < params.x2 ? uint(params.x2 - params.x1) : uint(params.x1 - params.x2);
                // params.deltaY = params.y1 < params.y2 ? uint(params.y2 - params.y1) : uint(params.y1 - params.y2);

                (string memory line) = treeSketch.line(params);
                console.log(line); 

    }


    function testPuzzle() public {
        Puzzle puzzle = new Puzzle();

        (string memory svg,) = puzzle.puzzle(bytes32(uint(98765
        )));
        vm.writeLine("SVGs/Puzzle/1.svg", svg);
        console.log(svg);


    }

    function testWhereDoYouDrawTheLine() public {
        createSignatures();
        for(uint i=0; i<50; i++) {
            art.mint(1);
        }
        createWhereDoYouDrawTheLine();
        for(uint i=0; i<50; i++) {
            art.mint(2);
        }

        for(uint i=1; i<=50; i++) {
        //   art.setGlobalSignatureId(1_000_000 + i); 
            vm.prank(address(123456789));
            art.setSignatureId(2, 1_000_000 + i);

          vm.writeLine(string.concat("SVGs/WhereDoYouDrawTheLine/",vm.toString(i), ".svg"), art.getRawSvg(2_000_000 + i)); 

        }
        
    }  

    function testWFC1() public {
        WFC1 wfc1 = new WFC1();
        // Edition memory wfc1 = createWFC1();
        bytes32 seed = keccak256(abi.encode(12345));
        console.log(wfc1.getRawSvg(seed));
        // wfc.test();
    }

}