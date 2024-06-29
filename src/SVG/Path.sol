pragma solidity ^0.8.13;

import {Element} from "./SVG.sol";
import {toString} from "./utils.sol";
import {LibString} from "../Solady/LibString.sol";


// type Data is string;



struct D {
    string data;
}

using {M,L,C,S,s} for D global;


// move to
function M(D memory d, int x, int y) pure returns(D memory) {
    d.data = string.concat(d.data, "M", toString(x), " ", toString(y));
    return d;
}

function L(D memory d, int newX, int newY) pure returns (D memory) {
    d.data = string.concat(d.data, "L", toString(newX), " ", toString(newY));
    return d;
}

// S x2 y2, x y
function S(D memory d, int x2, int y2, int x, int y) pure returns (D memory) {
    d.data = string.concat(
        d.data, 
        "S", 
        toString(x2), 
        " ", 
        toString(y2),
        ", ", 
        toString(x),
        " ", 
        toString(y)
        
        
        );
    return d;
}
function s(D memory d, int x2, int y2, int x, int y) pure returns (D memory) {
    d.data = string.concat(
        d.data, 
        "s", 
        toString(x2), 
        " ", 
        toString(y2),
        ", ", 
        toString(x),
        " ", 
        toString(y)
        
        
        );
    return d;
}



// bezier curve
function C(D memory d, int startControlX, int startControlY, int endControlX, int endControlY, int newX, int newY) pure returns(D memory) {
    d.data = string.concat(
        d.data, "C", 
        toString(startControlX), 
        " ", 
        toString(startControlY),
        ", ",
        toString(endControlX), 
        " ", 
        toString(endControlY),
        ", ",
        toString(newX), 
        " ", 
        toString(newY)
        );

        return d;
}



