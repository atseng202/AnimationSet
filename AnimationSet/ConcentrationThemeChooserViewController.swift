//
//  ConcentrationThemeChooserViewController.swift
//  Concentration
//
//  Created by Alan Tseng on 2/1/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import UIKit

class ConcentrationThemeChooserViewController: VCLLoggingViewController, UISplitViewControllerDelegate {

    override var vclLoggingName: String {
        return "Theme Chooser"
    }
    
    let themes = [
        "Sports": ["🏀","🏈","⚾️","⚽️","🎾","🏉","🎱","🏓","🏒","🤽‍♀️","🏐","🥊"],
        "Animals": ["🙈", "🐱", "🐳", "🐼", "😺", "🐽", "🐥", "🐭", "🐏", "🐉", "🐕", "🐿"],
        "Faces": ["😎", "😡", "😏", "😳", "😩", "😘", "😜", "😪", "😭", "😜"],
        "Buildings" : ["🏡", "🏠", "🗽", "⛪️", "🏥", "🗼", "💒", "🏩"],
        "Halloween" : ["🦇", "😱", "🙀", "😈", "🍭", "🍬", "🍎", "🎃", "👻"],
        "Foods" : ["🍕", "🍉", "🍟", "🍆", "🍩", "🍔", "🍌", "🍦"]
    ]
    
    private var splitViewDetailConcentrationViewController: ConcentrationViewController? {
        return splitViewController?.viewControllers.last as? ConcentrationViewController
        
    }
    
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if let cvc = secondaryViewController as? ConcentrationViewController {
            if cvc.theme == nil {
                return true
            }
        }
        return false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        splitViewController?.delegate = self
    }
    
    @IBAction func changeTheme(_ sender: Any) {
        // for Ipad and Iphone +
        if let cvc = splitViewDetailConcentrationViewController {
            if let themeName = (sender as? UIButton)?.currentTitle, let theme = themes[themeName] {
                cvc.theme = theme
            }
            // For all other iphones
        } else if let cvc = lastSeguedToConcentrationViewController {
            if let themeName = (sender as? UIButton)?.currentTitle, let theme = themes[themeName] {
                cvc.theme = theme
            }
            navigationController?.pushViewController(cvc, animated: true)
        }
        else {
            performSegue(withIdentifier: "Choose Theme", sender: sender)
        }
    }
    
    // MARK: - Navigation
    
    private var lastSeguedToConcentrationViewController: ConcentrationViewController?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "Choose Theme"?:
            if let themeName = (sender as? UIButton)?.currentTitle, let theme = themes[themeName] {
                if let cvc = segue.destination as? ConcentrationViewController {
                    cvc.theme = theme
                    lastSeguedToConcentrationViewController = cvc
                }
            }
            
        default:
            print("Could not segue to correct identifier")
        }
    }


}
