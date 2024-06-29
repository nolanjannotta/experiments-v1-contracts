pragma solidity ^0.8.13;

import {Attributes} from "../structs.sol";

import {Element, createElement, Transform, Colors} from "../SVG/SVG.sol";
import {D} from "../SVG/Path.sol";
import {Points} from "../SVG/Polygon.sol";
import {ArtGeneratorBase} from "./ArtGeneratorBase.sol";
import {LibString} from "../Solady/LibString.sol";




contract Signatures is ArtGeneratorBase {



    constructor() {}


    function getRawSvg(bytes32 seed) public view override returns(string memory svg) {
        (svg,) = signatures(seed);

    }

    function getRawSvgAndAttributes(bytes32 seed) public view override returns(string memory, string memory) {
        (string memory svg, Attributes memory attributes) = signatures(seed);
        return (svg, attributes.json());
    }


    function signatures(bytes32 seed) internal pure returns (string memory, Attributes memory tokenAttributes) {

        Element memory svg = createElement("svg");
 
        svg.setAttributeChunk('xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 1000" height="1000" width="1000"');
        // well make the rectangles as polygons:

        //////////////// outer polygon /////////////////////////////////////////
        Element memory polygon = createElement("polygon");

        

        Points memory points;

        points.addPoint(
            int(int8(uint8(seed[0]) % 20) + 10),
            int(int8(uint8(seed[1]) % 20) + 10)
        );
        points.addPoint(
            1000 - (int(int8(uint8(seed[2]) % 20) + 10)),
            int(int8(uint8(seed[3]) % 20) + 10)
        );
        points.addPoint(
            1000 - (int(int8(uint8(seed[4]) % 20) + 10)),
            1000 - int(int8(uint8(seed[5]) % 20) + 10)
        );
        points.addPoint(
            int(int8(uint8(seed[6]) % 20) + 10),
            1000 - (int(int8(uint8(seed[7]) % 20) + 10))
        );
        

        polygon.setAttribute("points", points.data);
        polygon.setAttribute("fill", Colors.rgb(255, 255, 240));
        polygon.setAttributeChunk('stroke-width="7" stroke="rgb(30, 30, 30)"');

        svg.appendChild(polygon);
        polygon.clear();
        points.data =  "";


        //////////////// internal colored polygon: /////////////////////////////////////////


        // Points memory coloredPoints;
        points.addPoint(
            int(int8(uint8(seed[8]) % 50)) + 100,
            int(int8(uint8(seed[9]) % 50)) + 100
        );
        points.addPoint(
            900 - int(int8(uint8(seed[10]) % 50)),
            int(int8(uint8(seed[11]) % 50)) + 100
        );
        points.addPoint(
            900 - int(int8(uint8(seed[12]) % 50)),
            900 - int(int8(uint8(seed[13]) % 50))
        );
        points.addPoint(
            int(int8(uint8(seed[14]) % 50)) + 100,
            900 - int(int8(uint8(seed[15]) % 50))
        );

        // Element memory coloredPolygon = createElement("polygon");

        polygon.setAttribute("points", points.data);
        
        polygon.setAttribute(
            "fill",
            Colors.rgba(
                uint8(seed[16]),
                uint8(seed[17]),
                uint8(seed[18]),
                (uint8(seed[19]) % 5) + 3
            )
        );

        svg.appendChild(polygon);

        polygon.clear();


        //////////////// outline of internal colored polygon: /////////////////////////////////////////
        // we use the same points, and sometimes rotate slightly
        
        polygon.setAttribute("points", points.data);

        polygon.setAttributeChunk('stroke-width="4" stroke="rgb(30, 30, 30)" fill="none" ');
 

        if (uint(seed) % 3 == 0) { // about 30%

            tokenAttributes.add("skewed", "yes");

            int dir1 = uint8(seed[20]) % 2 == 0 ? int(-1) : int(1);
            int dir2 = uint8(seed[21]) % 2 == 0 ? int(-1) : int(1);
            int dir3 = uint8(seed[22]) % 2 == 0 ? int(-1) : int(1);


            polygon.setAttribute(
                "transform",
                string.concat(
                    Transform.rotate(
                        int(uint(uint8(seed[23]) % 3)) * dir1,
                        uint(uint8(seed[24]) % 100) + 450,
                        uint(uint8(seed[25]) % 100) + 450
                    ),
                    Transform.translate(
                        int(uint(uint8(seed[26]) % 20)) * dir2,
                        int(uint(uint8(seed[27]) % 20)) * dir3
                    )
                )
            );
        }

        svg.appendChild(polygon);

        // /////////////////////////////the wavy line///////////////////////////////////////

        Element memory path = createElement("path");
        path.setAttributeChunk('stroke="rgb(30, 30, 30)" fill="none" stroke-width="4" stroke-linecap="round" ');


        D memory d;

        seed = keccak256(abi.encode(seed));
        d.M(50, int((uint(seed) % 255) + 372));
        // d.L(500,500);
        uint loops = (uint(seed) % 5) + 1;
        tokenAttributes.add("complexity", LibString.toString(loops));
        uint offset = 500 / loops;
        for (uint i = 0; i <= loops * 4; i += 4) {
            d.S(
                int(uint(uint8(seed[i])) + offset),
                int(uint(uint8(seed[i + 1]))) + 372,
                i + 2 == (loops * 4) + 2 ? int(950) : int(uint(uint8(seed[i + 2])) + offset),
                int(uint(uint8(seed[i + 3]))) + 372
            );



            offset += 100;
        }

        path.setAttribute("d", d.data);

        svg.appendChild(path);

        return (svg.draw(), tokenAttributes);
    }


    function getPlainSignature(bytes32 seed, int translateX, int translateY) public pure returns(string memory path) {
        Element memory path = createElement("path");
        path.setAttributeChunk('stroke="rgb(30, 30, 30)" fill="none" stroke-width="15" stroke-linecap="round" ');

        path.setAttribute("transform", string.concat(Transform.translate(translateX,translateY), Transform.scale(1)));



        D memory d;

        seed = keccak256(abi.encode(seed));
        d.M(50, int((uint(seed) % 255) + 372));
        uint loops = (uint(seed) % 5) + 1;
        uint offset = 500 / loops;
        for (uint i = 0; i <= loops * 4; i += 4) {
            d.S(
                int(uint(uint8(seed[i])) + offset),
                int(uint(uint8(seed[i + 1]))) + 372,
                i + 2 == (loops * 4) + 2 ? int(950) : int(uint(uint8(seed[i + 2])) + offset),
                int(uint(uint8(seed[i + 3]))) + 372
            );



            offset += 100;
        }

        path.setAttribute("d", d.data);
        return path.renderElement();
    }




}