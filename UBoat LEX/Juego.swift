//
//  Juego.swift
//  UBoat LEX
//
//  Created by Berganza on 16/12/2014.
//  Copyright (c) 2014 Berganza. All rights reserved.
//

import SpriteKit


class Juego: SKScene, SKPhysicsContactDelegate {

    var submarino = SKSpriteNode()
    var prisma = SKSpriteNode()
    var torpedo = SKSpriteNode()
    var malo = SKSpriteNode()

    
    
    var moverArriba = SKAction()
    var moverAbajo = SKAction()
    var puntos = 0
    var puntuacion = SKLabelNode()

    let velocidadFondo: CGFloat = 2
    private let torpedoCategory: UInt32 = 0x10
    private let enemigoCategory: UInt32 = 0x10
    
    override     func didMoveToView(view: SKView) {
        
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.cyanColor()
              
        heroe()
        prismaticos()
        crearEscenario()
        enemigo()
        target()
        marcador()
        
    }

// Llamada cuando torpedo choca con enemigo
    func didBeginContact(contact: SKPhysicsContact!) {
             
        if (contact.bodyB.categoryBitMask & torpedoCategory) != 0  {
            self.destruyeEnemigo(contact.bodyB.node as SKSpriteNode!, malo: contact.bodyA.node as SKSpriteNode!)
       }
    }

    override    func update(currentTime: NSTimeInterval) {
        scrollHorizontal()
       
    }

        func enemigo(){
        let malo = SKSpriteNode(imageNamed: "enemigo")
        malo.position.y = CGFloat(arc4random_uniform(500))+100
        malo.position.x = (CGFloat) (300 + 0.4*(malo.position.y - 100))
       
            malo.zPosition = 5
        malo.name = "enemigo"
         malo.setScale(0.6-malo.position.y/1000)
        malo.physicsBody = SKPhysicsBody (rectangleOfSize:malo.size)
        malo.physicsBody?.affectedByGravity = false
        malo.physicsBody?.dynamic = true
        malo.physicsBody?.categoryBitMask = enemigoCategory
        malo.physicsBody?.contactTestBitMask = torpedoCategory
        
        addChild(malo)
    }
        func marcador (){
            puntuacion.fontName = "arial"
            puntuacion.text = "Puntuacion : \(puntos)"
            puntuacion.fontSize = 20
            puntuacion.position = CGPoint(x: size.width / 2 + 40, y: size.height / 2 - 150)
        addChild(puntuacion)
    }
    
    func actualizaMarcador(){
            puntuacion.text = "Puntuacion : \(puntos)"
    }

    func target(){
        let tiro = SKSpriteNode(imageNamed: "Tiro")
        tiro.setScale(0.1)
        tiro.position = CGPoint(x: size.width / 2 + 290, y: size.height / 2 - 150)
        tiro.zPosition = 5
        tiro.name = "TiroBlanco"
        addChild(tiro)
    }
    
    func heroe() {
        
        submarino = SKSpriteNode(imageNamed: "UBoat")
        
        submarino.zPosition = 1
        submarino.position = CGPointMake(100, 200)
        submarino.setScale(0.6-submarino.position.y/1000)
        submarino.name = "heroe"
        
        submarino.physicsBody = SKPhysicsBody (rectangleOfSize:submarino.size)
        submarino.physicsBody?.dynamic = true
        submarino.physicsBody?.categoryBitMask = 0x1
        submarino.physicsBody?.contactTestBitMask = 0x01
        submarino.physicsBody?.affectedByGravity = false

        addChild(submarino)
        
        moverArriba = SKAction.moveByX(10, y: 20, duration: 0.2)
        moverAbajo = SKAction.moveByX(-10, y: -20, duration: 0.2)
        
    }
    
    func disparoTorpedo() {
        
        torpedo = SKSpriteNode(imageNamed: "torpedo")
        
        torpedo.xScale = 20
        torpedo.yScale = 1
        torpedo.setScale(0.05)
        torpedo.zPosition = 2
        torpedo.position = CGPointMake(submarino.position.x+50,submarino.position.y-20)
        
        torpedo.physicsBody = SKPhysicsBody (rectangleOfSize:torpedo.size)
        torpedo.physicsBody?.affectedByGravity = false
        torpedo.physicsBody?.dynamic = true
        torpedo.physicsBody?.categoryBitMask = torpedoCategory
        torpedo.physicsBody?.contactTestBitMask = enemigoCategory
        
        var torpedoMovim = SKAction.moveByX(600, y: 0, duration: 1.5)
        addChild(torpedo)
        
       torpedo.runAction(torpedoMovim)
       
        if torpedo.position.x == 600 {
         torpedo.removeFromParent()
        }
    }
    
    func destruyeEnemigo(torpedo: SKSpriteNode, malo: SKSpriteNode) {
        
        // When a missile hits an alien, both disappear
        torpedo.removeFromParent()
        malo.removeFromParent()
        puntos+=1
        actualizaMarcador()
        enemigo()
    }
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        for toke: AnyObject in touches {
            
            let dondeTocamos = toke.locationInNode(self)
            let loQueTocamos = self.nodeAtPoint(dondeTocamos)
            
           
           submarino.setScale(0.6-submarino.position.y/1000)
     
            
            if loQueTocamos.name == "TiroBlanco" {
                 disparoTorpedo()
            }else{
                if dondeTocamos.y > submarino.position.y {
                    if submarino.position.y < 750 {
                        submarino.runAction(moverArriba)
                    }
                } else {
                    if submarino.position.y > 50 {
                        submarino.runAction(moverAbajo)
                    }
                }
            }
            
        }
    }
    
    func prismaticos() {
        
        prisma = SKSpriteNode(imageNamed: "prismatic")
        prisma.setScale(0.66)
        prisma.zPosition = 2
        prisma.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
        addChild(prisma)
    }
    
    func crearEscenario() {
        for var indice = 0; indice < 2; ++indice {
            
            let fondo = SKSpriteNode(imageNamed: "mar4")
            fondo.position = CGPoint(x: indice * Int(fondo.size.width), y: 0)
            
            fondo.name = "fondo"
            fondo.zPosition = 0
            
            addChild(fondo)

        }
    }
    
    func scrollHorizontal() {
        
        self.enumerateChildNodesWithName("fondo", usingBlock: { (nodo, stop) -> Void in
            if let fondo = nodo as? SKSpriteNode {
                
                fondo.position = CGPoint(
                    x: fondo.position.x - self.velocidadFondo,
                    y: fondo.position.y)
                
                if fondo.position.x <= -fondo.size.width {
                    
                    fondo.position = CGPointMake(
                        fondo.position.x + fondo.size.width * 2,
                        fondo.position.y)
                }
            }
        })
        
    }
    
}

    




