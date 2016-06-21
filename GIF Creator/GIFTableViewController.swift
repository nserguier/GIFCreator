//
//  GIFTableViewController.swift
//  GIF Creator
//
//  Created by Nicklos Edouard Arthur Serguier on 4/20/16.
//  Copyright © 2016 Nicklos Serguier. All rights reserved.
//

import UIKit

// View controller for the table displaying all the GIFs
class GIFTableViewController: UITableViewController {
    
    var GIFs = [GIF]() //holds all the GIFs saved
    var indexSelected = 0 //holds the index of the GIF selected for detail view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My GIFs"
        
        //add a button to go back to the menu
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Menu", style: UIBarButtonItemStyle.Plain, target: self, action: "backToMenu")
        
        //load saved GIFs or a sample one if no GIF saved
        if let savedGIFs = loadGIFs(){
            if(savedGIFs.count>0){
                GIFs = savedGIFs
                print("Load \(GIFs.count) GIFs")
            }else{
                loadSampleGIF()
            }
            
        } else{
            loadSampleGIF()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //Add a sample GIF to the list of GIFs
    func loadSampleGIF() {
        let documentsDirectory = NSTemporaryDirectory()
        print(documentsDirectory)
        let url = NSURL(fileURLWithPath: documentsDirectory).URLByAppendingPathComponent("sample.gif")
        let gif = GIF(name: "sample", images: [UIImage(named: "wall_0.png")!], duration: 1.0,url: url)
        GIFs.append(gif!)
    }
    
    // MARK: Table View Methods
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GIFs.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //get the cell at the given path with the right identifier
        let cellIdentifier = "GIFcell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! GIFTableViewCell
        
        //associate the right GIF with this cell
        let GIF = GIFs[indexPath.row]
        cell.GIFname.text = GIF.name
        cell.GIFimage.image = GIF.images[0]
        
        cell.accessoryType = .DisclosureIndicator //add the disclosure arrow to the cell
        
        return cell
    }
    
    // MARK: Navigation
    
    //Prepare the displaying of the selected GIF
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showGIF" {
            let GIFDetailViewController = segue.destinationViewController as! GIFViewController
            
            if let selectedGIFCell = sender as? GIFTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedGIFCell)!
                let selectedGIF = GIFs[indexPath.row]
                indexSelected = indexPath.row
                GIFDetailViewController.gif = selectedGIF
            }
        }
    }
    
    // MARK: Actions
    
    //Go back to the main menu and remove the navigation bar
    func backToMenu(){
        self.navigationController?.navigationBarHidden = true
        self.performSegueWithIdentifier("backMenu", sender: self)
    }
    
    //Delete last selected GIF from the data
    func deleteGIF(){
        // Delete the row from the data source
        GIFs.removeAtIndex(indexSelected)
        saveGIFs()
        tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexSelected, inSection: 0)], withRowAnimation: .Fade)
    }
    
    // MARK: NSCoding
    
    //Save the GIFs to the dedicated file
    func saveGIFs() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(GIFs, toFile: GIF.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save GIFs...")
        }else{
            print("Saved \(GIFs.count) GIFs")
        }
    }
    
    //Load the GIFs from the dedicated file
    func loadGIFs() -> [GIF]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(GIF.ArchiveURL.path!) as? [GIF]
    }

    
}
