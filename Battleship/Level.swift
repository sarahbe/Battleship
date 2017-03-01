import Foundation
//Those are defined as global variables so we can reach them from all the files
let NumColumns = 8
let NumRows = 8

class Level {
    //array of all tiles in the grid
    private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    
    private var ships = Array2D<Ship>(columns: NumColumns, rows: NumRows)
    
    //we give the specified row and column and it returns the tile object inside it
    func tileAtColumn(column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
    
    func shipAtColumn(column: Int, row: Int) -> Ship?{
        return ships[column,row]
    }
    
    func shuffle() -> Set<Tile> {
        return createInitialTiles()
    }
    
    func shuffleShips() ->Set<Ship>
    {
        return createIntialShips()
    }
    
    func receiveBoard(boardArray:[Int]) ->Set<Tile>
    {
        var set = Set<Tile>()
        for i in 0..<64 {
            let hasShip = boardArray[i] == 1
            let column = i%8
            let row = i/8
            let tile = Tile(column: column, row: row, isOpened: false,hasShip:hasShip , isOccupied: false )
            set.insert(tile)
            tiles[column, row] = tile
        }
        return set
    }
    
    //create the initial value of our ships and tiles
    private func createInitialTiles() -> Set<Tile> {
        var set = Set<Tile>()
        for row in 0..<NumRows {
            
            for column in 0..<NumColumns {
                let tile = Tile(column: column, row: row, isOpened: false,hasShip:false , isOccupied: false )
                tiles[column, row] = tile
                set.insert(tile)
            }
        }
        return set
    }
    
    private func createIntialShips() -> Set<Ship>{
        var set = Set<Ship>()
        let fleet:[Int] = [4,4,3,3,2,2]
        //TO DO: if not available reset
        for size in fleet {
            let ship = getAvailableShip(size)
            set.insert(ship)
        }
        return set
        
    }
    
    private func getAvailableShip(size:Int) -> Ship
    {
        var isValid:Bool = false
        var column:Int = 0
        var row:Int = 0
        var isVertical:Bool = true
        var ship = Ship(column: column, row: row, size: size, isVertical: isVertical)
        var i:Int = 0
        while !isValid{
            i++
            (column, row, isVertical) = randomShipLocation()
            isValid = isValidPlacemnet(column, row:row,size:size, isVertical:isVertical)
            if i >= 200 {
            break
            }
        }
        if isValid {
            ship =  createShip(column, row:row,size:size,isVertical:isVertical)
        }
        return ship
    }
    
    
    private func createShip(column:Int, row:Int, size:Int, isVertical:Bool) -> Ship
    {
        let newShip = Ship(column:column,row: row,size: size, isVertical: isVertical)
        tagTileswithShip(column,row: row,size: size, isVertical: isVertical)
        return newShip
    }
    
    private func tagTileswithShip(column:Int, row:Int, size:Int, isVertical:Bool){
        for i in 0..<size {
            if isVertical{
                let tile = tileAtColumn(column, row: row+i)
                tile!.hasShip = true
                surroundingCells(column, row: row+i)
            }else{
                let tile = tileAtColumn(column+i, row: row)
                tile!.hasShip = true
                surroundingCells(column+i, row: row)
            }
            
        }
    }
    private func surroundingCells(column:Int, row:Int)
    {
        for x in 0..<3
        {
            for y in 0..<3
            {
                let vCell = abs(column - 1 + y)
                let hCell = abs(row - 1 + x)
                if (vCell<8 && hCell<8)
                {
                    let surroundTile = tileAtColumn(vCell, row: hCell)
                    surroundTile!.isOccupied = true
                }
            }
        }
    }
    
    private func isValidPlacemnet(column:Int, row:Int, size:Int, isVertical:Bool) -> Bool{
        if isVertical {
            if row + size > NumColumns-1 {
                return false
            }
        }
        else
        {
            if column + size > NumRows-1 {
                return false
            }
        }
        
        for i in 0..<size {
            if isVertical{
                let tile = tileAtColumn(column, row: row+i)
                
                if tile!.hasShip || tile!.isOccupied {
                    return false
                }
            }else{
                let  tile = tileAtColumn(column+i, row: row)
                if tile!.hasShip || tile!.isOccupied  {
                    return false
                }
            }
        }
        return true
    }
    
    private func randomShipLocation() -> (column:Int, row:Int, isVertical:Bool )
    {
        let randomColumn = Int(arc4random_uniform(8))
        let randomRow = Int(arc4random_uniform(8))
        let randomDirection = Int(arc4random_uniform(2))
        return (randomColumn, randomRow, randomDirection == 1)
    }
    
    func performOpen(open: OpenTile) {
        let columnA = open.tile.column
        let rowA = open.tile.row
        tiles[columnA,rowA] = open.tile
    }
}