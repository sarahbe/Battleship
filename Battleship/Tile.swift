import SpriteKit


class Tile : Hashable{
    var column: Int
    var row: Int
    var sprite: SKSpriteNode?
    var isOpened:Bool
    var hasShip:Bool
    var isOccupied:Bool
    
    var hashValue: Int {
        return row*10 + column
    }
    
    
    init(column: Int, row: Int, isOpened:Bool, hasShip:Bool, isOccupied:Bool) {
        self.column = column
        self.row = row
        self.isOpened = isOpened
        self.hasShip=hasShip
        self.isOccupied = isOccupied
    }
    
    
}

func ==(lhs: Tile, rhs: Tile) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}