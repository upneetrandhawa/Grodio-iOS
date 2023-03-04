//
//  UITextView+centerVertically.swift
//  Grodio
//
//  Created by Upneet  Randhawa on 2022-07-04.
//  Copyright © 2022 USR. All rights reserved.
//

import Foundation
import UIKit

extension UITextView {
    func centerVertically() {
        self.textAlignment = .center
        let fitSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fitSize)
        let calculate = (bounds.size.height - size.height * zoomScale) / 2
        let offset = max(1, calculate)
        contentOffset.y = -offset
    }
}
