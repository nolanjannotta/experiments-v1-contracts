pragma solidity ^0.8.13;

import {IArtGenerator} from "./interfaces.sol";


    struct Attributes {
        string attributes;
    }

    function add(Attributes memory self, string memory key, string memory value) pure returns(Attributes memory) {
        
        self.attributes = string.concat(self.attributes, bytes(self.attributes).length == 0 ?  '{"trait_type": "' : ',{"trait_type": "', key, '", "value":"', value, '"}');
        return self;

    }

    function json(Attributes memory self) pure returns(string memory tokenAttributes) {
        return string.concat("[",self.attributes, "]");
    }


    using{add,json} for Attributes global;


    struct Edition {
        string name;
        string description;
        string artistName;
        uint supply;
        uint counter;
        uint royalty;
        uint price;
        uint signatureId;
        bool mintStatus;
        IArtGenerator artGenerator;
        address royaltyReceiver;
        address artistAddress;
        


    }