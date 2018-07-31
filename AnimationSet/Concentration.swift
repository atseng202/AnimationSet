//
//  Concentration.swift
//  Concentration
//
//  Created by Alan Tseng on 11/29/17.
//  Copyright © 2017 Alan Tseng. All rights reserved.
//

import Foundation

struct Concentration {

    private(set) var cards = [Card]()
    
    private var indexOfOneAndOnlyFaceUpCard: Int? {
        get {
            return cards.indices.filter { cards[$0].isFaceUp }.oneAndOnly
//            return faceUpCardIndices.count == 1 ? faceUpCardIndices.first : nil
//            var foundIndex: Int?
//            for index in cards.indices {
//                if cards[index].isFaceUp {
//                    if foundIndex == nil {
//                        foundIndex = index
//                    } else {
//                        return nil
//                    }
//                }
//            }
//            return foundIndex
        }
        set {
            for index in cards.indices {
                cards[index].isFaceUp = false
            }
            let newIndex = newValue!
            cards[newIndex].isFaceUp = true
        }
    }
    
    private(set) var flipCount: Int = 0
    
    private(set) var gameScore: Int = 0
    
    private var cardsPreviouslyFlipped = [Card]()
    
    private var pairCountIncludingDuplicate = 0
    
    mutating func chooseCard(at index: Int) {
        assert(cards.indices.contains(index), "Concentration.chooseCard(at: \(index)): chosen index not in the cards")
        // model will flip card over
        if !cards[index].isMatched {
            if let matchIndex = indexOfOneAndOnlyFaceUpCard, matchIndex != index {
                // check if cards match
                if cards[matchIndex] == cards[index] {
                    cards[matchIndex].isMatched = true
                    cards[index].isMatched = true
                    gameScore += 2
                } else { // find out if the non-matched cards have pairs that were previously flipped
                    if !cards[index].wasPreviouslyFlipped {
                        cards[index].wasPreviouslyFlipped = true
                        cardsPreviouslyFlipped.append(cards[index])
                    }
                    else if cards[index].wasPreviouslyFlipped {
                        for flippedIndex in cardsPreviouslyFlipped.indices {
                            if cards[index] == cardsPreviouslyFlipped[flippedIndex] {
                                pairCountIncludingDuplicate += 1
                            }
                        }
                        pairCountIncludingDuplicate -= 1 // to delete duplicate
                    }
                    for _ in 0..<pairCountIncludingDuplicate {
                        gameScore -= 1
                    }
                }
                cards[index].isFaceUp = true
//                indexOfOneAndOnlyFaceUpCard = nil
                pairCountIncludingDuplicate = 0
            } else {
                // 0 cards or 2 cards are already faced up so indexOfOneAndOnly is nil
//                for flipDownIndex in cards.indices {
//                    cards[flipDownIndex].isFaceUp = false
//                }
//                cards[index].isFaceUp = true
                indexOfOneAndOnlyFaceUpCard = index
                
                if !cards[index].wasPreviouslyFlipped {
                    cards[index].wasPreviouslyFlipped = true
                    cardsPreviouslyFlipped.append(cards[index])
                } else {
                    for flippedIndex in cardsPreviouslyFlipped.indices {
                        if cards[index] == cardsPreviouslyFlipped[flippedIndex] {
                            pairCountIncludingDuplicate += 1
                        }
                    }
                    pairCountIncludingDuplicate -= 1 // delete duplicate
                }
                
            }
            flipCount += 1
        }
    }
    
    init(numberOfPairsOfCards: Int) {
        assert(numberOfPairsOfCards > 0, "Concentration.init(\(numberOfPairsOfCards)): you must have at least 1 pair of cards")
        for _ in 1...numberOfPairsOfCards {
            let card = Card()
            // appending will make a new copy of card not reference
            cards += [card, card]
        }

        // TODO: Shuffle the cards
    }
}

extension Collection {
    var oneAndOnly: Element? {
        return count == 1 ? first : nil
    }
}

