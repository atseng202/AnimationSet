//
//  ViewController.swift
//  Concentration
//
//  Created by Alan Tseng on 11/28/17.
//  Copyright © 2017 Alan Tseng. All rights reserved.
//

import UIKit

class ConcentrationViewController: VCLLoggingViewController{
    
    override var vclLoggingName: String {
        return "Game"
    }
    // lazy var are not used until they are initialized
    private lazy var game  = Concentration(numberOfPairsOfCards: numberOfPairsOfCards)
    
    private var numberOfPairsOfCards: Int {
        return (visibleCardButtons.count + 1) / 2
    }
    
    // outlets create an instance variable
    @IBOutlet private weak var flipCountLabel: UILabel! {
        didSet {
            updateFlipCountLabel()
        }
    }
    
    @IBOutlet private weak var gameScoreLabel: UILabel!
    
//    var gameScore = 0 { didSet { gameScoreLabel.text = "Score: \(gameScore)" } }
    
    // all instance variables have to be initialized
    // var flipCount = 0 { didSet { flipCountLabel.text = "Flips: \(flipCount)" } }
    
    // outlet collection creates a generic array of an instance variable type
    @IBOutlet private var cardButtons: [UIButton]!
    
    private var visibleCardButtons: [UIButton]! {
        return cardButtons?.filter { !$0.superview!.isHidden }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateViewFromModel()
    }
    
    // MARK: - Theme Helper Variables
    private var allThemes = [
        0 : ["🏀", "🏈", "⚾️", "⚽️", "🏉", "🚴‍♀️", "🏋", "🏅"],
        1 : ["🙈", "🐱", "🐳", "🐼", "😺", "🐽", "🐥", "🐭"],
        2 : ["🍕", "🍉", "🍟", "🍆", "🍩", "🍔", "🍌", "🍦"],
        3 : ["😎", "😡", "😏", "😳", "😩", "😘", "😜", "😪"],
        4 : ["🏡", "🏠", "🗽", "⛪️", "🏥", "🗼", "💒", "🏩"],
        5 : ["🦇", "😱", "🙀", "😈", "🍭", "🍬", "🍎", "🎃", "👻"]
    ]
    
    private var emojiChoices = ["🦇", "😱", "🙀", "😈", "🍭", "🍬", "🍎", "🎃", "👻"]
    
    private var emoji = Dictionary<Card, String>()
    
    // MARK: - Action Method
    @IBAction func touchCard(_ sender: UIButton) {
        // flipCount += 1
        if let cardNumber = visibleCardButtons.index(of: sender) {
            game.chooseCard(at: cardNumber)
//            flipCountLabel.text = "Flips: \(game.flipCount)"
            updateFlipCountLabel()
            gameScoreLabel.text = "Score: \(game.gameScore)"
            updateViewFromModel()
        } else {
            print("chosen card was not in cardButtons")
        }
    }
    
    @IBAction func beginNewGame(_ sender: UIButton) {
        let randomIndex = allThemes.count.arc4Random
        emojiChoices = allThemes[randomIndex]!
        emoji = [Card:String]()
        game = Concentration(numberOfPairsOfCards: (visibleCardButtons.count + 1) / 2)
        updateFlipCountLabel()
        gameScoreLabel.text = "Score: \(game.gameScore)"
        updateViewFromModel()
        
        
    }
    
    // MARK: - More Helper UI Functions
    private func updateViewFromModel() {
        // Added code so that when segue preparation occurs, we don't access outlets yet
        if visibleCardButtons != nil {
            for index in visibleCardButtons.indices {
                let button = visibleCardButtons[index]
                let card = game.cards[index]
                if card.isFaceUp {
                    button.setTitle(emoji(for: card), for: UIControlState.normal)
                    button.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                } else {
                    button.setTitle("", for: UIControlState.normal)
                    button.backgroundColor = card.isMatched ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0) : #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
                }
            }
        }
    }
    
    private func emoji(for card: Card) -> String {
        if emoji[card] == nil, emojiChoices.count > 0 {
            let randomIndex = emojiChoices.count.arc4Random
            emoji[card] = emojiChoices.remove(at: randomIndex)
        }
        return emoji[card] ?? "?"
    }
    
    private func updateFlipCountLabel() {
        let attributes : [NSAttributedStringKey: Any] = [
            .strokeWidth : 5.0,
            .strokeColor : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        ]
        let attributedString = NSAttributedString(
            string: traitCollection.verticalSizeClass == .compact ? "Flips\n\(game.flipCount)" : "Flips:  \(game.flipCount)",
            attributes: attributes
        )
        flipCountLabel.attributedText = attributedString
    }
    
    private func updateScoreLabelForTraitChange() {
        if traitCollection.verticalSizeClass == .compact {
            gameScoreLabel.text = "Score\n\(game.gameScore)"
        } else {
            gameScoreLabel.text = "Score: \(game.gameScore)"
        }
    }
    
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateFlipCountLabel()
        updateScoreLabelForTraitChange()
    }
    
    // MARK: - Unused Method?
    func flipCard(withEmoji emoji: String, on button: UIButton) {
        if button.currentTitle == emoji {
            button.setTitle("", for: UIControlState.normal)
            button.backgroundColor = #colorLiteral(red: 1, green: 0.6401408203, blue: 0.4703544898, alpha: 1)
        } else {
            button.setTitle(emoji, for: UIControlState.normal)
            button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }
    
    // MARK: - Lecture 7 Demo Methods and Variables
    var theme: [String]? {
        didSet {
            emojiChoices = theme ?? [String]()
            emoji = [:]
            updateViewFromModel()
        }
    }
    
    

}






