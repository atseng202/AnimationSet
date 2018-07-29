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
    private var isStartOfGame = true
    private var gameUIState: GameAndDeckUIState = GameAndDeckUIState.newGameStarted
    private var numberOfSelectedCards = 0

    private lazy var restartButton: UIButton = {
        let restartButton = UIButton()
        restartButton.setTitle("Restart Game", for: .normal)
        restartButton.titleLabel?.adjustsFontSizeToFitWidth = true
        restartButton.backgroundColor = UIColor.purple.withAlphaComponent(0.5)
        restartButton.addTarget(self, action: #selector(self.startNewGame(_:)), for: .touchUpInside)
        return restartButton
    }()
    
    private lazy var dealButton: UIButton = {
        let button = UIButton()
        button.setTitle("Deal", for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.backgroundColor = UIColor.purple.withAlphaComponent(0.5)
        button.addTarget(self, action: #selector(SetGameViewController.dealThreeMoreCards(_:)), for: .touchUpInside)
        return button
    }()
    
    var cardsOnScreen = [SetCardView]()

    var cardsToAnimateOnOrOffScreen = [SetCardView]()
    
    var indicesOfCardsUntouchedOnTable = [Int]()
    
    var selectedCards = [SetCardView]()
    
    var mostRecentMatchedCards = [SetCardView]()

    var discardPileCount = 0 { didSet { discardPileLabel.text = "\(discardPileCount) Set(s)" } }
    
    lazy var discardPileLabel: UILabel = {
        let discardPileLabel = UILabel(frame: dealButton.frame)
        discardPileLabel.text = "\(discardPileCount) Set(s)"
        discardPileLabel.textAlignment = .center
        discardPileLabel.numberOfLines = 1
        discardPileLabel.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        discardPileLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        discardPileLabel.adjustsFontSizeToFitWidth = true
        return discardPileLabel
    }()

    lazy var gameScoreLabel: UILabel = {
        let gameScoreLabel = UILabel()
        gameScoreLabel.text = "Score: \(setGame.gameScore)"
        gameScoreLabel.textAlignment = .center
        gameScoreLabel.numberOfLines = 0
        gameScoreLabel.backgroundColor = UIColor.purple
        gameScoreLabel.textColor = UIColor.white
        gameScoreLabel.adjustsFontSizeToFitWidth = true
        return gameScoreLabel
    }()

    // ---------------------------------------------------------------
    // MARK: - Animation Assignment / Animator Variables

    lazy var dynamicAnimator = UIDynamicAnimator(referenceView: view)

    // ---------------------------------------------------------------
    // MARK: - Labels Setup
    lazy var setCardsContainerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .blue
        return containerView
    }()

    lazy var discardLabelAndScoreLabelContainerStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [discardPileLabel, gameScoreLabel])
        sv.axis = .vertical
        sv.spacing = 4
        sv.distribution = .fillEqually
        return sv
    }()

    lazy var horizontalLabelsContainerStackView: UIStackView = {
        let horizontalLabelsStackView = UIStackView(arrangedSubviews: [restartButton, dealButton, discardLabelAndScoreLabelContainerStackView])
        horizontalLabelsStackView.axis = .horizontal
        horizontalLabelsStackView.spacing = 8
        horizontalLabelsStackView.distribution = .fillEqually
        return horizontalLabelsStackView
    }()

    private func setupLabelsStackView() {
//        let horizontalLabelsStackView = UIStackView(arrangedSubviews: [restartButton, dealButton, discardPileLabel])
//        horizontalLabelsStackView.axis = .horizontal
//        horizontalLabelsStackView.spacing = 8
//        horizontalLabelsStackView.distribution = .fillEqually
//        setupSetCardsContainerView()


        view.addSubview(setCardsContainerView)
        view.addSubview(horizontalLabelsContainerStackView)
      horizontalLabelsContainerStackView.anchor(top: nil, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 8), size: CGSize(width: 0, height: 50))

        setCardsContainerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: horizontalLabelsContainerStackView.topAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 8, bottom: 16, right: 8), size: CGSize(width: 0, height: 0))

        print("SetContainer View size", setCardsContainerView.frame.size)


    }

    private func setupSetCardsContainerView() {
        view.addSubview(setCardsContainerView)
        setCardsContainerView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets.zero, size: CGSize(width: 0, height: view.frame.height * 0.90))
    }

    // ---------------------------------------------------------------
    // MARK: - View Lifecyle Methods
    override func viewDidLoad() {
        print("View did load")
        super.viewDidLoad()
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.dealThreeMoreCards(_:)))
        swipe.direction = .down
        view.addGestureRecognizer(swipe)

        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(self.reshuffle(_:)))
        view.addGestureRecognizer(rotation)
//        let bottomMargin = CGFloat(8) //Space between button and bottom of the screen
//        let buttonSize = CGSize(width: 100, height: 50)


//        gameScoreLabel = UILabel(frame: CGRect(x: 0, y: 0, width: buttonSize.width, height: buttonSize.height))
//        gameScoreLabel.text = "Score: \(setGame.gameScore)"
//        gameScoreLabel.textAlignment = .left
//        gameScoreLabel.numberOfLines = 0
//        gameScoreLabel.backgroundColor = UIColor.purple
//        gameScoreLabel.textColor = UIColor.white
//        gameScoreLabel.adjustsFontSizeToFitWidth = true
        // Placing discard pile in this area first
//        view.addSubview(gameScoreLabel)

        setupLabelsStackView()
        self.updateViewFromModel(tappedCardIndex: nil)
    }
    
    override func loadView() {
        print("Loading View")
        super.loadView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        print("Laying out subviews")
        if setGame.deck.cards.isEmpty {
            dealButton.alpha = 0 
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("View did layout subviews")
//        setCardsContainerView.setNeedsUpdateConstraints()
//        horizontalLabelsContainerStackView.setNeedsUpdateConstraints()

        var grid = Grid(layout: .aspectRatio(5/8), frame: setCardsContainerView.bounds)
        grid.cellCount = setGame.cardsActivelyInPlay.count
        for index in cardsOnScreen.indices {
            print("Index # \(index) frame: ", grid[index])
            cardsOnScreen[index].frame = grid[index]!
            cardsOnScreen[index].setNeedsLayout()
//            cardsOnScreen[index].setNeedsDisplay()
        }
    }

    // ---------------------------------------------------------------
    // MARK: - Action Methods
    @objc func touchCard(_ recognizer: UITapGestureRecognizer) {
        guard recognizer.state == .ended, let touchedCardView = recognizer.view as? SetCardView else { return }

        guard var indexOfTappedCard = cardsOnScreen.index(of: touchedCardView) else { return }
        print("Tapped card at index: \(setGame.cardsActivelyInPlay[indexOfTappedCard])")
        setGame.chooseCard(at: indexOfTappedCard)

        // Note: - Model will either 1.) remove card from selectedCards if already selected, 2.) Remove the 3 selected cards if they are a match and add 3 new cards, 3.) Add the newly selected card to its stack of selected cards if less than 3.
        mostRecentMatchedCards.forEach { $0.removeFromSuperview() }
        mostRecentMatchedCards.removeAll()

        // Error in logic because the model first de-selects the card so I can't use this here, have to go back to previous implementation
        if selectedCards.count == 3 {
            if setGame.setIsAvailable {
                print("We have a match")
                for card in selectedCards {
                    mostRecentMatchedCards.append(card)
                }
                // TODO: - Animate flying away of the latest matched cards
                // keep track of the index in case the # of cards in play hit below 12
                guard let newestSelectedIndex = setGame.cardsActivelyInPlay.index(of: setGame.selectedCards[0]) else {
                    print("Newest selected index unavailable")
                    return
                }
                print("Index of tapped card is now at: ", newestSelectedIndex)
                indexOfTappedCard = newestSelectedIndex

                updateViewFromModel(tappedCardIndex: indexOfTappedCard)

            }else if selectedCards.contains(cardsOnScreen[indexOfTappedCard]) {
                // there were 3 selected cards before, but the user has selected one of those 3 cards again, so the model should deselect this card
                changeCardSelectionLayer(at: indexOfTappedCard)
            } else {
                print("3 cards but no set match")
                cardsOnScreen.forEach {
                    $0.cardIsSelected = false
                    $0.setNeedsDisplay()
                }
                selectedCards.removeAll()
                numberOfSelectedCards = 0
                changeCardSelectionLayer(at: indexOfTappedCard)
            }
            // Since this was the 4th card chosen, need to update the score
            // we either update the score here or in deal3Cards
            gameScoreLabel.text = "Score: \(setGame.gameScore)"

        } else {
            changeCardSelectionLayer(at: indexOfTappedCard)
        }
        // Deal with UI state of newest card selected

    }

    fileprivate func changeCardSelectionLayer(at cardIndex: Int) {
        print("Index of tapped card passed into helper function: ", cardIndex)
        if selectedCards.count > 0 && selectedCards.count <= 3, cardsOnScreen[cardIndex].cardIsSelected {
            print("Deselecting card")
            print("SelectedCardArray about to remove: ", selectedCards[0].card)
            print("Model has this many cards now: ", setGame.selectedCards.count)

            guard let selectedIndex = selectedCards.index(of: cardsOnScreen[cardIndex]) else {
                print("This card index does not exist for the cardOnScreen[\(cardIndex)]")
                print("This is the current cardOnScreen: ", cardsOnScreen[cardIndex].card)
                return
            }
            selectedCards.remove(at: selectedCards.index(of: cardsOnScreen[cardIndex])!)
            cardsOnScreen[cardIndex].cardIsSelected = false
            numberOfSelectedCards -= 1
            cardsOnScreen[cardIndex].setNeedsDisplay()
        } else {
            print("Selecting cardOnScreen: ", cardsOnScreen[cardIndex].card)

            cardsOnScreen[cardIndex].cardIsSelected = true
            numberOfSelectedCards += 1
            selectedCards.append(cardsOnScreen[cardIndex])
            cardsOnScreen[cardIndex].setNeedsDisplay()
        }
    }

    @objc func dealThreeMoreCards(_ sender: UIBarButtonItem) {
        print("Dealing 3 more cards if possible")
        
        // Clean-up before updating view from model
        mostRecentMatchedCards.forEach { $0.removeFromSuperview() }
        print("Removed previously matched cards from view")
        mostRecentMatchedCards.removeAll()
        
        let deckCountBeforeRemoval = setGame.deck.cards.count
        print("Deck count before removal: ", deckCountBeforeRemoval)
        if selectedCards.count == 3 {
            if setGame.isASetMatch(setGame.selectedCards) {
                setGame.replaceMatchedCardsWithNewCards()
                gameScoreLabel.text = "Score: \(setGame.gameScore)"

                // Keep track of most recent matched cards
                for card in selectedCards {
                    mostRecentMatchedCards.append(card)
                }

                print("Deck count after matching 3 cards")
                // Attempting to "fly away" matched cards here
                self.updateViewFromModel(tappedCardIndex: nil)
                // Clean up
                selectedCards.removeAll()
            } else {
                // TODO: - See below
                // penalize the player for trying to replace an incorrect set
                // then deselect all the selected cards
            }
        } else {
            print("Drawing 3 cards from deck, then updating view")
            setGame.drawThreeMoreCards()
            print("Deck count after model draws 3 cards:", setGame.deck.cards.count)
            if deckCountBeforeRemoval != 0 {
                self.updateViewFromModel(tappedCardIndex: nil)
            }
        }
    }

    @objc func startNewGame(_ sender: UIButton) {
        print("Restarting game")
        setGame = SetGame()
        isStartOfGame = true
        gameUIState = .newGameStarted
         gameScoreLabel.text = "Score: \(setGame.gameScore)"

        selectedCards.removeAll()
        numberOfSelectedCards = 0
        discardPileCount = 0
        cardsOnScreen.forEach { $0.removeFromSuperview() }
        cardsOnScreen.removeAll()
        mostRecentMatchedCards.forEach { $0.removeFromSuperview() }
        mostRecentMatchedCards.removeAll()

        dealButton.alpha = 1
        updateViewFromModel(tappedCardIndex: nil)
    }
    
    @objc func reshuffle(_ recognizer: UIRotationGestureRecognizer) {
        print("Re-shuffling deck")
        setGame.reshuffleCardsOnTable()
        updateViewFromModel(tappedCardIndex: nil)
    }

    // MARK: - View Functions To Start Game
    private func dealOutFreshCardsFromDeck() {
        cardsOnScreen.removeAll()
        cardsToAnimateOnOrOffScreen.removeAll()
        dealButton.isUserInteractionEnabled = false
        dealButton.setNeedsLayout()
        let setCardsInDeckView = setCardsContainerView.convert(dealButton.frame, from: dealButton)
        // trying out different frame from above
       print(setCardsInDeckView)
        for index in setGame.cardsActivelyInPlay.indices {
            cardsOnScreen.append(SetCardView(frame: dealButton.frame, card: setGame.cardsActivelyInPlay[index]))
            // cardsOnScreen[index] is now part of setOfCardsView hierarchy
            setCardsContainerView.addSubview(cardsOnScreen[index])
            cardsOnScreen[index].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchCard(_:))))
            cardsToAnimateOnOrOffScreen.append(cardsOnScreen[index])
        }
//        cardsToScreenPropertyAnimator.startAnimation()
        animateCardsFlyingOntoScreen()
    }

    private func animateCardsFlyingOntoScreen() {
        var grid = Grid(layout: .aspectRatio(5/8), frame: setCardsContainerView.bounds)
        grid.cellCount = setGame.cardsActivelyInPlay.count
        dealButton.isUserInteractionEnabled = false
        for index in cardsToAnimateOnOrOffScreen.indices {
            UIView.animate(withDuration: 0.1, delay: 0.3, options: .curveEaseInOut, animations: {
                self.cardsToAnimateOnOrOffScreen[index].frame = grid[index]!
            }) { (completed) in
                //
                UIView.transition(with: self.cardsToAnimateOnOrOffScreen[index], duration: 0.3, options: [.transitionFlipFromLeft], animations: {
                    self.cardsToAnimateOnOrOffScreen[index].isFaceUp = true
                    self.cardsToAnimateOnOrOffScreen[index].setNeedsDisplay()
                }, completion: { (completed) in
                    if index == self.cardsToAnimateOnOrOffScreen.indices.last {
                        self.dealButton.isUserInteractionEnabled = true
                    }
                })
            }
        }

    }

    private func updateViewFromModel(tappedCardIndex: Int?)  {
        print("Updating view from model")
//        setUpCardViews()
        // Final clean up since this array will be refreshed for the next view update
//        indicesOfCardsUntouchedOnTable.removeAll()

        self.setAnimationsAndPositionsOfCardViews(indexOfTappedCard: tappedCardIndex)
        if self.setGame.deck.cards.count == 0 {
            self.dealButton.alpha = 0
            self.dealButton.isUserInteractionEnabled = false
        }
    }

    // Helper function for indicating the current game state
    private func updateGameUIStateFromDeckChanges() {
        // for now don't worry about the new game case, will update that at the start of game
        // to the case for game in progress
        if setGame.cardsActivelyInPlay.count < cardsOnScreen.count, !mostRecentMatchedCards.isEmpty {
            // 1. case deckEmptyButSetExists
            gameUIState = .matchedSetButDeckEmpty
        } else if setGame.cardsActivelyInPlay.count > cardsOnScreen.count, mostRecentMatchedCards.isEmpty {
            gameUIState = .threeCardsAddedOntoTable
        } else if setGame.cardsActivelyInPlay.count == cardsOnScreen.count, !mostRecentMatchedCards.isEmpty {
            gameUIState = .matchedSetAndDeckExists
        } else {
            gameUIState = .gameInProgressButNoMatches
        }
    }

    // New version of setupCardViews(), part of updateViewFromModel functionl
    private func setAnimationsAndPositionsOfCardViews(indexOfTappedCard: Int?) {
        setCardsContainerView.setNeedsLayout()
        // This is the updated grid since the model has already been updated
        var grid = Grid(layout: .aspectRatio(5/8), frame: setCardsContainerView.bounds)
        grid.cellCount = setGame.cardsActivelyInPlay.count

        if gameUIState == .newGameStarted {
            dealOutFreshCardsFromDeck()
            gameUIState = .gameInProgressButNoMatches
        } else {
            updateGameUIStateFromDeckChanges()
            switch gameUIState {
            case .matchedSetButDeckEmpty:
                // 3 matched cards need to fly out, then the remaining cards should fall in place
                // insert animateFlyAwayMatchedCards function here
                animateMatchedCardsFlyingOut(mostRecentMatchedCards, withGrid: grid, deckIsEmpty: true, updatedCardIndexTapped: indexOfTappedCard)
            case .threeCardsAddedOntoTable, .matchedSetAndDeckExists:
                animateMatchedCardsFlyingOut(mostRecentMatchedCards, withGrid: grid, deckIsEmpty: false, updatedCardIndexTapped: indexOfTappedCard)
            default:
                break
            }
        }
    }

    private func animateMatchedCardsFlyingOut(_ matchedCards: [SetCardView], withGrid grid: Grid, deckIsEmpty: Bool, updatedCardIndexTapped: Int?) {
        // doing simple animation first
        // matched cardViews: mostRecentMatchedCards
        // non-matched: every other cardOnScreen
        // Here is a rough working flyaway implementation but gonna use the easy version first at 1.)
        let flyawayBehavior = SetCardBehavior(in: dynamicAnimator)
        var placeholderCardsFlyInFromDeck = [SetCardView]()
        var placeholderCardsFlyOutFromScreen = [SetCardView]()

        // 1.) Animate alpha of matchedCards to 0, propertyAnimator used below as a placeholder for dynamic animator
        // 2.) After matched cards alpha = 0, figure out how to get either the 3 new cards to deal in or 0 cards if deck empty, and animate every other card changing frames based on updated grid
        cardsToAnimateOnOrOffScreen.removeAll()
        self.dealButton.isUserInteractionEnabled = false
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            matchedCards.forEach { $0.alpha = 0 }
        }) { (position) in
            //
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
                matchedCards.forEach {
                    $0.alpha = 1
                    $0.frame = self.discardPileLabel.frame
                }
            }, completion: { (position) in
                if deckIsEmpty {
                    // just place all the remaining cards to their new frames
                    var nonMatchedCards = self.cardsOnScreen.filter { !matchedCards.contains($0) }
                    // not a good idea to remove these cards i still need to do cleanup
//                    self.cardsOnScreen.removeAll()
                    var updatedCardViewsOnScreen = [SetCardView]()
                    for index in 0..<self.setGame.cardsActivelyInPlay.count {
                        // grid indices, which should match the number of non-matched cards since the mdoel is already updated
                        let updatedCardInPlay = self.setGame.cardsActivelyInPlay[index]
                        let updatedCardViewInPlay = SetCardView(frame: grid[index]!, card: updatedCardInPlay)
                        updatedCardViewInPlay.alpha = 0
                        updatedCardViewInPlay.isFaceUp = true 
                        updatedCardViewsOnScreen.append(updatedCardViewInPlay)
                        updatedCardViewInPlay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SetGameViewController.touchCard(_:))))
                        self.setCardsContainerView.addSubview(updatedCardViewInPlay)
                        self.setSelectionLayerOf(updatedCardViewInPlay, card: updatedCardInPlay)

                        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
                            nonMatchedCards[index].frame = grid[index]!
                        }, completion: { (position) in
                            updatedCardViewInPlay.alpha = 1
                            nonMatchedCards[index].alpha = 0
                            // need to remove these nonMatchedCards from superView and array
                            if index == self.setGame.cardsActivelyInPlay.count - 1 {
                                // Cleanup after

                                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
                                    matchedCards.forEach { $0.alpha = 0 }
                                }, completion: { (position) in
                                    self.discardPileCount += 1
                                    self.cardsOnScreen.forEach { $0.removeFromSuperview()}
                                    self.cardsOnScreen.removeAll()
                                    self.cardsOnScreen.append(contentsOf: updatedCardViewsOnScreen)
                                    nonMatchedCards.removeAll()
                                    self.mostRecentMatchedCards.forEach { $0.removeFromSuperview() }
                                    self.mostRecentMatchedCards.removeAll()
                                    self.dealButton.isUserInteractionEnabled = true

                                    print("*********************************")
                                    if let tappedIndex = updatedCardIndexTapped {
                                        self.selectedCards.removeAll()
                                        self.numberOfSelectedCards = 0
                                        self.changeCardSelectionLayer(at: tappedIndex)
                                    }
                                    // nonMatched cards and matchedCards are all copied into an array from cardsOnScreen array so this is enough to cleanup the UIViews
                                    // This is uneccessary below
                                    //                        nonMatchedCards.forEach { $0.removeFromSuperview() }
                                    //                        nonMatchedCards.removeAll()

                                })
                            }
                        })
                    }
                } else {
                    if matchedCards.isEmpty {
                        // no match and deck not empty (case .3CardsAddedOnTable)
                        // Animate cardsOnScreen to their new position, then animate in the 3 new cards at the end facedown, UIView.transition into faceUp
                        self.shrinkAndAnimatePreviousCardsOnScreenToNewGridFrames(withGrid: grid)
                        let indexAtPositionOfLastThreeCards = self.setGame.cardsActivelyInPlay.count - 3
                    } else if !matchedCards.isEmpty {
                        // case matchedCardsAndDeckExists
                        // animate out matched cards (mostRecentCards) - occurred first in the method call
                        // then animate in the three newest cards in their position
                        // using cardsToAnimateOnOrOffScreen to hold the 3 new cards
                        self.mostRecentMatchedCards.forEach {
                            guard let matchedIndex = self.cardsOnScreen.index(of: $0) else { return }
                            let replacedCard = self.setGame.cardsActivelyInPlay[matchedIndex]
                            let replacedCardView = SetCardView(frame: self.dealButton.frame, card: replacedCard)
                            replacedCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SetGameViewController.touchCard(_:))))
                            self.setSelectionLayerOf(replacedCardView, card: replacedCard)

//                            self.cardsToAnimateOnOrOffScreen.append(replacedCardView)
                            self.setCardsContainerView.addSubview(replacedCardView)

                            // Animate out this matched card (ALREADY DID IT, first thing in this function call)
                            // Then animate in the replacedCardView to the correct index
                            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                                replacedCardView.frame = grid[matchedIndex]!
                            }, completion: { (position) in
                                UIView.transition(with: replacedCardView, duration: 0.3, options: [.transitionFlipFromLeft], animations: {
                                    replacedCardView.isFaceUp = true
                                    replacedCardView.setNeedsDisplay()
                                }, completion: { (completed) in
                                    self.cardsOnScreen[matchedIndex] = replacedCardView
                                })
                            })
                        }
                        self.mostRecentMatchedCards.forEach { $0.removeFromSuperview()}
                        self.mostRecentMatchedCards.removeAll()
                        self.discardPileCount += 1

                        // Selection of card for model
                        if let tappedIndex = updatedCardIndexTapped {
                            self.selectedCards.removeAll()
                            self.numberOfSelectedCards = 0
                            self.changeCardSelectionLayer(at: tappedIndex)
                        }
                        self.dealButton.isUserInteractionEnabled = true
                    }
                }
            })

        }
    }

    private func shrinkAndAnimatePreviousCardsOnScreenToNewGridFrames(withGrid grid: Grid) {
        dealButton.isUserInteractionEnabled = false
        print("# of old cards on screen: ", cardsOnScreen.count)
        print("# of cards in play from model", setGame.cardsActivelyInPlay.count)
        for index in cardsOnScreen.indices {
            UIView.transition(with: cardsOnScreen[index], duration: 0.2, options: .allowAnimatedContent, animations: {
                let x = grid[index]!.width / self.cardsOnScreen[index].frame.width
                let y = grid[index]!.height / self.cardsOnScreen[index].frame.height
                self.cardsOnScreen[index].transform =  CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
                self.cardsOnScreen[index].setNeedsDisplay()
            }) { (completed) in
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    self.cardsOnScreen[index].frame = grid[index]!
//                    self.cardsOnScreen[index].transform = CGAffineTransform.identity
                    self.cardsOnScreen[index].setNeedsLayout()
//                    self.cardsOnScreen[index].setNeedsDisplay()
                }, completion: { (position) in
                    UIView.transition(with: self.cardsOnScreen[index], duration: 0.2, options: .allowAnimatedContent, animations: {
//                        self.cardsOnScreen[index].transform = CGAffineTransform.identity
//                        self.cardsOnScreen[index].setNeedsLayout()
                        self.cardsOnScreen[index].setNeedsDisplay()
                    }, completion: { (completed) in
                        if index == self.cardsOnScreen.indices.last {
                            self.dealButton.isUserInteractionEnabled = true
                            self.animateInThreeNewCards(withGrid: grid)
                        }

                    })
                })
            }
        }
    }

    private func animateInThreeNewCards(withGrid grid: Grid) {
        let indexAtPositionOfLastThreeCards = self.setGame.cardsActivelyInPlay.count - 3
        for index in indexAtPositionOfLastThreeCards..<self.setGame.cardsActivelyInPlay.count {
            let addedCard = self.setGame.cardsActivelyInPlay[index]
            let addedCardView = SetCardView(frame: self.dealButton.frame, card: addedCard)
            // !isFaceUp
            addedCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SetGameViewController.touchCard(_:))))
            self.setCardsContainerView.addSubview(addedCardView)
            //                            self.setSelectionLayerOf(addedCardView, card: addedCard)
            self.cardsOnScreen.append(addedCardView)

            // Animating the addedCards
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                addedCardView.frame = grid[index]!
            }, completion: { (position) in
                UIView.transition(with: addedCardView, duration: 0.4, options: [.transitionFlipFromLeft], animations: {
                    addedCardView.isFaceUp = true
                    addedCardView.setNeedsDisplay()
//                    addedCardView.setNeedsLayout()
                }, completion: { (completed) in
                    if index == self.setGame.cardsActivelyInPlay.count - 1 {
                        self.dealButton.isUserInteractionEnabled = true
                        //                                        self.setCardsContainerView.setNeedsLayout()
                        print("Reached last card to be added and asking containerVIew to layoutSubviews")
//                        self.setCardsContainerView.layoutIfNeeded()
                    }
                })
            })
        }

    }

    private func setSelectionLayerOf(_ cardView: SetCardView, card: SetCard)  {
        if setGame.selectedCards.contains(card) {
            cardView.cardIsSelected = true
        } else {
            cardView.cardIsSelected = false
        }
        cardView.setNeedsDisplay()

    }
}

enum GameAndDeckUIState {
    case newGameStarted
    case gameInProgressButNoMatches
    case matchedSetButDeckEmpty
    case threeCardsAddedOntoTable
    case matchedSetAndDeckExists


}

