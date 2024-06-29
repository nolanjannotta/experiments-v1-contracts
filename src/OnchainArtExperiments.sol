pragma solidity ^0.8.13;


import {ERC721} from "./Solady/ERC721.sol";
import {Edition} from "./structs.sol";
import {ArtBase} from "./ArtBase.sol";
import {ISignature,IPaymentSplitter} from "./interfaces.sol";
import {LibString} from "./Solady/LibString.sol";
import {PaymentSplitter} from "openzeppelin-contracts/contracts/finance/PaymentSplitter.sol";

contract OnchainArtExperiments is ArtBase, ERC721 {

    mapping(uint => Edition) private editions;
    mapping(uint => bytes32) private idToSeed;

    address public OWNER;
    uint public EDITION_COUNTER;
    uint public PLATFORM_FEE = 5; // 5% of mint price
    uint public PLATFORM_ROYALTY = 10; // 10% of artist defined royalty
    
    modifier onlyOwner {
        if(msg.sender != OWNER) revert NotOwner();
        _;

    }

    modifier onlyArtist(uint editionId) {
        if(msg.sender != editions[editionId].artistAddress) revert NotArtist();
        _;

    }

    


    constructor()  {
        OWNER = msg.sender;
    }



    function name() public view override returns (string memory){
        return "Onchain-Experiments_V1";
    }

    function symbol() public view override returns (string memory) {
        return "O-E_V1";
    }

    function getMetadata(Edition memory edition, uint tokenId) internal view returns(string memory signature, string memory metadata) {
        // if signatureId is of the signature edition and is currently owned by the edition artist
        if(edition.signatureId/1_000_000 == 1 && _exists(edition.signatureId) && ownerOf(edition.signatureId) == edition.artistAddress){
            // try to get signature translate values if artGenerator supports it
            try edition.artGenerator.getSignatureTranslate(idToSeed[tokenId]) returns (int _translateX, int _translateY) {
                // ASSUMES SIGNATURES IS EDITION #1
                signature = ISignature(address(editions[1].artGenerator)).getPlainSignature(idToSeed[edition.signatureId], _translateX, _translateY);

            } catch {
                // if it does not support it, put signature at default coordinates
                signature = ISignature(address(editions[1].artGenerator)).getPlainSignature(idToSeed[edition.signatureId], 900, 925);
            }
        }
        metadata = string.concat('<title>', edition.name, ' #', LibString.toString(tokenId % 1_000_000),'</title><desc>art by ',bytes(edition.artistName).length == 0 ? LibString.toHexString(edition.artistAddress) : edition.artistName, '</desc>');
    }

    function getRawSvg(uint tokenId) external view returns(string memory) {
        if(!_exists(tokenId)) revert TokenDoesNotExist();
        Edition memory edition = editions[tokenId / 1_000_000];
        (string memory signature, string memory metadata) = getMetadata(edition, tokenId);
        string memory svg = edition.artGenerator.getRawSvg(idToSeed[tokenId]);
        return string.concat('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 1000" height="100%" width="100%">',metadata, svg, signature, '</svg>');
    }

    function getDataUri(uint tokenId) external view returns(string memory) {
        return generateDataURI(this.getRawSvg(tokenId));
    }

    function getEdition(uint edition) external view returns(Edition memory) {
        return editions[edition];
    }
 

    function modify(uint tokenId, bytes calldata data) external {
        if(msg.sender != ownerOf(tokenId)) revert NotOwner();
        idToSeed[tokenId] = editions[tokenId / 1_000_000].artGenerator.modify(tokenId, data);
    }


    function exists(uint tokenId) external view returns(bool) {
        return _exists(tokenId);
    }

    
    function tokenURI(uint tokenId) public view override returns (string memory) {
        if(!_exists(tokenId)) revert TokenDoesNotExist();
        Edition memory edition = editions[tokenId / 1_000_000];
        
        (string memory svg, string memory attributes) = edition.artGenerator.getRawSvgAndAttributes(idToSeed[tokenId]);


        (string memory signature, string memory metadata) = getMetadata(edition, tokenId);
        
        svg = string.concat('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 1000" height="100%" width="100%">',metadata, svg, signature, '</svg>');


        return generateTokenURI(edition.name, edition.artistName, edition.artistAddress, edition.description, svg, tokenId, attributes);
    }

    function getSeed(uint id) external view returns(bytes32) {
        return idToSeed[id];
    }

    // converts the packed bytes32 seed to an unpacked bytes array so we can abi.decode it off chain or in other contracts
    function unPackSeed(uint tokenId) external view returns(bytes memory) {
        return editions[tokenId / 1_000_000].artGenerator.unPackSeed(abi.encode(idToSeed[tokenId]));
    }

    ///////////////////////// artist controls: /////////////////////////

    function setMintStatus(uint edition, bool status) external onlyArtist(edition) {
        editions[edition].mintStatus = status;
    }

    function deleteEdition(uint edition) external onlyArtist(edition) {
        if(editions[edition].counter > 0) revert EditionHasMintedTokens();
        delete editions[edition];
    }
    function setRoyalty(uint edition, uint basisPoints) external onlyArtist(edition) {
        editions[edition].royalty = basisPoints;
    }

    function artistMint(uint edition) external onlyArtist(edition) returns (uint){
        return _baseMint(edition, msg.sender);
    }
    function setPrice(uint edition, uint price) external onlyArtist(edition) {
        editions[edition].price = price;
    }
    function setSignatureId(uint edition, uint id) external onlyArtist(edition)  {
        editions[edition].signatureId = id;
    }
    
    ///////////////////////////////////////////////////////////////////





    //////////////////////////owner controls///////////////////////////

    function changeOwner(address newOwner) external onlyOwner {
        OWNER = newOwner;
    }

    function setPlatformFee(uint fee) external onlyOwner {
        PLATFORM_FEE = fee;
    }
    // only affects edition deployed after this is set
    function setPlatformRoyalty(uint royalty) external onlyOwner {
        PLATFORM_ROYALTY = royalty;
    }
    function releasePlatformRoyalty(uint edition) external onlyOwner {
        IPaymentSplitter(editions[edition].royaltyReceiver).release(payable(address(this)));
    }
        
    function createNewEdition(string memory name, string memory description, uint supply, address artGenerator, address artistAddress, string memory artistName) external onlyOwner returns(uint) {

        address[] memory payees = new address[](2);
        payees[0] = artistAddress;
        payees[1] = address(this);
        uint[] memory shares = new uint[](2);
        shares[0] = 100 - PLATFORM_ROYALTY;
        shares[1] = PLATFORM_ROYALTY;
        address paymentSplitter = address(new PaymentSplitter(payees, shares));


        EDITION_COUNTER++;
        editions[EDITION_COUNTER] = _createEdition(name, description, supply, artGenerator, artistAddress, artistName, paymentSplitter);

        return EDITION_COUNTER;
    }
    
    function withdraw() external onlyOwner {
        OWNER.call{value: address(this).balance}("");
    }


    //////////////////////////////////////////////////////////////////
    




    




    function royaltyInfo(uint tokenId, uint salePrice) external view returns (address receiver, uint royaltyAmount) {
        Edition memory edition = editions[tokenId / 1_000_000];
        return (edition.royaltyReceiver, (salePrice * edition.royalty) / 10_000);

    }



    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == this.royaltyInfo.selector || super.supportsInterface(interfaceId);
    }


    function _baseMint(uint editionId, address to) private returns (uint) {
       Edition storage edition = editions[editionId];
        if(++edition.counter > edition.supply) revert MaxSupplyReached(); 
        uint id = (editionId * 1_000_000) + edition.counter;
        idToSeed[id] = edition.artGenerator.createSeed(id, to);
        _safeMint(to, id); 
        return id;
    } 


    // mints next token id for 'edition'
    function mint(uint editionId) external payable returns (uint) {
        Edition memory edition = editions[editionId];
        if(!edition.mintStatus) revert NotMintable();
        if(msg.value != edition.price) revert IncorrectPrice();
        // opting to directly transfer the funds to the artist in 
        // the mint function for simplicity
        if(msg.value > 0) {
            uint platformFee = (msg.value * PLATFORM_FEE) / 100;
            payable(edition.artistAddress).call{value: msg.value - platformFee}("");
        }

        return _baseMint(editionId, msg.sender);

    }

    // can be used in a warpcast frame where I pay the gas for the user
    function mintTo(uint editionId, address to) external payable returns (uint){
        Edition memory edition = editions[editionId];
        if(!edition.mintStatus) revert NotMintable();
        if(msg.value != edition.price) revert IncorrectPrice();
        if(msg.value > 0) {
            uint platformFee = (msg.value * PLATFORM_FEE) / 100;
            payable(address(this)).call{value: platformFee}("");
            payable(edition.artistAddress).call{value: msg.value - platformFee}("");
        }
        
        return _baseMint(editionId, to);
    }


    

    function tokensOfOwner(address owner) public view returns(uint[] memory) {
        uint balance = balanceOf(owner);

        uint[] memory result = new uint[](balance);
        uint index;
        for (uint i = 1; i <=EDITION_COUNTER; i++) {
            for(uint j=1; j<=editions[i].counter; j++) {
                uint tokenId = (i * 1_000_000) + j;
                if(_exists(tokenId) && ownerOf(tokenId) == owner) {
                    
                    result[index++] = tokenId;
                }
            }
                
        }
        return result;
    }



    function burn(uint tokenId) external {
        _burn(msg.sender, tokenId);
    }

}