
pragma solidity ^0.8.13;

import {IArtGenerato

r, Attributes} from "../interfaces.sol";
import {Element, createElement, utils} from "../SVG/SVG.sol";
// import {D,C} from "../SVG/Path.sol";
import {Points} from "../SVG/Polygon.sol";
import {Rectangle, Line, Point} from "../SVG/Rectangle.sol";
import {sqrt} from "../SVG/utils.sol";
import {ArtGeneratorBase} from "./ArtGeneratorBase.sol";

import "forge-std/console.sol";


contract PencilSketch is ArtGeneratorBase {

    function getRawSvg(bytes32 seed) public view override returns(string memory svg) {
            
        (svg,) = sketch(seed);

        }
    function getRawSvgAndAttributes(bytes32 seed) public view override returns(string memory svg, Attributes memory attributes) {

        (svg, attributes) = sketch(seed);

    }

    // function modify(bytes memory data, bytes32 seed) public view override returns(bytes32) {
    //     revert();
    // }
    // function createSeed(uint tokenId, address minter) public view override returns(bytes32) {
    //     return keccak256(abi.encode(tokenId, minter));
    // }

    // function dimensions(bytes32 seed) public pure override returns(uint, uint) {
    //     seed;
    //     return (1000,1000);
    // }

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
        // uint deltaX;
        // uint deltaY;
        // compute the delta x and y here, also the other parameters

    }


        // (2,3,39,86, 123);
    function getRandomPointOnLine(int x1, int y1, int x2, int y2, uint seed) public view returns(int x, int y) {
        // int slope;
        if(x2 == x1) {
            x2++;
        }

        int slope = (int(y2-y1) * 1_000) / int(x2-x1); 
        
        uint pointScaler = uint(keccak256(abi.encode(++seed))) % 20 + 40;
        
        int randomPointX = x1<=x2 ? int(uint(keccak256(abi.encode(++seed))) % uint(x2-x1)) + x1 : int(uint(keccak256(abi.encode(++seed))) % uint(x1-x2)) + x2; 

 
        int randomPointY =  ((slope * (randomPointX - x1))/1000) + y1;

  

        // (x,y) =(randomPointX,randomPointY);
        (x,y) = nudge(randomPointX,randomPointY, ++seed, 14);
    }


    function getRandomPointOnLine2(int x1, int y1, int x2, int y2, uint seed) public view returns(int x, int y) {
        // int slope;
        // if(x2 == x1) {
        //     x2++;
        // }

        // int deltaX = x1 < x2 ? int(x2 - x1) : int(x1 - x2);
        // int deltaY = y1 < y2 ? int(y2 - y1) : int(y1 - y2);


        // int slope = (int(y2-y1) * 1_000) / int(x2-x1); 
        
        // uint pointScaler = uint(keccak256(abi.encode(++seed))) % 20 + 40;

        int centerX = x1<x2 ? x1 + int(x2 - x1)/2 : x2 + int(x1 - x2)/2;
        int centerY = y1<y2 ? y1 + int(y2 - y1)/2 : y2 + int(y1 - y2)/2;




        // int randomPointX = x1<=x2 ? int(uint(keccak256(abi.encode(++seed))) % uint(x2-x1)) + x1 : int(uint(keccak256(abi.encode(++seed))) % uint(x1-x2)) + x2; 

 
        // int randomPointY =  ((slope * (randomPointX - x1))/1000) + y1;

  

        // (x,y) =(randomPointX,randomPointY);
        // (x,y) = nudge(randomPointX,randomPointY, ++seed, 14);
        (x,y) = nudge(centerX,centerY, ++seed, 14);
    }



    function createQuadraticCurve(LineParams memory params) public view returns(string memory curve) {
        (int newStartX, int newStartY) = nudge(params.x1, params.y1, ++params.seed,8);
        (int newEndX, int newEndY) = nudge(params.x2, params.y2, ++params.seed,8);

        curve = string.concat("M", utils.toString(newStartX), ",", utils.toString(newStartY));

        (int controlX, int controlY) = getRandomPointOnLine(params.x1, params.y1,params.x2, params.y2, ++params.seed);


        curve = string.concat(
            curve, "Q", 
            utils.toString(controlX), 
            ",", 
            utils.toString(controlY), 
            " ", 
            utils.toString(newEndX), 
            ",", 
            utils.toString(newEndY));
    }

    function createQuadraticCurve2(int x1, int y1, int x2, int y2, uint seed) public view returns(string memory curve) {
        // uint seed = uint(x1+y1+x2+y2);
        (int newStartX, int newStartY) = nudge(x1, y1, ++seed,4);
        (int newEndX, int newEndY) = nudge(x2, y2, ++seed,4);
        curve = string.concat("M", utils.toString(newStartX), ",", utils.toString(newStartY));

        int centerX = x1<x2 ? x1 + int(x2 - x1)/2 : x2 + int(x1 - x2)/2;
        int centerY = y1<y2 ? y1 + int(y2 - y1)/2 : y2 + int(y1 - y2)/2;

        (int controlX, int controlY) = nudge(centerX, centerY, ++seed, 4);

        curve = string.concat(
            curve, "Q", 
            utils.toString(controlX), 
            ",", 
            utils.toString(controlY), 
            " ", 
            utils.toString(newEndX), 
            ",", 
            utils.toString(newEndY));
    }


    function createBezierCurve2(int x1, int y1, int x2, int y2, uint seed) public view returns(string memory curve) {
        seed = uint(keccak256(abi.encode(seed)));
        (int newStartX, int newStartY) = nudge(x1, y1, ++seed,4);
        // console.log("curve start");
        // console.log(seed);
        (int newEndX, int newEndY) = nudge(x2, y2, ++seed,4);
        // console.log(seed);
        curve = string.concat("M", utils.toString(newStartX), ",", utils.toString(newStartY));

        int centerX = x1<x2 ? x1 + int(x2 - x1)/2 : x2 + int(x1 - x2)/2;
        int centerY = y1<y2 ? y1 + int(y2 - y1)/2 : y2 + int(y1 - y2)/2;

        (int control1X, int control1Y) = nudge(centerX, centerY, ++seed, 4);
        (int control2X, int control2Y) = nudge(centerX, centerY, ++seed, 4);

        // (int control1X, int control1Y) = getRandomPointOnLine2(x1, y1,x2, y2, ++seed);
        // // console.log(seed);
        // (int control2X, int control2Y) = getRandomPointOnLine2(x1, y1, x2, y2, ++seed);

        // console.log(seed);
        // console.log("curve end");
        curve = string.concat(
            curve, "C", 
            utils.toString(control1X), 
            ",", 
            utils.toString(control1Y), 
            " ", 
            utils.toString(control2X), 
            ",", 
            utils.toString(control2Y), 
            " ", 
            utils.toString(newEndX), 
            ",", 
            utils.toString(newEndY));


    }



    function createBezierCurve(LineParams memory params) public view returns(string memory curve) {
        (int newStartX, int newStartY) = nudge(params.x1, params.y1, ++params.seed,8);
        (int newEndX, int newEndY) = nudge(params.x2, params.y2, ++params.seed,8);

        curve = string.concat("M", utils.toString(newStartX), ",", utils.toString(newStartY));

        (int control1X, int control1Y) = getRandomPointOnLine(params.x1, params.y1,params.x2, params.y2, ++params.seed);
        // (control1X, control1Y) = nudge(control1X, control1Y, ++params.seed);

        (int control2X, int control2Y) = getRandomPointOnLine(params.x1, params.y1,params.x2, params.y2, ++params.seed);
        // (control2X, control2Y) = nudge(control2X, control2Y, ++params.seed);

        
        curve = string.concat(
            curve, "C", 
            utils.toString(control1X), 
            ",", 
            utils.toString(control1Y), 
            " ", 
            utils.toString(control2X), 
            ",", 
            utils.toString(control2Y), 
            " ", 
            utils.toString(newEndX), 
            ",", 
            utils.toString(newEndY));


    }

    function createLineParams(uint seed) internal view returns(LineParams memory params) {

        params = LineParams({
            x1: int(uint(keccak256(abi.encode(uint(seed) + 1))) % 500) + 100,
            y1: int(uint(keccak256(abi.encode(uint(seed) + 2))) % 500) + 500,
            x2: int(uint(keccak256(abi.encode(uint(seed) + 3))) % 500) + 100,
            y2: int(uint(keccak256(abi.encode(uint(seed) + 4))) % 500) + 500,
            seed: uint(seed),
            repetitions: 5
        });
    }
    function createLineParams2(uint seed) internal view returns(LineParams2 memory params) {

        params = LineParams2({
            x1: int(uint(keccak256(abi.encode(uint(seed) + 1))) % 500) + 100,
            y1: int(uint(keccak256(abi.encode(uint(seed) + 2))) % 500) + 500,
            x2: int(uint(keccak256(abi.encode(uint(seed) + 3))) % 500) + 100,
            y2: int(uint(keccak256(abi.encode(uint(seed) + 4))) % 500) + 500,
            seed: 123

        });

    }



    function line(LineParams memory params) internal view returns(string memory) {
            Element memory path = createElement("path");
            string memory paths;
            // D memory d;
            // C memory BexierCurve;
            for(uint i=0; i<params.repetitions; i++) {
                // string memory d = createBezierCurve(params);
                string memory d = createQuadraticCurve(params);
                path.setAttributeChunk('fill="none" stroke="black" stroke-width=".3" ');
                path.setAttribute("d", d);
                paths = string.concat(paths, path.renderElement());
                path.clear();
            }

            return paths;

    }

    function drawSegments(LineParams2 memory params, int segments) internal view returns(string memory d) {
        // int deltaX = int(params.x2 - params.x1);
        // int deltaY = int(params.y2 - params.y1);

        // deltaX = deltaX < 0 ? deltaX * -1 : deltaX;
        // deltaY = deltaY < 0 ? deltaY * -1 : deltaY;

        // int length = int(sqrt(uint(deltaX)**2 + uint(deltaY)**2));

        // int segments = length <= 75 ? int(1) : int(uint(keccak256(abi.encode(params.x1, params.y1, params.x2, params.y2))) % uint(length/75) + 1);
        // seed = uint(keccak256(abi.encode(seed)));
        int incrementerX = (params.x2 - params.x1)/(segments);
        int incrementerY = (params.y2 - params.y1)/(segments);


        int x2 = params.x1 + incrementerX;
        int y2 = params.y1 + incrementerY;
        int x1 = params.x1;
        int y1 = params.y1;
        // int x2 = params.x2;
        // int y2 = params.y2;
        // int x1 = params.x1;
        // int y1 = params.y1;
        for(uint i=0; i<uint(segments*2)-1; i++) {    
            params.seed = uint(keccak256(abi.encode(params.seed)));
            // d = string.concat(d, params.seed % 10 < 3  ? createQuadraticCurve2(x1, y1, x2, y2, params.seed) : "");       
           
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

            int length = int(sqrt(uint((params.x2 - params.x1)**2) + uint((params.y2 - params.y1)**2) ));

            int segments = length <= 75 ? int(1) : int(uint(keccak256(abi.encode(params.x1, params.y1, params.x2, params.y2))) % uint(length/75) + 1);


            // for(uint i=0; i<10; i++) {
            //     d = string.concat(d, drawSegments(params,2));
            //     d = string.concat(d, drawSegments(params,segments));
            //     params.seed++;
            // }
    

            // params.seed++;
            d = string.concat(d, drawSegments(params,4));
            params.seed++;
            // d = string.concat(d, drawSegments(params,2));
            // params.seed++;
            // d = string.concat(d, drawSegments(params,segments));
            // params.seed = uint(keccak256(abi.encode(params.seed)));
            // d = string.concat(d, drawSegments(params,3));
            // params.seed++;
            // d = string.concat(d, drawSegments(params,4));
            // params.seed++;
            // d = string.concat(d, drawSegments(params,segments));
            //d = string.concat(d, drawSegments(params, 20));
            //d = string.concat(d, drawSegments(params, 10));

            path.setAttributeChunk('fill="none" stroke="black" stroke-width=".3" ');
            path.setAttribute("d", d);


            return path.renderElement();

    }



    struct Rectangle {
        int width;
        int height;
        int x1; 
        int y1;
        int x2;
        int y2;

    }

    function createBranches(Rectangle memory rect) public view returns(string memory rectangle) {

    }


    function createRectangle(Rectangle memory rect) public view returns(string memory rectangle) {

        uint seed = 34567;
        (int bottomLeftX, int bottomLeftY) = nudge(rect.x1-(rect.width/2), rect.y1, seed, 10);
        (int topLeftX, int topLeftY) = nudge(rect.x1-(rect.width/2), rect.y1-rect.height, ++seed, 10);

        string memory lines;


        LineParams2 memory params = LineParams2({
            x1: bottomLeftX,
            y1: bottomLeftY,
            x2: topLeftX,
            y2: topLeftY,
            seed: 45678
            });

        lines = string.concat(lines, line2(params));

        params = LineParams2({
            x1: bottomLeftX + 50,
            y1: bottomLeftY,
            x2: topLeftX + 50,
            y2: topLeftY,
            seed: 987654
            });

        lines = string.concat(lines, line2(params));


        // (int bottomRightX, int bottomRightY) = nudge(rect.x1+(rect.width/2), rect.y1, ++seed, 10);
        // (int topRightX, int topRightY) = nudge(rect.x1+(rect.width/2), rect.y1-rect.height, ++seed, 10);

        // params = LineParams({
        //     x1: bottomRightX,
        //     y1: bottomRightY,
        //     x2: topRightX,
        //     y2: topRightY,
        //     seed: ++seed,
        //     repetitions: 5
        //     });


        // next params
        // Rectangle memory nextRect = Rectangle({
        //     width: rect.width/2,
        //     height: rect.height/2,
        //     x1: rect.x1- 
        //     int y1;
        //     int x2;
        //     int y2;
        // })

        // lines = string.concat(lines, line(params));
        return lines; 



    }


    // function sketch(bytes32 seed) public view returns(string memory, Attributes memory attributes) {
    //     Element memory svg = createElement("svg");
    //     Element memory polygon = createElement("polygon");
    //     Points memory points;

    //     svg.setAttributeChunk('xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 1000" height="1000" width="1000"');
    //     svg.appendChunk('<rect width="1000" height="1000" fill="#ffffff"></rect>');

        


    //     for(uint i=0; i<100; i++) {


    //         LineParams2 memory params = createLineParams2(uint(keccak256(abi.encode(uint(seed)+i))));
    //         svg.appendChunk(line2(params)); 
    //     }


    //     return(svg.draw(), attributes);

    // }

       function sketch(bytes32 seed) public view returns(string memory, Attributes memory attributes) {
        Element memory svg = createElement("svg");
        Element memory polygon = createElement("polygon");
        Points memory points;

        svg.setAttributeChunk('xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 1000" height="1000" width="1000"');
        svg.appendChunk('<rect width="1000" height="1000" fill="#ffffff"></rect>');

        


        for(int i=0; i<100; i++) {


            LineParams2 memory params = LineParams2({
                x1: 10 * i,
                y1: 1010 - (10* i),
                x2: 10 * i,
                y2: 10,
                seed: uint(keccak256(abi.encode(seed, i)))
            });

            svg.appendChunk(line2(params)); 
        }

        // LineParams2 memory params = LineParams2({
        //         x1: 500,
        //         y1: 50,
        //         x2: 600,
        //         y2: 900,
        //         seed: uint(seed)
        //         // deltaX: 0,
        //         // deltaY: 0
               
        //     });

        //     svg.appendChunk(line2(params));


        return(svg.draw(), attributes);

    }

}