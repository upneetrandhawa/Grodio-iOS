//
//  UIView+Shadow.swift
//  Grodio
//
//  Created by Upneet  Randhawa on 2022-08-28.
//  Copyright © 2022 USR. All rights reserved.
//

import Foundation

import UIKit

extension UIView {
    
    func addShadow(shadowColor: CGColor, shadowOpacity: Float, shadowOffset: CGSize, shadowRadius: CGFloat){
        
        self.layer.shadowColor = shadowColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowRadius
    }
}
