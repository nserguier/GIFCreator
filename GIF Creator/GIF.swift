//
//  GIF.swift
//  GIF Creator
//
//  Created by Nicklos Edouard Arthur Serguier on 4/18/16.
//  Copyright © 2016 Nicklos Serguier. All rights reserved.
//

import UIKit


//Define a GIF object that can be saved in a file
class GIF: NSObject, NSCoding {
    
    // MARK: Properties
    var name: String //name of the gif
    var images: [UIImage] //sequence of images of the gif
    var duration: Double //duration of one gif aniamtion
    var url: NSURL //url of the saved corresponding .gif file
    
    // MARK: Archiving Paths
    //Borrowed code: Swift - getting started: FoodTracker
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("GIFs")
    
    // MARK: Types
    
    struct PropertyKey {
        static let nameKey = "name"
        static let imagesKey = "images"
        static let durationKey = "duration"
        static let urlKey = "url"
    }
    
    init?(name: String, images: [UIImage], duration: Double, url: NSURL){
        self.name = name
        self.images = images
        self.duration = duration
        self.url = url
        super.init()
        
        //check if the properties have valid values
        if(name.isEmpty || images.isEmpty || duration<0){
            return nil
        }
    }
    
    // MARK: NSCoding
    
    //encode a GIF object
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(images, forKey: PropertyKey.imagesKey)
        aCoder.encodeDouble(duration, forKey: PropertyKey.durationKey)
        aCoder.encodeObject(url, forKey: PropertyKey.urlKey)
    }
    
    //decode a GIF object
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        let images = aDecoder.decodeObjectForKey(PropertyKey.imagesKey) as! [UIImage]
        let duration = aDecoder.decodeDoubleForKey(PropertyKey.durationKey)
        let url = aDecoder.decodeObjectForKey(PropertyKey.urlKey) as! NSURL
        
        // Must call designated initializer.
        self.init(name: name, images: images, duration: duration, url: url)
    }
}