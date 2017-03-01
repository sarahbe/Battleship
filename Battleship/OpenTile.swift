//This is a new object type to tell that the playes wants to open a tile
struct OpenTile: CustomStringConvertible {
    let tile: Tile
    init(tile: Tile) {
        self.tile = tile
    }
    
    var description: String {
        return "\(tile) is opened"
    }
}