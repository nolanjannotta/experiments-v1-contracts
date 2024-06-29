pragma solidity ^0.8.13;

import {Element} from "./SVG.sol";
import {toString} from "./utils.sol";


struct Points {
    string data;
}

function addPointStr(Points memory points, string memory x, string memory y) pure returns (Points memory) {
    points.data = string.concat(points.data, x, ",", y, " ");
    return points;
}

function addPoint(Points memory points, int x, int y) pure returns (Points memory) {
    points.data = string.concat(points.data, toString(x), ",", toString(y), " ");
    return points;
}



using {addPoint, addPointStr} for Points global;
