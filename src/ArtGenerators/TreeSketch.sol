
pragma solidity ^0.8.13;

import {IArt} from "../interfaces.sol";
import {Attributes} from "../structs.sol";
import {Element, createElement, utils} from "../SVG/SVG.sol";
import {ArtGeneratorBase} from "./ArtGeneratorBase.sol";

import {LibString} from "../Solady/LibString.sol";



contract TreeSketch is ArtGeneratorBase {

    function getRawSvg(bytes32 seed) public view override returns(string memory svg) {
            
        (svg,) = sketch(seed);

        }
    function getRawSvgAndAttributes(bytes32 seed) public view override returns(string memory, string memory) {
        (string memory svg, Attributes memory attributes) = sketch(seed);
        return (svg, attributes.json());

    }
    function getSignatureTranslate(bytes32 seed) external override view returns(int, int) {
        seed;
        return (900,925);
    }

    function nudge(int x, int y, uint seed, uint nudgeAmount) internal pure returns (int newX, int newY) {
        unchecked{
            newX = x + int(uint(keccak256(abi.encode(x,seed))) % nudgeAmount) - int(nudgeAmount/2);
            newY = y + int(uint(keccak256(abi.encode(y,seed))) % nudgeAmount) - int(nudgeAmount/2);  
        }
        
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


        function line(LineParams memory params) public view returns(string memory) {
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
                int newLength;
                while(newY2 < params.y2){

                        newLength = (length * (int(uint(keccak256(abi.encode(++params.seed))) % 20) + reducer)) / 100;

                        newY2 = (params.y1 + jump) + newLength;

                    if(newY2 > params.y2+10) {
                            newY2 = params.y2;
                            
                        }

                        d = string.concat(d, createQuadraticCurve2(params.x1, (params.y1 + jump), params.x2, newY2, ++params.seed));

                    
                    jump += int(uint(keccak256(abi.encode(++params.seed))) % uint(newLength));

                    }


                path.setAttributeChunk(string.concat('fill="none" stroke="black" stroke-width=".', LibString.toString((params.seed % 4) + 6), '" '));

                path.setAttribute("d", d);


                return (path.renderElement());

            }
        }



    struct Rectangle {
        int width;
        int height;
        int angle;
        int direction;
        int x1; 
        int y1;
        uint seed;


    }

    function updateParams(Rectangle memory rect) internal view returns(Rectangle memory rect1, Rectangle memory rect2) {
        
        unchecked {
            rect1.angle = int(uint(keccak256(abi.encode(++rect.seed))) % 40) + 10;
            rect1.width = (rect.width * int(uint(keccak256(abi.encode(++rect.seed))) % 10 + 50)) / 100;
            rect1.height = (rect.height * int(uint(keccak256(abi.encode(++rect.seed))) % 10 + 70)) / 100;
            rect1.direction = rect.direction == int(1) ? int(0) : int(1);
            rect1.seed = uint(keccak256(abi.encode(++rect.seed)));
            rect1.y1 = rect.y1 - rect.height;
            rect1.x1 = rect1.direction == 0 ? rect.x1 - rect.width/4 : rect.x1 + rect.width/4;

            
            rect2.angle = int(uint(keccak256(abi.encode(++rect.seed))) % 40) + 10;
            rect2.width = (rect.width * int(uint(keccak256(abi.encode(++rect.seed))) % 10 + 50)) / 100;
            rect2.height = (rect.height * int(uint(keccak256(abi.encode(++rect.seed))) % 10 + 70)) / 100;
            rect2.direction = rect1.direction == int(1) ? int(0) : int(1);
            rect2.seed = uint(keccak256(abi.encode(++rect.seed)));
            rect2.y1 = rect.y1 - rect.height;
            rect2.x1 = rect2.direction == 0 ? rect.x1 - rect.width/4 : rect.x1 + rect.width/4;
         
        }


    }


    function tree(Rectangle memory rect) internal view returns(string memory) {
        if(rect.height < 15) {
            return "";
        }
        

        (string memory currentRect, int rotateX, int rotateY) = createRectangle(rect);

        


        string memory angle = string.concat(
            "<g transform='rotate(", 
            rect.direction == 0 ? "-" : "", 
            LibString.toString(rect.angle),
            ",", 
            LibString.toString(rotateX),
            ",",
            LibString.toString(rotateY),")'>");

        

        (Rectangle memory rect1, Rectangle memory rect2) = updateParams(rect);

        return string.concat(angle, currentRect, tree(rect1), tree(rect2), "</g>");



    }

    
    function createRectangle(Rectangle memory rect) public view returns(string memory rectangle, int, int) {
        unchecked {

            if(rect.height < 20) {

                LineParams memory params = LineParams({
                    x1: rect.x1,
                    x2: rect.x1,
                    y1: rect.y1-rect.height, 
                    y2: rect.y1,
                    seed: uint(keccak256(abi.encode(++rect.seed)))
                    });

                (string memory newLine) =  line(params);

                return(string.concat(newLine), params.x2, params.y2);
            }
            
        string memory lines;

        LineParams memory params = LineParams({
            x1: rect.x1-(rect.width/2),
            x2: rect.x1-(rect.width/2),
            y1: rect.y1-rect.height, 
            y2: rect.y1,
            seed: uint(keccak256(abi.encode(++rect.seed)))
            });

        string memory newLine =  line(params);


        lines = string.concat(lines, newLine);

        params.x1 = rect.x1+(rect.width/2);
        params.x2 = rect.x1+(rect.width/2);
        params.seed = uint(keccak256(abi.encode(++rect.seed)));

        newLine = line(params);
        lines = string.concat(lines, newLine);


        return (lines,params.x2, params.y2); 

        }

    }


       function sketch(bytes32 seed) public view returns(string memory, Attributes memory attributes) {
        Element memory svg = createElement("svg");
        Element memory polygon = createElement("polygon");

        svg.setAttributeChunk('xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 1000" height="1000" width="1000"');
        svg.appendChunk('<rect width="1000" height="1000" stroke="black" stroke-width="1"  fill="#ffffff"></rect>');

        
        Rectangle memory rect = Rectangle({
            width: 60,
            height: 200,
            angle: 0,
            direction: 0,
            x1: 500, 
            y1: 900,
            seed: uint(seed)
        });



        svg.appendChunk(tree(rect)); 

    
        return(svg.draw(), attributes);

    }

}