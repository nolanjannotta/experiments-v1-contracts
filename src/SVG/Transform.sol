pragma solidity ^0.8.13;


import {LibString} from "../Solady/LibString.sol";


function rotate(int256 angle, uint256 x, uint256 y) pure returns (string memory) {
    return string(
        abi.encodePacked(
            "rotate(",
            angle < 0 ? "-" : "",
            LibString.toString(uint256(angle < 0 ? angle * -1 : angle)),
            " ",
            LibString.toString(x),
            " ",
            LibString.toString(y),
            ") "
        )
    );
}

function translate(int x, int y) pure returns(string memory) {
    return string.concat(
        "translate(",
        LibString.toString(x),
        " ",
        LibString.toString(y),
        ")"
    );

}
// currently anything above 10 returns 1
function scale(int value) pure returns(string memory) {
    return string.concat("scale(", value < 10 ? string.concat(".", LibString.toString(value)) : "1" ,")");
}

function skewX(int256 a) pure returns (string memory) {
    return string.concat("skewX(", a < 0 ? "-" : "", LibString.toString(uint256(a < 0 ? a * -1 : a)), ") ");
}



function skewY(int256 a) pure returns (string memory) {
    return string.concat("skewY(", a < 0 ? "-" : "", LibString.toString(uint256(a < 0 ? a * -1 : a)), ") ");
}