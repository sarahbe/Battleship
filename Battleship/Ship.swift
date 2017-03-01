import SpriteKit

class Ship: Hashable {
    var column:Int
    var row:Int
    var isVertical:Bool
    var size:Int
    var sprite: SKSpriteNode!
    
    
    var hashValue: Int {
        return row*10 + column
    }
    
    init(column:Int , row:Int, size: Int, isVertical:Bool)
    {
        self.column = column
        self.row = row
        self.size = size
        self.isVertical = isVertical
    }

}

func ==(lhs: Ship, rhs: Ship) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}