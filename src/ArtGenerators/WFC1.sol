pragma solidity ^0.8.13;


import {Attributes} from "../structs.sol";
import {Element, createElement, utils} from "../SVG/SVG.sol";
// import {D} from "../SVG/Path.sol";
import {Points} from "../SVG/Polygon.sol";
import {Rectangle, Line, Point} from "../SVG/Rectangle.sol";
import {ArtGeneratorBase} from "./ArtGeneratorBase.sol";

import "forge-std/console.sol";


contract WFC1 is ArtGeneratorBase {

    constructor(){}

    function getRawSvg(bytes32 seed) public view override returns(string memory svg) {
            
        (svg,) = wfc1(seed);

        }
    function getRawSvgAndAttributes(bytes32 seed) public view override returns(string memory, string memory) {
         (string memory svg, Attributes memory attributes) = wfc1(seed);
        return (svg, attributes.json());

    }

    // function modify(bytes memory data, bytes32 seed) public view override returns(bytes32) {
    //     revert();
    // }

    

    function nudge(int value, bytes1 seed, int padding) internal pure returns (int newValue) {
        uint8 p = uint8(int8(padding+1));
        // if(p<2) p=2;
        newValue = value + int((int8(uint8(seed) % p/2) - int8(p)/4));
    }


    function wfc1(bytes32 seed) internal view returns(string memory, Attributes memory attributes) {
        
        Element memory svg = startSvg();
        Element memory polygon = createElement("polygon");
        Points memory points;

        return (svg.draw(), attributes);

    }


}