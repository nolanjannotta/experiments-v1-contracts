
pragma solidity ^0.8.13;

import {Attributes} from "../structs.sol";
import {Element, createElement} from "../SVG/SVG.sol";
// import {D} from "../SVG/Path.sol";
import {Points} from "../SVG/Polygon.sol";
import {ArtGeneratorBase} from "./ArtGeneratorBase.sol";




contract Window is ArtGeneratorBase {

    function getRawSvg(bytes32 seed) public view override returns(string memory svg) {
            
        (svg,) = window(seed);

        }
    function getRawSvgAndAttributes(bytes32 seed) public view override returns(string memory, string memory) {
         (string memory svg, Attributes memory attributes) = window(seed);
         
        return (svg, attributes.json());

    }


    function nudge(int value, bytes1 seed) internal pure returns (int newValue) {
        newValue = value + int((int8(uint8(seed) % 20) - 10));
    }





    function window(bytes32 seed) internal view returns(string memory, Attributes memory attributes) {
        Element memory svg = createElement("svg");
        Element memory polygon = createElement("polygon");
        Points memory points;

        svg.setAttributeChunk('xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 1000" height="1000" width="1000"');
        svg.appendChunk('<rect width="1000" height="1000" fill="#ffffff"></rect>');


        points.addPoint(nudge(50, seed[0]),  nudge(50, seed[1]));
        points.addPoint(nudge(950, seed[2]), nudge(50, seed[3]));
        points.addPoint(nudge(950, seed[4]), nudge(950, seed[5]));
        points.addPoint(nudge(50, seed[6]),  nudge(950, seed[7]));
       
        polygon.setAttributeChunk("fill='none' stroke='black' "); 
        polygon.setAttribute("points", points.data);

        svg.appendChild(polygon);

        return(svg.draw(), attributes);

    }
}