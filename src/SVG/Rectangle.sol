pragma solidity ^0.8.13;



// handles the <rect> element


struct Point {
    uint x;
    uint y;
}

struct Line {
    Point A;
    Point B;
}
struct Rectangle {
    Point[] points;
}

// function addPoint(Rectangle memory self, uint x, uint y) pure returns(Rectangle memory) {
//     self.points.push(Point(x,y));
// }

function addPoints(Rectangle memory self, uint[] memory _points) pure returns(Rectangle memory) {
    Point[] memory points = new Point[](4);
    for(uint i=0; i<8; i+=2) {
        
        points[i/2] = Point(_points[i], _points[i+1]);
    }
    self.points = points;   
    return self;

}
function addLine(Line memory self, uint x1, uint x2, uint y1, uint y2) pure returns(Line memory) {
    self.A.x = x1;
    self.A.y = y1;
    self.B.x = x2;
    self.B.y = y2;

}


function side(Rectangle memory self, uint side) pure returns(Line memory line) {
    
    line.A = self.points[side%4];
    line.B = self.points[(side+1)%4];


}






using{side, addPoints} for Rectangle global;
using {addLine} for Line global;