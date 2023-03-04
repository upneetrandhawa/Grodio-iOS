//
//  UITextField+setLeftImage.swift
//  Grodio
//
//  Created by Upneet  Randhawa on 2022-07-04.
//  Copyright © 2022 USR. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {

    func setLeftImage(image: UIImage?) {
        
        let textFieldLeftModeImageWidthAndHeight = self.frame.height / 2
        
        let imageView = UIImageView(frame: CGRect(x: 8.0, y: (CGFloat(Double(self.frame.height)) - textFieldLeftModeImageWidthAndHeight)/2, width: textFieldLeftModeImageWidthAndHeight, height: textFieldLeftModeImageWidthAndHeight))
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.systemGreen

        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: Int(textFieldLeftModeImageWidthAndHeight)+4, height: Int(self.frame.height)))
        containerView.addSubview(imageView)
        self.leftViewMode = .always
        self.leftView = containerView
    }
}
