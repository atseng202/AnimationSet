//
//  SetGameViewController.swift
//  AnimationSet
//
//  Created by Alan Tseng on 1/22/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import UIKit

class SetGameViewController: UIViewController {
    // ---------------------------------------------------------------
    // MARK: - Properties
    private var setGame = SetGame()
    private var gameUIState: GameAndDeckUIState = GameAndDeckUIState.newGameStarted

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
    // MARK: - Animator Variables
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
        view.addSubview(setCardsContainerView)
        view.addSubview(horizontalLabelsContainerStackView)

      horizontalLabelsContainerStackView.anchor(top: nil, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 8), size: CGSize(width: 0, height: 50))

        setCardsContainerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: horizontalLabelsContainerStackView.topAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 8, bottom: 16, right: 8), size: CGSize(width: 0, height: 0))
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
        setupLabelsStackView()

        startNewGame(nil)
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

        // Added re-frame code for when user switches between portrait mode/landscape mode
        var grid = Grid(layout: .aspectRatio(5/8), frame: setCardsContainerView.bounds)
        // Using cardViewsCount because the model updates instantly but the layoutSubviews is called twice
        grid.cellCount = cardsOnScreen.count
        for index in cardsOnScreen.indices {
//            print("Index # \(index) frame: ", grid[index])
            if !mostRecentMatchedCards.contains(cardsOnScreen[index]) {
                cardsOnScreen[index].frame = grid[index]!
                cardsOnScreen[index].setNeedsLayout()
            }
        }
    }

    // ---------------------------------------------------------------
    // MARK: - Action Methods
    @objc func touchCard(_ recognizer: UITapGestureRecognizer) {
        guard recognizer.state == .ended, let touchedCardView = recognizer.view as? SetCardView else { return }

        guard var indexOfTappedCard = cardsOnScreen.index(of: touchedCardView) else { return }
        print("Tapped card at index: \(setGame.cardsActivelyInPlay[indexOfTappedCard])")
        // Note: - Model will either 1.) remove card from selectedCards if already selected, 2.) Remove the 3 selected cards if they are a match and add 3 new cards, 3.) Add the newly selected card to its stack of selected cards if less than 3.
        setGame.chooseCard(at: indexOfTappedCard)

        mostRecentMatchedCards.forEach { $0.removeFromSuperview() }
        mostRecentMatchedCards.removeAll()

        if selectedCards.count == 3 {
            if setGame.setIsAvailable {
                print("We have a match")
                for card in selectedCards {
                    mostRecentMatchedCards.append(card)
                }
                // Keeping track of the updated index in case the # of cards in play suddenly change model's index count is out of sync from view
                guard let newestSelectedIndex = setGame.cardsActivelyInPlay.index(of: setGame.selectedCards[0]) else {
                    print("Newest selected index unavailable")
                    return
                }
                print("Index of tapped card is now at: ", newestSelectedIndex)
                indexOfTappedCard = newestSelectedIndex

                updateViewFromModel(tappedCardIndex: indexOfTappedCard)

            }else if selectedCards.contains(cardsOnScreen[indexOfTappedCard]) {
                // 3 cards had been selected, but the user has selected one of those 3 cards again, so the model should deselect this card
                changeCardSelectionLayer(at: indexOfTappedCard)
            } else {
                // 3 cards had been selected but there was no match
                cardsOnScreen.forEach {
                    $0.cardIsSelected = false
                    $0.setNeedsDisplay()
                }
                selectedCards.removeAll()
                changeCardSelectionLayer(at: indexOfTappedCard)
                gameScoreLabel.text = "Score: \(setGame.gameScore)"
            }
            // Updating the score from model
//            gameScoreLabel.text = "Score: \(setGame.gameScore)"

        } else {
            // less than 3 cards selected so just change border UI to indicate selection
            changeCardSelectionLayer(at: indexOfTappedCard)
        }
    }

    fileprivate func changeCardSelectionLayer(at cardIndex: Int) {
        if selectedCards.count > 0 && selectedCards.count <= 3, cardsOnScreen[cardIndex].cardIsSelected {
            print("Deselecting card")
            guard let _ = selectedCards.index(of: cardsOnScreen[cardIndex]) else {
                print("This card index does not exist for the cardOnScreen[\(cardIndex)]")
                return
            }
            selectedCards.remove(at: selectedCards.index(of: cardsOnScreen[cardIndex])!)
            cardsOnScreen[cardIndex].cardIsSelected = false
            cardsOnScreen[cardIndex].setNeedsDisplay()
        } else {
            print("Selecting cardOnScreen: ", cardsOnScreen[cardIndex].card)
            cardsOnScreen[cardIndex].cardIsSelected = true
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
//                gameScoreLabel.text = "Score: \(setGame.gameScore)"

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
                setGame.reduceScoreForWrongSet()
                selectedCards.forEach { $0.cardIsSelected = false; $0.setNeedsDisplay() }
                selectedCards.removeAll()
                gameScoreLabel.text = "Score: \(setGame.gameScore)"

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

    @objc func startNewGame(_ sender: UIButton?) {
        print("Restarting game")
        setGame = SetGame()
        gameUIState = .newGameStarted
        gameScoreLabel.text = "Score: \(setGame.gameScore)"

        selectedCards.removeAll()
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
        let setCardsInDeckViewFrame = setCardsContainerView.convert(dealButton.bounds, from: dealButton)

        for index in setGame.cardsActivelyInPlay.indices {
            cardsOnScreen.append(SetCardView(frame: setCardsInDeckViewFrame, card: setGame.cardsActivelyInPlay[index]))
            setCardsContainerView.addSubview(cardsOnScreen[index])
            cardsOnScreen[index].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchCard(_:))))
            cardsToAnimateOnOrOffScreen.append(cardsOnScreen[index])
        }
        print("Number of cards to animate on screen:", cardsToAnimateOnOrOffScreen.count)
        animateCardsFlyingOntoScreen()
    }

    private func animateCardsFlyingOntoScreen() {
        var grid = Grid(layout: .aspectRatio(5/8), frame: setCardsContainerView.bounds)
        grid.cellCount = setGame.cardsActivelyInPlay.count
        dealButton.isUserInteractionEnabled = false
        guard var _ = cardsToAnimateOnOrOffScreen.indices.first, let _ = cardsToAnimateOnOrOffScreen.indices.last else {
            print("No first index or last index")
            return }

        for index in cardsToAnimateOnOrOffScreen.indices {
            UIView.animate(withDuration: 0.5, delay: 0.1 * Double(index), options: .curveEaseInOut, animations: {
                self.cardsToAnimateOnOrOffScreen[index].frame = grid[index]!
            }) { (completed) in
                UIView.transition(with: self.cardsToAnimateOnOrOffScreen[index], duration: 0.3, options: [.transitionFlipFromLeft], animations: {
                    self.cardsToAnimateOnOrOffScreen[index].isFaceUp = true
                    self.cardsToAnimateOnOrOffScreen[index].setNeedsDisplay()
                }, completion: { (completed) in
                    if index == self.cardsToAnimateOnOrOffScreen.indices.last {
                        self.dealButton.isUserInteractionEnabled = true
                        self.cardsOnScreen.forEach { $0.isUserInteractionEnabled = true  }
                    }
                })
            }
        }
    }

    private func updateViewFromModel(tappedCardIndex: Int?)  {
        print("Updating view from model")
        self.setAnimationsAndPositionsOfCardViews(indexOfTappedCard: tappedCardIndex)
        if self.setGame.deck.cards.count == 0 {
            self.dealButton.alpha = 0
            self.dealButton.isUserInteractionEnabled = false
        }
    }

    // Helper function for indicating the current game state
    private func updateGameUIStateFromDeckChanges() {
        if setGame.cardsActivelyInPlay.count < cardsOnScreen.count, !mostRecentMatchedCards.isEmpty {
            gameUIState = .matchedSetButDeckEmpty
        } else if setGame.cardsActivelyInPlay.count > cardsOnScreen.count, mostRecentMatchedCards.isEmpty {
            gameUIState = .threeCardsAddedOntoTable
        } else if setGame.cardsActivelyInPlay.count == cardsOnScreen.count, !mostRecentMatchedCards.isEmpty {
            gameUIState = .matchedSetAndDeckExists
        } else {
            print("Game in progress and no matches")
            gameUIState = .gameInProgressButNoMatches
        }
    }

    // Helper Function for updating view from model
    private func setAnimationsAndPositionsOfCardViews(indexOfTappedCard: Int?) {
        var grid = Grid(layout: .aspectRatio(5/8), frame: setCardsContainerView.bounds)
        grid.cellCount = setGame.cardsActivelyInPlay.count
        cardsOnScreen.forEach { $0.isUserInteractionEnabled = false }

        if gameUIState == .newGameStarted {
            dealOutFreshCardsFromDeck()
            gameUIState = .gameInProgressButNoMatches
        } else {
            updateGameUIStateFromDeckChanges()
            switch gameUIState {
            case .matchedSetButDeckEmpty:
                // 3 matched cards need to fly out, then the remaining cards should fall in place
                flyAwayMatchedCards(mostRecentMatchedCards) { [weak self] in
                    guard let strongSelf = self else { return }
                    self?.animateViewUpdates(strongSelf.mostRecentMatchedCards, withGrid: grid, deckIsEmpty: true, updatedCardIndexTapped: indexOfTappedCard)
                }
            case .threeCardsAddedOntoTable, .matchedSetAndDeckExists:
                flyAwayMatchedCards(mostRecentMatchedCards) { [weak self] in
                    guard let strongSelf = self else { return }
                    self?.animateViewUpdates(strongSelf.mostRecentMatchedCards, withGrid: grid, deckIsEmpty: false, updatedCardIndexTapped: indexOfTappedCard)
                }
            default:
                break
            }
        }
    }

    private func animateViewUpdates(_ matchedCards: [SetCardView], withGrid grid: Grid, deckIsEmpty: Bool, updatedCardIndexTapped: Int?) {
        if deckIsEmpty {
            var nonMatchedCards = self.cardsOnScreen.filter { !matchedCards.contains($0) }
            var updatedCardViewsOnScreen = [SetCardView]()
            for index in 0..<self.setGame.cardsActivelyInPlay.count {
                let updatedCardInPlay = self.setGame.cardsActivelyInPlay[index]
                let updatedCardViewInPlay = SetCardView(frame: grid[index]!, card: updatedCardInPlay)
                updatedCardViewInPlay.alpha = 0
                updatedCardViewInPlay.isFaceUp = true
                updatedCardViewsOnScreen.append(updatedCardViewInPlay)
                updatedCardViewInPlay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SetGameViewController.touchCard(_:))))
                self.setCardsContainerView.addSubview(updatedCardViewInPlay)
                self.setSelectionLayerOf(updatedCardViewInPlay, card: updatedCardInPlay)

                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.4, delay: 0, options: [.curveEaseInOut], animations: {
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
                            // Updating the score from model
                            self.gameScoreLabel.text = "Score: \(self.setGame.gameScore)"

                            self.cardsOnScreen.forEach { $0.removeFromSuperview()}
                            self.cardsOnScreen.removeAll()
                            self.cardsOnScreen.append(contentsOf: updatedCardViewsOnScreen)
                            nonMatchedCards.removeAll()
                            self.mostRecentMatchedCards.forEach { $0.removeFromSuperview() }
                            self.mostRecentMatchedCards.removeAll()
                            print("*********************************")
                            self.dealButton.isUserInteractionEnabled = true
//                            self.cardsOnScreen.forEach { $0.isUserInteractionEnabled = true  }
                            if let tappedIndex = updatedCardIndexTapped {
                                self.selectedCards.removeAll()
                                self.changeCardSelectionLayer(at: tappedIndex)
                            }
                        })
                    }
                })
            }
        } else {
            if matchedCards.isEmpty {
                // no match and deck not empty (case .3CardsAddedOnTable)
                self.shrinkAndAnimatePreviousCardsOnScreenToNewGridFrames(withGrid: grid)
            } else if !matchedCards.isEmpty {
                // case matchedCardsAndDeckExists
                let setCardsInDeckViewFrame = self.setCardsContainerView.convert(self.dealButton.bounds, from: self.dealButton)
                for index in 0..<self.mostRecentMatchedCards.count {
                    guard let matchedIndex = self.cardsOnScreen.index(of: self.mostRecentMatchedCards[index]) else { return }
                    let replacedCard = self.setGame.cardsActivelyInPlay[matchedIndex]
                    let replacedCardView = SetCardView(frame: setCardsInDeckViewFrame, card: replacedCard)
                    replacedCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SetGameViewController.touchCard(_:))))
                    self.setSelectionLayerOf(replacedCardView, card: replacedCard)
                    self.setCardsContainerView.addSubview(replacedCardView)

                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0.1*Double(index), options: .curveEaseInOut, animations: {
                        replacedCardView.frame = grid[matchedIndex]!
                    }, completion: { (position) in
                        UIView.transition(with: replacedCardView, duration: 0.3, options: [.transitionFlipFromLeft], animations: {
                            replacedCardView.isFaceUp = true
                            replacedCardView.setNeedsDisplay()
                        }, completion: { (completed) in
                            self.cardsOnScreen[matchedIndex] = replacedCardView

                            if index == self.mostRecentMatchedCards.count - 1 {
                                self.mostRecentMatchedCards.forEach { $0.removeFromSuperview()}
                                self.mostRecentMatchedCards.removeAll()
                                self.discardPileCount += 1
                                // Updating the score from model
                                self.gameScoreLabel.text = "Score: \(self.setGame.gameScore)"

                                self.cardsOnScreen.forEach { $0.isUserInteractionEnabled = true  }

                                if let tappedIndex = updatedCardIndexTapped {
                                    self.selectedCards.removeAll()
                                    self.changeCardSelectionLayer(at: tappedIndex)
                                }
                                self.dealButton.isUserInteractionEnabled = true
                            }
                        })
                    })
                }
            }
        }
    }

    private func flyAwayMatchedCards(_ matchedCards: [SetCardView], completion: @escaping () -> Void) {
        guard matchedCards.count > 0 else {
            completion()
            return
        }
        let flyawayBehavior = SetCardBehavior(in: dynamicAnimator)
        var placeholderCardsAnchoringOntoDiscardPile = [SetCardView]()
        var placeholderCardsFlyOutFromScreen = [SetCardView]()

        let matchedCardsToStackViewFrame = discardLabelAndScoreLabelContainerStackView.convert(discardPileLabel.bounds, from: discardPileLabel)
        for index in 0..<matchedCards.count {
            let placeholderCardOnScreenView = SetCardView(frame: matchedCards[index].frame, card: matchedCards[index].card!)
            placeholderCardOnScreenView.isFaceUp = true

            let placeholderCardInDiscardPileView = SetCardView(frame: matchedCardsToStackViewFrame, card: matchedCards[index].card!)
            print("Placeholder in discard pile frame:", placeholderCardInDiscardPileView.frame)
            placeholderCardInDiscardPileView.alpha = 0
            placeholderCardInDiscardPileView.isFaceUp = true

            placeholderCardsFlyOutFromScreen.append(placeholderCardOnScreenView)
            placeholderCardsAnchoringOntoDiscardPile.append(placeholderCardInDiscardPileView)
            setCardsContainerView.addSubview(placeholderCardOnScreenView)
//            setCardsContainerView.addSubview(placeholderCardInDiscardPileView)
            discardLabelAndScoreLabelContainerStackView.addSubview(placeholderCardInDiscardPileView)
        }
        // Placeholder cards for flying out and anchoring on discard pile are ready and added as subviews
        matchedCards.forEach { $0.alpha = 0 }
        placeholderCardsFlyOutFromScreen.forEach { flyawayBehavior.addItem($0) }

        for flyingCard in placeholderCardsFlyOutFromScreen {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                flyingCard.alpha = 0
            }) { (position) in
                if flyingCard == placeholderCardsFlyOutFromScreen.last {
                    for anchoredCard in placeholderCardsAnchoringOntoDiscardPile {
                        UIView.transition(with: anchoredCard, duration: 0.8, options: .transitionFlipFromLeft, animations: {
                            anchoredCard.isFaceUp = false
                            anchoredCard.alpha = 1
                            anchoredCard.setNeedsDisplay()
                        }, completion: { (completed) in
                            if anchoredCard == placeholderCardsAnchoringOntoDiscardPile.last {
                                placeholderCardsFlyOutFromScreen.forEach {
                                    flyawayBehavior.removeItem($0)
                                    $0.removeFromSuperview()
                                }
                                placeholderCardsAnchoringOntoDiscardPile.forEach { $0.removeFromSuperview() }
                                completion()
                            }
                        })
                    }
                }
            }
        }
    }

    private func shrinkAndAnimatePreviousCardsOnScreenToNewGridFrames(withGrid grid: Grid) {
        dealButton.isUserInteractionEnabled = false
        print("# of old cards on screen: ", cardsOnScreen.count)
        print("# of cards in play from model", setGame.cardsActivelyInPlay.count)
        for index in cardsOnScreen.indices {
            UIView.transition(with: cardsOnScreen[index], duration: 0.2, options: .allowAnimatedContent, animations: {
                self.cardsOnScreen[index].transform =  CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
                self.cardsOnScreen[index].setNeedsDisplay()
            }) { (completed) in
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    self.cardsOnScreen[index].frame = grid[index]!
                    self.cardsOnScreen[index].setNeedsLayout()
                }, completion: { (position) in
                    UIView.transition(with: self.cardsOnScreen[index], duration: 0.2, options: .allowAnimatedContent, animations: {
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
        let setCardsInDeckViewFrame = self.setCardsContainerView.convert(self.dealButton.bounds, from: self.dealButton)
        let indexAtPositionOfLastThreeCards = self.setGame.cardsActivelyInPlay.count - 3
        var timeOfDelay = 0
        for index in indexAtPositionOfLastThreeCards..<self.setGame.cardsActivelyInPlay.count {
            let addedCard = self.setGame.cardsActivelyInPlay[index]
            let addedCardView = SetCardView(frame: setCardsInDeckViewFrame, card: addedCard)
            addedCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SetGameViewController.touchCard(_:))))
            self.setCardsContainerView.addSubview(addedCardView)
            self.cardsOnScreen.append(addedCardView)

            // Animating the addedCards
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0.1*Double(timeOfDelay), options: .curveEaseInOut, animations: {
                addedCardView.frame = grid[index]!
                 timeOfDelay += 1
            }, completion: { (position) in
                UIView.transition(with: addedCardView, duration: 0.3, options: [.transitionFlipFromLeft], animations: {
                    addedCardView.isFaceUp = true
                    addedCardView.setNeedsDisplay()
                }, completion: { (completed) in
                    if index == self.setGame.cardsActivelyInPlay.count - 1 {
                        self.dealButton.isUserInteractionEnabled = true
                        self.cardsOnScreen.forEach { $0.isUserInteractionEnabled = true  }
                        print("Reached last card to be added and asking containerVIew to layoutSubviews")
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

