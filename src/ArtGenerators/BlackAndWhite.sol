pragma solidity ^0.8.13;

import {IArt} from "../interfaces.sol";
import {Attributes} from "../structs.sol";
import {LibString} from "../Solady/LibString.sol";

contract BlackAndWhite {

    constructor(){
        

    }

     function getRawSvg(bytes32 seed) external view returns(string memory svg) {
        (svg,) = blackAndWhite(seed);

    }

    function getRawSvgAndAttributes(bytes32 seed) external view returns(string memory, string memory) {
        (string memory svg, Attributes memory attributes) = blackAndWhite(seed);
        return (svg, attributes.json());
    }

    function modify(uint tokenId, bytes memory data) external view returns(bytes32) {
        uint targetId = abi.decode(data, (uint));

        // this causes endless recursion and will fail
        if(tokenId == targetId) {
            revert("can't point to itself");
        }

        return bytes32(abi.encodePacked(uint32(tokenId), uint32(targetId)));

    }

    function unPackSeed(bytes calldata seed) external pure returns(bytes memory unPackedSeed) {
        uint32 self = uint32(bytes4(seed[:4]));
        uint32 target = uint32(bytes4(seed[4:8]));
        return abi.encode(self, target);

    }

    function createSeed(uint tokenId, address minter) external view returns(bytes32) {
        minter;
        return bytes32(abi.encodePacked(uint32(tokenId),uint32(0)));
    }

    function blackAndWhite(bytes32 seed) internal view returns(string memory, Attributes memory attributes) {
        uint _seed = uint(seed);


        IArt art = IArt(msg.sender);

        (uint32 selfId, uint32 targetId) = abi.decode(this.unPackSeed(abi.encode(_seed)), (uint32, uint32));
        string memory svg;

        if(art.exists(targetId) && art.ownerOf(selfId) == art.ownerOf(targetId)) {
            attributes.add("display", string.concat(art.getEdition(targetId/1_000_000).name, " #", LibString.toString(targetId % 1_000_000)));
            svg = art.getRawSvg(targetId);
        }


        string memory svgStart = '<defs> <filter id="bw"> <feColorMatrix in="SourceGraphic" type="saturate" values="0"/> </filter> </defs> <g width="100%" filter="url(#bw)">';

        return (string.concat(svgStart, svg, '</g>'), attributes);
    }




}