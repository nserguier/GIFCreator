//
//  ViewController.swift
//  GIF Creator
//
//  Created by Nicklos Serguier on 29/03/16.
//  Copyright © 2016 Nicklos Serguier. All rights reserved.
//

import UIKit

// View controller for the main menu
class ViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var newButton: UIButton!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet var backImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        randomBackground()
        // Animate the elements of the menu
        UIView.animateWithDuration(0.6, delay: 0.0,
            options: [.CurveEaseOut], animations: {
                self.label.center.y += self.view.bounds.height
                self.newButton.center.y -= self.view.bounds.height
            }, completion: nil)
        
        UIView.animateWithDuration(0.6, delay: 0.1,
            options: [.CurveEaseOut], animations: {
                self.allButton.center.y -= self.view.bounds.height
            }, completion: nil)
    }

    //MARK: Methods
    
    // Display a random background image among the 8 avaiable images
    func randomBackground(){
        let r = arc4random_uniform(8)
        let image_name = "wall_" + String(r)
        backImage.image = UIImage(named:image_name)
    }
    
    //MARK: Actions
    
    // Perform segue when the new gif button is clicked
    @IBAction func newGIF(sender: UIButton) {
        self.performSegueWithIdentifier("newGIF", sender: self)
    }

    // Perform segue when the see all gifs button is clicked
    @IBAction func allGIFs(sender: UIButton) {
        self.performSegueWithIdentifier("allGIFs", sender: self)
    }

}

