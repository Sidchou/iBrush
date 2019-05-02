//
//  icons.swift
//  MobileLabARKit
//
//  Created by ching Hsi chou on 5/2/19.
//  Copyright © 2019 Mobile Lab. All rights reserved.
//

import UIKit

class Icons: UIView {

    var forSizes = false
    var forAlpha = false
    
    override func draw(_ rect: CGRect){
        ////        let radius: CGFloat = max(bounds.width, bounds.height)/2
        var cord2 = CGPoint(x: bounds.width/2*0.95, y: bounds.height/2*0.95)
        if forSizes {
        cord2 = CGPoint(x: bounds.width/2*0.5, y: bounds.height/2*0.5)
        }
        let cord1 = CGPoint(x: (bounds.width - cord2.x)/2, y: (bounds.height - cord2.y)/2)

        let newRect = CGRect(x: cord1.x, y: cord1.y, width: cord2.x, height: cord2.y)

        let path = UIBezierPath(ovalIn: newRect)
//        let path = UIBezierPath(
        UIColor.lightGray.withAlphaComponent(0.9).setFill()
        if forAlpha{
        UIColor.lightGray.withAlphaComponent(0.1).setFill()
        }
        path.fill()
        UIColor.white.setStroke()
        path.lineWidth = 1
        path.stroke()
    }

}
