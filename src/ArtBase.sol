pragma solidity ^0.8.13;

import {Base64} from "./Solady/Base64.sol";
import {LibString} from "./Solady/LibString.sol";
import {Attributes, Edition} from "./structs.sol";
import {IArtGenerator} from "./interfaces.sol";

abstract contract ArtBase {

    error NotOwner();
    error MaxSupplyReached();
    error NotMintable();
    error IncorrectPrice();
    error EditionHasMintedTokens();
    error NotArtist();
    error PlatformNotActive();
    
    function _createEdition(string memory name, string memory description, uint supply, address artGenerator, address artist, string memory artistName, address paymentSplitter) internal pure returns(Edition memory edition) {
        edition.name = name;
        edition.description = description;
        edition.supply = supply;
        edition.artGenerator = IArtGenerator(artGenerator);
        edition.royaltyReceiver = paymentSplitter;
        edition.artistAddress = artist;
        edition.artistName = artistName;
    }



    function generateDataURI(string memory rawSvg) internal pure returns(string memory) {
        return string.concat("data:image/svg+xml;base64,", Base64.encode(bytes(rawSvg)));
    }


    
    function generateTokenURI(string memory name, string memory artistName, address artistAddress, string memory description, string memory svg, uint tokenId, string memory attributes) internal pure returns(string memory) {
        return string.concat(
            "data:application/json;base64,",

                Base64.encode(
                    abi.encodePacked(
                        '{"name": "', 
                        name,
                        " #",
                        LibString.toString(tokenId % 1_000_000),
                        '", "description": "',
                        description,
                        '", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(svg)),
                        '", "artist": "',
                        bytes(artistName).length == 0 ? LibString.toHexString(artistAddress) : artistName,
                        '", "attributes": ', 
                        attributes,
                        '}')
                    )
                );


    }

    

    receive() external payable {}


}
