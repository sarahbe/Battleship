import UIKit
import SpriteKit
import MultipeerConnectivity



class GameViewController: UIViewController,MCBrowserViewControllerDelegate  {
    var scene: GameScene!
    var level: Level!
    var appDelegate:AppDelegate!
    var newTiles:Set<Tile> = []
    var newShips:Set<Ship> = []
    var componentBoard:[Int] = []
    var isISentBoard = false
    var myScoreCounter:Int = 0
    var OpponentScore:Int = 0
    //  var currentPlayer:String!
    
    @IBAction func connectButton(sender: AnyObject) {
        
        if appDelegate.mpcHandler.session != nil{
            appDelegate.mpcHandler.setupBrowser()
            appDelegate.mpcHandler.browser.delegate = self
            scene.currentPlayer = UIDevice.currentDevice().name
            self.presentViewController(appDelegate.mpcHandler.browser, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func shuffleButton(sender: UIBarButtonItem) {
        scene.removeAllSprites()
        shuffle()
    }
    
    @IBAction func startButton(sender: UIBarButtonItem) {
        restartGame()
        isISentBoard = true
        sendMyBoard()
    }
    
    func restartGame(isRestart:Bool? = false){
        if isRestart == true{
        scene.removeAllSprites()
        shuffle()
        }
        scene.currentPlayer = UIDevice.currentDevice().name
        myScoreCounter = 0
        OpponentScore = 0
        scene.componentScore.text = String(OpponentScore)
        scene.myScore.text = String(myScoreCounter)

    }
    
    func getTileArray() -> Array<Int>
    {
        var result:[Int] = []
        
        for row in 0..<8 {
            for column in 0..<8{
                
                let tile = level.tileAtColumn(column, row: row)
                if tile!.hasShip {
                    result.append(1)
                }else
                {
                    result.append(0)
                }
                
            }
            
        }
        
        
        
        
        /*
        
        for  tile in newTiles
        {
        if tile.hasShip {
        result.append(1)
        }else
        {
        result.append(0)
        }
        }
        */
        return result
    }
    
    func sendMyBoard(){
        var tileArray = getTileArray()
        var dictData:[String:Array] = ["board":tileArray]
        do{
            let messageData = try NSJSONSerialization.dataWithJSONObject(dictData, options: .PrettyPrinted)
            try appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
        }catch{
            print(error)
        }
        
    }
    
    func peerChangedStateWithNotification(notification:NSNotification){
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        
        let state = userInfo.objectForKey("state") as! Int
        
        if state != MCSessionState.Connecting.rawValue{
            self.navigationItem.title = "Connected"
        }
        
    }
    
    
    func handleReceivedDataWithNotification(notification:NSNotification){
        // Get the user info dictionary that was received along with the notification.
        var userInfoDict = notification.userInfo! as Dictionary
        let data = userInfoDict["data"] as! NSData
        do{
            let message = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
            
            //      let value = message.objectForKey("player")
            
            if message.objectForKey("player") != nil
            {
                scene.currentPlayer = UIDevice.currentDevice().name
                OpponentScore = message.objectForKey("player") as! Int
                scene.componentScore.text = String(OpponentScore)
                scene.myScore.text = String(myScoreCounter) + " *"
                if OpponentScore == 18 {
                    let senderName = message.objectForKey("sender")
                    let alert = UIAlertController(title: "Winner", message: "The winner is \(senderName)", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Restart", style: UIAlertActionStyle.Default, handler: { (alert:UIAlertAction) -> Void in
                            self.restartGame(true)
                        }))
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                }
                

            }else
            {
                let boardArray = message.objectForKey("board") as! [Int]
                //level.receiveBoard(boardArray)
                componentBoard = boardArray
                if !isISentBoard {
                    sendMyBoard()
                }
                RedrawBoard()
            }
        }
        catch{
            print(error)
        }
        
    }
    
    func RedrawBoard(){
        let tiles = level.receiveBoard(componentBoard)
        scene.removeAllSprites()
        scene.addSpritesForSquare(tiles, hasStarted: true)
        
    }
    
    // func handleReceivedDataWithNotification(notification:NSNotification){
    
    // }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.AllButUpsideDown]
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mpcHandler.setupPeerWithDisplayName(UIDevice.currentDevice().name)
        appDelegate.mpcHandler.setupSession()
        appDelegate.mpcHandler.advertiseSelf(true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerChangedStateWithNotification:", name: "MPC_DidChangeStateNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MPC_DidReceiveDataNotification", object: nil)
        
        
        
        // Configure the view.
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        level=Level()
        scene.level = level
        scene.openHandler = handleOpen
        // Present the scene.
        skView.presentScene(scene)
        
        beginGame()
    }
    
    
    
    func beginGame() {
        shuffle()
    }
    
    func shuffle() {
        newTiles = level.shuffle()
        newShips = level.shuffleShips()
        scene.addSpritesForSquare(newTiles)
        scene.addSpritesForShips(newShips)
        
        
        
    }
    func sendMessage (){
    
        do {
            let messageDict:[String:AnyObject] = ["player":myScoreCounter, "sender": appDelegate.mpcHandler.peerID.displayName ]
            let messageData = try NSJSONSerialization.dataWithJSONObject(messageDict, options: .PrettyPrinted)
            try appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            scene.currentPlayer = ""
        }
        catch   {
            print(error)
        }

    }
    
    
    func handleOpen(open: OpenTile) {
        //we set the userInteraction to false so that it doesn't trap touch events for itself, and pass them up to the your Scene.
        view.userInteractionEnabled = false
        
        level.performOpen(open)
        
        scene.animateOpen(open) {
            self.view.userInteractionEnabled = true
        }
        if open.tile.hasShip == false
        {
           sendMessage()
            scene.componentScore.text = String(OpponentScore) + " *"
            scene.myScore.text = String(myScoreCounter)
                  }
        else{
         myScoreCounter = myScoreCounter + 1
            scene.myScore.text = String(myScoreCounter) + " *"
            
            
            if myScoreCounter == 18 {
                sendMessage()
                let alert = UIAlertController(title: "Winner", message: "The winner is \(appDelegate.mpcHandler.peerID.displayName)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Restart", style: UIAlertActionStyle.Default, handler: { (alert:UIAlertAction) -> Void in
                    self.restartGame(true)
                }))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
}