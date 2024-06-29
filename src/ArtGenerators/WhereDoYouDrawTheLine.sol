
pragma solidity ^0.8.13;

import {IArt} from "../interfaces.sol";
import {Attributes} from "../structs.sol";
import {Element, createElement, Transform} from "../SVG/SVG.sol";
import {Points} from "../SVG/Polygon.sol";
import {ArtGeneratorBase} from "./ArtGeneratorBase.sol";
import {LibString} from "../Solady/LibString.sol";



contract WhereDoYouDrawTheLine is ArtGeneratorBase {

    function getRawSvg(bytes32 seed) public view override returns(string memory svg) {
            
        (svg,) = whereDoYouDrawTheLine(seed);

        }
    function getRawSvgAndAttributes(bytes32 seed) public view override returns(string memory, string memory) {
         (string memory svg, Attributes memory attributes) = whereDoYouDrawTheLine(seed);
        return (svg, attributes.json());

    }

    function getSignatureTranslate(bytes32 seed) external override view returns(int, int) {
        seed;
        return (900,925);
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


    function createQuadraticCurve(int x1, int y1, int x2, int y2, uint seed) public view returns(string memory curve) {
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

    function line(LineParams memory params) public view returns(string memory d) {
            Element memory path = createElement("path");
            string memory d;
            unchecked {
                int jump = 0;

                int reducer;
                int length;
                    if(params.x2 - params.x1 == 0) {
                        int newY2 = params.y1;
                        length = params.y2 - params.y1;
                        reducer = (75 - (length / 10))+1;
                        if(reducer < 5) {
                            reducer = 5;
                        }
                        while(newY2 < params.y2){
                            int newLength = (length * (int(uint(keccak256(abi.encode(++params.seed))) % 20) + reducer)) / 100;
                            newY2 = (params.y1 + jump) + newLength;
                            if(newY2 > params.y2+30) {
                                newY2 = params.y2;
                            }
                            d = string.concat(d, createQuadraticCurve(params.x1, (params.y1 + jump), params.x2, newY2, ++params.seed));
                            jump += int(uint(keccak256(abi.encode(++params.seed))) % uint(newLength));

                        }

                    }
                    else if(params.y2 - params.y1 == 0) {
                        length = params.x2 - params.x1;
                        int newX2 = params.x1;
                        reducer = (75 - (length / 10))+1;
                        if(reducer < 5) {
                            reducer = 5;
                        }
                        while(newX2 < params.x2){

                            int newLength = (length * (int(uint(keccak256(abi.encode(++params.seed))) % 20) + reducer)) / 100;

                            newX2 = (params.x1 + jump) + newLength;

                            if(newX2 > params.x2+30) {
                                newX2 = params.x2;
                            }

                            d = string.concat(d, createQuadraticCurve(params.x1 + jump, params.y1, newX2, params.y2, ++params.seed));
                                                
                            
                            jump += int(uint(keccak256(abi.encode(++params.seed))) % uint(newLength));

                        }
                    }
                path.setAttributeChunk(string.concat('fill="none" stroke="black" stroke-width=".', LibString.toString((params.seed % 4) + 6), '" '));
                path.setAttribute("d", d);
                return (path.renderElement());
            }
    }


    struct Shape {
        int x1;
        int y1;
        int x2;
        int y2;
        int iteration;
        int iterations;
        uint seed;

    }

    function updateParams(Shape memory currentShape) internal view returns(Shape memory shape1, Shape memory shape2) {
        uint seed1 = uint(keccak256(abi.encode(++currentShape.seed)));
        uint seed2 = uint(keccak256(abi.encode(++currentShape.seed)));



        int length1 = int(uint(keccak256(abi.encode(++currentShape.seed))) % 200) + 200;
        int length2 = int(uint(keccak256(abi.encode(++currentShape.seed))) % 200) + 200;

        bool direction1 = seed1 % 2 == 0;
        bool direction2 = seed2 % 2 == 0;

        // vertical line
        if(currentShape.x1 == currentShape.x2) {
            int topIntersect = int(uint(keccak256(abi.encode(++currentShape.seed))) % (uint(currentShape.y2 - currentShape.y1)/2));
            int bottomIntersect = int(uint(keccak256(abi.encode(++currentShape.seed))) % (uint(currentShape.y2 - currentShape.y1)/2));

                shape1.x1 = direction1 ? currentShape.x1-length1 : currentShape.x1;
                shape1.y1 = currentShape.y1 + topIntersect;
                shape1.x2 = direction1 ? currentShape.x2 : currentShape.x2+length1;
                shape1.y2 = currentShape.y1 + topIntersect;
                shape1.iteration = currentShape.iteration++;
                shape1.iterations = currentShape.iterations;
                shape1.seed = seed1;

                shape2.x1 = direction2 ? currentShape.x2-length2 : currentShape.x2;
                shape2.y1 = currentShape.y2 - bottomIntersect;
                shape2.x2 = direction2 ? currentShape.x2 : currentShape.x2+length2;
                shape2.y2 = currentShape.y2 - bottomIntersect;
                shape2.iteration = currentShape.iteration++;
                shape2.iterations = currentShape.iterations;
                shape2.seed = seed2;

        }

        // horizontal line
        else if(currentShape.y1 == currentShape.y2) {
           
            int leftIntersect = int(uint(keccak256(abi.encode(++currentShape.seed))) % (uint(currentShape.x2 - currentShape.x1)/2));
            int rightIntersect = int(uint(keccak256(abi.encode(++currentShape.seed))) % (uint(currentShape.x2 - currentShape.x1)/2));


                shape1.x1 = currentShape.x1 + leftIntersect;
                shape1.y1 = direction1 ? currentShape.y1-length1 : currentShape.y1;
                shape1.x2 = currentShape.x1 + leftIntersect;
                shape1.y2 = direction1 ? currentShape.y1 : currentShape.y1+length1;
                shape1.iteration = currentShape.iteration++;
                shape1.iterations = currentShape.iterations;
                shape1.seed = seed1;

                shape2.x1 = currentShape.x2 - rightIntersect;
                shape2.y1 = direction2 ? currentShape.y2-length2 : currentShape.y2;
                shape2.x2 = currentShape.x2 - rightIntersect;
                shape2.y2 = direction2 ? currentShape.y2 : currentShape.y2+length2;
                shape2.iteration = currentShape.iteration++;
                shape2.iterations = currentShape.iterations;
                shape2.seed = seed2;
        }

    }



    function createPiece(Shape memory shape) internal view returns(string memory) {
        

        if(shape.x1 < 50 || shape.y1 < 50 || shape.x2 < 50 || shape.y2 < 50 || shape.x1 > 950 || shape.y1 > 950 || shape.x2 > 950 || shape.y2 > 950 || shape.iteration == shape.iterations) {


            return ("");
        }


        LineParams memory params1 = LineParams({
            x1: shape.x1,
            y1: shape.y1,
            x2: shape.x2,   
            y2: shape.y2,
            seed: shape.seed
        });
        string memory line1 = line(params1);


        (Shape memory newShape1, Shape memory newShape2) = updateParams(shape);

        (string memory line2) = createPiece(newShape1);
        (string memory line3) = createPiece(newShape2);

        return (string.concat(line1,line2, line3));
    }





    function whereDoYouDrawTheLine(bytes32 seed) public view returns(string memory, Attributes memory attributes) {
        Element memory svg = createElement("svg");
        Element memory group = createElement("g");
        Points memory points;

        svg.setAttributeChunk('xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 1000" height="1000" width="1000"');
        svg.appendChunk('<rect width="1000" height="1000" stroke="black" stroke-width=".5"  fill="#ffffff"></rect>');
        group.setAttribute("transform", string.concat(Transform.skewX(int(uint(uint8(seed[2]) % 4)) - 2)));

        Shape memory shape;
        int position = int(uint(seed) % 100) + 450;
        int length = int(uint(seed) % 200) + 200;
        int iterations = int(uint(seed) % 2) + 2;


        if(uint(seed) % 2 == 0) {
            // vertical start
            shape.x1 = position;
            shape.y1 = length;
            shape.x2 = position;
            shape.y2 = 1000 - length;
            shape.iteration = 0;
            shape.iterations = iterations;
            shape.seed = uint(seed);

        }
        else {
            // horizontal start
            shape.x1 = length;
            shape.y1 = position;
            shape.x2 = 1000 - length;
            shape.y2 = position;
            shape.iteration = 0;
            shape.iterations = iterations;
            shape.seed = uint(seed);

        }

        (string memory image) = createPiece(shape);

        group.appendChunk(image);
        svg.appendChild(group); 

        return(svg.draw(), attributes);

    }


}