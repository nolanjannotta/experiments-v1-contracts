pragma solidity ^0.8.13;

import {IArtGenerator, IArt} from "../interfaces.sol";
import {Attributes} from "../structs.sol";
import {Element, createElement, utils} from "../SVG/SVG.sol";
// import {D} from "../SVG/Path.sol";
import {Points} from "../SVG/Polygon.sol";
import {Rectangle, Line, Point} from "../SVG/Rectangle.sol";
import {ArtGeneratorBase} from "./ArtGeneratorBase.sol";

import "forge-std/console.sol";

contract Banner is ArtGeneratorBase {

    constructor(){
        

    }

     function getRawSvg(bytes32 seed) public view override returns(string memory svg) {
        (svg,) = banner(seed);

    }

    function getRawSvgAndAttributes(bytes32 seed) public view override returns(string memory, string memory) {
        (string memory svg, Attributes memory attributes) = banner(seed);
        return (svg, attributes.json());
    }

    // function dimensions(bytes32 seed) public pure override returns(uint, uint) {

    //     return (0,700);
    // }

    // function unPackSeed(bytes calldata seed) external pure override returns(bytes memory unPackedSeed) {
    //     uint32 first = (uint32(bytes4(seed[:4])));
    //     uint32 second = uint8(bytes1(seed[4:8]));
    //     uint32 third = uint24(bytes3(seed[8:12]));
    //     uint32 fourth = uint64(bytes8(seed[12:16]));
    //     uint32 fifth = uint64(bytes8(seed[12:16]));
    //     uint32 sixth = uint64(bytes8(seed[12:16]));
    //     uint32 seventh = uint64(bytes8(seed[12:16]));
    //     uint32 eighth = uint64(bytes8(seed[12:16]));

    //     return abi.encode(generator, metadataFrozen, signatureId, misc);
    // }

    function modify(uint tokenId, bytes memory data) public override view returns(bytes32) {
        // uint32 selfId = (uint32(uint(IArt(msg.sender).getSeed(tokenId))));

        (uint32 first, uint32 second, uint32 third, uint32 fourth, uint32 fifth, uint32 sixth, uint32 seventh, uint eighth) = abi.decode(data, (uint32, uint32, uint32, uint32,uint32, uint32, uint32, uint32));

        // for(uint i=0; i<8; i++) {

        // }
        if(tokenId == first || tokenId == second || tokenId == third || tokenId == fourth || tokenId == fifth || tokenId == sixth || tokenId == seventh || tokenId == eighth) {
            revert("can't display itself");
        }

        return bytes32(abi.encodePacked(first, second, third, fourth, fifth, sixth, seventh, eighth));

    }
    // function decodeSeed(uint seed) internal view returns()

    // function createSeed(uint tokenId, address minter) public view override returns(bytes32 seed) {

    //     return bytes32(tokenId);
    // }


     function banner(bytes32 seed) internal view returns(string memory, Attributes memory attributes) {
        // uint _seed = uint(seed);


        IArt art = IArt(msg.sender);
        Element memory svg = createElement("svg");
        Element memory g = createElement("g");
        Points memory points;


        return (svg.draw(), attributes);
    

    }




    // function banner(bytes32 seed) internal view returns(string memory, Attributes memory attributes) {
    //     uint _seed = uint(seed);
    //     uint layout = uint(uint32(_seed >> (160)));

    //     IArt art = IArt(msg.sender);
    //     Element memory svg = createElement("svg");
    //     Element memory g = createElement("g");
    //     Points memory points;

    //     address owner = art.ownerOf(uint(uint32(_seed)));


    //     // its all horizontal
    //     if(layout == 1) {
    //         attributes.add("layout", "1x4");
    //         uint width;
    //         for(uint i=1; i<=4; i++) {
    //         uint id = uint(uint32(_seed >> (i*32)));

    //         uint[4] memory x = [uint(100),uint(600),uint(1100),uint(1600)];

    //         if(art.exists(id) && (art.ownerOf(id) == owner)) {
    //             width += 525;
    //             attributes.add("art", string.concat(art.getEdition(id / 1_000_000).name, " #", utils._toString(id % 1_000_000)));
    //             g.appendChunk(string.concat('<image x="',utils._toString(x[i-1]), '" y="150" width="400" href="', art.getDataUri(id), '"></image>'));

    //             }

            
    //         }

    //         svg.setAttributeChunk(string.concat('xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ', utils._toString(width), ' 700"'));
    //         svg.appendChunk(string.concat('<rect width="',utils._toString(width-30), '" height="660" fill="none" x="15" y="15" rx="5"  stroke-width="10" stroke="black"></rect>'));
    //     }
        

    //     // this is 2x2
    //     else {
    //         attributes.add("layout", "2x2");
    //        for(uint i=1; i<=4; i++) {
    //         uint id = uint(uint32(_seed >> (i*32)));
    //         uint[4] memory x = [uint(66),uint(532),uint(66),uint(532)];
    //         uint[4] memory y = [uint(66),uint(532),uint(532),uint(66)];

    //         if(art.exists(id) && (art.ownerOf(id) == owner)) {
    //             attributes.add("art", string.concat(art.getEdition(id / 1_000_000).name, " #", utils._toString(id % 1_000_000)));
    //             g.appendChunk(string.concat('<image x="',utils._toString(x[i-1]), '" y="', utils._toString(y[i-1]), '" width="400" href="', art.getDataUri(id), '"></image>'));
    //         }
    //     } 
    //         svg.setAttributeChunk(string.concat('xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 1000" height="1000" width="1000"'));


    //         svg.appendChunk(string.concat('<rect width="970" height="970" fill="none" x="15" y="15" rx="5"  stroke-width="10" stroke="black"></rect>'));
            

    //     }

        
    //     svg.appendChild(g);

    //     return (svg.draw(), attributes);
    

    // }

}