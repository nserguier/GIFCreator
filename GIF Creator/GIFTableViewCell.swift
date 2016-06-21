//
//  GIFTableViewCell.swift
//  GIF Creator
//
//  Created by Nicklos Edouard Arthur Serguier on 4/18/16.
//  Copyright © 2016 Nicklos Serguier. All rights reserved.
//

import UIKit

// Define the prototype cell of the gif table view
class GIFTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var GIFname: UILabel! //the name of the GIF
    @IBOutlet weak var GIFimage: UIImageView! //the sequeunce of images of the GIF
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
