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

    var shape: SetCard.Shape? {
        return card?.shape
    }

    var striping: SetCard.Shading? {
        return card?.shading
    }

    var setCardColor: SetCard.Color? {
        return card?.color
    }

    var numberOfShapes: SetCard.Number? {
        return card?.number
    }

    var cardIsSelected: Bool = false
    var isFaceUp: Bool

    // MARK: - New initializer that with less dependencies since we use GraphicsView to defer drawing of graphics
    convenience init(frame: CGRect, card: SetCard) {
        self.init(frame: frame)
        self.card = card
        self.cardIsSelected = false
        self.isFaceUp = false
        self.backgroundColor = UIColor.lightGray
    }

    //    convenience init(frame: CGRect, shape: SetCard.Shape, striping: SetCard.Shading, setCardColor: SetCard.Color, numberOfShapes: SetCard.Number, card: SetCard) {
    //        self.init(frame: frame)
    //
    //        self.shape = shape
    //        self.striping = striping
    //        self.setCardColor = setCardColor
    //        self.numberOfShapes = numberOfShapes
    //        self.card = card
    //    }

    required init?(coder aDecoder: NSCoder) {
        self.isFaceUp = false
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        self.isFaceUp = false
        super.init(frame: frame)
    }

    // MARK: - Helpers For Graphics Drawing
    // Note: This var holds the frames of the individual graphics which change according to the number of graphics (1, 2, or 3)
    private var graphicsFrames: [CGRect] {
        var frames = [CGRect]()
        guard let numberOfShapes = numberOfShapes else { return [] }
        var initialY = spaceBetweenGraphics
        // First graphic frame
        var graphicFrame = CGRect(x: graphicsMargin, y: initialY, width: heightOfOneGraphic, height: heightOfOneGraphic)
        frames.append(graphicFrame)

        for _ in 1..<numberOfShapes.rawValue {
            initialY += (heightOfOneGraphic + spaceBetweenGraphics)
            graphicFrame = CGRect(x: graphicsMargin, y: initialY, width: heightOfOneGraphic, height: heightOfOneGraphic)
            frames.append(graphicFrame)
        }
        return frames
    }

    private var heightOfOneGraphic: CGFloat {
        return bounds.height / 4
    }

    private var graphicsMargin: CGFloat {
        return bounds.midX - heightOfOneGraphic / 2
    }

    private var spaceBetweenGraphics: CGFloat {
        if let numberOfShapes = numberOfShapes {
            switch numberOfShapes {
            case .one:
                return bounds.height * 3/8
            case .two:
                return bounds.height * 1/6
            case .three:
                return cornerRadius
            }
        }
        return bounds.height * 3/8
    }


    private var selectionLayerColor: UIColor {
        if !cardIsSelected {
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        } else {
            // Card is selected, change selection layer
            return #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        }
    }

    private func drawGraphics() {
        for graphic in self.subviews {
            graphic.removeFromSuperview()
        }

        if let numberOfShapes = numberOfShapes?.rawValue, let card = card {
            for i in 0..<numberOfShapes {
                let graphicView  = GraphicsView(frame: graphicsFrames[i], shape: card.shape, striping: card.shading, color: card.color)
                graphicView.clipsToBounds = true
                self.addSubview(graphicView)
            }
        }
    }


    override func draw(_ rect: CGRect) {
        if isFaceUp {
            drawGraphics()
            let border = UIBezierPath(rect: CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.width, height: bounds.height))
            border.lineWidth = self.cardIsSelected ? 5.0 : 3.0
            selectionLayerColor.setStroke()
            border.stroke()
        } else {
            let faceDownFill = UIBezierPath(rect: bounds)
            UIColor.magenta.setFill()
            faceDownFill.fill()
        }

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsDisplay()
        setNeedsLayout()
    }

    // MARK: - Helper Path Methods Being Phased Out
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
