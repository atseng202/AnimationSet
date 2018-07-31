//
//  GraphicsView.swift
//  Concentration
//
//  Created by Alan Tseng on 7/20/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import UIKit

class GraphicsView: UIView {

    var shape: SetCard.Shape? { didSet {setNeedsDisplay(); setNeedsLayout() } }
    var striping: SetCard.Shading? { didSet {setNeedsDisplay(); setNeedsLayout() } }
    var setCardColor: SetCard.Color? { didSet {setNeedsDisplay(); setNeedsLayout() } }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    convenience init(frame: CGRect, shape: SetCard.Shape, striping: SetCard.Shading, color: SetCard.Color) {
        self.init(frame: frame)
        self.clipsToBounds = true
        self.shape = shape
        self.striping = striping
        self.setCardColor = color
//        self.backgroundColor = UIColor.lightGray
        self.backgroundColor = UIColor.init(red: 246/255, green: 237/255, blue: 233/255, alpha: 1)
    }

    private var shapePath: UIBezierPath {
        guard let shape = shape else { return UIBezierPath() }
        switch shape {
        case .circle:
            return UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY), radius: bounds.height / 2, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        case .diamond:
            let path = UIBezierPath()
            path.move(to: CGPoint(x: bounds.width / 2, y: bounds.origin.y))
            path.addLine(to: CGPoint(x: bounds.width, y: bounds.height / 2))
            path.addLine(to: CGPoint(x: bounds.width / 2, y: bounds.height))
            path.addLine(to: CGPoint(x: bounds.origin.x, y: bounds.height / 2))
            path.close()
            return path
        case .squiggle:
            let path = UIBezierPath()
            path.move(to: CGPoint(x: bounds.origin.x + bounds.size.width * 0.05, y: bounds.origin.y + bounds.size.height * 0.40))

            path.addCurve(to: CGPoint(x: bounds.origin.x + bounds.size.width * 0.35, y: bounds.origin.y + bounds.size.height * 0.25),
                          controlPoint1: CGPoint(x: bounds.origin.x + bounds.size.width*0.09, y: bounds.origin.y + bounds.size.height*0.15),
                          controlPoint2: CGPoint(x: bounds.origin.x + bounds.size.width*0.18, y: bounds.origin.y + bounds.size.height*0.10))

            path.addCurve(to: CGPoint(x: bounds.origin.x + bounds.size.width*0.75, y: bounds.origin.y + bounds.size.height*0.30),
                          controlPoint1: CGPoint(x: bounds.origin.x + bounds.size.width*0.40, y: bounds.origin.y + bounds.size.height*0.30),
                          controlPoint2: CGPoint(x: bounds.origin.x + bounds.size.width*0.60, y: bounds.origin.y + bounds.size.height*0.45))

            path.addCurve(to: CGPoint(x: bounds.origin.x + bounds.size.width*0.97, y: bounds.origin.y + bounds.size.height*0.35),
                          controlPoint1: CGPoint(x: bounds.origin.x + bounds.size.width*0.87, y: bounds.origin.y + bounds.size.height*0.15),
                          controlPoint2:CGPoint(x: bounds.origin.x + bounds.size.width*0.98, y: bounds.origin.y + bounds.size.height*0.00))

            path.addCurve(to: CGPoint(x: bounds.origin.x + bounds.size.width*0.45, y: bounds.origin.y + bounds.size.height*0.85),
                          controlPoint1: CGPoint(x: bounds.origin.x + bounds.size.width*0.95, y: bounds.origin.y + bounds.size.height*1.10),
                          controlPoint2: CGPoint(x: bounds.origin.x + bounds.size.width*0.50, y: bounds.origin.y + bounds.size.height*0.95))

            path.addCurve(to: CGPoint(x: bounds.origin.x + bounds.size.width*0.25, y: bounds.origin.y + bounds.size.height*0.85),
                          controlPoint1: CGPoint(x: bounds.origin.x + bounds.size.width*0.40, y: bounds.origin.y + bounds.size.height*0.80),
                          controlPoint2: CGPoint(x: bounds.origin.x + bounds.size.width*0.35, y: bounds.origin.y + bounds.size.height*0.75))

            path.addCurve(to: CGPoint(x: bounds.origin.x + bounds.size.width*0.05, y: bounds.origin.y + bounds.size.height*0.40),
                          controlPoint1:CGPoint(x: bounds.origin.x + bounds.size.width*0.00, y: bounds.origin.y + bounds.size.height*1.10),
                          controlPoint2: CGPoint(x: bounds.origin.x + bounds.size.width*0.005, y: bounds.origin.y + bounds.size.height*0.60))
            return path
        }
    }

    override func draw(_ rect: CGRect) {
        let shape = shapePath
        shape.addClip()

        var shapeColor = UIColor.white
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

        if let striping = striping {
            switch striping {
            case .solid:
                shapeColor.setFill()
                shape.fill()
            case .striped:
                shapeColor.setStroke()
                //                shape.stroke()
                for x in stride(from: 0, to: bounds.width, by: bounds.width / 10) {
                    let stripePath = UIBezierPath()
                    stripePath.move(to: CGPoint(x: x, y: 0)) // uncertain where y is
                    stripePath.addLine(to: CGPoint(x: x, y: bounds.height))
                    stripePath.stroke()
                }
            case .open:
                shapeColor.setStroke()
                shape.stroke()
            }
        }
    }


}
