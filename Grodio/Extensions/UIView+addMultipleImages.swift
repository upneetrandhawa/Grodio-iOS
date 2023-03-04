//
//  UIView+addMultipleImages.swift
//  Grodio
//
//  Created by Upneet  Randhawa on 2022-07-08.
//  Copyright © 2022 USR. All rights reserved.
//

import UIKit
import Foundation

extension UIView{
    
    func addCircleImageToAView(tintColor: UIColor){
        print("\(#fileID) \(#function)")
        
        let textFieldLeftModeImageWidthAndHeight = 5.0
        let viewFrame = self.frame
        let noOfImagesPossibleInRow = Int(Double(viewFrame.width) / textFieldLeftModeImageWidthAndHeight)
        let noOfImagesPossibleInColumn = Int(Double(viewFrame.height) / textFieldLeftModeImageWidthAndHeight)
        
        print("\(#fileID) \(#function) noOfImagesPossibleInRow ", noOfImagesPossibleInRow)
        print("\(#fileID) \(#function) noOfImagesPossibleInColumn ", noOfImagesPossibleInColumn)
        
        
        for x in 1..<noOfImagesPossibleInRow {
            
            var alternate = x % 2 == 0
            
            for y in 1..<noOfImagesPossibleInColumn {
                if alternate {
                    alternate = !alternate
                    let circleFillImageView = UIImageView(frame: CGRect(x: Double(Double(x)*textFieldLeftModeImageWidthAndHeight),
                                                                        y: Double(Double(y)*textFieldLeftModeImageWidthAndHeight),
                                                                        width: textFieldLeftModeImageWidthAndHeight,
                                                                        height: textFieldLeftModeImageWidthAndHeight))
                    circleFillImageView.image =  UIImage(systemName: "circle.fill")
                    circleFillImageView.contentMode = .scaleAspectFit
                    circleFillImageView.tintColor = tintColor
                    
                    self.addSubview(circleFillImageView)
                    
                    
                }
                else {
                    alternate = !alternate
                }
            }
        }
    }
}
