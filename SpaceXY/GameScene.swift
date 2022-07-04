import GameController
import SpriteKit

class GameScene: SKScene {
    
    let shotSpeed = 8.0
    
    let rightStickSpeed = 1.0
    let xAxisSpeed = 10.0
    let player = SKSpriteNode(imageNamed: "player")
    
    var currentKeyboard: GCKeyboard?
    var directionPad: GCControllerDirectionPad?
    var rightStick: GCControllerDirectionPad?
    
    override func didMove(to view: SKView) {
        listenForInput()
        guard let starfield = SKEmitterNode(fileNamed: "Starfield") else {
            fatalError()
        }
        
        starfield.position = CGPoint(x: 0, y: size.height / 2)
        starfield.zPosition = -1
        starfield.advanceSimulationTime(60)
        addChild(starfield)
        
        player.position = CGPoint(x: 0, y: -Int(size.height)/2 + Int(player.size.height) + 50)
        player.zRotation = CGFloat.pi / 2
        player.zPosition = 1
//        player.run(SKAction.rotate(toAngle: Double.pi/2, duration: 0))
        addChild(player)
    }
    
    override func update(_ currentTime: TimeInterval) {
        pollControllerInput()
    }
    
    private func listenForInput() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleControllerDidConnect),
                                               name: NSNotification.Name.GCControllerDidBecomeCurrent, object: nil)
    }
    
    @objc
    func handleControllerDidConnect(_ notification: Notification) {
        guard let gameController = notification.object as? GCController else {
            return
        }
        setup(gameController: gameController)
    }
    
    private func setup(gameController: GCController) {
        var buttonA: GCControllerButtonInput?
        
        if let gamepad = gameController.extendedGamepad {
            directionPad = gamepad.leftThumbstick
            rightStick = gamepad.rightThumbstick
            buttonA = gamepad.buttonA
        } else if let gamepad = gameController.microGamepad {
            directionPad = gamepad.dpad
            buttonA = gamepad.buttonA
        }
        
        buttonA?.pressedChangedHandler = { [weak self] _, _, isPressed in
            if isPressed {
                self?.fire()
            }
        }
    }
    
    private func fire() {
        fire(xOffset: -1 * (player.size.height / 2))
        fire(xOffset: (player.size.height / 2))
    }
    
    private func fire(xOffset: CGFloat) {
        let shot = SKSpriteNode(imageNamed: "playerWeapon")
        shot.name = "playerWeapon"
        shot.position = player.position
        
        let angle = player.zRotation
        shot.position.x += cos(angle) * ((player.size.height / 2) / (CGFloat.pi / 2)) + xOffset
        shot.position.y += sin(angle) * ((player.size.width / 2) / (CGFloat.pi / 2))
        
        shot.zRotation = player.zRotation
        shot.speed = shotSpeed
        shot.zPosition = 1
        shot.setScale(0.4)

        shot.physicsBody = SKPhysicsBody(rectangleOf: shot.size)
//        shot.physicsBody?.categoryBitMask = CollisionType.playerWeapon.rawValue
//        shot.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
//        shot.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        addChild(shot)

        let movement = SKAction.move(to: CGPoint(x: position.x + cos(angle) * size.width + xOffset, y: position.y + sin(angle) * size.height), duration: 5)
        let sequence = SKAction.sequence([movement, .removeFromParent()])
        shot.run(sequence)
    }
    
    
    func pollControllerInput() {
        if let gamePadLeft = self.directionPad {
            player.position.x += (CGFloat(gamePadLeft.xAxis.value) * xAxisSpeed)
        }
        
        if let rightStick = self.rightStick, rightStick.xAxis.value != 0.0 {
            let angle = CGFloat(atan2(rightStick.yAxis.value, rightStick.xAxis.value))
//            print("input angle \(angle)")
//            var direction: CGFloat = angle > 0 ? 1 : -1
//            player.zRotation += direction * (CGFloat.pi / 180) * rightStickSpeed
//            print("angle: \(angle * (180 / Double.pi))")
//            player.zRotation = angle
            player.run(SKAction.rotate(toAngle: angle, duration: 0.1, shortestUnitArc: true))
//            print("play zRot \(player.zRotation)")
           fire()
        }
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
            case 123: player.position.x -= 1.0 * xAxisSpeed
            case 124: player.position.x += 1.0 * xAxisSpeed
            default: super.keyDown(with: event)
        }
    }
}
