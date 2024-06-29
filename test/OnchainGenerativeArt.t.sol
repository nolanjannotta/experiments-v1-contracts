// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {OnchainArtExperiments} from "../src/OnchainArtExperiments.sol";

import {IArtGenerator} from "../src/interfaces.sol";
import { Attributes, Edition} from "../src/structs.sol";


import {Signatures} from "../src/ArtGenerators/Signatures.sol";
import {NotSquiggles} from "../src/ArtGenerators/NotSquiggles.sol";
import {Panels} from "../src/ArtGenerators/Panels.sol";
import {BlackAndWhite} from "../src/ArtGenerators/BlackAndWhite.sol";
import {TestHelpers} from "./TestHelpers.t.sol";


interface IERC2981 {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount);

    // function whatIfThereIsAnotherOne(uint256 a, string memory b) external view returns (string memory);
}

contract OnchainArtExperimentsTest is TestHelpers {

 
    // make sure it implements all interfaces:
    // IERC2981: 0x2a55205a
    // ERC165: 0x01ffc9a7
    // ERC721: 0x80ac58cd 
    // ERC721Metadata: 0x5b5e139f
    function testSupportsInterface() public {
        // bytes4 signature = type(IERC2981).interfaceId;

        bytes4 IERC2981 = 0x2a55205a;
        bytes4 ERC165 = 0x01ffc9a7;
        bytes4 ERC721 = 0x80ac58cd;
        bytes4 ERC721Metadata = 0x5b5e139f;

        bool supportsInterface = art.supportsInterface(IERC2981);
        assertTrue(supportsInterface);

        supportsInterface = art.supportsInterface(ERC165);
        assertTrue(supportsInterface);

        supportsInterface = art.supportsInterface(ERC721);
        assertTrue(supportsInterface);

        supportsInterface = art.supportsInterface(ERC721Metadata);
        assertTrue(supportsInterface);

    }


    function testAllGenerators() public {
        createSignatures();
        createNotSquiggles();
        createPanels();
        createBlackAndWhite();
        // createClock();
        createRectangularClock();
    }

    function testTokenExistsCheck() public {
        createSignatures();

        vm.expectRevert(abi.encodeWithSignature("TokenDoesNotExist()"));
        art.tokenURI(1_000_100);

        vm.expectRevert(abi.encodeWithSignature("TokenDoesNotExist()"));
        art.getRawSvg(1_000_100);

        vm.expectRevert(abi.encodeWithSignature("TokenDoesNotExist()"));
        art.getDataUri(1_000_100);

    }

    function testOwnerControls() public {
        createSignatures();
        art.mint(1);
        
        // changeOwner
        vm.expectRevert(abi.encodeWithSignature("NotOwner()"));
        vm.prank(address(123));
        art.changeOwner(address(123));

        address newOwner = address(456);
        art.changeOwner(newOwner);
        assertEq(art.OWNER(), newOwner);

        // setPlatformFee
        vm.expectRevert(abi.encodeWithSignature("NotOwner()"));
        vm.prank(address(123));
        art.setPlatformFee(10);

        vm.prank(newOwner);
        art.setPlatformFee(10);
        assertEq(art.PLATFORM_FEE(), 10);

        // setPlatformRoyalty
        vm.expectRevert(abi.encodeWithSignature("NotOwner()"));
        vm.prank(address(123));
        art.setPlatformRoyalty(10);

        vm.prank(newOwner);
        art.setPlatformRoyalty(20);
        assertEq(art.PLATFORM_ROYALTY(), 20);

        // releasePlatformRoyalty

        art.getEdition(1).royaltyReceiver.call{value: 1 ether}("");
        uint platformBalanceBefore = address(art).balance;
        
         vm.expectRevert(abi.encodeWithSignature("NotOwner()"));
        vm.prank(address(123));
        art.releasePlatformRoyalty(1);

        vm.prank(newOwner);
        art.releasePlatformRoyalty(1);
        // when edition 1 was deployed, platform royalty share was 10%
        assertEq(address(art).balance, platformBalanceBefore + .1 ether);


        // createNewEdition
        vm.expectRevert(abi.encodeWithSignature("NotOwner()"));
        vm.prank(address(123));
        art.createNewEdition("test", "test", 10, address(123), address(234), "test");

        vm.prank(newOwner);
        art.createNewEdition("test", "test", 10, address(123), address(234), "test");
        assertEq(art.EDITION_COUNTER(), 2);
        assertEq(art.getEdition(2).name, "test");
        assertEq(art.getEdition(2).description, "test");
        assertEq(art.getEdition(2).supply, 10);
        assertEq(address(art.getEdition(2).artGenerator), address(123));
        assertEq(art.getEdition(2).artistAddress, address(234));
        assertEq(art.getEdition(2).artistName, "test");

        // withdraw
        address(art).call{value: 1 ether}("");

        uint artBalanceBefore = address(art).balance;

        vm.expectRevert(abi.encodeWithSignature("NotOwner()"));
        vm.prank(address(123));
        art.withdraw();
        uint ownerBalanceBefore = newOwner.balance;
        vm.prank(newOwner);
        art.withdraw();
        assertEq(address(art).balance, 0);
        assertEq(newOwner.balance, ownerBalanceBefore + artBalanceBefore);

    }


    function testRoyaltyInfo() public {
        createSignatures();
        art.mint(1);
        vm.prank(address(123456789));
        art.setRoyalty(1, 1_000); // 10% in basis points

        assertEq(art.supportsInterface(bytes4(keccak256("royaltyInfo(uint256,uint256)"))), true);

        (address receiver, uint royaltyAmount) = art.royaltyInfo(1_000_001, 1 ether);
        assertEq(royaltyAmount, .1 ether);
        assertEq(receiver, art.getEdition(1).royaltyReceiver);

    }

    function testArtistControls() public {
        Edition memory signatures = createSignatures(); // edition id 1
        assertEq(signatures.artistAddress, address(123456789));

        // setMintStatus
        assertEq(signatures.mintStatus, true);
        vm.prank(address(123456789));
        art.setMintStatus(1, false);
        assertEq(art.getEdition(1).mintStatus, false);

        vm.prank(address(123));
        vm.expectRevert(abi.encodeWithSignature("NotArtist()"));
        art.setMintStatus(1, true);
        assertEq(art.getEdition(1).mintStatus, false);

        // deleteEdition
        vm.expectRevert(abi.encodeWithSignature("NotArtist()"));
        vm.prank(address(123));
        art.deleteEdition(1);

        

        // from artist
        vm.prank(address(123456789));
        art.deleteEdition(1);

        assertEq(art.getEdition(1).artistAddress, address(0));
        assertEq(art.getEdition(1).name, "");
        assertEq(art.getEdition(1).description, "");
        assertEq(address(art.getEdition(1).artGenerator), address(0));
        assertEq(art.getEdition(1).supply, 0);

        createSignatures(); // 2
        art.mint(2);
        assertEq(art.getEdition(2).counter, 1);
        
        vm.expectRevert(abi.encodeWithSignature("EditionHasMintedTokens()"));
        vm.prank(address(123456789));
        art.deleteEdition(2);

        // setRoyaltyInfo
        assertEq(art.getEdition(2).royalty, 0);
        vm.prank(address(123456789));
        art.setRoyalty(2, 500);
        assertEq(art.getEdition(2).royalty, 500);

        vm.expectRevert(abi.encodeWithSignature("NotArtist()"));
        vm.prank(address(123));
        art.setRoyalty(2, 1000);

        // setPrice
        assertEq(art.getEdition(2).price, 0);
        vm.prank(address(123456789));
        art.setPrice(2, 1 ether);
        assertEq(art.getEdition(2).price, 1 ether);

        vm.expectRevert(abi.encodeWithSignature("NotArtist()"));
        vm.prank(address(123));
        art.setPrice(2, 2 ether);

        // artistMint
        assertEq(art.getEdition(2).price, 1 ether);
        vm.prank(address(123456789));
        art.setMintStatus(2, false);
        vm.prank(address(123456789));
        art.artistMint(2);
        assertEq(art.getEdition(2).counter, 2);

        vm.expectRevert(abi.encodeWithSignature("NotArtist()"));
        vm.prank(address(123));
        art.artistMint(2);

        

        // setSignatureId
        assertEq(art.getEdition(2).signatureId, 0);
        vm.prank(address(123456789));
        art.setSignatureId(2,2_000_001);
        assertEq(art.getEdition(2).signatureId, 2_000_001);

        vm.expectRevert(abi.encodeWithSignature("NotArtist()"));
        vm.prank(address(123));
        art.setSignatureId(2,2_000_002);



    }

    function testModify() public {
        vm.warp(1705817413);
        createSignatures(); // 1


    
        createBlackAndWhite(); // 2 
        createRectangularClock(); // 3

        art.mint(1);
        art.mint(2);
        art.mint(3);

        // test modify function of black and white
        (uint32 selfId, uint32 targetId) = abi.decode(art.unPackSeed(2_000_001), (uint32, uint32));
        // default seed
        assertEq(selfId, 2_000_001);
        assertEq(targetId, 0);

        // modify seed
        art.modify(2_000_001, abi.encode(3_000_001));

        (selfId, targetId) = abi.decode(art.unPackSeed(2_000_001), (uint32, uint32));

        assertEq(selfId, 2_000_001);
        assertEq(targetId, 3_000_001);


        // rectangular clock
        (selfId, targetId) = abi.decode(art.unPackSeed(3_000_001), (uint32, uint32));



        
    }

    function testMintWithFee() public {
        createSignatures();
        // vm.prank(address(678));
        vm.prank(address(123456789));
        art.setPrice(1, 1 ether);
        uint platformFee = art.PLATFORM_FEE();

        uint platformBalanceBefore = address(art).balance;
        uint artistBalanceBefore = art.getEdition(1).artistAddress.balance;

        address minter = address(123);
        vm.deal(minter, 1 ether);
        vm.prank(minter);
        art.mint{value: 1 ether}(1);

        // (msg.value * PLATFORM_FEE) / 100;

        uint fee = (1 ether * platformFee) / 100;

        uint artistSplit = 1 ether - fee;
        uint platFormSplit = 1 ether - artistSplit;

        // assertEq(address(art).balance, platformBalanceBefore + platFormSplit);
        assertEq(art.getEdition(1).artistAddress.balance, artistBalanceBefore + artistSplit);
        

        

    }

    // possible split these into multiple functions, idk

    function testAllMintFunctions() public {
        address user1 = address(1234);
        address user2 = address(5678);
        address minter = address(9876);

        assertEq(art.OWNER(), address(this));

        createSignatures(); // 1
        

        vm.startPrank(user1);

        ////////////normal mint function//////////// 
        uint id = art.mint(1);
        assertEq(art.ownerOf(id), user1);
        assertEq(art.balanceOf(user1), 1);
        assertEq(art.getEdition(1).counter, 1);
        ////////////////////////////////////////////


        ////////////mintTo function////////////
        id = art.mintTo(1, user2);
        assertEq(art.ownerOf(id), user2);
        assertEq(art.balanceOf(user2), 1);
        assertEq(art.getEdition(1).counter, 2);
        /////////////////////////////////////////
        vm.stopPrank();

        // ARTIST MINT FUNCTION/////////
        address ARTIST = art.getEdition(1).artistAddress;
        vm.startPrank(ARTIST);
        id = art.artistMint(1);
        assertEq(art.ownerOf(id), ARTIST);
        assertEq(art.balanceOf(ARTIST), 1);
        assertEq(art.getEdition(1).counter, 3);

        art.setMintStatus(1, false);
        id = art.artistMint(1);
        assertEq(art.ownerOf(id), ARTIST);
        assertEq(art.balanceOf(ARTIST), 2);
        assertEq(art.getEdition(1).counter, 4);
        vm.stopPrank();

        // edition #1 should be paused to the public and not mintable to non artist, lets test
        vm.expectRevert(abi.encodeWithSignature("NotMintable()"));
        id = art.mint(1);

    }


    function testTokenUri() public {
        createSignatures();
        createBlackAndWhite();
        createPanels();
        createRectangularClock();
        // createBanner();
        createNotSquiggles();
        createTreeSketch();
        createWhereDoYouDrawTheLine();
        for (uint i = 1; i <= art.EDITION_COUNTER(); i++) {
            for (uint j = 1; j <= art.getEdition(i).counter; j++) {
                vm.writeLine(
                    string.concat(
                        "SVGs/tokenURIs/",
                        vm.toString((i * 1_000_000) + j),
                        ".txt"
                    ),
                    art.tokenURI((i * 1_000_000) + j)
                );
            }
        }

        // for (uint j = 1; j <= 5; j++) {
        //     vm.writeLine(
        //         string.concat(
        //             "SVGs/tokenURIs/",
        //             vm.toString((8_000_000) + j),
        //             ".txt"
        //         ),
        //         art.tokenURI((8_000_000) + j)
        //     );
        // }

    }

    // function testDimensions() public {
    //     createSignatures(); // 1
    //     createBlackAndWhite(); // 2
    //     createPanels(); // 3
    //     createRectangularClock(); // 4
    //     createBanner(); // 5
    //     createNotSquiggles(); // 6


    // }

    function testWithdraw() public {
        address(art).call{value: 2 ether}("");
        assertEq(address(art).balance, 2 ether);
        uint ownerBalanceBefore = address(this).balance;

        art.withdraw();
        assertEq(msg.sender.balance, ownerBalanceBefore + 2 ether);
        console.log(msg.sender.balance);
    }


    function testUnPackSeed() public {
        createSignatures(); // 1
        createBlackAndWhite(); // 2
        createPanels(); // 3
        createRectangularClock(); // 4


    }

    function testTokensOfOwner() public {
        createSignatures();
        // createPanels();

        art.mint(1);
        art.mint(1);
        art.mint(1);
        art.mint(1);
        art.mint(1);
        art.mint(1);
        art.burn(1_000_002);
        art.burn(1_000_003);
        art.burn(1_000_004);
        art.burn(1_000_005);
        art.burn(1_000_006);

        uint[] memory tokens = art.tokensOfOwner(address(this)); // = new uint[](art.balanceOf(address(this))-10);
        // tokens = art.tokensOfOwner(address(this));
        for (uint i = 0; i < tokens.length; i++) {
            console.log(tokens[i]);
        }

        assertEq(tokens.length, 1);
        assertEq(art.balanceOf(address(this)), 1);

        console.log(art.balanceOf(address(this)));
        console.log(tokens.length);

    }

    function testBurn() public {
        createSignatures();
        createPanels();

        art.mint(1);
        art.mint(1);
        
        assertEq(art.ownerOf(1_000_001), address(this));
        art.burn(1_000_001);
        vm.expectRevert(abi.encodeWithSignature("TokenDoesNotExist()"));
        art.ownerOf(1_000_001);
        
        vm.prank(address(123));
        vm.expectRevert(abi.encodeWithSignature("NotOwnerNorApproved()"));
        art.burn(1_000_002);

        // console.log(art.getRawSvg(1_000_002));
    }




    //     function testUnPackSeed() public {
    //     createSignatures(); // 1
    //     createBlackAndWhite(); // 2
    //     createPanels(); // 3
    //     createRectangularClock(); // 4
    //     bytes memory num = hex"cbabcba6";
    //     console.log(string(num));

    // }
}
