pragma solidity ^0.8.13;

import {IArt} from "../interfaces.sol";
import {Attributes} from "../structs.sol";
import {Element, createElement, Colors} from "../SVG/SVG.sol";
import {Points} from "../SVG/Polygon.sol";
import {ArtGeneratorBase} from "./ArtGeneratorBase.sol";
import {LibString} from "../Solady/LibString.sol";




contract Panels is ArtGeneratorBase {

    function getRawSvg(bytes32 seed) public view override returns(string memory svg) {
            
        (svg,) = panels(seed);

        }
    function getRawSvgAndAttributes(bytes32 seed) public view override returns(string memory, string memory) {
        (string memory svg, Attributes memory attributes) = panels(seed);
        return (svg, attributes.json());

    }

    function nudge(int value, bytes1 seed, int padding) internal pure returns (int newValue) {
        padding++;
        newValue = value + (int(uint(uint8(seed))) % padding/2) - (padding/4);
    }


    struct Params {
        int topLeftX;
        int topLeftY;
        int bottomRightX;
        int bottomRightY;
        int padding;
        int paddingReducer;
        int collapseDensity;
        Element polygon;
        Points points;
        bytes32 seed;
        uint collapseOdds;
        uint colorOdds;
        uint opacity;
    }


    function getPoints(Params memory params) internal pure returns(string memory) {
        params.points.addPoint(nudge(params.topLeftX, params.seed[0], params.padding),     nudge(params.topLeftY, params.seed[1], params.padding));
        params.points.addPoint(nudge(params.bottomRightX, params.seed[2], params.padding), nudge(params.topLeftY, params.seed[3], params.padding));
        params.points.addPoint(nudge(params.bottomRightX, params.seed[4], params.padding), nudge(params.bottomRightY, params.seed[5], params.padding));
        params.points.addPoint(nudge(params.topLeftX, params.seed[6], params.padding),     nudge(params.bottomRightY, params.seed[7], params.padding));
        return params.points.data;

    }

    

    function updateParams(Params memory params) internal view returns(Params memory params1, Params memory params2, Params memory params3) {
        uint8 divider1 = uint8(params.seed[0]) % 2; // 0 means divided horizontally.  1 means divided vertically
        uint8 divider2 = uint8(params.seed[1]) % 2; 
        
        uint height = (params.bottomRightY > params.topLeftY) ? uint(params.bottomRightY - params.topLeftY) : 1;
        uint width = uint(params.bottomRightX - params.topLeftX);
        int intersectYValue = int(uint(keccak256(abi.encode(uint(params.seed)))) % height);
        int intersectXValue = int(uint(keccak256(abi.encode(uint(params.seed) + 1))) % width);

        params1.polygon = params.polygon;
        params1.points = params.points;
        params1.seed = keccak256(abi.encode(params.seed, "1"));
        params1.padding = (params.padding * params.paddingReducer) / 100;
        params1.paddingReducer = params.paddingReducer;
        params1.collapseDensity = params.collapseDensity;
        params1.collapseOdds = params.collapseOdds;
        params1.colorOdds = params.colorOdds;
        params1.opacity = params.opacity;

        params2.polygon = params.polygon;
        params2.points = params.points;
        params2.seed = keccak256(abi.encode(params.seed, "2"));
        params2.padding = (params.padding * params.paddingReducer) / 100;
        params2.paddingReducer = params.paddingReducer;
        params2.collapseDensity = params.collapseDensity;
        params2.collapseOdds = params.collapseOdds;
        params2.colorOdds = params.colorOdds;
        params2.opacity = params.opacity;

        params3.polygon = params.polygon;
        params3.points = params.points;
        params3.seed = keccak256(abi.encode(params.seed, "3"));
        params3.padding = (params.padding * params.paddingReducer) / 100;
        params3.paddingReducer = params.paddingReducer;
        params3.collapseDensity = params.collapseDensity;
        params3.collapseOdds = params.collapseOdds;
        params3.colorOdds = params.colorOdds;
        params3.opacity = params.opacity;


        if(divider1 == 0) {
            // horizontal
            

            if(divider2 == 0) {
                // top is divided, so bottom side is big
                // bottom section
                params1.topLeftX = params.topLeftX;
                params1.topLeftY = params.topLeftY + intersectYValue;
                params1.bottomRightX = params.bottomRightX;
                params1.bottomRightY = params.bottomRightY;


                


                // top sections
                // left
                params2.topLeftX = params.topLeftX;
                params2.topLeftY = params.topLeftY;
                params2.bottomRightX = params.topLeftX + intersectXValue;
                params2.bottomRightY = params.topLeftY + intersectYValue;


                // right
                params3.topLeftX = params.topLeftX + intersectXValue;
                params3.topLeftY = params.topLeftY;
                params3.bottomRightX = params.bottomRightX;
                params3.bottomRightY = params.topLeftY + intersectYValue;


            }
            else{

                // bottom is divided, so top side is big
                // top section
                params1.topLeftX = params.topLeftX;
                params1.topLeftY = params.topLeftY;
                params1.bottomRightX = params.bottomRightX;
                params1.bottomRightY = params.topLeftY + intersectYValue;

            

                // bottom sections
                // bottom left
                params2.topLeftX = params.topLeftX;
                params2.topLeftY = params.topLeftY + intersectYValue;
                params2.bottomRightX = params.bottomRightX - intersectXValue;
                params2.bottomRightY = params.bottomRightY;

                // bottom right
                params3.topLeftX = params.bottomRightX - intersectXValue;
                params3.topLeftY = params.topLeftY + intersectYValue;
                params3.bottomRightX = params.bottomRightX;
                params3.bottomRightY = params.bottomRightY;

            }

        }

        else {
            // DIVIDER1 == 1
            // now we first divide vertically first

            if(divider2 == 0) {
                // left side is big, right side is divided horizontally
                // left side first
                params1.topLeftX = params.topLeftX;
                params1.topLeftY = params.topLeftY;
                params1.bottomRightX = params.bottomRightX - intersectXValue;
                params1.bottomRightY = params.bottomRightY;

                // top right section
                params2.topLeftX = params.bottomRightX - intersectXValue;
                params2.topLeftY = params.topLeftY;
                params2.bottomRightX = params.bottomRightX;
                params2.bottomRightY = params.topLeftY + intersectYValue;



                // bottom right side
                params3.topLeftX = params.bottomRightX - intersectXValue;
                params3.topLeftY = params.topLeftY + intersectYValue;
                params3.bottomRightX = params.bottomRightX;
                params3.bottomRightY = params.bottomRightY;
    

            }
            else{

                // right side is big, left side is divided horizontally
                params1.topLeftX = params.topLeftX + intersectXValue;
                params1.topLeftY = params.topLeftY;
                params1.bottomRightX = params.bottomRightX;
                params1.bottomRightY = params.bottomRightY;


            

                // left sections
                // top  left
                params2.topLeftX = params.topLeftX;
                params2.topLeftY = params.topLeftY;
                params2.bottomRightX = params.topLeftX + intersectXValue;
                params2.bottomRightY = params.bottomRightY - intersectYValue;
        

                // bottom left
                params3.topLeftX = params.topLeftX;
                params3.topLeftY = params.bottomRightY - intersectYValue;
                params3.bottomRightX =  params.topLeftX + intersectXValue;
                params3.bottomRightY = params.bottomRightY;




            }
           




        }


    }
    // this function recursively draws polygons getting smaller and smaller
    function collapse(Params memory params) internal view returns(string memory svg) {
       

        if((params.bottomRightX - params.topLeftX) < 15 || (params.bottomRightY - params.topLeftY) < 15) {
            return "";
        }

        params.polygon.clear();
        params.points.data = "";

        params.polygon.setAttributeChunk("fill='none' stroke='black' "); 

        params.points.addPoint(nudge(params.topLeftX, params.seed[0], params.padding),     nudge(params.topLeftY, params.seed[1], params.padding));
        params.points.addPoint(nudge(params.bottomRightX, params.seed[2], params.padding), nudge(params.topLeftY, params.seed[3], params.padding));
        params.points.addPoint(nudge(params.bottomRightX, params.seed[4], params.padding), nudge(params.bottomRightY, params.seed[5], params.padding));
        params.points.addPoint(nudge(params.topLeftX, params.seed[6], params.padding),     nudge(params.bottomRightY, params.seed[7], params.padding));

        params.polygon.setAttribute("points", params.points.data);

        string memory current = params.polygon.renderElement();

      

        params.topLeftX += params.collapseDensity;
        params.topLeftY += params.collapseDensity;
        params.bottomRightX -= params.collapseDensity;
        params.bottomRightY -= params.collapseDensity;
        
        params.seed = keccak256(abi.encode(params.seed));

        
        svg = string.concat(current, collapse(params));
        

    }

    
    
    function getPolygons(Params memory params) internal view returns(string memory, uint collapsed) {
        // adding 2 because of the stroke width
        params.topLeftX += params.padding + 2;
        params.topLeftY += params.padding + 2;
        params.bottomRightX -= params.padding + 2; 
        params.bottomRightY -= params.padding + 2;
        
        
       

       
        bool colored = (uint(uint8(params.seed[0])) % 100 < params.colorOdds) && params.bottomRightX-params.topLeftX < 600;
        bool isCollapsed = uint(uint8(params.seed[1])) % 100 < params.collapseOdds && uint(params.bottomRightX - params.topLeftX) < 400;

        



        if(params.bottomRightX - params.topLeftX < 4 || params.bottomRightY - params.topLeftY < 4 || params.padding < 2) {
            return ("", 0);
        }

        params.polygon.clear();
        params.points.data = "";


        if(colored){

            params.polygon.setAttributeChunk("stroke='black' "); 
            params.polygon.setAttribute(
                "fill", 
                Colors.rgba(
                    uint8(params.seed[4]),
                    uint8(params.seed[5]),
                    uint8(params.seed[6]), 
                    uint8(params.opacity)));
        }
        else {
           params.polygon.setAttributeChunk("fill='none' stroke='black' "); 
        }
        

        
        
        
        params.polygon.setAttribute("points", getPoints(params));

        string memory current = params.polygon.renderElement();

        if(isCollapsed) {
            return (collapse(params), 1);
        }
        if(colored) {
            return (current, 0);
        }

        (Params memory params1, Params memory params2, Params memory params3) = updateParams(params);


        (string memory polygon1, uint collapsed1) = getPolygons(params1);
        (string memory polygon2, uint collapsed2) = getPolygons(params2);
        (string memory polygon3, uint collapsed3) = getPolygons(params3);

        collapsed = collapsed1 + collapsed2 + collapsed3;

        if(isCollapsed) {
          collapsed++;
        } 




        return (string.concat(current,polygon1,polygon2,polygon3), collapsed);

    }
    
    function getSignatureTranslate(bytes32 seed) external override view returns(int translateX, int translateY) {
        int padding = int(uint(uint8(seed[0]) % 30) + 10);

        return (900-padding,925-padding);
    }

    function panels(bytes32 seed) internal view returns(string memory, Attributes memory attributes) {
        
        Element memory svg = createElement("svg");
        Element memory polygon = createElement("polygon");
        Points memory points;
        
        
        svg.setAttributeChunk('xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 1000" height="1000" width="1000"');
        svg.appendChunk('<rect width="1000" height="1000" fill="#ffffff"></rect>');
        int padding = int(uint(uint8(seed[0]) % 30) + 10);
        int paddingReducer = int(uint(uint8(seed[1]) % 49) + 50);
        int collapseDensity = int(uint(uint8(seed[2]) % 4)) + 4;
        uint collapseOdds = uint(uint8(seed[3]) % 5) + 1;
        uint colorOdds = uint(uint8(seed[3]) % 10) + 10;
        uint opacity = uint(uint8(seed[3]) % 4) + 4;
        

        attributes.add("padding", LibString.toString(padding));
        attributes.add("padding reducer", LibString.toString(paddingReducer));
        attributes.add("color odds", LibString.toString(colorOdds));
        attributes.add("opacity", LibString.toString(opacity));

        Params memory params  = Params({
            topLeftX: 0,
            topLeftY: 0,
            bottomRightX: 1000,
            bottomRightY: 1000,
            polygon: polygon,
            points: points,
            seed: seed,
            padding: padding,
            paddingReducer: paddingReducer,
            collapseDensity: collapseDensity,
            collapseOdds: collapseOdds,
            colorOdds: colorOdds,
            opacity: opacity
            });

        (string memory polygons, uint collapsed) = getPolygons(params);

        if(collapsed > 0) {
            attributes.add("collapse density", LibString.toString(collapseDensity));
            attributes.add("collapse odds", LibString.toString(collapseOdds));
            attributes.add("collapsed", LibString.toString(collapsed)); 
        }
        


        svg.appendChunk(polygons);

        return (svg.draw(), attributes);

    }


}