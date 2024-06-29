pragma solidity ^0.8.13;

import {LibString} from "../Solady/LibString.sol";



function rotate(int256 angle, uint256 x, uint256 y) pure returns (string memory) {
    return string(
        abi.encodePacked(
            "rotate(",
            angle < 0 ? "-" : "",
            _toString(uint256(angle < 0 ? angle * -1 : angle)),
            " ",
            _toString(x),
            " ",
            _toString(y),
            ") "
        )
    );
}

function translate(int x, int y) pure returns(string memory) {
    return string.concat(
        "translate(",
        toString(x),
        " ",
        toString(y),
        ")"
    );

}

function skewX(int256 a) pure returns (string memory) {
    return string.concat("skewX(", a < 0 ? "-" : "", _toString(uint256(a < 0 ? a * -1 : a)), ") ");
}



function skewY(int256 a) pure returns (string memory) {
    return string.concat("skewY(", a < 0 ? "-" : "", _toString(uint256(a < 0 ? a * -1 : a)), ") ");
}

function rgb(uint256 r, uint256 g, uint256 b) pure returns (string memory) {
    return string.concat(
        "rgb(", 
        _toString(r), 
        ", ", 
        _toString(g), 
        ", ", 
        _toString(b),
        ")"
        );
}
function rgba(uint r, uint g, uint b, uint a) pure returns (string memory) {
    return string.concat(
        "rgba(", 
        _toString(r), 
        ", ", 
        _toString(g), 
        ", ", 
        _toString(b), 
        ", ",  
        a < 10 ? "." : "", 
        _toString(a == 10 ? 1 : a),
        ")"
        
        );
}

// function hsl(uint256 h, uint256 s, uint256 l) pure returns (string memory) {
//     return string.concat(
//         "hsl(", 
//         _toString(h), 
//         ", ", 
//         _toString(s), 
//         "%, ", 
//         _toString(l), 
//         "%)"
//         );
// }

function toString(int value) pure returns (string memory) {
    if(value < 0) {
        return string.concat("-", _toString(uint(value * -1)));
    }
    return _toString(uint(value));
}


// copied from erc721A
function _toString(uint256 value) pure returns (string memory str) {
    assembly {
        // The maximum value of a uint256 contains 78 digits (1 byte per digit), but
        // we allocate 0xa0 bytes to keep the free memory pointer 32-byte word aligned.
        // We will need 1 word for the trailing zeros padding, 1 word for the length,
        // and 3 words for a maximum of 78 digits. Total: 5 * 0x20 = 0xa0.
        let m := add(mload(0x40), 0xa0)
        // Update the free memory pointer to allocate.
        mstore(0x40, m)
        // Assign the `str` to the end.
        str := sub(m, 0x20)
        // Zeroize the slot after the string.
        mstore(str, 0)

        // Cache the end of the memory to calculate the length later.
        let end := str

        // We write the string from rightmost digit to leftmost digit.
        // The following is essentially a do-while loop that also handles the zero case.
        // prettier-ignore
        for { let temp := value } 1 {} {
            str := sub(str, 1)
            // Write the character to the pointer.
            // The ASCII index of the '0' character is 48.
            mstore8(str, add(48, mod(temp, 10)))
            // Keep dividing `temp` until zero.
            temp := div(temp, 10)
            // prettier-ignore
            if iszero(temp) { break }
        }

        let length := sub(end, str)
        // Move the pointer 32 bytes leftwards to make room for the length.
        str := sub(str, 0x20)
        // Store the length.
        mstore(str, length)
    }
}

// copied from uniswap v2 i think
function sqrt(uint y) pure returns (uint z) {
    if (y > 3) {
        z = y;
        uint x = y / 2 + 1;
        while (x < z) {
            z = x;
            x = (y / x + x) / 2;
        }
    } else if (y != 0) {
        z = 1;
    }
}
