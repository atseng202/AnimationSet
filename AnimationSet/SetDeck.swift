//
//  SetDeck.swift
//  SetV2
//
//  Created by Alan Tseng on 1/22/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import Foundation

struct SetDeck
{
    private(set) var cards = [SetCard]()
    
    init() {
        for shape in SetCard.Shape.all {
            for shading in SetCard.Shading.all {
                for color in SetCard.Color.all {
                    for number in SetCard.Number.all {
                        cards.append(SetCard(shape: shape, shading: shading, color: color, number: number))
                    }
                }
            }
        }
    }
    
    mutating func draw() -> SetCard? {
        if cards.count > 0 {
            return cards.remove(at: cards.count.arc4Random)
        } else {
            return nil
        }
    }
}



extension Int {
    var arc4Random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}

