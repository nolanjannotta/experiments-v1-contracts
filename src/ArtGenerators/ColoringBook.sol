
pragma solidity ^0.8.13;

import {Attributes} from "../structs.sol";
import {Element, createElement} from "../SVG/SVG.sol";
// import {D,C} from "../SVG/Path.sol";
import {Points} from "../SVG/Polygon.sol";
import {Rectangle} from "../SVG/Rectangle.sol";
import {sqrt} from "../SVG/utils.sol";
import {ArtGeneratorBase} from "./ArtGeneratorBase.sol";
import {LibString} from "../Solady/LibString.sol";

import "forge-std/console.sol";


contract ColoringBook is ArtGeneratorBase {

    function getRawSvg(bytes32 seed) public view override returns(string memory svg) {
            
        (svg,) = coloringBook(seed);

        }
    function getRawSvgAndAttributes(bytes32 seed) public view override returns(string memory, string memory) {
        (string memory svg, Attributes memory attributes) = coloringBook(seed);
        return (svg, attributes.json());

    }

    function nudge(int x, int y, uint seed, uint nudgeAmount) internal pure returns (int newX, int newY) {
        newX = x + int(uint(keccak256(abi.encode(x,seed))) % nudgeAmount) - int(nudgeAmount/2);
        newY = y + int(uint(keccak256(abi.encode(y,seed))) % nudgeAmount) - int(nudgeAmount/2);
    }

    struct LineParams{
        int x1;
        int y1;
        int x2;
        int y2;
        uint seed;
    }

    function createQuadraticCurve2(int x1, int y1, int x2, int y2, uint seed) public view returns(string memory curve) {
        (int newStartX, int newStartY) =  nudge(x1, y1, ++seed,4);
        (int newEndX, int newEndY) =  nudge(x2, y2, ++seed,4);

        curve = string.concat("M", LibString.toString(newStartX), ",", LibString.toString(newStartY));

        int centerX = x1<x2 ? x1 + int(x2 - x1)/2 : x2 + int(x1 - x2)/2;
        int centerY = y1<y2 ? y1 + int(y2 - y1)/2 : y2 + int(y1 - y2)/2;

        (int controlX, int controlY) = nudge(centerX, centerY, ++seed, 4);

        curve = string.concat(
            curve, "Q", 
            LibString.toString(controlX), 
            ",", 
            LibString.toString(controlY), 
            " ", 
            LibString.toString(newEndX), 
            ",", 
            LibString.toString(newEndY));
    }


    function verticalLine(LineParams memory params) public view returns(string memory) {
        Element memory path = createElement("path");
            string memory d;
            unchecked {
    
            int jump = 0;
            int length = params.y2 - params.y1;

            int reducer = (75 - (length / 10))+1;
            if(reducer < 5) {
                reducer = 5;
            }
            int newY2 = params.y1;
             while(newY2 < params.y2){

                    int newLength = (length * (int(uint(keccak256(abi.encode(++params.seed))) % 20) + reducer)) / 100;

                    newY2 = (params.y1 + jump) + newLength;

                   if(newY2 > params.y2+30) {
                        newY2 = params.y2;
                        
                    }

                    d = string.concat(d, createQuadraticCurve2(params.x1, (params.y1 + jump), params.x2, newY2, ++params.seed));

                
                jump += int(uint(keccak256(abi.encode(++params.seed))) % uint(newLength));

                }


            path.setAttributeChunk(string.concat('fill="none" stroke="black" stroke-width=".', LibString.toString((params.seed % 4) + 6), '" '));
            // path.setAttributeChunk(string.concat('fill="none" stroke="', length<20 ? 'green" stroke-width="1" ' : 'black" stroke-width=".5" '));

            path.setAttribute("d", d);


            return (path.renderElement());

        }
    }


    // q: how to get length of a line given 2 coordinates? 
    // a: sqrt((x2-x1)^2 + (y2-y1)^2)
    // this one will be made of smaller lines combined together

    function horizontalLine(LineParams memory params) public view returns(string memory) {
            Element memory path = createElement("path");
            string memory d;
            unchecked {
    
            int jump = 0;
            int length = params.x2 - params.x1;

            int reducer = (75 - (length / 10))+1;
            if(reducer < 5) {
                reducer = 5;
            }
            

            int newX2 = params.x1;
            while(newX2 < params.x2){

                // horizontal line
                int newLength = (length * (int(uint(keccak256(abi.encode(++params.seed))) % 20) + reducer)) / 100;

                console.log(uint(newLength));
                newX2 = (params.x1 + jump) + newLength;

                if(newX2 > params.x2+30) {
                    newX2 = params.x2;
                }

                d = string.concat(d, createQuadraticCurve2(params.x1 + jump, params.y1, newX2, params.y2, ++params.seed));
                                    
            
            jump += int(uint(keccak256(abi.encode(++params.seed))) % uint(newLength));

            }

            path.setAttributeChunk(string.concat('fill="none" stroke="black" stroke-width=".', LibString.toString((params.seed % 4) + 6), '" '));
            // path.setAttributeChunk(string.concat('fill="none" stroke="', length<20 ? 'green" stroke-width="1" ' : 'black" stroke-width=".5" '));

            path.setAttribute("d", d);


            return (path.renderElement());

        }
    }




    function updateParams(Rectangle memory rect) internal view returns(Rectangle memory rect1, Rectangle memory rect2) {
        



    }


    struct Rectangle {
        int topLeftX;
        int topLeftY;
        int bottomRightX;
        int bottomRightY;
        uint seed;
    }

    function createRectangle(Rectangle memory rect) public view returns (string memory) {


        LineParams memory lineParams = LineParams({
            x1: rect.topLeftX,
            y1: rect.topLeftY,
            x2: rect.bottomRightX,
            y2: rect.topLeftY,
            seed: rect.seed++
        });
        string memory top = horizontalLine(lineParams);
        lineParams.y1 = rect.bottomRightY;
        lineParams.y2 = rect.bottomRightY;
        string memory bottom = horizontalLine(lineParams);
        lineParams.x1 = rect.topLeftX;
        lineParams.x2 = rect.topLeftX;
        lineParams.y1 = rect.topLeftY;
        lineParams.y2 = rect.bottomRightY;
        string memory left = verticalLine(lineParams);
        lineParams.x1 = rect.bottomRightX;
        lineParams.x2 = rect.bottomRightX;
        string memory right = verticalLine(lineParams);

        return string.concat(top, bottom, left, right);
    }


    function coloringBook(bytes32 seed) public view returns(string memory, Attributes memory attributes) {
        Element memory svg = createElement("svg");
        Element memory polygon = createElement("polygon");
        Points memory points;

        svg.setAttributeChunk('xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 1000" height="1000" width="1000"');
        svg.appendChunk('<rect width="1000" height="1000" stroke="black" stroke-width="1"  fill="#ffffff"></rect>');

        Rectangle memory rect = Rectangle({
            topLeftX: 300,
            topLeftY: 300,
            bottomRightX: 600,
            bottomRightY: 600,
            seed: uint(seed)
        });


            string memory line = createRectangle(rect);
            svg.appendChunk(line);

        // }
        
        

        return(svg.draw(), attributes);

    }

}