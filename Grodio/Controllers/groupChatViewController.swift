//
//  groupChatViewController.swift
//  Grodio
//
//  Created by Upneet  Randhawa on 2022-07-03.
//  Copyright © 2022 USR. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestoreSwift

class GroupChatViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    
    @IBOutlet weak var groupNameLabel: UILabel!
    
    @IBOutlet weak var chatCollectionView: UICollectionView!
    @IBOutlet weak var messageInputTF: UITextField!
    
    @IBOutlet weak var chatTabBarItem: UITabBarItem!
    
    var messages:[Message]?
    
    var firebaseDB:Firestore?
    var firebaseDBChatsRef:CollectionReference?
    var firebaseDBGroupsRef:CollectionReference?
    var firestoreGroupDocumenLastMessagetListener:ListenerRegistration?
    
    var notSeenMessagesCount:Int = 0
    
    var hasViewAlreadyAppeared = false
    
    private let sectionInsets = UIEdgeInsets(
      top: 5.0,
      left: 0.0,
      bottom: 300.0,
      right: 0.0)
    
    var statusBarStyle = UIStatusBarStyle.default { didSet { setNeedsStatusBarAppearanceUpdate() } }
    override var preferredStatusBarStyle: UIStatusBarStyle { statusBarStyle }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("\(#fileID) \(#function)")
        
        //set statusbarstyle
        setStatusBarColor(traitCollection: traitCollection)
        
        self.groupNameLabel.text = group?.groupName?.capitalized
        messages = [Message]()
        
        chatCollectionView.delegate = self
        chatCollectionView.dataSource = self
        
        let sendButton = UIButton(type: .system)
        sendButton.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        sendButton.tintColor = .systemGreen
        sendButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        sendButton.frame = CGRect(x: CGFloat(messageInputTF.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        sendButton.addTarget(self, action: #selector(self.sendButtonPressed), for: .touchUpInside)
        messageInputTF.rightView = sendButton
        messageInputTF.rightViewMode = .always
        messageInputTF.layer.cornerRadius = 15.0
        messageInputTF.layer.borderWidth = 1.0
        messageInputTF.layer.borderColor = UIColor.systemGreen.cgColor
        
        let inputAccessoryCustomView: UIView = {
            let accView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: messageInputTF.frame.height + 2))
            accView.backgroundColor = .systemBackground
            
            let sendButtonAccessoryView = UIButton(type: .system)
            sendButtonAccessoryView.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
            sendButtonAccessoryView.tintColor = .systemGreen
            sendButtonAccessoryView.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
            sendButtonAccessoryView.addTarget(self, action: #selector(self.sendButtonPressed), for: .touchUpInside)
            
            let inputTextFieldAccessoryView = UITextField()
            inputTextFieldAccessoryView.placeholder = "message"
            inputTextFieldAccessoryView.tag = 10
            inputTextFieldAccessoryView.returnKeyType = .send
            inputTextFieldAccessoryView.layer.cornerRadius = 15.0
            inputTextFieldAccessoryView.layer.borderWidth = 1.0
            inputTextFieldAccessoryView.layer.borderColor = UIColor.systemGreen.cgColor
            
            
            inputTextFieldAccessoryView.frame = CGRect(x: CGFloat(messageInputTF.frame.origin.x), y: CGFloat(0), width: CGFloat(view.frame.width - 25), height: CGFloat(messageInputTF.frame.height))
            
            sendButtonAccessoryView.frame = CGRect(x: CGFloat(inputTextFieldAccessoryView.frame.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
            
            inputTextFieldAccessoryView.addTarget(self, action: #selector(self.inputAccessoryTextFieldEditingChanged(_:)), for: .editingChanged)
            inputTextFieldAccessoryView.delegate = self
            inputTextFieldAccessoryView.rightView = sendButtonAccessoryView
            inputTextFieldAccessoryView.rightViewMode = .always
            
            let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
            inputTextFieldAccessoryView.leftView = paddingView
            inputTextFieldAccessoryView.leftViewMode = .always
            
            accView.addSubview(inputTextFieldAccessoryView)
            
            
            return accView
        }()
        
        messageInputTF.inputAccessoryView = inputAccessoryCustomView
        
        initFirebase()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(hideKeyboard)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        loadChat()
        
        //listener for last chat
        //attachListenerToFirestoreGroupAndGetLastMessageUpdates()
        
        
        print("\(#fileID) \(#function): messages = \(messages?.description)")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // handle theme change here.
            print("\(#fileID) : \(#function): ")
            
            //set statusbarstyle
            setStatusBarColor(traitCollection: traitCollection)
        }
        
    }
    
    func setStatusBarColor(traitCollection: UITraitCollection){
        print("\(#fileID) \(#function)")
        
        switch traitCollection.userInterfaceStyle {
            case .unspecified: statusBarStyle = .default
            case .light: statusBarStyle = .lightContent
            case .dark: statusBarStyle = .darkContent
        }
    }
    
    func initFirebase(){
        print("\(#fileID) \(#function)")
        
        firebaseDB = Firestore.firestore()
        firebaseDBChatsRef = firebaseDB?.collection("chats")
        firebaseDBGroupsRef = firebaseDB?.collection("groups")
    }
    
    @objc func hideKeyboard(){
        print("\(#fileID) \(#function)")
        
        self.view.endEditing(true)
        self.messageInputTF.inputAccessoryView?.resignFirstResponder()
//        guard let inputAccessoryViewTextField = messageInputTF.inputAccessoryView?.viewWithTag(10) else { return }
//        inputAccessoryViewTextField.resignFirstResponder()
//        self.messageInputTF.isEnabled = false
//
//        print("\(#fileID) \(#function) BEFORE messageInputTF isEnabled = \(messageInputTF.isEnabled)")
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//
//            self.messageInputTF.isEnabled = true
//            print("\(#fileID) \(#function) AFTER messageInputTF isEnabled = \(self.messageInputTF.isEnabled)")
//        }
//
//        self.messageInputTF.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        print("\(#fileID) \(#function)")
        
//        if let keyboardFrame:NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue{
//            let bottomSpace = self.view.frame.height - (messageInputTF.frame.height + messageInputTF.frame.origin.y)
//            self.view.frame.origin.y -= keyboardFrame.cgRectValue.height - bottomSpace - 120
//        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            self.collectionViewScrollToBottom()
        }
        
    }
    
    @objc func keyboardWillHide(){
        print("\(#fileID) \(#function)")
        
//        self.view.frame.origin.y = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            self.collectionViewScrollToBottom()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("\(#fileID) \(#function)")
//        textField.resignFirstResponder()
//        keyboardWillHide()
        
        sendButtonPressed(self)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let currentCharacterCount = textField.text?.count ?? 0
        if range.length + range.location > currentCharacterCount {
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        
        return newLength <= 256
    }
        
    override func viewDidDisappear(_ animated: Bool) {
        print("\(#fileID) \(#function)")
        
        firestoreGroupDocumenLastMessagetListener?.remove()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("\(#fileID) \(#function)")
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("\(#fileID) \(#function)")
        print("\(#fileID) \(#function): badgeValue notSeenMessagesCount = \(notSeenMessagesCount)")
        
        if hasViewAlreadyAppeared {
            notSeenMessagesCount = 0
            chatTabBarItem.badgeValue = nil
            loadChat()
        }
        
        else {
            hasViewAlreadyAppeared = true
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("\(#fileID) \(#function)")
    }
    @IBAction func messageInputTFTouchDown(_ sender: Any) {
        print("\(#fileID) \(#function)")
        guard let inputAccessoryViewTextField = messageInputTF.inputAccessoryView?.viewWithTag(10) else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            inputAccessoryViewTextField.becomeFirstResponder()
        }
    }
    
    @objc func inputAccessoryTextFieldEditingChanged(_ textField: UITextField){
        print("\(#fileID) \(#function)")
        self.messageInputTF.text = textField.text
    }
    
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        print("\(#fileID) \(#function)")
        
        guard let msgLength = messageInputTF.text?.trimmingCharacters(in: .whitespaces).count else {
            print("\(#fileID) \(#function): error getting text from messageInputTF returning")
            return
        }
        
        if msgLength < 1 {
            print("\(#fileID) \(#function): empty message returning")
            return
        }
        
        let msg = Message(_senderUsername: user?.username,
                          _message: messageInputTF.text,
                          _creationDate: Timestamp.init().dateValue())
        
        print("\(#fileID) \(#function): new msg = \(msg)")
        
        do {
            try firebaseDBChatsRef?.document(group?.groupName ?? "").collection("messages").addDocument(from: msg, completion: { (error) in
                if let _ = error {
                    print("\(#fileID) \(#function): Error writing group to Firestore: \(String(describing: error))")
                }
                else {
                    //attach a listener for updates
                    print("\(#fileID) \(#function): create document successful")
                    
                    self.messageInputTF.text = ""
                    guard let inputAccessoryViewTextField:UITextField = self.messageInputTF.inputAccessoryView?.viewWithTag(10) as? UITextField else { return }
                    inputAccessoryViewTextField.text = ""
                    //self.getDocuments()
                    
                    self.updateLastMessageInGroup(msg: msg)
                    
                }
            })
                
            }
        catch let error {
            print("\(#fileID) \(#function): Error writing group to Firestore: \(error)")
        }
        
    }

    func loadChat(){
        print("\(#fileID) \(#function)")
        
        messages = [Message]()
        
        firebaseDBChatsRef?.document(group?.groupName ?? "").collection("messages").order(by: "creationDate", descending: false).getDocuments(completion: { (snapshot, error) in
            if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    
                    for document in snapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        
                        let result = Result {
                            try document.data(as: Message.self)
                            }
                        
                        switch result {
                        case .success(let msg):
                            if let messageObj = msg {
                                print("\(#fileID) \(#function): msg: \(messageObj)")
                                self.messages?.append(messageObj)
                                
                            } else {
                                print("Document does not exist")
                                
                            }
                        case .failure(let error):
                            // A `City` value could not be initialized from the DocumentSnapshot.
                            print("\(#fileID) \(#function): Error decoding user: \(error)")
                        }
                        
                        
                        
                    }
                    
                    if let messagesArray = self.messages, messagesArray.count > 0 {
                        group?.lastMessage = messagesArray[messagesArray.count - 1]
                    }
                    
                    self.attachListenerToFirestoreGroupAndGetLastMessageUpdates()
                    
                    print("\(#fileID) \(#function): messages count = \(self.messages?.count)")
                    
                    self.chatCollectionView.reloadData()
                    
                    self.collectionViewScrollToBottom()
                    
                    
                }
        })
    }
    
    func updateLastMessageInGroup(msg:Message){
        print("\(#fileID) \(#function): msg = \(msg)")
        
        guard let groupName = group?.groupName else {
            print("\(#fileID) \(#function): group name retrieve error")
            return
        }
        
        firebaseDBGroupsRef?.document(groupName).updateData([
            "lastMessage.message": msg.message,
            "lastMessage.senderUsername": msg.senderUsername,
            "lastMessage.creationDate": msg.creationDate
        ], completion: { (error) in
            if let err = error {
                    print("\(#fileID) \(#function): Error updating data = \(err)")
                } else {
                    print("\(#fileID) \(#function): Document successfully written!")
                }
        })
        
    }
    
    func attachListenerToFirestoreGroupAndGetLastMessageUpdates(){
        print("\(#fileID) \(#function)")
        
        firestoreGroupDocumenLastMessagetListener =  firebaseDBGroupsRef?.document(group?.groupName ?? "").addSnapshotListener(includeMetadataChanges: false
            , listener: { (documentSnapshot, error) in
                guard let document = documentSnapshot else {
                    print("\(#fileID) \(#function): Error fetching document: \(error!)")
                    //TODO
                    return
                }
                guard let data = document.data() else {
                    print("\(#fileID) \(#function): Document data was empty.")
                    return
                }
                
                let source = document.metadata.hasPendingWrites ? "Local" : "Server"
                
                if source != "Server"{
                    print("\(#fileID) \(#function): Source is \(source) : returning")
                    return
                }
                
                print("\(#fileID) \(#function): Source is \(source)")
                    
                let result = Result {
                    try document.data(as: Group.self)
                }
                
                switch result {
                case .success(let _group):
                    if let groupObj = _group {
                        print("\(#fileID) \(#function): server msg: \(groupObj.lastMessage)")
                        print("\(#fileID) \(#function): local group last msg: \(group?.lastMessage)")
                        
                        let serverGroupLastMessage = Message(_senderUsername: groupObj.lastMessage?.senderUsername, _message: groupObj.lastMessage?.message, _creationDate: groupObj.lastMessage?.creationDate)
                        
                        if group?.lastMessage == nil {
                            
                            if groupObj.lastMessage != nil {
                                print("\(#fileID) \(#function): last message is null")
                                group?.lastMessage = serverGroupLastMessage
                                self.addSingleMessageToCollectionViewAndReload(adding: serverGroupLastMessage)
                            }
                        }
                        else if let localGroupLastMessage = group?.lastMessage {
                            if !localGroupLastMessage.equals(compareTo: serverGroupLastMessage){
                                print("\(#fileID) \(#function): last message changed")
                                group?.lastMessage = serverGroupLastMessage
                                self.addSingleMessageToCollectionViewAndReload(adding: serverGroupLastMessage)
                            }
                            
                        }
                        
                        else {
                            print("\(#fileID) \(#function): error retreiving last message")
                        }
                        
                    } else {
                        print("Document does not exist")
                        
                    }
                case .failure(let error):
                    // A `City` value could not be initialized from the DocumentSnapshot.
                    print("\(#fileID) \(#function): Error decoding user: \(error)")
                }
                
                
            })
    }
    
    func addSingleMessageToCollectionViewAndReload(adding msg:Message){
        print("\(#fileID) \(#function):")
        messages?.append(msg)
        chatCollectionView.reloadData()
//        if let count = messages?.count {
//            if count == 0 {return}
//            let indexPath = IndexPath(item: count - 1, section: 0)
//            chatCollectionView.reloadItems(at: [indexPath])
//        }
        collectionViewScrollToBottom()
        
        addBadgeValueToChatIconOnToolbar()
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("\(#fileID) \(#function): count = \(String(describing: messages?.count))")
        
        if let messages = messages {
            return messages.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //print("\(#fileID) \(#function): indexPath = \(indexPath.row)")
        let cell:MessageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageCell",for: indexPath) as! MessageCell
            
        // Configure the cell
        
        if let message = messages?[indexPath.row] {
            cell.configureCellWith(message: message)
            
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)] as [NSAttributedString.Key: Any]

            let messageEstimatedFrame = NSString(string: message.message ?? "").boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font:  UIFont.systemFont(ofSize: 17)], context: nil)
            
            let usernameEstimatedFrame = NSString(string: message.senderUsername ?? "").boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font:  UIFont.systemFont(ofSize: 17)], context: nil)
            
            let messageDateEstimatedFrame = NSString(string: message.getCreatedDateInChatTime() ).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font:  UIFont.systemFont(ofSize: 15)], context: nil)
            
            let finalMessageTextViewWidth = (messageEstimatedFrame.width > usernameEstimatedFrame.width + messageDateEstimatedFrame.width) ? messageEstimatedFrame.width : usernameEstimatedFrame.width + messageDateEstimatedFrame.width
            
            let finalMessageTextViewHeight = messageEstimatedFrame.height + usernameEstimatedFrame.height
            
            cell.messageContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width + 16, height: finalMessageTextViewHeight + 20)
            
            
            
            
            
            if message.senderUsername == user?.username {
                cell.messageSenderUsernameLabel.frame = CGRect(x: view.frame.width - finalMessageTextViewWidth - 2*sectionInsets.right - 40, y: 0, width: usernameEstimatedFrame.width, height: usernameEstimatedFrame.height)
                cell.dateSendLabel.frame = CGRect(x: view.frame.width - finalMessageTextViewWidth + usernameEstimatedFrame.width - 2*sectionInsets.right - 40 + 5, y: 2, width: messageDateEstimatedFrame.width, height: messageDateEstimatedFrame.height)
                cell.messageTV.frame = CGRect(x: view.frame.width - finalMessageTextViewWidth - 2*sectionInsets.right - 40, y: usernameEstimatedFrame.height + 10, width: finalMessageTextViewWidth + 16, height: messageEstimatedFrame.height + 10)
                
            }
            else {
                cell.messageSenderUsernameLabel.frame = CGRect(x: 8, y: 0, width: usernameEstimatedFrame.width, height: usernameEstimatedFrame.height)
                cell.dateSendLabel.frame = CGRect(x: usernameEstimatedFrame.width + 8 + 5, y: 2, width: messageDateEstimatedFrame.width, height: messageDateEstimatedFrame.height)
                cell.messageTV.frame = CGRect(x: 8, y: usernameEstimatedFrame.height + 5, width: finalMessageTextViewWidth + 16, height: messageEstimatedFrame.height + 10)
            }
            
            
            
            //print("\(#fileID) \(#function): indexPath = \(indexPath.row): estimatedFrame = \(finalMessageTextViewWidth) \(finalMessageTextViewHeight)")
        }
        
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //print("\(#fileID) \(#function)")
        
        var size = CGSize.zero
        
        guard let message = messages?[indexPath.row] else {
            return size
        }
        
        if let message = messages?[indexPath.row] {
            
            let paddingSpace:CGFloat = sectionInsets.left
            let maxWidthOfCell = view.frame.width - 2 * paddingSpace
            
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)] as [NSAttributedString.Key: Any]

            let messageEstimatedFrame = NSString(string: message.message ?? "").boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font:  UIFont.systemFont(ofSize: 17)], context: nil)
            
            let usernameEstimatedFrame = NSString(string: message.senderUsername ?? "").boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font:  UIFont.systemFont(ofSize: 17)], context: nil)
            
            //print("\(#fileID) \(#function): indexPath = \(indexPath.row): estimatedFrame = \(messageEstimatedFrame.width) \(messageEstimatedFrame.height)")
            
            return CGSize(width: maxWidthOfCell, height: messageEstimatedFrame.height + usernameEstimatedFrame.height + 20)
        }
        
        return size
    }
    
    func getSizeFromFont(font: UIFont, text:String) -> CGSize {
        //print("\(#fileID) \(#function): font name = \(font.fontName), font size = \(font.pointSize) text = \(text)")
        
        let fontAttributes = [NSAttributedString.Key.font: font]
                return text.size(withAttributes: fontAttributes)
    }
    
    func getHeightOfTextWithConstrainedWidth(width: CGFloat, font: UIFont, text: String) -> CGFloat{
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
      ) -> UIEdgeInsets {
        return sectionInsets
      }
      
      // 4
      func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
      ) -> CGFloat {
        return sectionInsets.top
      }
    
    
    func collectionViewScrollToBottom() {
        let numberOfSections = self.chatCollectionView!.numberOfSections
        if numberOfSections > 0 {
            let numberOfRows = self.chatCollectionView!.numberOfItems(inSection: numberOfSections - 1)
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.chatCollectionView!.scrollToItem(at: indexPath, at: .top, animated: true)
            }
        }
    }
    
    func addBadgeValueToChatIconOnToolbar(){
        print("\(#fileID) \(#function)")
        if self.isViewLoaded && self.view.window != nil {
            print("\(#fileID) \(#function): view visible")
            return
        }
        print("\(#fileID) \(#function): view not visible")
        notSeenMessagesCount += 1
        print("\(#fileID) \(#function): notSeenMessagesCount = \(notSeenMessagesCount)")
        //chatTabBarItem.badgeValue = String(notSeenMessagesCount)
    }
    
}
