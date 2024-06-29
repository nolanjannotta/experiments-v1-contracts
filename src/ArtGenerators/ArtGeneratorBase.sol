pragma solidity ^0.8.13;

import {IArtGenerator} from "../interfaces.sol";
import {Element, createElement} from "../SVG/SVG.sol";




abstract contract ArtGeneratorBase is IArtGenerator {

    error NotModifiable();

    
    function createSeed(uint tokenId, address minter) public virtual view override returns(bytes32) {
        return keccak256(abi.encode(tokenId, minter, block.timestamp));
    }
    function modify(uint tokenId, bytes memory data) public virtual view override returns(bytes32) {
        revert NotModifiable();
    }

    function getSignatureTranslate(bytes32 seed) external virtual view returns(int, int) {
        seed;
        revert();
    }

    function unPackSeed(bytes calldata seed) external virtual pure override returns(bytes memory unPackedSeed) {
        return seed;
    }

    function startSvg() internal pure returns(Element memory svg) {
        svg = createElement("svg");
        svg.setAttributeChunk('xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 1000" height="1000" width="1000"');
    }


}


