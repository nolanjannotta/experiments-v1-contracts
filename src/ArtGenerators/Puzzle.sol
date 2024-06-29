
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


contract Puzzle is ArtGeneratorBase {

    function getRawSvg(bytes32 seed) public view override returns(string memory svg) {
            
        (svg,) = puzzle(seed);

        }
    function getRawSvgAndAttributes(bytes32 seed) public view override returns(string memory, string memory) {
        (string memory svg, Attributes memory attributes) = puzzle(seed);
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
        uint repetitions;
    }

    struct LineParams2{
        int x1;
        int y1;
        int x2;
        int y2;
        uint seed;
    }


    function createQuadraticCurve2(int x1, int y1, int x2, int y2, uint seed) public view returns(string memory curve) {
        (int newStartX, int newStartY) =  nudge(x1, y1, ++seed,8);
        (int newEndX, int newEndY) =  nudge(x2, y2, ++seed,8);
        curve = string.concat("M", LibString.toString(newStartX), ",", LibString.toString(newStartY));

        int centerX = x1<x2 ? x1 + int(x2 - x1)/2 : x2 + int(x1 - x2)/2;
        int centerY = y1<y2 ? y1 + int(y2 - y1)/2 : y2 + int(y1 - y2)/2;

        (int controlX, int controlY) = nudge(centerX, centerY, ++seed, 14);

        curve = string.concat(
            curve, "Q", 
            LibString.toString(controlX), 
            ",", 
            LibString.toString(controlY), 
            " ", 
            LibString.toString(x2), 
            ",", 
            LibString.toString(y2));
    }

    function drawSegments(LineParams2 memory params, int segments) internal view returns(string memory d) {
       
        int incrementerX = (params.x2 - params.x1)/(segments);
        int incrementerY = (params.y2 - params.y1)/(segments);


        int x2 = params.x1 + incrementerX;
        int y2 = params.y1 + incrementerY;
        int x1 = params.x1;
        int y1 = params.y1;

        for(uint i=1; i<uint(segments*2); i++) {    
            params.seed = uint(keccak256(abi.encode(++params.seed)));           
            d = string.concat(d, createQuadraticCurve2(x1, y1, x2, y2, params.seed++));
            x2 = x2 + incrementerX/2;
            y2 = y2 + incrementerY/2;

            x1 = x1 + (incrementerX/2);
            y1 = y1 + (incrementerY/2);
            
        }
    }


    // q: how to get length of a line given 2 coordinates? 
    // a: sqrt((x2-x1)^2 + (y2-y1)^2)
    // this one will be made of smaller lines combined together
    function line2(LineParams2 memory params) public view returns(string memory) {
            Element memory path = createElement("path");
            string memory d;
            unchecked {
            int length = int(sqrt(uint((params.x2 - params.x1)**2) + uint((params.y2 - params.y1)**2) ));


            for(int i; i<2; i++) {
                
                    int segments = int(uint(keccak256(abi.encode(params.seed))) % (uint(length/200)+1) + 1);
                    d = string.concat(d, drawSegments(params,segments));
                    params.seed++; 
                }
                // d = string.concat(d, drawSegments(params,2));
                
            }

            path.setAttributeChunk('fill="none" stroke="black" stroke-width=".5" ');
            // path.setAttributeChunk(string.concat('fill="none" stroke="', length<20 ? 'green" stroke-width="1" ' : 'black" stroke-width=".5" '));

            path.setAttribute("d", d);


            return (path.renderElement());

    }



    struct Puzzle {
        int x1; 
        int y1;
        int x2;
        int y2;
        int x3; 
        int y3;
        int x4;
        int y4;
        int x5; 
        int y5;
        uint seed;

    }

    function updateParams(Rectangle memory rect) internal view returns(Rectangle memory rect1, Rectangle memory rect2) {
        



    }

    function createPiece(Puzzle memory puzzle) internal view returns(string memory) {

        LineParams2 memory params1 = LineParams2({
            x1: puzzle.x1,
            y1: puzzle.y1,
            x2: puzzle.x2,
            y2: puzzle.y2,
            seed: ++puzzle.seed
        });
        LineParams2 memory params2 = LineParams2({
            x1: puzzle.x2,
            y1: puzzle.y2,
            x2: puzzle.x3,
            y2: puzzle.y3,
            seed: ++puzzle.seed
        });
        LineParams2 memory params3 = LineParams2({
            x1: puzzle.x3,
            y1: puzzle.y3,
            x2: puzzle.x4,
            y2: puzzle.y4,
            seed: ++puzzle.seed
        });
        LineParams2 memory params4 = LineParams2({
            x1: puzzle.x4,
            y1: puzzle.y4,
            x2: puzzle.x1,
            y2: puzzle.y1,
            seed: ++puzzle.seed
        });
        // LineParams2 memory params5 = LineParams2({
        //     x1: puzzle.x5,
        //     y1: puzzle.y5,
        //     x2: puzzle.x1,
        //     y2: puzzle.y1,
        //     seed: ++puzzle.seed
        // });

        // string memory line1 = line2(params);

        return string.concat(line2(params1), line2(params2), line2(params3), line2(params4));
    }





    function puzzle(bytes32 seed) public view returns(string memory, Attributes memory attributes) {
        Element memory svg = createElement("svg");
        Element memory polygon = createElement("polygon");
        Points memory points;

        svg.setAttributeChunk('xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 1000" height="1000" width="1000"');
        svg.appendChunk('<rect width="1000" height="1000" stroke="black" stroke-width="1"  fill="#ffffff"></rect>');

        Puzzle memory puzzle;


        for(uint i; i<1; i++) {
            seed = keccak256(abi.encode(seed));

            puzzle = Puzzle({
            x1: int(int8(uint8(seed[0]))) + 372,
            y1: int(int8(uint8(seed[1]) % 10)) + (50),

            x2: 1000 - (int(int8(uint8(seed[2]) % 10) + 50)),
            y2: int(int8(uint8(seed[3]) % 10) + 50),

            x3: 1000 -int(int8(uint8(seed[4]) % 10) + 50),
            y3: 1000 - int(int8(uint8(seed[5]) % 10) + 50),


            x4: int(int8(uint8(seed[6]) % 10) + 50),
            y4: 1000 - int(int8(uint8(seed[7]) % 10) + 50),

            x5: int(int8(uint8(seed[8]) % 10) + 50),
            y5: int(int8(uint8(seed[9]) % 10) + 50),

            seed: uint(seed)
        });
            svg.appendChunk(createPiece(puzzle)); 
            // console.log(puzzle.seed);
        }


        // svg.appendChunk(createPiece(puzzle)); 

        // seed = keccak256(abi.encode(seed));



        

        return(svg.draw(), attributes);

    }

}