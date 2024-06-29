pragma solidity ^0.8.13;

import {IArtGenerator, Attributes, IArt} from "../interfaces.sol";
import {Element, createElement, utils} from "../SVG/SVG.sol";
// import {D} from "../SVG/Path.sol";
import {Points} from "../SVG/Polygon.sol";
import {Rectangle, Line, Point} from "../SVG/Rectangle.sol";
import {LibString} from "../Solady/LibString.sol";
import {ArtGeneratorBase} from "./ArtGeneratorBase.sol";


import "forge-std/console.sol";

contract Clock is ArtGeneratorBase {



    function getRawSvg(bytes32 seed) public view override returns(string memory svg) {
        (svg,) = clock(seed);

    }

    function getRawSvgAndAttributes(bytes32 seed) public view override returns(string memory svg, Attributes memory attributes) {
        (svg, attributes) = clock(seed);
    }

    function modify(bytes memory data, bytes32 seed) public view override returns(bytes32) {
        // timeZoneOffset
        // negative. 
        // 1 means substract timeZoneOffset 
        // 0 means add timeZoneOffset
        (uint timeZoneOffset, uint negative, uint background, string memory location) = abi.decode(data, (uint, uint,uint, string));
        bytes memory locationAsBytes = bytes(location);
        uint length = locationAsBytes.length;
        uint num = uint(bytes32(locationAsBytes)) >> (256 - (length * 8));

        require(timeZoneOffset < 12 && negative < 2 && length<25, "invalid inputs");
        uint packed = timeZoneOffset;
        packed |= negative << 8;
        packed |= length << 16;
        packed |= background << 24; // background, set it to zero intiially
        packed |= num << 56;
        return bytes32(packed);
    }

    // function dimensions(bytes32 seed) public pure override returns(uint, uint) {
    //     seed;
    //     return (1000,1000);
    // }

    function createSeed(uint tokenId, address minter) public view override returns(bytes32) {
        
        uint offset = 8; // 8 hours
        uint negative = 1; // 1 = a negative number 0 = positive number
        string memory location = "Los Angeles";

        bytes memory locationAsBytes = bytes(location);
        uint length = locationAsBytes.length;
        uint num = uint(bytes32(locationAsBytes)) >> (256 - (length * 8));

        uint packed = offset;
        packed |= negative << 8;
        packed |= length << 16;
        packed |= 0 << 24; // background, set it to zero intiially
        packed |= num << 56;
        return bytes32(packed);
    }

    function unPackSeed(uint num) public pure returns(uint hourOffset, uint negative, uint background, string memory location) {
        hourOffset = uint(uint8(num));
        negative = uint(uint8(num >> 8));
        uint length = uint(uint8(num >> 16));
        background = uint(uint32(num >> 24));

        if(length == 1) {
            location = string(abi.encodePacked(uint8(num >> 56)));
        }
        else if(length == 2) {
            location = string(abi.encodePacked(uint16(num >> 56)));
        }
        else if(length == 3) {
            location = string(abi.encodePacked(uint24(num >> 56)));
        }
        else if(length == 4) {
            location = string(abi.encodePacked(uint32(num >> 56)));
        }
        else if(length == 5) {
            location = string(abi.encodePacked(uint40(num >> 56)));
        }
        else if(length == 6) {
            location = string(abi.encodePacked(uint48(num >> 56)));
        }
        else if(length == 7) {
            location = string(abi.encodePacked(uint56(num >> 56)));
        }
        else if(length == 8) {
            location = string(abi.encodePacked(uint64(num >> 56)));
        }
        else if(length == 9) {
            location = string(abi.encodePacked(uint72(num >> 56)));
        }
        else if(length == 10) {
            location = string(abi.encodePacked(uint80(num >> 56)));
        }
        else if(length == 11) {
            location = string(abi.encodePacked(uint88(num >> 56)));
        }
        else if(length == 12) {
            location = string(abi.encodePacked(uint96(num >> 56)));
        }
        else if(length == 13) {
            location = string(abi.encodePacked(uint104(num >> 56)));
        }
        else if(length == 14) {
            location = string(abi.encodePacked(uint112(num >> 56)));
        }
        else if(length == 15) {
            location = string(abi.encodePacked(uint120(num >> 56)));
        }
        else if(length == 16) {
            location = string(abi.encodePacked(uint128(num >> 56)));
        }
        else if(length == 17) {
            location = string(abi.encodePacked(uint136(num >> 56)));
        }
        else if(length == 18) {
            location = string(abi.encodePacked(uint144(num >> 56)));
        }
        else if(length == 19) {
            location = string(abi.encodePacked(uint152(num >> 56)));
        }
        else if(length == 20) {
            location = string(abi.encodePacked(uint160(num >> 56)));
        }
        else if(length == 21) {
            location = string(abi.encodePacked(uint168(num >> 56)));
        }
        else if(length == 22) {
            location = string(abi.encodePacked(uint176(num >> 56)));
        }
        else if(length == 23) {
            location = string(abi.encodePacked(uint184(num >> 56)));
        }
        else if(length == 24) {
            location = string(abi.encodePacked(uint192(num >> 56)));
        }
        else if(length == 25) {
            location = string(abi.encodePacked(uint200(num >> 56)));
        }

        
    }

    function getTime(uint timestamp) internal view returns(uint hour, uint minute, uint second) {
        uint secondsPerMinute = 60;
        uint secondsPerHour = secondsPerMinute*60;
        uint secondsPerDay = secondsPerHour*24;

        hour = ((timestamp % secondsPerDay) / secondsPerHour);
        minute = (timestamp % secondsPerHour) / secondsPerMinute;
        second =  (timestamp % secondsPerMinute);

    }




    function clock(bytes32 timeZoneOffset) public view returns (string memory, Attributes memory attributes) {
        // uint offsetHours = uint(uint8(uint(timeZoneOffset)));
        (uint offsetHours, uint negative, uint background, string memory location) = unPackSeed(uint(timeZoneOffset));

        uint256 timestamp = negative == 0 ? block.timestamp + (offsetHours * 1 hours) : block.timestamp - (offsetHours * 1 hours);

        
        (uint hour, uint minute, uint second) = getTime(timestamp);

        Element memory svg = createElement("svg");
        svg.setAttribute("xmlns", "http://www.w3.org/2000/svg");
        svg.setAttribute("viewBox", "0 0 1000 1000");
        // svg.setAttribute("height", "1000");
        // svg.appendChunk('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 1000" >');
        svg.appendChunk(string.concat('<text x="500" y="950" text-anchor="middle" font-size="60px">', location, "</text>"));

        svg.appendChunk(string.concat('<defs ><line id="hourMark" x1="500" x2="500" y1="110" y2="50" stroke="rgb(29, 29, 29)" stroke-width="8px" stroke-linecap="round" ></line> </defs> <use href="#hourMark" transform="rotate(0 500 450)" ></use> <use href="#hourMark" transform="rotate(30 500 450)" ></use> <use href="#hourMark" transform="rotate(60 500 450)" ></use> <use href="#hourMark" transform="rotate(90 500 450)" ></use> <use href="#hourMark" transform="rotate(120 500 450)" ></use> <use href="#hourMark" transform="rotate(150 500 450)" ></use> <use href="#hourMark" transform="rotate(180 500 450)" ></use> <use href="#hourMark" transform="rotate(210 500 450)" ></use> <use href="#hourMark" transform="rotate(240 500 450)" ></use> <use href="#hourMark" transform="rotate(270 500 450)" ></use> <use href="#hourMark" transform="rotate(300 500 450)" ></use> <use href="#hourMark" transform="rotate(330 500 450)" ></use>'));

        try IArt(msg.sender).getDataUri(background) returns (string memory result) {
            svg.appendChunk(string.concat('<image x="217" y="167" width="565" href="', result, '"></image>'));
        } catch {
            console.log("failed");

        }
        svg.appendChunk('<circle xmlns="http://www.w3.org/2000/svg" cx="500" cy="450" r="400" fill="none" stroke="rgb(29, 29, 29)" stroke-width="10px"/>');


        Element memory line = createElement("line");

        Element memory rotateAnimation = createElement("animateTransform");
        // minute hand
        line.setAttributeChunk('x1="500" y1="470" x2="500" y2="150" stroke="rgb(29, 29, 29)" stroke-width="6px" stroke-linecap="round" ');

        int256 angle = int256(6 * minute);

        angle = angle + ((int256(second) * 6) / 60);
        line.setAttribute("transform", utils.rotate(angle, 500, 450));

        rotateAnimation.setAttribute("attributeName", "transform");
        rotateAnimation.setAttribute("type", "rotate");
        rotateAnimation.setAttribute(
            "from",
            string(
                abi.encodePacked(utils._toString(uint256(angle)), " 500 450")
            )
        );
        rotateAnimation.setAttribute(
            "to",
            string(
                abi.encodePacked(
                    utils._toString(uint256(angle) + 360),
                    " 500 500"
                )
            )
        );

        rotateAnimation.setAttribute("dur", "3600s");
        rotateAnimation.setAttribute("repeatCount", "indefinite");
        line.appendChild(rotateAnimation);
        svg.appendChild(line); //appending clears the attributes and children of the child. does not clear name, so we can reuse it for the element of the same type

        // hour hand
        line.setAttributeChunk('x1="500" y1="470" x2="500" y2="220" stroke="rgb(29, 29, 29)" stroke-width="12px" stroke-linecap="round" ');
        angle = int256(30 * hour);
        angle = angle + ((int256(minute) * 30) / 60);

        line.setAttribute("transform", utils.rotate(angle, 500, 450));

        rotateAnimation.setAttribute("attributeName", "transform");
        rotateAnimation.setAttribute("type", "rotate");
        rotateAnimation.setAttribute(
            "from",
            string(
                abi.encodePacked(utils._toString(uint256(angle)), " 500 450")
            )
        );
        rotateAnimation.setAttribute(
            "to",
            string(
                abi.encodePacked(
                    utils._toString(uint256(angle) + 360),
                    " 500 450"
                )
            )
        );

        rotateAnimation.setAttribute("dur", "43200s");
        rotateAnimation.setAttribute("repeatCount", "indefinite");
        line.appendChild(rotateAnimation);

        svg.appendChild(line);

        // 
        // second hand
        line.setAttributeChunk('x1="500" y1="520" x2="500" y2="60" stroke="red" stroke-width="4px" stroke-linecap="round" ');
        line.setAttribute(
            "transform",
            utils.rotate(int256(6 * second), 500, 450)
        );

        rotateAnimation.setAttribute("attributeName", "transform");
        rotateAnimation.setAttribute("type", "rotate");
        rotateAnimation.setAttribute(
            "from",
            string(abi.encodePacked(utils._toString(6 * second), " 500 450"))
        );
        rotateAnimation.setAttribute(
            "to",
            string(
                abi.encodePacked(
                    utils._toString((6 * second) + 360),
                    " 500 450"
                )
            )
        );
        rotateAnimation.setAttribute("dur", "60s");
        rotateAnimation.setAttribute("repeatCount", "indefinite");
        line.appendChild(rotateAnimation);
        svg.appendChild(line);

        Element memory center = createElement("circle");
        center.setAttribute("cx", "500");
        center.setAttribute("cy", "450");
        center.setAttribute("r", "10");
        center.setAttribute("fill", utils.rgb(29, 29, 29));
        svg.appendChild(center);



        return (svg.draw(), attributes);
    }

}
