//
//  SetGame.swift
//  SetV2
//
//  Created by Alan Tseng on 1/22/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import Foundation

struct SetGame {
    
    private(set) var deck = SetDeck()
    
    private var numberOfCards: Int {
        return deck.cards.count
    }
    
    var cardsActivelyInPlay = [SetCard]()
    
    
    private(set) var selectedCards = [SetCard]()
    
    private(set) var gameScore = 0.0
    
    private(set) var pointsGivenForMatch = 6.0
    
    private(set) var setIsAvailable = false
    
    // MARK: - Initializer
    /// Creates a game instance with 12 random cards drawn from the SetDeck onto the array of
    /// active cards in play.
    init() {
        for _ in 1...12 {
            cardsActivelyInPlay.append(deck.draw()!)
        }
    }
    
    // MARK: - Action Methods
    
    /**
     
     Chooses a card from an array of cards actively in play, replacing cards with the SetDeck if 3 are matching before a selection
     
     - Author:
     Alan Tseng
     
     -Important:
     A detailed description can go here
     
     - returns:
     Void
     
     - parameters:
        - index: The index of the card being chosen from the cards in play based off the UIButton number
     
     
     */
    // MARK: - Method first evaluates if a set exists for the currently selected cards, and then selects the newest card after 
    mutating func chooseCard(at index: Int) {
        assert(cardsActivelyInPlay.indices.contains(index), "Set.chooseCard(at: \(index)): chosen index is not one of the cards in play")
        
        print("Choosing card in play at original index of: \(index). Note that cards may be removed from model if there is a match")
        print("Original # of cards in play: \(cardsActivelyInPlay.count)")
        
        if selectedCards.contains(cardsActivelyInPlay[index]) {
            selectedCards.remove(at: selectedCards.index(of: cardsActivelyInPlay[index])!)
            self.setIsAvailable = false
            return
        }
        // pointer to selected card 
        let newlySelectedCard = cardsActivelyInPlay[index]
        
        // First check if there are 3 cards selected that match
        if selectedCards.count == 3 {
            // Next check for match
            if isASetMatch(selectedCards) {
                self.setIsAvailable = true
                // Remove the matched cards in play and replace with 3 new cards
                self.replaceMatchedCardsWithNewCards()
            } else {
                // No match so remove the 3 selected cards
                selectedCards.removeAll()
                self.gameScore -= 3
                self.setIsAvailable = false 
            }
        } else {
            self.setIsAvailable = false
        }
        // After cards are removed or not in model, add newly selected card to my array
        selectedCards.append(newlySelectedCard)
        print("This card was just selected in the model: ", newlySelectedCard)
    }
    
    /// Returns a Boolean indicating whether the 3 cards in the selectedCards parameter are
    /// matching based on the Set Game match logic
    func isASetMatch(_ selectedCards: [SetCard] ) -> Bool {
        if selectedCards.count < 3 {
            return false
        }
//        return true

        let colors = Set(selectedCards.map { $0.color })
        let shades = Set(selectedCards.map {$0.shading })
        let numbers = Set(selectedCards.map {$0.number })
        let shapes = Set(selectedCards.map {$0.shape })
        
        return colors.count != 2 && shades.count != 2 && numbers.count != 2 && shapes.count != 2
        
    }
    
    // MARK: - Helper Method to add cards to end of table
    
    /// Removes and inserts card from deck into table of cards actively in play if there is
    /// room and the deck is not empty, and decrements points given by 0.5.
    mutating func drawThreeMoreCards() {
        for _ in 0..<3 {
            if deck.cards.count > 0 {
                cardsActivelyInPlay.append(deck.draw()!)
            }
        }
        if self.pointsGivenForMatch > 1 {
            self.pointsGivenForMatch -= 0.5
        }
    }
    
    // MARK: - Helper Method to add cards in place of removed cards
    
    /// Removes a selected card and inserts a random card from the SetDeck into the table of
    /// cards actively in play if the deck is not empty, and clears the array of selected
    /// cards.
    mutating func replaceMatchedCardsWithNewCards() {
        for card in selectedCards {
            if cardsActivelyInPlay.contains(card) {
                // Add new card in, then remove matched card at index it is found
                if deck.cards.count > 0 {
                    let drawnCard = deck.draw()!
                    cardsActivelyInPlay.insert(drawnCard, at: cardsActivelyInPlay.index(of: card)!)
                    print("Drew card out of deck: \(drawnCard)")
                }
                print("Removing card in play at index: \(cardsActivelyInPlay.index(of: card)!)")
                
                cardsActivelyInPlay.remove(at: cardsActivelyInPlay.index(of: card)!)
                
            }
        }
        print("Final count of cards in play: \(cardsActivelyInPlay.count)")
        selectedCards.removeAll()
        self.gameScore += pointsGivenForMatch
        
    }

    mutating func reduceScoreForWrongSet() {
        gameScore -= 3
    }
    
    mutating func reshuffleCardsOnTable() {
        var temporaryDeck = [SetCard]()
        for card in cardsActivelyInPlay {
            temporaryDeck.append(card)
        }
        cardsActivelyInPlay.removeAll()
        
        while temporaryDeck.count > 0 {
            cardsActivelyInPlay.append(temporaryDeck.remove(at: temporaryDeck.count.arc4Random))
        }
    }
    
    
}
