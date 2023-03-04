//
//  UIButton+rotate.swift
//  Grodio
//
//  Created by Upneet  Randhawa on 2022-07-04.
//  Copyright © 2021 USR. All rights reserved.
//

import Foundation

import UIKit

extension UIButton {
    private static let kRotationAnimationKey = "rotationanimationkey"

    func rotate(duration: Double = 1) {
        if layer.animation(forKey: UIButton.kRotationAnimationKey) == nil {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")

            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = Float.pi * 2.0
            rotationAnimation.duration = duration
            rotationAnimation.repeatCount = Float.infinity

            layer.add(rotationAnimation, forKey: UIButton.kRotationAnimationKey)
        }
    }

    func stopRotating() {
        if layer.animation(forKey: UIButton.kRotationAnimationKey) != nil {
            layer.removeAnimation(forKey: UIButton.kRotationAnimationKey)
        }
    }
}
