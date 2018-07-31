//
//  Card.swift
//  Concentration
//
//  Created by Alan Tseng on 11/29/17.
//  Copyright © 2017 Alan Tseng. All rights reserved.
//

import Foundation

struct Card: Hashable {
    var hashValue: Int { return identifier }
    
    static func ==(lhs: Card, rhs: Card) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    
    var wasPreviouslyFlipped = false 
    var isFaceUp = false
    var isMatched = false
    private var identifier: Int // encapsulate it since we have hash values now using identifiers
    
    private static var identifierFactory = 0
    
    private static func getUniqueIdentifier() -> Int {
        identifierFactory += 1
        return identifierFactory
    }
    
    init() {
        self.identifier = Card.getUniqueIdentifier()
    }
    
}
