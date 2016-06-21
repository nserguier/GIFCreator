//
//  GIFViewController.swift
//  GIF Creator
//
//  Created by Nicklos Edouard Arthur Serguier on 4/20/16.
//  Copyright © 2016 Nicklos Serguier. All rights reserved.
//

import UIKit

//View controller for the detailed viewing of a GIF
class GIFViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var GIFimage: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var gif: GIF!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //add buttons to delete and share the GIF
        let trash = UIImage(named: "trash.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let share = UIImage(named: "share.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let trashButton = UIBarButtonItem(image: trash, style: UIBarButtonItemStyle.Plain, target: self, action: "delete")
        let shareButton = UIBarButtonItem(image: share, style: UIBarButtonItemStyle.Plain, target: self, action: "share")
        self.navigationItem.setRightBarButtonItems([trashButton,shareButton], animated: true)
        
        // set up the gif animation when loading existing gif
        if let gif = gif {
            navigationItem.title = gif.name
            GIFimage.animationImages = gif.images
            GIFimage.animationDuration = gif.duration
            GIFimage.startAnimating()

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Methods
    
    //Delete the current GIF from the table and go back to the table view
    func delete(){
        let alert = UIAlertController(title: "Delete GIF", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
            self.loadingIndicator.startAnimating() // start the loading animation
            self.performSelector("actualDelete", withObject: self, afterDelay: 0.1)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    //Actual delete function, performed after the loading animation started
    func actualDelete(){
        let viewControllers = navigationController!.viewControllers
        let rootViewController = viewControllers[viewControllers.count - 2] as! GIFTableViewController
        rootViewController.deleteGIF()
        navigationController?.popViewControllerAnimated(true)
    }
    
    //Allow to share the GIF on social media and others
    //code borrowed from http://stackoverflow.com/questions/31765148/sharing-gifs-swift
    func share(){
        //get the .gif file from its url
        let shareURL = gif.url
        let shareData: NSData = NSData(contentsOfURL: shareURL)!
        let firstActivityItem: Array = [shareData]
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: firstActivityItem, applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }

}
