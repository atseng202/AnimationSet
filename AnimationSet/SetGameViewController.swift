//
//  ViewController.swift
//  SetV2
//
//  Created by Alan Tseng on 1/22/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import UIKit

class SetGameViewController: UIViewController {
    
    private var setGame = SetGame()
    
    private var numberOfSelectedCards = 0
    
    private var gameScoreLabel: UILabel!
    
    private var restartButton: UIButton!
    
    private var dealButton: UIButton!
    
    var cardsOnScreen = [SetCardView]()
    
    var indicesOfCardsUntouchedOnTable = [Int]()
    
    var selectedCards = [SetCardView]()
    
    var mostRecentMatchedCards = [SetCardView]()
    
    private func setCardsFrame() -> CGRect {
        let marginBetweenButtonAndCards = CGFloat(8)
        let bottomMargin = CGFloat(100)
        let dealButtonSize = CGSize(width: 100, height: 50)
        let cardsOnlyFrame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height - dealButtonSize.height - bottomMargin - marginBetweenButtonAndCards)
        return cardsOnlyFrame
    }
    
    // MARK: - Animation Assignment / Animator Variables
    
    var discardPileCount = 0 { didSet { discardPileLabel.text = "\(discardPileCount) Set(s)" }}
    
    var discardPileLabel: UILabel!
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    
    // MARK: - View Lifecyle Methods
    override func viewDidLoad() {
        print("View did load")
        super.viewDidLoad()
        
//        let bottomMargin = CGFloat(8) //Space between button and bottom of the screen
        let buttonSize = CGSize(width: 100, height: 50)
        
        dealButton = UIButton()
        // dealButton.center = CGPoint(x: view.bounds.size.width / 2, y: view.bounds.size.height - buttonSize.height / 2 - bottomMargin)
        dealButton.setTitle("Deal", for: .normal)
        dealButton.titleLabel?.adjustsFontSizeToFitWidth = true
        dealButton.backgroundColor = UIColor.purple.withAlphaComponent(0.5)
        
        dealButton.addTarget(self, action: #selector(SetGameViewController.dealThreeMoreCards(_:)), for: .touchUpInside)
        view.addSubview(dealButton)
        dealButton.translatesAutoresizingMaskIntoConstraints = false
        
//        gameScoreLabel = UILabel(frame: CGRect(x: 0, y: 0, width: buttonSize.width, height: buttonSize.height))
//        gameScoreLabel.text = "Score: \(setGame.gameScore)"
//        gameScoreLabel.textAlignment = .left
//        gameScoreLabel.numberOfLines = 0
//        gameScoreLabel.backgroundColor = UIColor.purple
//        gameScoreLabel.textColor = UIColor.white
//        gameScoreLabel.adjustsFontSizeToFitWidth = true
        // Placing discard pile in this area first
//        view.addSubview(gameScoreLabel)
        
        restartButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonSize.width, height: buttonSize.height))
        restartButton.setTitle("Restart Game", for: .normal)
        restartButton.titleLabel?.adjustsFontSizeToFitWidth = true
        restartButton.backgroundColor = UIColor.purple.withAlphaComponent(0.5)
        
        restartButton.addTarget(self, action: #selector(self.startNewGame(_:)), for: .touchUpInside)
        view.addSubview(restartButton)
        restartButton.translatesAutoresizingMaskIntoConstraints = false
        
        discardPileLabel = UILabel(frame: dealButton.frame)
        discardPileLabel.text = "\(discardPileCount) Set(s)"
        discardPileLabel.textAlignment = .left
        discardPileLabel.numberOfLines = 1
        discardPileLabel.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        discardPileLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        discardPileLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(discardPileLabel)
        
        
        let guide = view.safeAreaLayoutGuide
        let margins = view.layoutMarginsGuide
        
        dealButton.trailingAnchor.constraint(equalTo: discardPileLabel.leadingAnchor, constant: -8).isActive = true
        dealButton.leadingAnchor.constraint(equalTo: restartButton.trailingAnchor, constant: 8).isActive = true
        dealButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -16).isActive = true
        
        
//        gameScoreLabel.translatesAutoresizingMaskIntoConstraints = false
//        gameScoreLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -8).isActive = true
//        gameScoreLabel.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -8).isActive = true
        
        restartButton.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 8).isActive = true
        restartButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -16).isActive = true
        
        discardPileLabel.translatesAutoresizingMaskIntoConstraints = false 
        discardPileLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -8).isActive = true
        discardPileLabel.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -16).isActive = true
    
        self.updateViewFromModel()
    }
    
    override func loadView() {
        print("Loading View")
        super.loadView()
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.dealThreeMoreCards(_:)))
        swipe.direction = .down
        view.addGestureRecognizer(swipe)
        
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(self.reshuffle(_:)))
        view.addGestureRecognizer(rotation)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        print("Laying out subviews")
        if setGame.deck.cards.isEmpty {
            dealButton.alpha = 0 
        }

    }
    
    // MARK: - Action Methods
    @objc func touchCard(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            if let cardView = sender.view as? SetCardView {
                
                var cardIndex = cardsOnScreen.index(of: cardView)!
                print("Tapped: \(setGame.cardsActivelyInPlay[cardIndex])")
                
                setGame.chooseCard(at: cardIndex)
                
                // Clean-up before updating view from model
                mostRecentMatchedCards.forEach { $0.removeFromSuperview() }
                print("Removed previously matched cards from view")
                mostRecentMatchedCards.removeAll()
                
                if setGame.setIsAvailable {
                    // Set should only be available on selection of 4th card and
                    // match occurred in model for the first 3 cards
                    print("We have a match")
                    
                    // Place these most recently matched cards into the array for model updating
                    for card in selectedCards {
                        mostRecentMatchedCards.append(card)
                    }
                    // Finding the currently selected card from model
                    let indexOfCurrentlySelectedCard = setGame.cardsActivelyInPlay.index(of: setGame.selectedCards[0])
                    cardIndex = indexOfCurrentlySelectedCard!

                    
                    self.updateViewFromModel()
                    
                    selectedCards.removeAll()
                    numberOfSelectedCards = 0
                    
                } else {
                    print("No match")
                    if selectedCards.count == 3 {
                        cardsOnScreen.forEach {
                            $0.cardIsSelected = false
                            $0.setNeedsDisplay()
                        }
                        selectedCards.removeAll()
                        numberOfSelectedCards = 0
                    }
                }
                if selectedCards.count > 0 && selectedCards.count < 3, cardsOnScreen[cardIndex].cardIsSelected {
                    print("Deselecting card")
                    selectedCards.remove(at: selectedCards.index(of: cardsOnScreen[cardIndex])!)

                    cardsOnScreen[cardIndex].cardIsSelected = false
                    numberOfSelectedCards -= 1
                    cardsOnScreen[cardIndex].setNeedsDisplay()
                } else {
                    print("Selecting card")

                    cardsOnScreen[cardIndex].cardIsSelected = true
                    numberOfSelectedCards += 1
                    selectedCards.append(cardsOnScreen[cardIndex])
                    cardsOnScreen[cardIndex].setNeedsDisplay()
                }
                // gameScoreLabel.text = "Score: \(setGame.gameScore)"
            }
        default:
            print("Unable to identify which card was tapped")
        }
    }
    
    @objc func dealThreeMoreCards(_ sender: UIBarButtonItem) {
        print("Dealing 3 more cards if possible")
        
        // Clean-up before updating view from model
        mostRecentMatchedCards.forEach { $0.removeFromSuperview() }
        print("Removed previously matched cards from view")
        mostRecentMatchedCards.removeAll()
        
        let deckCountBeforeRemoval = setGame.deck.cards.count
        
        if selectedCards.count == 3 {
            if setGame.isASetMatch(setGame.selectedCards) {
                setGame.replaceMatchedCardsWithNewCards()
//                 gameScoreLabel.text = "Score: \(setGame.gameScore)"
                
                // Keep track of most recent matched cards
                for card in selectedCards {
                    mostRecentMatchedCards.append(card)
                }
                
                // Attempting to "fly away" matched cards here
                self.updateViewFromModel()
            }
        } else {
            setGame.drawThreeMoreCards()
            if deckCountBeforeRemoval != 0 {
                self.updateViewFromModel()
            }
        }

    }
    

    
    @objc func startNewGame(_ sender: UIButton) {
        print("Restarting game")
        setGame = SetGame()
        // gameScoreLabel.text = "Score: \(setGame.gameScore)"
        
        selectedCards.removeAll()
        numberOfSelectedCards = 0
        discardPileCount = 0
        cardsOnScreen.forEach { $0.removeFromSuperview() }
        cardsOnScreen.removeAll()
        mostRecentMatchedCards.forEach { $0.removeFromSuperview() }
        mostRecentMatchedCards.removeAll()
        self.updateViewFromModel()
 
    }
    
    @objc func reshuffle(_ recognizer: UIRotationGestureRecognizer) {
        print("Re-shuffling deck")
        
        setGame.reshuffleCardsOnTable()
        
        self.updateViewFromModel()
    }

    // MARK: - View Helper Functions
    private func updateViewFromModel() {
        print("Updating view from model")
        setUpCardViews()
        // Final clean up since this array will be refreshed for the next view update
        indicesOfCardsUntouchedOnTable.removeAll()
        


    }
    private func setUpCardViews() {
        let frame = setCardsFrame()
        var setGrid = Grid(layout: .aspectRatio(5/8), frame: frame)
        let notUpdatedCardsOnScreenCount = self.cardsOnScreen.count
        setGrid.cellCount = notUpdatedCardsOnScreenCount == 0 ? setGame.cardsActivelyInPlay.count : notUpdatedCardsOnScreenCount
        
        var matchedIndices = [Int]()
        
        // Initially filter and check for the indices of cards un-matched and remaining on table
        // Also Keep track of matched indices in an array
        if notUpdatedCardsOnScreenCount > 0 {
            print("There are \(notUpdatedCardsOnScreenCount) cards before any updates")
            var matchedCards = [SetCard]()
            if !mostRecentMatchedCards.isEmpty {
                for cardView in mostRecentMatchedCards {
                    matchedCards.append(cardView.card!)
                }
            }
            for index in 0..<cardsOnScreen.count {
                // if not empty, there are 3 matched cards
                if !mostRecentMatchedCards.isEmpty, matchedCards.contains(cardsOnScreen[index].card!) {
                    matchedIndices.append(index)
                } else {
                    indicesOfCardsUntouchedOnTable.append(index)
                }

            }
        }
        self.cardsOnScreen.forEach {
            $0.removeFromSuperview()
        }
        self.cardsOnScreen.removeAll()

        // Fix my conditions to compare if I have the same # of cards as the last model, less number, or more number of cards
        if notUpdatedCardsOnScreenCount == 0 {
            print("This is the start of a new game")
            // Gamme was restarted or just launched
            for index in setGame.cardsActivelyInPlay.indices {
                let card = setGame.cardsActivelyInPlay[index]
                 
                let cardView = SetCardView(frame: setGrid[index]!, shape: card.shape, striping: card.shading, setCardColor: card.color, numberOfShapes: card.number, card: card)
                if setGame.selectedCards.contains(card) {
                    cardView.cardIsSelected = true
                }
                cardsOnScreen.append(cardView)
                
                view.addSubview(cardsOnScreen[index])

                cardsOnScreen[index].contentMode = .redraw
                cardsOnScreen[index].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SetGameViewController.touchCard(_:))))
            }
        }
           else  if setGame.cardsActivelyInPlay.count < notUpdatedCardsOnScreenCount, !matchedIndices.isEmpty {
            print("There are going to be less cards on the table than before, I have 3 matched cards, please animate the matched cards")
            print("out of the screen, then animate the changing of grid frames of the remaining cards")
            for position in 0..<3 {
                let cardIndex = matchedIndices[position]
                print("Card index: \(cardIndex)")
                mostRecentMatchedCards[position].frame = setGrid[cardIndex]!
                view.addSubview(mostRecentMatchedCards[position])
            }
            // Experiment #2
            var cardCount = 0
            for cardIndex in 0..<notUpdatedCardsOnScreenCount {
                if cardCount == setGame.cardsActivelyInPlay.count { break }
                if matchedIndices.contains(cardIndex) {
                    continue
                } else {
                    let card = setGame.cardsActivelyInPlay[cardCount]
                    print("Card View index currently incremented to \(cardCount)")
                    let cardView = SetCardView(frame: setGrid[cardIndex]!, shape: card.shape, striping: card.shading, setCardColor: card.color, numberOfShapes: card.number, card: card)
                    if setGame.selectedCards.contains(card) {
                        cardView.cardIsSelected = true
                    }
                    cardsOnScreen.append(cardView)
                    
                    view.addSubview(cardsOnScreen[cardCount])
                    
                    
                    //                cardsOnScreen[index].alpha = 1
                    cardsOnScreen[cardCount].contentMode = .redraw
                    cardsOnScreen[cardCount].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SetGameViewController.touchCard(_:))))
                    
                    cardCount += 1
                }
            }
            // Animate out matched cards to discard pile, then change alpha to 0
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.6, delay: 0, options: [], animations: { self.mostRecentMatchedCards.forEach {
                    $0.frame = self.discardPileLabel.frame
                } }, completion: {position in
                    setGrid = Grid(layout: .aspectRatio(5/8), frame: frame)
                    setGrid.cellCount = self.setGame.cardsActivelyInPlay.count
                    
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.6, delay: 1.0, options: [], animations: {
                        for index in self.cardsOnScreen.indices {
                            self.cardsOnScreen[index].frame = setGrid[index]!
                        }
                        self.mostRecentMatchedCards.forEach {
                            $0.alpha = 0
                        }
                        self.discardPileCount += 1
                    }, completion: nil)
            })
        } else if setGame.cardsActivelyInPlay.count > notUpdatedCardsOnScreenCount, matchedIndices.isEmpty {
            print("I dealt in 3 new cards, I don't have any matches, please just update the view for any additional cards dealt in")
            var cardsToAnimateIn = [SetCardView]()
            var indicesToAnimateIn = [Int]()
            
            // Have to change the grid again
            setGrid.cellCount = setGame.cardsActivelyInPlay.count
            for index in setGame.cardsActivelyInPlay.indices {
                let card = setGame.cardsActivelyInPlay[index]
                let cardView = SetCardView(frame: setGrid[index]!, shape: card.shape, striping: card.shading, setCardColor: card.color, numberOfShapes: card.number, card: card)
                if setGame.selectedCards.contains(card) {
                    cardView.cardIsSelected = true
                }
                cardsOnScreen.append(cardView)
                
                view.addSubview(cardsOnScreen[index])
                
                //                cardsOnScreen[index].alpha = 1
                cardsOnScreen[index].contentMode = .redraw
                cardsOnScreen[index].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SetGameViewController.touchCard(_:))))
                
                // Final condition: check if the card was on screen before
                // If not, we want to animate it in
                if !indicesOfCardsUntouchedOnTable.contains(index) {
                    cardsOnScreen[index].frame = dealButton.frame
                    cardsOnScreen[index].alpha = 0
                    cardsToAnimateIn.append(cardsOnScreen[index])
                    indicesToAnimateIn.append(index)
                }
            }
            // Animate in the new cards
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, options: [],
                animations: {
                    for index in self.cardsOnScreen.indices {
                        if cardsToAnimateIn.contains(self.cardsOnScreen[index]) {
                            self.cardsOnScreen[index].frame = setGrid[index]!
                            self.cardsOnScreen[index].alpha = 1
                        }
                    }
                }, completion: nil)
            
        } else if setGame.cardsActivelyInPlay.count == notUpdatedCardsOnScreenCount, !matchedIndices.isEmpty {
            print("There is a match, 3 matched cards have been replaced with 3 new cards, please update the view so the deck will animate in 3 cards in place of the 3 matches cards and keep the remaining cards in place")
            
            // Set up old cards to be animated out later
            for position in 0..<3 {
                let cardIndex = matchedIndices[position]
                print("Card index: \(cardIndex)")
                mostRecentMatchedCards[position].frame = setGrid[cardIndex]!
                view.addSubview(mostRecentMatchedCards[position])
            }
            // Add in all the new cards but keep the replacement cards in the deck to be animated in
            var cardsToAnimateIn = [SetCardView]()
            var indicesToAnimateIn = [Int]()
            for index in setGame.cardsActivelyInPlay.indices {
                let card = setGame.cardsActivelyInPlay[index]
                let cardView = SetCardView(frame: setGrid[index]!, shape: card.shape, striping: card.shading, setCardColor: card.color, numberOfShapes: card.number, card: card)
                if setGame.selectedCards.contains(card) {
                    cardView.cardIsSelected = true
                }
                cardsOnScreen.append(cardView)
                
                view.addSubview(cardsOnScreen[index])
                cardsOnScreen[index].contentMode = .redraw
                cardsOnScreen[index].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SetGameViewController.touchCard(_:))))
                // Need to animate out old cards first
                if matchedIndices.contains(index) {
                    cardsOnScreen[index].frame = dealButton.frame
                    cardsToAnimateIn.append(cardsOnScreen[index])
                    indicesToAnimateIn.append(index)
                }
            }
            // Animate out old cards, then animate in new cards
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.5, delay: 0,options: [],
                animations: {
                    self.mostRecentMatchedCards.forEach {
                        $0.frame = self.discardPileLabel.frame
                    }
            }, completion: {
                position in
                
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.6, delay: 2.0, options: [], animations: {
                    for index in self.cardsOnScreen.indices {
                        if cardsToAnimateIn.contains(self.cardsOnScreen[index]) {
                            self.cardsOnScreen[index].frame = setGrid[index]!
                        }
                    }
                    self.mostRecentMatchedCards.forEach {
                        $0.alpha = 0
                    }
                    self.discardPileCount += 1
                }, completion: nil)
            })
            
            
        }
    }

}

