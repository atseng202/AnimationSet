//
//  Card.swift
//  SetV2
//
//  Created by Alan Tseng on 1/22/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import Foundation

struct SetCard: CustomStringConvertible, Equatable
{
    static func ==(lhs: SetCard, rhs: SetCard) -> Bool {
        return lhs.color == rhs.color &&
            lhs.shading == rhs.shading &&
            lhs.shape == rhs.shape &&
            lhs.number == rhs.number
    }
    
    var description: String {
        return "\(number) \(shading) \(color) \(shape)"
    }
    
    enum Shape: String, CustomStringConvertible {
        var description: String { return rawValue }
        
        case diamond = "diamond"
        case circle = "circle"
        case squiggle = "squiggle"
        
        static var all = [Shape.diamond, .circle, .squiggle]
    }
    
    enum Shading: String, CustomStringConvertible {
        var description: String { return rawValue }
        
        case solid = "solid"
        case striped = "striped"
        case open = "open"
        
        static var all = [Shading.solid, .striped, .open]
    }
    
    enum Color: String, CustomStringConvertible {
        var description: String { return rawValue }
        
        case red = "red"
        case green = "green"
        case purple = "purple"
        
        static var all = [Color.red, .green, .purple]
    }
    
    enum Number: Int, CustomStringConvertible {
        var description: String { return String(rawValue) }
        
        case one = 1
        case two = 2
        case three = 3
        
        static var all = [Number.one, .two, .three]
    }
    
    var shape: Shape
    var shading: Shading
    var color: Color
    var number: Number
    
}
