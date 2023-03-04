//
//  UIView+rotate.swift
//  Grodio
//
//  Created by Upneet  Randhawa on 2022-07-04.
//  Copyright © 2022 USR. All rights reserved.
//

import UIKit
import Foundation

extension UIView{
    
    func rotateByRandomDegrees() {
        let angle = Float.random(in: 10...80)
        let radians = CGFloat(angle / 180.0) * CGFloat.pi
        let rotation = self.transform.rotated(by: radians);
        self.transform = rotation
    }
}
