//
//  SetCardView.swift
//  GraphicalSet
//
//  Created by Alan Tseng on 1/26/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import UIKit

class SetCardView: UIView {
    
    var card: SetCard?
    
    var shape: SetCard.Shape? { didSet {setNeedsDisplay(); setNeedsLayout() } }
    
    var striping: SetCard.Shading? { didSet {setNeedsDisplay(); setNeedsLayout() } }
    
    var setCardColor: SetCard.Color? { didSet {setNeedsDisplay(); setNeedsLayout() } }
    
    var numberOfShapes: SetCard.Number? { didSet {setNeedsDisplay(); setNeedsLayout() } }
    
    var cardIsSelected: Bool = false
    
    convenience init(frame: CGRect, shape: SetCard.Shape, striping: SetCard.Shading, setCardColor: SetCard.Color, numberOfShapes: SetCard.Number, card: SetCard) {
        self.init(frame: frame)
        
        self.shape = shape
        self.striping = striping
        self.setCardColor = setCardColor
        self.numberOfShapes = numberOfShapes
        self.card = card
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // MARK: - Helper Path Methods
    private func setDiamondPathAtPoint(_ point: CGPoint) -> UIBezierPath
    {
        let path = UIBezierPath()
        
        
        path.move(to: point)
        path.addLine(to: CGPoint(x: bounds.maxX - cornerRadius, y: point.y + bounds.height / 8))
        path.addLine(to: CGPoint(x: bounds.midX, y: point.y + bounds.height / 4))
        path.addLine(to: CGPoint(x: bounds.minX + cornerRadius, y: point.y + bounds.height / 8))
        path.close()
        
        return path
        
    }
    
    
    private func setSquigglePathAtPoint(_ point: CGPoint) -> UIBezierPath {
        let path = UIBezierPath()
        
        path.move(to: point)
        
        path.addCurve(to: CGPoint(x: point.x - 41.0 , y: point.y + 39.0), controlPoint1: CGPoint(x: point.x + 8.4, y: point.y - 21.9), controlPoint2: CGPoint(x: point.x - 14.3, y: point.y + 45.8))
        path.addCurve(to: CGPoint(x: point.x - 77, y: point.y + 38), controlPoint1: CGPoint(x: point.x - 51.7, y: point.y + 36.3) , controlPoint2: CGPoint(x: point.x - 61.8, y: point.y + 27.0))
        path.addCurve(to: CGPoint(x: point.x - 99.0, y: point.y + 25.0), controlPoint1: CGPoint(x: point.x - 94.4, y: point.y + 50.6), controlPoint2: CGPoint(x: point.x - 98.6, y: point.y + 43.3))
        path.addCurve(to: CGPoint(x: point.x - 68.0, y: point.y - 3.0), controlPoint1: CGPoint(x: point.x - 99.4, y: point.y + 7.0), controlPoint2: CGPoint(x: point.x - 84.9, y: point.y - 5.3))
        path.addCurve(to: CGPoint(x: point.x - 15.0, y: point.y - 1.0), controlPoint1: CGPoint(x: point.x - 44.8, y: point.y + 0.2), controlPoint2: CGPoint(x: point.x - 42.1, y: point.y + 16.5))
        path.addCurve(to: point, controlPoint1: CGPoint(x: point.x - 8.7, y: point.y - 5.0), controlPoint2: CGPoint(x: point.x - 3.1, y: point.y - 8.1))
        
        return path
    }
    
    private func setCirclePathAtPoint(_ point: CGPoint) -> UIBezierPath {
        return UIBezierPath(arcCenter: point, radius: bounds.height / 8, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
    }
    
    // MARK: - Big helper function to draw all the shapes in one card
    /// Draws the card images using UIBezierPath and the shape and number parameters
    private func drawAllPicturePaths(shapeType: SetCard.Shape , number: SetCard.Number) -> [UIBezierPath] {
        var paths = [UIBezierPath]()
        
        switch shapeType {
        case .squiggle:
            switch number {
            case .one:
                paths.append(setSquigglePathAtPoint(CGPoint(x: bounds.maxX - cornerRadius, y: bounds.midY)))
            case .two:
                paths.append(setSquigglePathAtPoint(CGPoint(x: bounds.maxX - cornerRadius, y: bounds.midY / 2)))
                paths.append(setSquigglePathAtPoint(CGPoint(x: bounds.maxX - cornerRadius, y: bounds.midY / 2 + bounds.height / 4)))
            case .three:
                paths.append(setSquigglePathAtPoint(CGPoint(x: bounds.maxX - cornerRadius, y: bounds.midY / 2)))
                paths.append(setSquigglePathAtPoint(CGPoint(x: bounds.maxX - cornerRadius, y: bounds.midY)))
                paths.append(setSquigglePathAtPoint(CGPoint(x: bounds.maxX - cornerRadius, y: bounds.midY + bounds.midY / 2)))
            }
        case .circle:
            switch number {
            case .one:
                paths.append(setCirclePathAtPoint(CGPoint(x: bounds.midX - cornerRadius, y: bounds.midY + cornerRadius)))
            case .two:
                paths.append(setCirclePathAtPoint(CGPoint(x: bounds.midX - cornerRadius, y: bounds.midY / 2 + cornerRadius)))
                paths.append(setCirclePathAtPoint(CGPoint(x: bounds.midX - cornerRadius, y: bounds.midY + cornerRadius)))
            case .three:
                paths.append(setCirclePathAtPoint(CGPoint(x: bounds.midX - cornerRadius, y: bounds.midY / 2 + cornerRadius)))
                paths.append(setCirclePathAtPoint(CGPoint(x: bounds.midX - cornerRadius, y: bounds.midY + cornerRadius)))
                paths.append(setCirclePathAtPoint(CGPoint(x: bounds.midX - cornerRadius, y: bounds.midY + (bounds.midY) / 2 + cornerRadius)))
            }
        case .diamond:
            switch number {
            case .one:
                paths.append(setDiamondPathAtPoint(CGPoint(x: bounds.midX, y: (bounds.midY / 4) + bounds.height / 4)))
            case .two:
                paths.append(setDiamondPathAtPoint(CGPoint(x: bounds.midX, y: bounds.midY / 2 )))
                paths.append(setDiamondPathAtPoint(CGPoint(x: bounds.midX, y: bounds.midY)))
            case .three:
                paths.append(setDiamondPathAtPoint(CGPoint(x: bounds.midX, y: bounds.midY / 4 + cornerRadius)))
                paths.append(setDiamondPathAtPoint(CGPoint(x: bounds.midX, y: (bounds.midY / 4) + bounds.height / 4 + cornerRadius)))
                paths.append(setDiamondPathAtPoint(CGPoint(x: bounds.midX, y: bounds.midY + (bounds.midY / 4) + cornerRadius)))
            }
        }
        
        return paths
    }
    

    private var selectionLayerColor: UIColor {
        if !cardIsSelected {
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        } else {
            // Card is selected, change selection layer
            return #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        }
    }
    
    
    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: self.cornerRadius)
        roundedRect.addClip()
        UIColor.white.setFill()
        roundedRect.fill()
        
        let paths = self.drawAllPicturePaths(shapeType: shape!, number: numberOfShapes!)
        
        var shapeColor: UIColor = UIColor.white
        
        
        if let color = setCardColor {
            switch color {
            case .red:
                shapeColor = UIColor.red
            case .green:
                shapeColor = UIColor.green
            case .purple:
                shapeColor = UIColor.purple
            }
        }
        
        for path in paths {
            let context = UIGraphicsGetCurrentContext()
            context?.saveGState()
            
            path.addClip()
            if let shading = striping {
                switch shading {
                case .solid:
                    shapeColor.setFill()
                    path.fill()
                case .striped:
                    shapeColor.setStroke()
                    path.stroke()
                    for x in stride(from: 0, to: bounds.width, by: bounds.width / 20) {
                        let stripePath = UIBezierPath()
                        stripePath.move(to: CGPoint(x: x, y: 0)) // uncertain where y is
                        stripePath.addLine(to: CGPoint(x: x, y: bounds.height))
                        stripePath.stroke()
                    }
                case .open:
                    shapeColor.setStroke()
                    path.stroke()
                }
            }
            context?.restoreGState()
            
        }
     
        let border = UIBezierPath(rect: CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.width, height: bounds.height))
        border.lineWidth = self.cardIsSelected ? 5.0 : 3.0
        selectionLayerColor.setStroke()
        border.stroke()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsDisplay()
        setNeedsLayout()
    }

}

extension SetCardView {
    private struct SizeRatio {
        static let cornerFontSizeToBoundsHeight: CGFloat = 0.085
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
        static let cornerOffsetToCornerRadius: CGFloat = 0.33
        static let faceCardImageSizeToBoundsSize: CGFloat = 0.75
    }
    
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    private var cornerOffset: CGFloat {
        return cornerRadius * SizeRatio.cornerOffsetToCornerRadius
    }
    private var cornerFontSize: CGFloat {
        return bounds.size.height * SizeRatio.cornerFontSizeToBoundsHeight
    }
}
