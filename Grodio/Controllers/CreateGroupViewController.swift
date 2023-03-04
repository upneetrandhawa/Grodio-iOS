//
//  CreateGroupViewController.swift
//  Grodio
//
//  Created by Upneet  Randhawa on 2022-06-29.
//  Copyright © 2021 USR. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import Firebase
import FirebaseFirestoreSwift

class CreateGroupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var createFrontView: UIView!
    @IBOutlet weak var speakerFrontView: UIView!
    @IBOutlet weak var joinFrontView: UIView!
    
    
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var joinGroupButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var createGroupNameTF: UITextField!
    @IBOutlet weak var createGroupPinTF: UITextField!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var screw1CreateFrontView: UIImageView!
    @IBOutlet weak var screw2CreateFrontView: UIImageView!
    @IBOutlet weak var screw3CreateFrontView: UIImageView!
    @IBOutlet weak var screw4CreateFrontView: UIImageView!
    
    var firebaseDB:Firestore?
    var firebaseDBGroupsRef:CollectionReference?
    var firebaseDBUsersRef:CollectionReference?
    
    let localStorage = LocalStorage.sharedInstance
    
    var statusBarStyle = UIStatusBarStyle.default { didSet { setNeedsStatusBarAppearanceUpdate() } }
    override var preferredStatusBarStyle: UIStatusBarStyle { statusBarStyle }
    
    override func viewDidLoad() {
        print("\(#fileID) \(#function)")
        super.viewDidLoad()
        
        //set statusbarstyle
        setStatusBarColor(traitCollection: traitCollection)

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.backItem?.backBarButtonItem?.tintColor = .systemGreen
        
        //set corner radius and borders for our views
        createFrontView.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        backgroundView.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        joinFrontView.addBorder(cornerRadius: 7.5, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        speakerFrontView.addBorder(cornerRadius: 15.0, borderWidth: 5.0, borderColor: UIColor.systemGreen.cgColor)
        
        createButton.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        joinGroupButton.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        backButton.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        createGroupNameTF.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        createGroupPinTF.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        //add shadows
        joinFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 2.0)
        
        createFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 2.0)
        
        createButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 5.0), shadowRadius: 1.0)
        
        joinGroupButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 3.0), shadowRadius: 1.0)
        
        backButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 5.0), shadowRadius: 1.0)
        
        //add dots to speakerFrontView
        speakerFrontView.addCircleImageToAView(tintColor: UIColor.systemBackground)
        
        //add random rotation to our screws
        screw1CreateFrontView.rotateByRandomDegrees()
        screw2CreateFrontView.rotateByRandomDegrees()
        screw3CreateFrontView.rotateByRandomDegrees()
        screw4CreateFrontView.rotateByRandomDegrees()
        
        //set textfields textField image
        createGroupNameTF.setLeftImage(image: UIImage(systemName: "person.3"))
        createGroupPinTF.setLeftImage(image: UIImage(systemName: "lock"))
        
        createGroupNameTF.delegate = self
        createGroupPinTF.delegate = self
        
        initFirebase()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(hideKeyboard)))
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // handle theme change here.
            print("\(#fileID) : \(#function): ")
            
            
            //set statusbarstyle
            setStatusBarColor(traitCollection: traitCollection)
            
            joinFrontView.layer.borderColor = UIColor.systemBackground.cgColor
            createFrontView.layer.borderColor = UIColor.systemBackground.cgColor
            backgroundView.layer.borderColor = UIColor.systemBackground.cgColor
            
            createGroupNameTF.layer.borderColor = UIColor.systemBackground.cgColor
            createGroupPinTF.layer.borderColor = UIColor.systemBackground.cgColor
            
            createButton.layer.borderColor = UIColor.systemBackground.cgColor
            joinGroupButton.layer.borderColor = UIColor.systemBackground.cgColor
            backButton.layer.borderColor = UIColor.systemBackground.cgColor
            
            joinFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 2.0)
            
            createFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 2.0)
            
            createButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 5.0), shadowRadius: 1.0)
            
            joinGroupButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 3.0), shadowRadius: 1.0)
            
            backButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 5.0), shadowRadius: 1.0)
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
        firebaseDBGroupsRef = firebaseDB?.collection("groups")
        firebaseDBUsersRef = firebaseDB?.collection("users")
    }
    
    @objc func hideKeyboard(){
        print("\(#fileID) \(#function)")
        self.view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        self.vibrate(style: .soft)
        
        let currentCharacterCount = textField.text?.count ?? 0
        if range.length + range.location > currentCharacterCount {
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        
        if textField == createGroupPinTF {
            return newLength <= 4
        }
        return newLength <= 16
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.vibrate(style: .soft)
        
        textField.resignFirstResponder()
        
        if textField == createGroupPinTF{
            createButtonPressed(self)
        }
        else {
            createGroupPinTF.becomeFirstResponder()
        }
        
        return true
    }
    
    
    @IBAction func createButtonPressed(_ sender: Any) {
        print("\(#fileID) \(#function)")
        
        self.vibrate(style: .soft)
        
        if let enteredName = createGroupNameTF?.text {
            
            print("\(#fileID) \(#function): entered name = \(enteredName)")
            
            let name = enteredName.trimmingCharacters(in: .whitespaces)
            print("\(#fileID) \(#function): name = \(name)")
            
            if name.count < 4 {
                print("\(#fileID) \(#function): not enough name chars")
                createGroupNameTF?.text = ""
                statusLabel.textColor = .systemRed
                statusLabel.text = "name must be atleast 4 chars"
                
                self.vibrate(style: .heavy)
                return
            }
            
            guard let enteredPin = createGroupPinTF.text else {
                print("\(#fileID) \(#function): empty pin")
                createGroupPinTF?.text = ""
                statusLabel.textColor = .systemRed
                statusLabel.text = "pin required"
                
                self.vibrate(style: .heavy)
                return
            }
            
            let pin = enteredPin.trimmingCharacters(in: .whitespaces)
            print("\(#fileID) \(#function): pin = \(pin)")
            
            if pin.count != 4 {
                print("\(#fileID) \(#function): not enough pin chars")
                createGroupPinTF?.text = ""
                statusLabel.textColor = .systemRed
                statusLabel.text = "pin must be 4 digits"
                
                self.vibrate(style: .heavy)
                return
            }
            
            
            
            checkIfGroupNameExists(name: name) {(groupNameExists) in
                
                //creating group
                if groupNameExists {
                    print("\(#fileID) \(#function): CREATING_GROUP: group name already exists")
                    self.createGroupNameTF?.text = ""
                    self.createGroupNameTF?.clearsOnBeginEditing = true
                    self.statusLabel.textColor = .systemRed
                    self.statusLabel.text = "group " + name + " already exists"
                    
                    self.vibrate(style: .heavy)
                }
                else {
                    print("\(#fileID) \(#function): CREATING_GROUP: group name available")
                    self.createGroupNameTF?.text = ""
                    self.createGroupPinTF?.text = ""
                    self.statusLabel.textColor = .systemGreen
                    self.statusLabel.text = "creating group " + name
                
                    print("\(#fileID) \(#function): name = \(name)")
                    
                    let newGroup = Group(groupName: name,
                                         pin: pin,
                                         songURL: "",
                                         songName: "",
                                         songStartTime: 0,
                                         isPlaying: false,
                                         masterSync: false,
                                         lastTimeSongPlaybackWasStarted: Timestamp.init().dateValue(),
                                         lastMessage: nil,
                                         creationDate: Timestamp.init().dateValue(),
                                         usersCurrentlyJoined: 0,
                                         usernamesCurrentlyJoined: [String](),
                                         createdByUsername: user?.username)
                    
                    //firebaseDBGroupsRef.doc
                    do {
                        try self.firebaseDBGroupsRef?.document(name).setData(from: newGroup, completion: { (error) in
                            if let _ = error {
                                print("\(#fileID) \(#function): Error writing group to Firestore: \(String(describing: error))")
                            }
                            else {
                                //attach a listener for updates
                                print("\(#fileID) \(#function): create group \(name) successful")
                                group = newGroup
                                
                                self.addGroupToUserFirestore(newGroup: newGroup)
                                
                                //present to the next vc
//                                let destViewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "playerChatTabBarView") as UIViewController
                                let destViewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "playerView") as UIViewController
                                destViewController.modalTransitionStyle = .coverVertical
                                self.present(destViewController, animated: true, completion: nil)
                            }
                        })
                    }
                    catch let error {
                        print("\(#fileID) \(#function): Error writing group to Firestore: \(error)")
                        self.statusLabel.textColor = .systemRed
                        self.statusLabel.text = "error creating " + name + " try again"
                    }
                    
                    
                }
                
            }
        }
        
    }
    
    
    @IBAction func joinGroupButtonPressed(_ sender: Any) {
        print("\(#fileID) \(#function)")
        
        backButtonPressed(self)
    }
    
    
    
    
    func checkIfGroupNameExists(name:String, completion: @escaping (Bool) -> Void){
        print("\(#fileID) \(#function)")
        
        firebaseDBGroupsRef?.document(name).getDocument(completion: { (snapshot, error) in
            if let nameExists = snapshot?.exists {
                print("\(#fileID) \(#function): name = \(name) : exists = \(nameExists)")
                completion(nameExists)
            }
            
        })
    }
    
    func addGroupToUserFirestore(newGroup: Group){
        print("\(#fileID) \(#function)")
        
        var updatedUser = user
        var groupExistsAlready = false
        
        for currGroup in user?.groupsJoined ?? []{
            if currGroup.groupName == newGroup.groupName {
                groupExistsAlready = true
            }
        }
        
        if !groupExistsAlready{
            updatedUser?.groupsJoined.append(newGroup)
        }
        
        do {
            try self.firebaseDBUsersRef?.document((user?.username)!).setData(from: updatedUser, completion: { (error) in
                if let _ = error {
                    print("\(#fileID) \(#function): Error writing user to Firestore: \(String(describing: error))")
                }
                else {
                    print("\(#fileID) \(#function): updated user \((user?.username)!) successful")
                    
                    user = updatedUser
                    
                }
            })
        }
        catch let error {
            print("\(#fileID) \(#function): Error writing user to Firestore: \(error)")
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        print("\(#fileID) \(#function)")
        
        self.vibrate(style: .soft)
        
        navigationController?.popToRootViewController(animated: true)
    }

}
