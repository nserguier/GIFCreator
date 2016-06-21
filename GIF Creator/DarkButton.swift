//
//  DarkButton.swift
//  GIF Creator
//
//  Created by Nicklos Edouard Arthur Serguier on 3/31/16.
//  Copyright © 2016 Nicklos Serguier. All rights reserved.
//

import UIKit

//Custom rounded button with dark translucid color
class DarkButton: UIButton {

    override func drawRect(rect: CGRect) {
        
        let back = UIColor(red: 0.0,green: 0.0,blue: 0.0,alpha: 0.4)
        let border = UIColor(red: 0.5,green: 0.5,blue: 0.5,alpha: 0.6)
        let white = UIColor.whiteColor()
        setTitleColor(white, forState: UIControlState.Normal)
        layer.backgroundColor = back.CGColor
        layer.cornerRadius = 25
        layer.borderWidth = 1
        layer.borderColor = border.CGColor
        contentEdgeInsets = UIEdgeInsetsMake(15,15,15,15)
        
    }

}
