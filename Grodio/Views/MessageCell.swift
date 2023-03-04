//
//  MessageCell.swift
//  Grodio
//
//  Created by Upneet  Randhawa on 2022-01-19.
//  Copyright © 2022 USR. All rights reserved.
//

import UIKit

class MessageCell: UICollectionViewCell {
    
    
    @IBOutlet weak var messageContainer: UIView!
    
    let messageTV: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 17)
        tv.text = "message"
        tv.textColor = .white
        tv.isEditable = false
        tv.isScrollEnabled = false
        return tv
    }()
    
    let messageSenderUsernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.text = "username"
        return label
    }()
    let dateSendLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .lightGray
        label.text = "date"
        return label
    }()
    

    override func awakeFromNib() {
        print("\(#fileID) \(#function)")
        super.awakeFromNib()
        self.messageTV.layer.cornerRadius = 10.0
        
        
        //var messageWidth = getSizeFromFont(font: UIFont.systemFont(ofSize: 17), text:self.messageTV.text).width
        
//        if (messageWidth > self.messageContainer.bounds.size.width) {
//            messageWidth = self.messageContainer.bounds.size.width
//        }
//        self.messageTV.bounds.size.width = messageWidth + 10
    }

    //MARK: Helpers

    func configureCellWith(message :Message) {
        print("\(#fileID) \(#function)")
        
        
        self.messageSenderUsernameLabel.text = message.senderUsername
        self.dateSendLabel.text = message.getCreatedDateInChatTime()
        
        self.messageTV.text = message.message
        self.messageTV.centerVertically()
        
        if message.senderUsername == user?.username {
            self.messageTV.backgroundColor = .systemGreen
            self.messageTV.textAlignment = .right
        }
        else {
            self.messageTV.backgroundColor = .lightGray
            self.messageTV.textAlignment = .left
        }
        
       
       
    }
    
    override func layoutSubviews() {
        print("\(#fileID) \(#function)")
        super.layoutSubviews()
        addSubview(messageContainer)
        addSubview(messageSenderUsernameLabel)
        addSubview(dateSendLabel)
        addSubview(messageTV)
        
       
        
        
    }
    
    func getSizeFromFont(font: UIFont, text:String) -> CGSize {
        print("\(#fileID) \(#function): font name = \(font.fontName), font size = \(font.pointSize) text = \(text)")
        
        let fontAttributes = [NSAttributedString.Key.font: font]
                return text.size(withAttributes: fontAttributes)
    }
    
    
    
}
