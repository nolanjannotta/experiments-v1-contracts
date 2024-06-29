pragma solidity ^0.8.13;

import {IArt} from "../interfaces.sol";
import {Attributes} from "../structs.sol";
import {Element, createElement, Transform} from "../SVG/SVG.sol";
import {LibString} from "../Solady/LibString.sol";
import {ArtGeneratorBase} from "./ArtGeneratorBase.sol";

contract RectangularClock is ArtGeneratorBase {

    struct Data {
        uint8 offsetHours;
        uint8 length;
        uint32 backgroundId;
        uint32 selfId;
        string location;
    }



    function getRawSvg(bytes32 seed) public view override returns(string memory svg) {
        (svg,) = rectangularClock(seed);

    }

    function getRawSvgAndAttributes(bytes32 seed) public view override returns(string memory, string memory) {
         (string memory svg, Attributes memory attributes) = rectangularClock(seed);
        return (svg, attributes.json());
    }


    function modify(uint tokenId, bytes memory data) public view override returns(bytes32) {
        (uint timeZoneOffset, uint background, bytes memory location) = abi.decode(data, (uint, uint, bytes));
        timeZoneOffset %= 24;
        location = location.length == 0 ? bytes("") : location;
        return bytes32(abi.encodePacked(uint8(timeZoneOffset), uint32(tokenId), uint32(background), string(location)));
    }


    function createSeed(uint tokenId, address minter) public view override returns(bytes32) {
        
        uint8 offset = 17; 
        bytes memory location = "Los Angeles";

        return bytes32(abi.encodePacked(offset, uint32(tokenId), uint32(0), location));
    }


    function unPackSeed(bytes calldata seed) external pure override returns(bytes memory unPackedSeed) {
        uint8 offset = uint8(bytes1(seed[0]));
        uint32 selfId = uint32(bytes4(seed[1:5]));
        uint32 backgroundId = uint32(bytes4(seed[5:9]));

        uint endIndex = 32;
        for(uint i = 9; i < 32; i++) {
            if(seed[i] == 0) {
                endIndex = i;
                break;
            }
            
        }
        string memory location = string(seed[9:endIndex]);
        
        return abi.encode(offset, selfId, backgroundId, location);
    }




    function getTime(uint timestamp) internal view returns(uint hour, uint minute, uint second) {
        uint secondsPerMinute = 60;
        uint secondsPerHour = secondsPerMinute*60;
        uint secondsPerDay = secondsPerHour*24;

        hour = ((timestamp % secondsPerDay) / secondsPerHour);
        minute = (timestamp % secondsPerHour) / secondsPerMinute;
        second =  (timestamp % secondsPerMinute);

    }




    function rectangularClock(bytes32 seed) public view returns (string memory, Attributes memory attributes) {
        Data memory data;

        (data.offsetHours, data.selfId, data.backgroundId, data.location) = abi.decode(this.unPackSeed(abi.encode(seed)), (uint8, uint32, uint32, string));


        uint timestamp = block.timestamp + (uint(data.offsetHours) * 1 hours);
        
        (uint hour, uint minute, uint second) = getTime(timestamp);
        attributes.add("time zone offset", string.concat(LibString.toString(data.offsetHours), " hours"));


        Element memory svg = createElement("svg");
        svg.setAttributeChunk('xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 1000" height="1000" width="1000"');
        svg.appendChunk('<rect width="1000" height="1000" fill="#ffffff"></rect>');

        Element memory g = createElement("g");
        g.appendChunk('<rect x="135.5" y="75" width="729" height="850" fill="white" stroke="black" stroke-width="20"></rect> <rect x="270" y="215" width="460" height="570" fill="none" stroke="black"></rect> <g letter-spacing="-2" text-anchor="middle" font-weight="bold"> <text x="210" y="200" font-size="100px" transform="skewX(30)">XI</text> <text x="500" y="200" font-size="100px" >XII</text> <text x="788" y="200" font-size="100px" transform="skewX(-30)">I</text> <text x="210" y="200" font-size="100px" transform="skewX(-30) rotate(180 500 500)">VII</text> <text x="500" y="200" font-size="100px" transform="rotate(180 500 500)">VI</text> <text x="788" y="200" font-size="100px" transform="skewX(30) rotate(180 500 500)">V</text> <text x="785" y="255" font-size="100px" transform="skewY(-30) rotate(90 500 500) ">II</text> <text x="500" y="255" font-size="100px" transform="rotate(90 500 500)">III</text> <text x="210" y="255" font-size="100px" transform=" skewY(30) rotate(90 500 500) ">IIII</text> <text x="790" y="255" font-size="100px" transform="skewY(30) rotate(-90 500 500)">X</text> <text x="500" y="255" font-size="100px" transform="rotate(-90 500 500)">IX</text> <text x="195" y="255" font-size="100px" transform="skewY(-30) rotate(-90 500 500)">VIII</text> </g>');

        IArt art = IArt(msg.sender);

        if(art.exists(data.selfId) && art.exists(data.backgroundId) && art.ownerOf(data.selfId) == art.ownerOf(data.backgroundId)) {
            
            attributes.add("background", string.concat(art.getEdition(data.backgroundId / 1_000_000).name, " #", LibString.toString(data.backgroundId % 1_000_000)));
            g.appendChunk(string.concat('<g transform="translate(275,275) scale(.45)">', art.getRawSvg(data.backgroundId), '</g>'));
        }


        Element memory polygon = createElement("polygon");

        Element memory rotateAnimation = createElement("animateTransform");
        // minute hand
        polygon.setAttributeChunk('points="497,500 485,195 500,180 515,195 503,500" fill="black" ');

        int256 angle = int256(6 * minute);

        angle = angle + ((int256(second) * 6) / 60);
        polygon.setAttribute("transform", Transform.rotate(angle, 500, 500));

        rotateAnimation.setAttributeChunk('attributeName="transform" type="rotate" dur="3600s" repeatCount="indefinite" ');
        rotateAnimation.setAttribute("from",string.concat(LibString.toString(uint256(angle)), " 500 500"));
        rotateAnimation.setAttribute("to",string.concat(LibString.toString(uint256(angle) + 360)," 500 500"));


        polygon.appendChild(rotateAnimation);
        g.appendChild(polygon); 
        polygon.clear();
        // hour hand
        polygon.setAttributeChunk('points="496,500 480,295 500,275 520,295 504,500" fill="black" ');
        angle = int256(30 * hour);
        angle = angle + ((int256(minute) * 30) / 60);

        polygon.setAttribute("transform", Transform.rotate(angle, 500, 500));

        rotateAnimation.setAttributeChunk('attributeName="transform" type="rotate" dur="43200s" repeatCount="indefinite" ');
        rotateAnimation.setAttribute("from",string.concat(LibString.toString(uint256(angle)), " 500 500"));
        rotateAnimation.setAttribute("to",string.concat(LibString.toString(uint256(angle) + 360)," 500 500"));


        polygon.appendChild(rotateAnimation);
        g.appendChild(polygon);
        g.appendChunk('<circle r="15" fill="black" cx="500" cy="500"></circle>');

        if(bytes(data.location).length > 0) {
            g.setAttribute("transform", Transform.translate(0,-50));
            svg.appendChild(g);
            svg.appendChunk(string.concat('<text x="500" y="980" text-anchor="middle" font-size="60px" font-weight="bold">', data.location, '</text>'));
        }
        else {
          svg.appendChild(g);  
        }


        

        return (svg.draw(), attributes);
    }

}
