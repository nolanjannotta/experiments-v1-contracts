pragma solidity ^0.8.13;

import "./utils.sol" as utils; // this lets us import utils from the SVG file
import "./Path.sol" as Path;
// import "./Rectangle.sol" as Rectangle;
import "./Polygon.sol" as Polygon;
import "./Colors.sol" as Colors;
import "./Transform.sol" as Transform;

import {Rectangle, Line, Point} from "./Rectangle.sol";


struct Element {
    string name;
    string attributes;
    string children;
}

function renderElement(Element memory self) pure returns (string memory) {
    if (bytes(self.name).length == 0) {
        return "";
    }

    return string.concat("<", self.name, " ", self.attributes, ">", self.children, "</", self.name, ">");
}

function appendChild(Element memory self, Element memory child) pure returns (Element memory) {
    self.children = string.concat(self.children, child.renderElement());
    child.clear();
    return self;
}

function appendChunk(Element memory self, string memory chunk) pure returns(Element memory) {
    self.children = string.concat(self.children, chunk);
}

// function createElement(Element memory self, string memory name) pure returns(Element memory) {
//     self.name = name;
//     return self;

// }

function createElement(string memory name) pure returns (Element memory element) {
    element.name = name;
    return element;
}

function setAttribute(Element memory self, string memory attribute, string memory value) pure returns (Element memory) {
    self.attributes = string.concat(self.attributes, attribute, '="', value, '" ');
    return self;
}

function setAttributeChunk(Element memory self, string memory newAttributes) pure returns(Element memory) {
    self.attributes = string.concat(self.attributes, newAttributes);
}

function clear(Element memory self) pure returns (Element memory) {
    // self.name = "";
    self.children = "";
    self.attributes = "";
    return self;
}

function draw(Element memory self) pure returns (string memory) {
    return renderElement(self);
}



using {setAttribute,setAttributeChunk, appendChild, clear, renderElement, draw, appendChunk} for Element global;
