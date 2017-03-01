import SpriteKit

class GameScene: SKScene {
    //one way to communicate with GameViewController is by delegate. but since this is the only message we will use closure
    var openHandler: ((OpenTile) -> ())?
    
    var level: Level!
    var player:String? = UIDevice.currentDevice().name
    var currentPlayer:String? //= UIDevice.currentDevice().name
    
    let TileWidth: CGFloat = 32.0
    let TileHeight: CGFloat = 36.0
    
    let gameLayer = SKNode()
    let squareLayer = SKNode()
    let shipLayer = SKNode()
    
    var componentScore = SKLabelNode()
    var myScore = SKLabelNode()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    //Gamescene Intilaizer
    override init(size: CGSize) {
        super.init(size: size)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let background = SKSpriteNode(imageNamed: "Background-2")
        background.size = self.frame.size;
        background.zPosition = 0
        
        addChild(background)
        
        addChild(gameLayer)
        //To start the board from the bottom left corner
        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 2)
        addLabels()
        squareLayer.position = layerPosition
        shipLayer.position = layerPosition
        gameLayer.addChild(squareLayer)
        gameLayer.addChild(shipLayer)
    }
    
    func addLabels(){
        
        
        let myScoreLabel = SKLabelNode(text: "You")
        myScoreLabel.zPosition = 1
        myScoreLabel.position  = CGPoint(
            x: (-TileWidth * CGFloat(NumColumns) / 2 ) + 50 ,
            y: (-TileHeight * CGFloat(NumRows) / 2 ) - 75)
        addChild(myScoreLabel)
        
        
        let componentScoreLabel = SKLabelNode(text: "Opponent")
        componentScoreLabel.zPosition = 1
        componentScoreLabel.position  = CGPoint(
            x: (-TileWidth * CGFloat(NumColumns) / 2 ) + 105 ,
            y: (-TileHeight * CGFloat(NumRows) / 2 ) - 125)
        addChild(componentScoreLabel)
        
        myScore = SKLabelNode(text: "0")
        myScore.zPosition = 1
        myScore.position  = CGPoint(
            x: (-TileWidth * CGFloat(NumColumns) / 2 ) + 210 ,
            y: (-TileHeight * CGFloat(NumRows) / 2 ) - 75)
        addChild(myScore)
        
        componentScore = SKLabelNode(text: "0")
        componentScore.zPosition = 1
        componentScore.position  = CGPoint(
            x: (-TileWidth * CGFloat(NumColumns) / 2 ) + 210 ,
            y: (-TileHeight * CGFloat(NumRows) / 2 ) - 125)
        addChild(componentScore)
        
        
    }
    
    //Add sprite (tile imaage) for each square
    func addSpritesForSquare(tiles: Set<Tile>, hasStarted:Bool? = false) {
        for tile in tiles{
            var sprite = SKSpriteNode()
            sprite = SKSpriteNode(imageNamed: "Tile")
            //This is only for test to see if the ships are shown
            
            if tile.hasShip {
                if hasStarted == false {
                    sprite = SKSpriteNode(imageNamed: "ship")
                    sprite.size = CGSize(width: TileWidth, height: TileHeight)
                }
            }
            else if tile.isOccupied {
            }
            sprite.position = pointForColumn(tile.column, row:tile.row)
            squareLayer.addChild(sprite)
            tile.sprite = sprite
        }
    }
    
    func removeAllSprites ()
    {
        squareLayer.removeAllChildren()
    }
    
    func addSpritesForShips(ships: Set<Ship>)
    {
        for ship in ships{
            for i in 0..<ship.size {
                let sprite = SKSpriteNode()
                //   sprite = SKSpriteNode(color: UIColor.greenColor(), size: CGSize(width: TileWidth, height: TileHeight))
                if ship.isVertical {
                    sprite.position = pointForColumn(ship.column, row: ship.row+i)
                }else {
                    sprite.position = pointForColumn(ship.column+i, row: ship.row)
                }
                
                shipLayer.addChild(sprite)
                ship.sprite = sprite
            }
            
        }
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if player == currentPlayer
        {
            let touch = touches.first!
            let location = touch.locationInNode(squareLayer)
            let (success, column, row) = convertPoint(location)
            //if we click inside the grid
            if success {
                if let tile = level.tileAtColumn(column, row: row) {
                    if tile.isOpened == false
                    {
                        tile.isOpened = true
                        
                        if let handler = openHandler {
                            let open = OpenTile(tile: tile)
                            handler(open)
                        } //end if handler
                    }//end tile.isopened
                    print("You hit square \(column) , \(row), is occupied \(tile.isOccupied) ")
                }//end tile.isopened
            }//end  tileAtColumn
            
        }
        
    }
    
    
    //we pass the value of column and row, and returns CGPoint to draw the tile
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*TileWidth + TileWidth/2,
            y: CGFloat(row)*TileHeight + TileHeight/2)
    }
    
    
    //This method takes a CGPoint that is relative to the squareLayer and converts it into column and row numbers. The return value of this method is a tuple with three values: 1) the boolean that indicates success or failure; 2) the column number; and 3) the row number. If the point falls outside the grid, this method returns false for success.
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth &&
            point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight {
                return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
    
    func animateOpen(openTile: OpenTile, completion: () -> ()) {
        
        var spriteA = openTile.tile.sprite!
        let Duration: NSTimeInterval = 0.3
        var openA = SKAction()
        if openTile.tile.hasShip
        {
            //openA = SKAction.colorizeWithColor(UIColor.blueColor(), colorBlendFactor: 1, duration: Duration)
            openA = SKAction.setTexture(SKTexture(imageNamed: "ship"))
        }else
        {
            //openA = SKAction.colorizeWithColor(UIColor.redColor(), colorBlendFactor: 1, duration: Duration)
            
            openA = SKAction.setTexture(SKTexture(imageNamed: "explosion"))
        }
        
        spriteA.runAction(openA, completion: completion)
        
    }
    
    
}