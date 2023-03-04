//
//  UIView+Border.swift
//  Grodio
//
//  Created by Upneet  Randhawa on 2022-07-04.
//  Copyright © 2022 USR. All rights reserved.
//

import UIKit

extension UIView {
    
    func addBorder(cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: CGColor){
        
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor
    }
}
