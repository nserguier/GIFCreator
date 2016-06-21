//
//  CreateViewController.swift
//  GIF Creator
//
//  Created by Nicklos Serguier on 03/04/16.
//  Copyright © 2016 Nicklos Serguier. All rights reserved.
//

import UIKit
import ImageIO
import MobileCoreServices

// Controller for the view dedicated to gif creation
class CreateViewController: UIViewController, UIImagePickerControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate {
    

    // MARK: Propoerties
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saveGIF: UIStackView!
    
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var doneButton: DarkButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var handImage: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    let picker = UIImagePickerController() //allow user to pick images from library/camera
    var blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light)) //blur effect on the selected image when clicked
    var blur = false //if the blur on the image is present or not
    
    var GIFs = [GIF]() //holds all the gifs from the memory
    var images : [UIImage] = [] //holds the sequence of images for the gif in creation
    var landscape = false //whether the image is in landscape mode(true) or portrait mode(false)
    var duration : Double = 0 //the duration of the gif animation
    var indexSelected = -1 //holds the index of the selected image
    var mode = 0 //keeps track of the mode, mode 0 is the mode where the user import his images, mode 1 is when we pick a name and a speed
    let reuseIdentifier = "cell"
    var draggedCell : UICollectionViewCell? //the cell that is being dragged
    var draggedIndex = -1 //holds the index of the dragged cell
    
    let t_min = 0.1 // minimum time of animation per frame
    let t_max = 1.0 // maximum time of animation per frame
    let blue = UIColor(red: 30/255, green: 144/255, blue: 1, alpha: 1.0)
    
    var galleryButtonCenter = CGPoint()
    var cameraButtonCenter = CGPoint()
    var importButtonFrame = CGRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.clipsToBounds = true
        
        //set the delegates
        picker.delegate = self
        nameField.delegate = self
        
        //set center values for future animations
        galleryButtonCenter = galleryButton.center
        cameraButtonCenter = cameraButton.center
        importButtonFrame = cameraButton.frame
        
        //hide the elements for mode 1
        saveGIF.hidden = true
        galleryButton.hidden = true
        cameraButton.hidden = true
        
        //remove some behaviors when no images at first
        deleteButton.hidden = true
        doneButton.enabled = false
        
        //set up the swipe recognizers
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "swipeRightHandler:")
        swipeRight.direction = .Right
        view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "swipeLeftHandler:")
        swipeLeft.direction = .Left
        view.addGestureRecognizer(swipeLeft)
        
        //set the long pressure recognizer
        let long = UILongPressGestureRecognizer(target: self, action: "cellLongPressed:")
        long.minimumPressDuration = 0.4
        long.delaysTouchesBegan = true
        long.delegate = self
        collectionView.addGestureRecognizer(long)
        
        //set the drag recognizer
        let pan = UIPanGestureRecognizer(target:self, action:"cellDragged:")
        pan.maximumNumberOfTouches = 1
        pan.minimumNumberOfTouches = 1
        collectionView.addGestureRecognizer(pan)
        
    }
    
    //handle simultaneously gestures
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: Picker Delegate
    //CODE BORROWED from Swift-Getting started, FoodTracker
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[String : AnyObject]){
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        dismissViewControllerAnimated(true, completion: nil)
        clearImage()
        addNewImage(chosenImage)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
        if(imageView.image == nil){
           bringHandBack()
        }
        clearImage()
    }
    
    // MARK: TextField dDelegate
    //CODE BORROWED from Swift-Getting started, FoodTracker
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidGIFName()
        navigationItem.title = textField.text
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable the done button while editing the name
        doneButton.enabled = false
    }
    
    func checkValidGIFName() {
        // Disable the done button if the text field is empty
        let text = nameField.text ?? ""
        doneButton.enabled = !text.isEmpty
    }
    
    // MARK: CollectionView
    
    //tell how many cells are in the collection
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    //get the cell at the given index
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        //get the cell using its path and identitifer
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MyCollectionViewCell
        
        //put the right image in the cell
        cell.myImage.image = self.images[indexPath.item]
        
        return cell
    }

    //user selected a cell
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        updateSelectedTo(indexPath.item)
    }
    
    //change the size of the cell depending on the orientation
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        var w = 0.0
        if(landscape){
            w = 75
        }else{ w = 52}

        return CGSize(width: w, height: 65)
    }
    
    //handle a long press on the collection view
    func cellLongPressed(gestureRecognizer: UILongPressGestureRecognizer){
        //get the cell pressed
        if gestureRecognizer.state != UIGestureRecognizerState.Recognized && draggedCell == nil{
        let p = gestureRecognizer.locationInView(self.collectionView)
        let indexPath = self.collectionView.indexPathForItemAtPoint(p)
        
            if let index = indexPath {
                let cell = self.collectionView.cellForItemAtIndexPath(index)
                draggedCell = cell
                draggedIndex = index.row
                updateSelectedTo(index.row)
            }
        }
    }
    
    //handle the drag on a the collection view
    //code borrowed from http://stackoverflow.com/questions/29241691/how-do-i-use-uilongpressgesturerecognizer-with-a-uicollectionviewcell-in-swift
    func cellDragged(gestureRecognizer: UIPanGestureRecognizer){
        if(draggedCell != nil){
        let p = gestureRecognizer.locationInView(self.collectionView)
        var center:CGPoint = CGPointZero
            
            switch gestureRecognizer.state {
            case .Began:
                collectionView.bringSubviewToFront(draggedCell!)
                
            case .Changed:
                center = draggedCell!.center
                let distance = sqrt(pow((center.x - p.x), 2.0) + pow((center.y - p.y), 2.0))
                if distance > 1 {
                    draggedCell!.center.x = p.x
                }
                
            case .Ended:
                let p = gestureRecognizer.locationInView(self.collectionView)
                let indexPath = self.collectionView.indexPathForItemAtPoint(p)
                if let index = indexPath{
                    switchCells(draggedIndex,index2: index.row)
                    updateSelectedTo(index.row)
                }else{
                    switchCells(draggedIndex,index2: images.count - 1) //switch with last image
                    updateSelectedTo(images.count - 1)
                }
                draggedCell = nil
                draggedIndex = -1
                
            default: break
                
            }
        }
        
    }
    
    //MARK: Ations
    
    //The user tap the main image in the middle
    @IBAction func tapImage(sender: UITapGestureRecognizer) {
        if(mode == 0){ //tap on image only works in the mode 0
            nameField.resignFirstResponder() //hide the keyboard
            
            if(handImage.alpha != 0){
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.handImage.transform = CGAffineTransformMakeScale(1.3, 1.3)
                    self.handImage.alpha = 0.0
                    }, completion: nil)
            }else if(imageView.image == nil){
                bringHandBack()            }
            
            if(!blur){ //add blur and import buttons
                blur = true
                blurEffectView.frame = view.bounds
                blurEffectView.alpha = 0.8
                blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
                imageView.addSubview(blurEffectView)
            
                //show and hide the import buttons before the animation
                galleryButton.alpha = 0
                cameraButton.alpha = 0
                galleryButton.hidden = false
                cameraButton.hidden = false
            
                //animate the appearing of the import buttons
                cameraButton.frame = CGRect(x: (cameraButtonCenter.x + galleryButtonCenter.x)/2,y: cameraButtonCenter.y,width: 0,height: 0)
                galleryButton.frame = CGRect(x: (cameraButtonCenter.x + galleryButtonCenter.x)/2,y: cameraButtonCenter.y,width: 0,height: 0)
                UIView.animateWithDuration(0.2, delay: 0.0,
                    options: .CurveEaseIn , animations: {
                        self.cameraButton.alpha = 1
                        self.galleryButton.alpha = 1
                        self.cameraButton.center.x = self.cameraButtonCenter.x
                        self.galleryButton.center.x = self.galleryButtonCenter.x
                        self.cameraButton.frame = self.importButtonFrame
                        self.galleryButton.frame = self.importButtonFrame
                    }, completion: nil)
                
            }else{ //if blur and import already there, remove them
                clearImage()
            }
        }
    }
    
    //The user tap the red tap image in the center
    @IBAction func tapCenter(sender: UITapGestureRecognizer) {
        tapImage(sender) //it does the same than tapping the image around
    }
    
    //The user tap the importButtons stack
    @IBAction func tapStack(sender: UITapGestureRecognizer) {
        //handle the click in the center even when the hand image is invisible
        if(imageView.image != nil){
            tapImage(sender)
        }
    }
    
    //The user tap the gallery import button
    //Borrowed from Swift - Getting started: FoodTracker
    @IBAction func importFromGallery(sender: UIButton) {
        nameField.resignFirstResponder() //hide keyboard
        
        picker.allowsEditing = false
        picker.sourceType = .PhotoLibrary
        presentViewController(picker, animated: true, completion: nil)
    }
    
    //The user tap the camera import button
    @IBAction func importFromCamera(sender: UIButton) {
        nameField.resignFirstResponder() //hide keyboard

        //if device has a rear camera set the picker
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.cameraCaptureMode = .Photo
            presentViewController(picker, animated: true, completion: nil)
        } else {
            noCamera()
            clearImage()
        }
    }

    //The user tap the delete button
    @IBAction func deleteClicked(sender: UIButton) {
        clearImage()
        if(indexSelected == images.count-1){ // if we are deleting the last picture of the collection
            images.removeAtIndex(indexSelected)
            collectionView.reloadSections(NSIndexSet(index: 0)) //make sure a deleted cell wont be picked
            if(indexSelected == 0){ // if we delete the only picture that was left
                imageView.image = nil
                bringHandBack()
                //remove some behaviors when no images
                deleteButton.hidden = true
                doneButton.enabled = false
            }else{
                updateSelectedTo(indexSelected - 1)
                
            }
        }else{
            images.removeAtIndex(indexSelected)
            collectionView.reloadSections(NSIndexSet(index: 0)) //make sure a deleted cell wont be picked
            updateSelectedTo(indexSelected)
        }
        collectionView.reloadData() // refresh the collection to show modifications
    }
    
    //The user tap the next/done button
    @IBAction func doneClicked(sender: UIButton) {
        if(mode == 1){ //we are done editing the name and speed of the gif
            loadingIndicator.startAnimating() // start the loading animation
            performSelector("saveAndQuit", withObject: self, afterDelay: 0.1) //allow some time for the loading animation to start
        }
        else if(mode == 0){ //we are done dealing with the pictures of the gif
            mode = 1
            doneButton.enabled = false //disable the done button while user did not pick a name
            saveGIF.center.x += self.view.bounds.width //move the saveGIF elements to the right off screen
            backButton.enabled = false
            //animate the transition from the collection view to the saveGIF elements
            UIView.animateWithDuration(1.0, delay: 0.0,
                options: .CurveEaseIn , animations: {
                    self.collectionView.center.x -= self.view.bounds.width
                    self.saveGIF.hidden = false
                    self.saveGIF.center.x -= self.view.bounds.width
                    self.deleteButton.alpha = 0
                }, completion: {
                    (value: Bool) in
                    sender.setTitle("Done", forState: .Normal) // change the title of the next button to Done
                    self.collectionView.alpha = 0
                    self.deleteButton.hidden = true
                    self.backButton.enabled = true
                    
                    //start the gif animation in the main image view
                    self.imageView.animationImages = self.images
                    if(self.duration == 0){ //no duration has been set yet
                        self.duration = (self.t_min + 0.5*(self.t_max - self.t_min))*Double(self.images.count)
                    }
                    self.imageView.animationDuration = self.duration
                    self.imageView.startAnimating()
            })
            
        }
    }
    
    //The user tap the back button
    @IBAction func backClicked(sender: UIButton) {
        if(mode == 0){ //back to the menu
            if(images.count != 0){ //ask confirmation
                //code borrowed from: http://stackoverflow.com/questions/25511945/swift-alert-view-ios8-with-ok-and-cancel-button-which-button-tapped
                let alert = UIAlertController(title: "Back to menu", message: "Are you sure? Your work will be lost", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
                    self.performSegueWithIdentifier("backToMenu", sender: self)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
            }else{
                performSegueWithIdentifier("backToMenu", sender: self)
            }
        }
        else if(mode == 1){ //back to mode 0
            mode = 0
            collectionView.alpha = 1
            self.collectionView.center.x -= self.view.bounds.width
            doneButton.enabled = false
            //animate the translation from the saveGIF elements back to the collection view
            UIView.animateWithDuration(1.0, delay: 0.0,
                options: .CurveEaseIn , animations: {
                    self.collectionView.center.x += self.view.bounds.width
                    self.saveGIF.center.x += self.view.bounds.width
                    self.deleteButton.hidden = false
                    self.deleteButton.alpha = 1
                }, completion: {
                    (value: Bool) in
                    self.saveGIF.hidden = true
                    self.doneButton.setTitle("Next", forState: .Normal)
                    self.doneButton.enabled = true
                    self.imageView.stopAnimating()
            })
        }
    }
    
    //The user change the slider value
    @IBAction func speedChanged(sender: UISlider) {
        nameField.resignFirstResponder() //hide keyboard
        
        let t = 1.0 - Double(sender.value) //duration percent value from 0.0(fast) to 1.0(slow)
        //restart the animation with the updated duration/speed
        imageView.animationImages = self.images
        duration = (t_min + t*(t_max - t_min))*Double(images.count)
        imageView.animationDuration = duration
        imageView.startAnimating()
    }
    
    //Handle the user's swipe in the right direction
    func swipeRightHandler(sender: UITapGestureRecognizer) {
        if ( sender.state == .Ended && indexSelected > 0){
            updateSelectedTo(indexSelected - 1) //select the previous image
        }
    }
    
    //Handle the user's swipe in the left direction
    func swipeLeftHandler(sender: UITapGestureRecognizer) {
        if ( sender.state == .Ended && indexSelected < images.count-1){
            updateSelectedTo(indexSelected + 1) //select the next image
        }
    }
    
    //MARK: Methods
    
    //remove blue highlight from all cell
    func removeHighlight(){
        for i in 0..<images.count{
            let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forRow: i, inSection: 0))
            cell?.backgroundColor = UIColor.grayColor()
        }
    }
    
    //add blue highlight to selected cell
    func addHilight(){
        let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forRow: indexSelected, inSection: 0))
        cell?.backgroundColor = blue
    }
    
    //Add a new image to the collection and set as selected one
    func addNewImage(image: UIImage){
        if(images.count == 0){ //first image added
            //allows delete and done action
            deleteButton.hidden = false
            doneButton.enabled = true
            
            //specify the orientation of the image
            landscape = isLandscape(image)
        }
        
        if(landscape == isLandscape(image)){ //if the image has the same orientation than the first image
            //add image to the collection
            imageView.image = image
            images.append(image)
            collectionView.reloadSections(NSIndexSet(index: 0)) //make sure a we wont get a nil cell
            
            //uptade to selected cell
            indexSelected = images.count - 1
            removeHighlight()
            addHilight()
        }else{
            let alert = UIAlertController(title: "Image not imported", message: "All images must have the same orientation", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    //switch two cells of the collection view
    func switchCells(index1 : Int, index2: Int){
        let img2 = images[index2]
        images[index2] = images[index1]
        images[index1] = img2
        collectionView.reloadSections(NSIndexSet(index: 0))
        
    }
    
    //Check if an image is in landscape or portrait mode
    func isLandscape(image: UIImage)-> Bool{
        let ratio = image.size.width/image.size.height
        if(1.48 < ratio && ratio < 1.52){
            return true
        }
        return false
    }
    
    //Move the blue highlight and change the selected index
    func updateSelectedTo(target: Int){
        
        removeHighlight()
        
        //update the selected image
        indexSelected = target
        imageView.image = images[indexSelected]
        
        //add a blue highlight to the newly selected cell
        addHilight()
    }
    
    //Display an alert when device has no camera
    func noCamera(){
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style:.Default, handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC, animated: true, completion: nil)
        bringHandBack()
    }
    
    //Clear the blur effect on the main image view
    func clearImage(){
        if(blur){
            //animate the disappearing of the import buttons and blur
            UIView.animateWithDuration(0.5, delay: 0.0,
                options: .CurveEaseIn , animations: {
                    self.cameraButton.alpha = 0
                    self.galleryButton.alpha = 0
                    self.blurEffectView.alpha = 0
                }, completion: {
                    (value: Bool) in
                    self.cameraButton.hidden = true
                    self.galleryButton.hidden = true
                    self.blurEffectView.removeFromSuperview()
                    self.blur = false
            })

        }
    }
    
    //bring the hand image button back with animation
    func bringHandBack(){
        handImage.transform = CGAffineTransformMakeScale(1, 1)
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.handImage.alpha = 1
            }, completion: nil)
    }
    
    //save GIFs to database and doc directory, then go back to the menu
    func saveAndQuit(){
        if let savedGIFs = loadGIFs() { //Load the GIFs if there is some
            GIFs = savedGIFs
        }
        let url = saveToDir() //save the .gif file
        let newGIF = GIF(name: nameField.text!, images: self.images, duration: self.duration,url: url)
        GIFs.append(newGIF!)
        saveGIFs() // add new GIF and save to database
        performSegueWithIdentifier("backToMenu", sender: self)

    }
    
    //save as a .gif to the documents folder and return the destination url
    //code borrowed from http://stackoverflow.com/questions/31845981/problems-creating-an-animated-gif-in-swift
    func saveToDir()->NSURL{
        //let documentsDirectory = NSTemporaryDirectory()
        let url = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!.URLByAppendingPathComponent(nameField.text! + ".gif")
        //let url = NSURL(fileURLWithPath: documentsDirectory).URLByAppendingPathComponent(nameField.text! + ".gif")
        let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]] //loop indefintely
        let frameDuration = CGFloat(duration)/CGFloat(images.count)
        let gifProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: frameDuration]]
        let destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, images.count, nil)!
        CGImageDestinationSetProperties(destination, fileProperties)
        
        for image in images {
            CGImageDestinationAddImage(destination, image.CGImage!, gifProperties)
        }
        
        CGImageDestinationFinalize(destination)
        return url
    }

    // MARK: NSCoding
    
    //Save the GIFs to the dedicated file (database)
    func saveGIFs() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(GIFs, toFile: GIF.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save GIFs...")
        }
    }
    
    //Load the GIFs from the dedicated file (database)
    func loadGIFs() -> [GIF]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(GIF.ArchiveURL.path!) as? [GIF]
    }
    
}
