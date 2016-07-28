//
//  GameScene.swift
//  Sliced
//
//  Created by Leo on 07/28/16.
//  Copyright (c) 2016 iteloolab. All rights reserved.
//

import SpriteKit

class GameScene : SKScene {
    
    let grid = Grid(blockSize: 50.0, rows:7, cols:7)
    
    let gamePiece = SKSpriteNode(imageNamed: "Spaceship")
    
    override func didMoveToView(view: SKView) {
        // add gestures
        let dirs: [UISwipeGestureRecognizerDirection] = [.Right, .Left, .Up, .Down]
        for dir in dirs {
            let swipe = UISwipeGestureRecognizer(target: self, action: Selector("respondToSwipeGesture:"))
            swipe.direction = dir
            view.addGestureRecognizer(swipe)
        }
        
        scaleMode = .ResizeFill
        //physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
        // add grid
        grid.position = CGPointMake(CGRectGetMidX(view.frame), CGRectGetMidY(view.frame))
//        let gridBody = SKPhysicsBody(edgeLoopFromRect: CGRectMake(0,0,100,2))
//        gridBody.usesPreciseCollisionDetection = true
//        grid.physicsBody = gridBody
        addChild(grid)
        
        // init game piece
        gamePiece.setScale(0.0625)
        let gamePieceBody = SKPhysicsBody(circleOfRadius: 1)
        gamePieceBody.affectedByGravity = false
        gamePieceBody.usesPreciseCollisionDetection = true
        gamePiece.physicsBody = gamePieceBody
        gamePiece.position = grid.gridPosition(3, col:3)
        grid.addChild(gamePiece)
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipe = gesture as? UISwipeGestureRecognizer {
            let dir = swipe.direction
            let delta : (CGFloat,CGFloat) = {
                if dir == .Right {
                    return (1,0)
                } else if dir == .Down {
                    return (0,-1)
                } else if dir == .Left {
                    return (-1,0)
                } else if dir == .Up {
                    return (0,1)
                } else {
                    return (0,0)
                }
            }()
            let pos = gamePiece.position
            let dv = CGVector(dx: delta.0 * grid.blockSize, dy: delta.1 * grid.blockSize)
            let new_pos = CGPointMake(pos.x + dv.dx, pos.y + dv.dy)
            print(String(new_pos))
            if grid.isInside(new_pos) {
                let action = SKAction.moveByX(dv.dx, y: dv.dy, duration: 0.15)
                gamePiece.runAction(action)
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
    }
}


// [todo] move to own module
class Grid : SKSpriteNode {
    
    var rows : Int!
    var cols : Int!
    var blockSize : CGFloat!
    
    convenience init(blockSize : CGFloat, rows : Int, cols : Int) {
        let texture = Grid.gridTexture(blockSize,rows: rows, cols:cols)
        self.init(texture: texture, color: SKColor.clearColor(), size: texture.size())
        self.blockSize = blockSize
        self.rows = rows
        self.cols = cols
    }
    
    override init(texture: SKTexture!, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func gridTexture(blockSize:CGFloat, rows:Int, cols:Int) -> SKTexture {
        // Add 1 to the height and width to ensure the borders are within the sprite
        let size = CGSize(width: CGFloat(cols)*blockSize+1.0, height: CGFloat(rows)*blockSize+1.0)
        UIGraphicsBeginImageContext(size)
        
        let context = UIGraphicsGetCurrentContext()
        let bezierPath = UIBezierPath()
        let offset:CGFloat = 0.5
        // Draw vertical lines
        for i in 0...cols {
            let x = CGFloat(i)*blockSize + offset
            bezierPath.moveToPoint(CGPoint(x: x, y: 0))
            bezierPath.addLineToPoint(CGPoint(x: x, y: size.height))
        }
        // Draw horizontal lines
        for i in 0...rows {
            let y = CGFloat(i)*blockSize + offset
            bezierPath.moveToPoint(CGPoint(x: 0, y: y))
            bezierPath.addLineToPoint(CGPoint(x: size.width, y: y))
        }
        SKColor.blackColor().setStroke()
        bezierPath.lineWidth = 1.0
        bezierPath.stroke()
        CGContextAddPath(context, bezierPath.CGPath)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image)
    }
    
    func gridPosition(row:Int, col:Int) -> CGPoint {
        let offset = blockSize / 2.0 + 0.5
        let x = CGFloat(col) * blockSize - (blockSize * CGFloat(cols)) / 2.0 + offset
        let y = CGFloat(rows - row - 1) * blockSize - (blockSize * CGFloat(rows)) / 2.0 + offset
        return CGPoint(x:x, y:y)
    }
    
    func gridCoordinates(point:CGPoint) -> (Int, Int) {
        let offset = blockSize / 2.0 + 0.5
        let j = Int(round((point.x + (blockSize * CGFloat(cols)) / 2.0 - offset) / blockSize))
        let i = Int(round(CGFloat(rows - 1) - ((point.y + (blockSize * CGFloat(rows)) / 2.0 - offset) / blockSize)))
        return (i,j)
    }
    
    func isInside(point: CGPoint) -> (Bool) {
        let (i,j) = gridCoordinates(point)
        return (0 <= i) && (i < rows) && (0 <= j) && (j < cols)
    }
}
