pragma solidity ^0.8.13;

import {Base64} from "./Solady/Base64.sol";
import {LibString} from "./Solady/LibString.sol";
import {Edition} from "./structs.sol";



interface IPaymentSplitter {
    function release(address payable account) external;
}

interface ISignature {
    function getPlainSignature(bytes32,int256,int256) external view returns(string memory);
}

interface IArtGenerator {


    function getRawSvg(bytes32 seed) external view returns(string memory);
    function getRawSvgAndAttributes(bytes32 seed) external view returns(string memory, string memory);
    function modify(uint tokenId, bytes memory data) external view returns (bytes32);
    function unPackSeed(bytes calldata seed) external pure returns(bytes memory);
    function createSeed(uint tokenId, address minter) external view returns(bytes32);
    // function dimensions(bytes32 seed) external view returns(uint,uint);
    function getSignatureTranslate(bytes32 seed) external view returns(int, int);

}


interface IArt {

    function getRawSvg(uint id) external view returns (string memory);
    function getDataUri(uint id) external view returns (string memory);
    function dimensionsOfId(uint id) external view returns (uint,uint);
    function getEdition(uint id) external view returns (Edition memory);
    function modify(uint id, bytes calldata data) external;
    function getSeed(uint id) external view returns (bytes32);
    function unPackSeed(uint id) external view returns (bytes memory);

    function updateSeed(uint tokenId) external;
    function ownerOf(uint tokenId) external view returns(address);
    function exists(uint tokenId) external view returns(bool);
    function getSignature(int translateX, int translateY) external view returns(string memory);
    
}



