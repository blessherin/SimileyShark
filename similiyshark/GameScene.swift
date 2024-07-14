import SpriteKit
import GameplayKit

protocol GameDelegate: AnyObject {
    func updateDepth(_ depth: Int)
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var player: SKSpriteNode?
    var bom: SKSpriteNode?
    var ubur: SKSpriteNode?
    var rock: SKSpriteNode?
    var layer2:SKSpriteNode?
    var layer3:SKSpriteNode?
    var layer31:SKSpriteNode?
    var background: SKSpriteNode?
    var gelembung: SKSpriteNode?
    var monster: SKSpriteNode?
    let xPositions = [-160, 0, 160]  // Lane positions
    var playerPosition = 2  // Default to middle lane
    var depth = 0
    var depthLabel: SKLabelNode?
    var oxygenLabel: SKLabelNode?
    var oxygenBar: SKSpriteNode?
    var oxygenPercentage: CGFloat = 1.0 // 100% initially
    weak var gameDelegate: GameDelegate?

    
    // Durasi aksi awal
      var bomMoveDuration: TimeInterval = 7
      var uburMoveDuration: TimeInterval = 6
      var gelembungWaitDuration: TimeInterval = 4
      var MonsterMoveDuration: TimeInterval  = 3
    
    
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        player = self.childNode(withName: "//player") as? SKSpriteNode
        bom = self.childNode(withName: "//bom") as? SKSpriteNode
        rock = self.childNode(withName: "//rock") as? SKSpriteNode
        gelembung = self.childNode(withName: "//gelembung") as? SKSpriteNode
        ubur = self.childNode(withName: "//ubur") as? SKSpriteNode
        background = self.childNode(withName: "//background") as? SKSpriteNode
        layer2 = self.childNode(withName: "//layer2") as? SKSpriteNode
        layer3 = self.childNode(withName: "//layer3") as? SKSpriteNode
        layer31 = self.childNode(withName: "//layer31") as? SKSpriteNode
        monster = self.childNode(withName: "//monster") as? SKSpriteNode

        repeatedlySpawnGelembung()
        repeatedlySpawnBom()
        repeatedlyMoveRock()
        repeatedlySpawnUbur()
        repeatedlyMoveLayer2()
        repeatedlyMoveLayer3()
        repeatedlySpawnMonster()
        player?.physicsBody = SKPhysicsBody(rectangleOf: player?.size ?? .zero)
        player?.physicsBody?.affectedByGravity = false
        player?.physicsBody?.allowsRotation = false
        player?.physicsBody?.contactTestBitMask = player?.physicsBody?.collisionBitMask ?? 0
        
        depthLabel = SKLabelNode(text: "Depth: \(depth) meter")
        depthLabel?.fontSize = 24
        depthLabel?.fontColor = .black
        depthLabel?.fontName = "Slackey"
        depthLabel?.position = CGPoint(x: -200, y: size.height / 2 - 125)
        depthLabel?.zPosition = 4
        if let depthLabel = depthLabel {
            self.addChild(depthLabel)
        }

        oxygenBar = SKSpriteNode(color: .green, size: CGSize(width: 200, height: 20))
        oxygenBar?.position = CGPoint(x: -70, y: size.height / 2 - 160)
        oxygenBar?.anchorPoint = CGPoint(x: 0, y: 0.5)
        oxygenBar?.zPosition = 3 // Set zPosition to 3
        if let oxygenBar = oxygenBar {
            self.addChild(oxygenBar)
        }
        
        oxygenLabel = SKLabelNode(text: "Oxygen: 100% ")
        oxygenLabel?.fontSize = 24
        oxygenLabel?.fontColor = .black
        oxygenLabel?.fontName = "Slackey"
        oxygenLabel?.position = CGPoint(x: -180, y: size.height / 2 - 170)
        oxygenLabel?.zPosition = 4 // Ensure this is above the oxygen bar
        if let oxygenLabel = oxygenLabel {
            self.addChild(oxygenLabel)
        }

        let incrementDepthAction = SKAction.run {
            self.incrementDepth()
        }
        let waitAction = SKAction.wait(forDuration: 0.4)
        let incrementSequence = SKAction.sequence([incrementDepthAction, waitAction])
        run(SKAction.repeatForever(incrementSequence))
        
        // Schedule oxygen decrease
        let decreaseOxygenAction = SKAction.run {
            self.decreaseOxygen()
        }
        let oxygenWaitAction = SKAction.wait(forDuration: 4.0)
        let oxygenSequence = SKAction.sequence([decreaseOxygenAction, oxygenWaitAction])
        run(SKAction.repeatForever(oxygenSequence))
    }

    func incrementDepth() {
        depth += 1
        depthLabel?.text = "Depth: \(depth)m"
        gameDelegate?.updateDepth(depth)  // Notify the delegate of the depth change
        if depth % 150 == 0 {
            adjustNodeSpeeds() // Adjust speeds for bom and gelembung
                   changeBackground()

               }
    }
//untuk kecepartan jika kedalaman lebih 150
    func adjustNodeSpeeds() {
        if depth >= 350 {
            bomMoveDuration = 1 // Increase speed of bom
            uburMoveDuration = 1 // Increase speed of ubur
            gelembungWaitDuration = 9 // Increase delay of gelembung spawn
        } else if depth >= 120 {
            bomMoveDuration = 2 // Increase speed of bom
            uburMoveDuration = 2 // Increase speed of ubur
            gelembungWaitDuration = 7// Increase delay of gelembung spawn

        } else if depth >= 80 {
            bomMoveDuration = 3 // Increase speed of bom
            uburMoveDuration = 3 // Increase speed of ubur
            gelembungWaitDuration = 3 // Increase delay of gelembung spawn
        } else {
            // Jika kedalaman kurang dari 80, tidak melakukan perubahan
            bomMoveDuration = 8 // Kecepatan default
            uburMoveDuration = 4 // Kecepatan default
            gelembungWaitDuration = 10 // Delay default

        }
        
        // Print statement untuk debugging
        print("Bom Move Duration: \(bomMoveDuration)")
        print("Ubur Move Duration: \(uburMoveDuration)")
        print("Gelembung Wait Duration: \(gelembungWaitDuration)")
        
        // Perbesar ukuran player jika kedalaman >= 150
            if depth >= 150 {
                let scaleAction = SKAction.scale(by: 1.4, duration: 4) // Tambah ukuran 20% dalam 0.5 detik
                player?.run(scaleAction)
            } else {
                // Kembalikan ukuran player ke ukuran awal jika kedalaman < 150
                let scaleAction = SKAction.scale(to: 1.0, duration: 0.5) // Kembalikan ukuran ke ukuran normal
                player?.run(scaleAction)
            }
    }

    
    func decreaseOxygen() {
        if oxygenPercentage > 0 {
            oxygenPercentage -= 0.02 // Decrease by 2%
            let newWidth = 200 * oxygenPercentage
            oxygenBar?.size = CGSize(width: newWidth, height: 20)
            oxygenLabel?.text = "Oxygen: \(Int(oxygenPercentage * 100))% :"
            
            // Check if oxygen is depleted
            if oxygenPercentage <= 0 {
                gameOver()
            }
        }
    }

    func increaseOxygen(by amount: CGFloat) {
        oxygenPercentage = min(oxygenPercentage + amount, 1.0) // Increase oxygen but not above 100%
        let newWidth = 200 * oxygenPercentage
        oxygenBar?.size = CGSize(width: newWidth, height: 20)
        oxygenLabel?.text = "Oxygen: \(Int(oxygenPercentage * 100))%"
        
        // Add a pulse animation to indicate oxygen increase
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        oxygenBar?.run(pulse)
        oxygenLabel?.run(pulse)
    }

    func updatePlayerPosition() {
        player?.run(SKAction.moveTo(x: CGFloat(xPositions[playerPosition - 1]), duration: 0.1))
    }

    @objc func swipeRight() {
        if playerPosition < 3 {
            playerPosition += 1
            updatePlayerPosition()
        }
    }

    @objc func swipeLeft() {
        if playerPosition > 1 {
            playerPosition -= 1
            updatePlayerPosition()
        }
    }

//    fungsi monster
    func spawnMonster(){
        guard let monster = monster else {
            print("Monster node is nil")
            return
        }

        let newMonster = monster.copy() as! SKSpriteNode
        newMonster.position = CGPoint(x: xPositions[Int.random(in: 0..<xPositions.count)], y: -900)
        newMonster.physicsBody = SKPhysicsBody(rectangleOf: newMonster.size)
        newMonster.physicsBody?.isDynamic = true
        newMonster.physicsBody?.categoryBitMask = 0x1 << 1 // Sesuaikan sesuai kebutuhan
        newMonster.physicsBody?.collisionBitMask = 0x1 << 0 // Sesuaikan sesuai kebutuhan
        newMonster.physicsBody?.contactTestBitMask = 0x1 << 0 // Sesuaikan sesuai kebutuhan
        addChild(newMonster)
        
        // Panggil moveMonster untuk memindahkan newMonster
        moveMonster(node: newMonster)
    }

    func moveMonster(node: SKNode) {
        // Durasi perpindahan vertikal
        let verticalMoveDuration = MonsterMoveDuration
        
        // Durasi perpindahan horizontal (dapat disesuaikan sesuai kebutuhan)
        let horizontalMoveDuration = 0.5
        
        // Aksi perpindahan vertikal
        let moveDownAction = SKAction.moveTo(y: 700, duration: verticalMoveDuration)
        
        // Posisi x target untuk perpindahan lane
        let targetX = xPositions[Int.random(in: 0..<xPositions.count)]
        
        // Aksi perpindahan horizontal ke posisi targetX
        let moveHorizontalAction = SKAction.moveTo(x: CGFloat(targetX), duration: horizontalMoveDuration)
        
        // Aksi gabungan untuk perpindahan vertikal dan horizontal
        let combinedAction = SKAction.group([moveDownAction, moveHorizontalAction])
        
        // Aksi untuk menghapus node setelah selesai
        let removeNodeAction = SKAction.removeFromParent()
        
        // Menjalankan urutan aksi
        node.run(SKAction.sequence([combinedAction, removeNodeAction]))
    }

    func repeatedlySpawnMonster(){
        let spawnAction = SKAction.run {
            self.spawnMonster()
        }
        let waitAction = SKAction.wait(forDuration: 15)
        let spawnAndWaitAction = SKAction.sequence([spawnAction, waitAction])
        run(SKAction.repeatForever(spawnAndWaitAction))
    }

    
    // Ubur-ubur functions
    func spawnUbur() {
        let newUbur = ubur?.copy() as! SKSpriteNode
        newUbur.position = CGPoint(x: xPositions[Int.random(in: 0..<xPositions.count)], y: -800)
        newUbur.physicsBody = SKPhysicsBody(rectangleOf: newUbur.size)
        newUbur.physicsBody?.isDynamic = false
        addChild(newUbur)
        
        moveUbur(node: newUbur)
    }
    
    func repeatedlySpawnUbur() {
        let spawnAction = SKAction.run {
            self.spawnUbur()
        }
        let waitAction = SKAction.wait(forDuration: 6)
        let spawnAndWaitAction = SKAction.sequence([spawnAction, waitAction])
        run(SKAction.repeatForever(spawnAndWaitAction))
    }
    
    func moveUbur(node: SKNode) {
        let moveDownAction = SKAction.moveTo(y: 700, duration: uburMoveDuration)
        let removeNodeAction = SKAction.removeFromParent()
        node.run(SKAction.sequence([moveDownAction, removeNodeAction]))
    }

    // Bom functions
    func spawnBom() {
        let newBom = bom?.copy() as! SKSpriteNode
        newBom.position = CGPoint(x: xPositions[Int.random(in: 0..<xPositions.count)], y: -700)
        newBom.physicsBody = SKPhysicsBody(rectangleOf: newBom.size)
        newBom.physicsBody?.isDynamic = false
        addChild(newBom)
        
        moveBom(node: newBom)
    }
    
    func repeatedlySpawnBom() {
        let spawnAction = SKAction.run {
            self.spawnBom()
        }
        let waitAction = SKAction.wait(forDuration: 6)
        let spawnAndWaitAction = SKAction.sequence([spawnAction, waitAction])
        run(SKAction.repeatForever(spawnAndWaitAction))
    }

    func moveBom(node: SKNode) {
        let moveDownAction = SKAction.moveTo(y: 700, duration: bomMoveDuration)
        let removeNodeAction = SKAction.removeFromParent()
        node.run(SKAction.sequence([moveDownAction, removeNodeAction]))
    }

    // Gelembung functions
    func spawnGelembung() {
        let newGelembung = gelembung?.copy() as! SKSpriteNode
        newGelembung.position = CGPoint(x: xPositions[Int.random(in: 0..<xPositions.count)], y: -700)
        newGelembung.physicsBody = SKPhysicsBody(rectangleOf: newGelembung.size)
        newGelembung.physicsBody?.isDynamic = false
        addChild(newGelembung)
        
        moveGelembung(node: newGelembung)
    }
    
    func repeatedlySpawnGelembung() {
        let spawnAction = SKAction.run {
            self.spawnGelembung()
        }
        let waitAction = SKAction.wait(forDuration: gelembungWaitDuration)
        let spawnAndWaitAction = SKAction.sequence([spawnAction, waitAction])
        run(SKAction.repeatForever(spawnAndWaitAction))
    }
    
    func moveGelembung(node: SKNode) {
        let moveDownAction = SKAction.moveTo(y: 700, duration: 2)
        let removeNodeAction = SKAction.removeFromParent()
        node.run(SKAction.sequence([moveDownAction, removeNodeAction]))
    }

    

//    semua fungsi tentang layer 2
    // Fungsi untuk memunculkan layer2
    func spawnLayer2() {
        guard let layer2 = layer2 else {
            print("Layer2 node is not set.")
            return
        }
        
        let newLayer2 = layer2.copy() as! SKSpriteNode
        newLayer2.position = CGPoint(x: -size.width / 2, y: 0) // Start from the left edge
        newLayer2.physicsBody = SKPhysicsBody(rectangleOf: newLayer2.size)
        newLayer2.physicsBody?.isDynamic = false
        addChild(newLayer2)
        
        moveLayer2(node: newLayer2)
    }

    // Function to move layer2 horizontally
    func moveLayer2(node: SKNode) {
        let moveRightAction = SKAction.moveBy(x: size.width + node.frame.width, y: 0, duration: 30)
        let resetPositionAction = SKAction.moveBy(x: -size.width - node.frame.width, y: 0, duration: 0)
        let waitAction = SKAction.wait(forDuration: 30)
        let sequence = SKAction.sequence([moveRightAction, waitAction, resetPositionAction])
        let repeatAction = SKAction.repeatForever(sequence)
        node.run(repeatAction)
    }

    // Function to start moving layer2 repeatedly
    func repeatedlyMoveLayer2() {
        if let layer2 = layer2 {
            moveLayer2(node: layer2)
        }
    }


    // Rock functions
    func spawnRock() {
        let newRock = rock?.copy() as! SKSpriteNode
        newRock.position = CGPoint(x: 0, y: -700)
        newRock.physicsBody = SKPhysicsBody(rectangleOf: newRock.size)
        newRock.physicsBody?.isDynamic = false
        addChild(newRock)
        
        moveRock(node: newRock)
    }
    
    func moveRock(node: SKNode) {
        let moveUpAction = SKAction.moveTo(y: size.height + 800, duration: 10)
        let resetPositionAction = SKAction.moveTo(y: -2300, duration: 0)
        let waitAction = SKAction.wait(forDuration: 1)
        let sequence = SKAction.sequence([moveUpAction, waitAction, resetPositionAction])
        let repeatAction = SKAction.repeatForever(sequence)
        node.run(repeatAction)
    }
    
    func repeatedlyMoveRock() {
        if let rock = rock {
            moveRock(node: rock)
        }
    }

//    layer 3 meresahkan
    // Fungsi untuk men-spawn layer3
    func spawnLayer3() {
        guard let layer3 = layer3 else {
            print("Node layer3 tidak disetel.")
            return
        }
        
        let newLayer3 = layer3.copy() as! SKSpriteNode
        newLayer3.position = CGPoint(x: 0, y: 90)
        newLayer3.physicsBody = SKPhysicsBody(rectangleOf: newLayer3.size)
        newLayer3.physicsBody?.isDynamic = false
        addChild(newLayer3)
        
        moveLayer3(node: newLayer3)
    }

    // Fungsi untuk men-spawn layer31
    func spawnLayer31() {
        guard let layer31 = layer31 else {
            print("Node layer31 tidak disetel.")
            return
        }
        
        let newLayer31 = layer31.copy() as! SKSpriteNode
        newLayer31.position = CGPoint(x: 0, y: 80)
        newLayer31.physicsBody = SKPhysicsBody(rectangleOf: newLayer31.size)
        newLayer31.physicsBody?.isDynamic = false
        addChild(newLayer31)
        
        moveLayer31(node: newLayer31)
    }

    // Fungsi untuk menggerakkan layer3 ke atas
    func moveLayer3(node: SKNode) {
        let moveUpAction = SKAction.moveBy(x: 0, y: size.height + 700 + node.frame.height, duration: 30)
        let resetPositionAction = SKAction.moveBy(x: 0, y: -(size.height + 700 + node.frame.height), duration: 0)
        let sequence = SKAction.sequence([moveUpAction, resetPositionAction])
        let repeatAction = SKAction.repeatForever(sequence)
        node.run(repeatAction)
    }

    // Fungsi untuk menggerakkan layer31 ke atas
    func moveLayer31(node: SKNode) {
        let moveUpAction = SKAction.moveBy(x: 0, y: size.height + 700 + node.frame.height, duration: 30)
        let resetPositionAction = SKAction.moveBy(x: 0, y: -(size.height + 700 + node.frame.height), duration: 0)
        let sequence = SKAction.sequence([moveUpAction, resetPositionAction])
        let repeatAction = SKAction.repeatForever(sequence)
        node.run(repeatAction)
    }

    // Fungsi untuk memulai pergerakan berulang pada layer3 dan layer31
    func repeatedlyMoveLayer3() {
        if let layer3 = layer3 {
            moveLayer3(node: layer3)
        }
        if let layer31 = layer31 {
            moveLayer31(node: layer31)
        }
    }


//end layer 3
    // Handling contact and explosions
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }

        if (nodeA.name == "player" && (nodeB.name == "bom" || nodeB.name == "ubur" || (nodeB.name == "monster" && depth < 150))) ||
           ((nodeA.name == "bom" || nodeA.name == "ubur" || (nodeA.name == "monster" && depth < 150)) && nodeB.name == "player") {
            // Run explosion effect at the position of the contact
            let explosionPosition = (nodeA.name == "bom" || nodeA.name == "ubur" || (nodeA.name == "monster" && depth < 150)) ? nodeA.position : nodeB.position
            runExplosionEffect(at: explosionPosition)

            // Run animation for the character
            let characterNode = (nodeA.name == "player") ? nodeA : nodeB
            runCharacterAnimation(for: characterNode)

            // Remove the nodes after the effect is displayed
            let waitAction = SKAction.wait(forDuration: 1.5) // Wait for the explosion and animation to finish
            let removeNodeAction = SKAction.run {
                nodeA.removeFromParent()
                nodeB.removeFromParent()

                print("KENA BOM ATAU UBUR! atau monster")
                self.gameOver() // Move to game over screen after effects
            }
            run(SKAction.sequence([waitAction, removeNodeAction]))
        } else if (nodeA.name == "player" && (nodeB.name == "monster" && depth >= 150)) ||
                  ((nodeA.name == "monster" && depth >= 150) && nodeB.name == "player") {
            // If depth is >= 150, just remove the monster and make it spin
            let monsterNode = (nodeA.name == "monster") ? nodeA : nodeB
            
            // Create a rotating action for the monster
            let rotateAction = SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat.pi, duration: 1))
            monsterNode.run(rotateAction)
            
            // Optionally, you can add some visual feedback or sound effect here
            print("KENA MONSTER, TAPI TIDAK MATI dan monster berputar")

            // Remove the monster after rotating
            let waitAction = SKAction.wait(forDuration: 0.5) // Wait to let the rotation be visible
            let removeNodeAction = SKAction.removeFromParent()
            monsterNode.run(SKAction.sequence([waitAction, removeNodeAction]))
        } else if (nodeA.name == "player" && nodeB.name == "gelembung") || (nodeA.name == "gelembung" && nodeB.name == "player") {
            if nodeA.name == "gelembung" {
                nodeA.removeFromParent()
            } else {
                nodeB.removeFromParent()
            }
            increaseOxygen(by: 0.1) // Increase oxygen by 10%
        }
    }


    // Running the explosion effect
    func runExplosionEffect(at position: CGPoint) {
        if let explosion = SKEmitterNode(fileNamed: "efect") {
            explosion.position = position
            addChild(explosion)
            
            let wait = SKAction.wait(forDuration: 0.5)
//            let remove = SKAction.removeFromParent()
            explosion.run(SKAction.sequence([wait]))
        }
    }
    
    // Running the character animation
    func runCharacterAnimation(for character: SKNode) {
        let rotateAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 1.0)
        let scaleAction = SKAction.scale(to: 0.5, duration: 1.0)
        let groupAction = SKAction.group([rotateAction, scaleAction])
        let fadeOutAction = SKAction.fadeOut(withDuration: 1.0)
        let sequenceAction = SKAction.sequence([groupAction, fadeOutAction])
        let remove = SKAction.removeFromParent()

        character.run(SKAction.sequence([sequenceAction, remove]))
    }

    
    
    func changeBackground() {
        guard let background = self.background else {
            print("Background node is nil")
            return
        }

        // Check if the background node has a texture
        if let currentTexture = background.texture {
            print("Current background texture: \(currentTexture)")
        } else {
            print("Background node does not have a texture")
        }

        // Save current texture and apply special texture
        let normalBackgroundTexture = background.texture
        let specialBackgroundTexture = SKTexture(imageNamed: "specialbg")
        
        // Ensure special texture is loaded
        if specialBackgroundTexture.size() == .zero {
            print("Special background texture is not loaded correctly")
            return
        }

        background.texture = specialBackgroundTexture
        
        // Revert to normal texture after 10 seconds
        let waitAction = SKAction.wait(forDuration: 10.0)
        let revertAction = SKAction.run {
            if let normalTexture = normalBackgroundTexture {
                background.texture = normalTexture
            }
        }
        let sequenceAction = SKAction.sequence([waitAction, revertAction])
        run(sequenceAction)
    }

    
    // Game over function
    func gameOver() {
        isPaused = true
        NotificationCenter.default.post(name: NSNotification.Name("gameover"), object: nil)
    }
}
