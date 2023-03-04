//
//  UIViewController+vibrate.swift
//  Grodio
//
//  Created by Upneet  Randhawa on 2022-08-29.
//  Copyright © 2022 USR. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func vibrate(style: UIImpactFeedbackGenerator.FeedbackStyle){
        
        if #available(iOS 10.0, *) {
             UIImpactFeedbackGenerator(style: style).impactOccurred()
        }
    }
}

