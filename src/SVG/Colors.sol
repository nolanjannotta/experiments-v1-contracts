pragma solidity ^0.8.13;


import {LibString} from "../Solady/LibString.sol";

function rgb(uint r, uint g, uint b) pure returns (string memory) {
    return string.concat(
        "rgb(", 
        LibString.toString(r), 
        ", ", 
        LibString.toString(g), 
        ", ", 
        LibString.toString(b),
        ")"
        );
}
function rgba(uint8 r, uint8 g, uint8 b, uint8 a) pure returns (string memory) {
    return string.concat(
        "rgba(", 
        LibString.toString(uint(r)), 
        ", ", 
        LibString.toString(uint(g)), 
        ", ", 
        LibString.toString(uint(b)), 
        ", ",  
        a < 10 ? "." : "", 
        LibString.toString(a == 10 ? 1 : uint(a)),
        ")"
        
        );
}

function hsl(string memory h, uint s, uint l) pure returns (string memory) {
    return string.concat(
        "hsl(", 
        h, 
        ", ", 
        LibString.toString(s), 
        "%, ", 
        LibString.toString(l), 
        "%)"
        );
}
