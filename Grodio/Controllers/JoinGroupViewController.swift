//
//  JoinGroupViewController.swift
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

class JoinGroupViewController: UIViewController, UITextFieldDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var joinFrontView: UIView!
    @IBOutlet weak var speakerFrontView: UIView!
    @IBOutlet weak var joinGroupsFrontView: UIView!
    @IBOutlet weak var createGroupFrontView: UIView!
    
    
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var createGroupButton: UIButton!
    
    @IBOutlet weak var joinGroupNameTF: UITextField!
    @IBOutlet weak var joinGroupPinTF: UITextField!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var joinGroupsCollectionView: UICollectionView!
    
    @IBOutlet weak var screw1JoinFrontView: UIImageView!
    @IBOutlet weak var screw2JoinFrontView: UIImageView!
    @IBOutlet weak var screw3JoinFrontView: UIImageView!
    @IBOutlet weak var screw4JoinFrontView: UIImageView!
    
    
    var firebaseDB:Firestore?
    var firebaseDBGroupsRef:CollectionReference?
    var firebaseDBUsersRef:CollectionReference?
    
    let displayNameCell = "displayNameCell"
    
    let localStorage = LocalStorage.sharedInstance
    
    var statusBarStyle = UIStatusBarStyle.default { didSet { setNeedsStatusBarAppearanceUpdate() } }
    override var preferredStatusBarStyle: UIStatusBarStyle { statusBarStyle }

    override func viewDidLoad() {
        print("\(#fileID) \(#function)")
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //set statusbarstyle
        setStatusBarColor(traitCollection: traitCollection)
        
        //hide/show collection view based on data
        if user?.groupsJoined.count ?? 0 < 1 {
            joinGroupsFrontView.isHidden = true
            speakerFrontView.layoutIfNeeded()
        }
        
        joinGroupsCollectionView.delegate = self
        joinGroupsCollectionView.dataSource = self
        joinGroupsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        //set corner radius and borders for our views
        joinFrontView.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        backgroundView.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        joinGroupsFrontView.addBorder(cornerRadius: 10, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        createGroupFrontView.addBorder(cornerRadius: 7.5, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        speakerFrontView.addBorder(cornerRadius: 15.0, borderWidth: 5.0, borderColor: UIColor.systemGreen.cgColor)
        
        joinButton.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        createGroupButton.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        joinGroupNameTF.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        joinGroupPinTF.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        //add shadows
        joinFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 2.0)
        
        joinGroupsFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 2.0)
        
        createGroupFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 2.0)
        
        joinButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 5.0), shadowRadius: 1.0)
        
        createGroupButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 3.0), shadowRadius: 1.0)
        
        //add dots to speakerFrontView
        speakerFrontView.addCircleImageToAView(tintColor: UIColor.systemBackground)
        
        //add random rotation to our screws
        screw1JoinFrontView.rotateByRandomDegrees()
        screw2JoinFrontView.rotateByRandomDegrees()
        screw3JoinFrontView.rotateByRandomDegrees()
        screw4JoinFrontView.rotateByRandomDegrees()
        
        //set loginUsernameTF textField image
        joinGroupNameTF.setLeftImage(image: UIImage(systemName: "person.3"))
        joinGroupPinTF.setLeftImage(image: UIImage(systemName: "lock"))
        
        joinGroupNameTF.delegate = self
        joinGroupPinTF.delegate = self
        
        initFirebase()
        
        self.joinFrontView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(hideKeyboard)))
        self.speakerFrontView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(hideKeyboard)))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("\(#fileID) : \(#function): ")
        
        if user?.groupsJoined.count ?? 0 < 1 {
            joinGroupsFrontView.isHidden = true
            speakerFrontView.layoutIfNeeded()
        }
        else {
            joinGroupsFrontView.isHidden = false
            speakerFrontView.layoutIfNeeded()
        }
        
        joinGroupsCollectionView.reloadData()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // handle theme change here.
            print("\(#fileID) : \(#function): ")
            
            
            //set statusbarstyle
            setStatusBarColor(traitCollection: traitCollection)
            
            joinFrontView.layer.borderColor = UIColor.systemBackground.cgColor
            joinGroupsFrontView.layer.borderColor = UIColor.systemBackground.cgColor
            createGroupFrontView.layer.borderColor = UIColor.systemBackground.cgColor
            backgroundView.layer.borderColor = UIColor.systemBackground.cgColor
            
            joinGroupNameTF.layer.borderColor = UIColor.systemBackground.cgColor
            joinGroupPinTF.layer.borderColor = UIColor.systemBackground.cgColor
            
            joinButton.layer.borderColor = UIColor.systemBackground.cgColor
            createGroupButton.layer.borderColor = UIColor.systemBackground.cgColor
            
            joinFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 2.0)
            
            joinGroupsFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 2.0)
            
            createGroupFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 2.0)
            
            joinButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 5.0), shadowRadius: 1.0)
            
            createGroupButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 3.0), shadowRadius: 1.0)
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("\(#fileID) \(#function)")
        //return localStorage.getCurrentUsersGroupLogins().count
        return user?.groupsJoined.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("\(#fileID) \(#function)")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: displayNameCell, for: indexPath) as! DisplayNameCollectionViewCell
        
        cell.nameLabel.text = user?.groupsJoined[indexPath.item].groupName
        cell.addBorder(cornerRadius: 10.0, borderWidth: 2.0, borderColor: UIColor.systemGreen.cgColor)
        cell.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 5.0), shadowRadius: 0.5)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("\(#fileID) \(#function)")
        //let padding = 5
        //let textWidth = data[indexPath.item].size(withAttributes: [.font: UIFont(name: Fonts.menlo, size: 17) ?? UIFont.systemFont(ofSize: 17)]).width
        //
        //let textWidth = data[indexPath.item].size(withAttributes: [.font: UIFont.systemFont(ofSize: 17)]).width
        //return CGSize(width: textWidth + CGFloat(4*padding), height: collectionView.frame.height - CGFloat(padding))
        
        return CGSize(width: collectionView.frame.width * 0.4, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(#fileID) \(#function): item = ", indexPath.item)
        
        self.vibrate(style: .soft)
        
        joinGroupNameTF.text = user?.groupsJoined[indexPath.item].groupName
        joinGroupPinTF.text = user?.groupsJoined[indexPath.item].pin
        
        localStorage.userSelected(arrayType: .GROUP_LOGIN, index: indexPath.item)
        localStorage.updateDataToLocalStorage(updateType: .GROUP_LOGIN)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.joinButtonPressed(self)
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
        
        if textField == joinGroupPinTF {
            return newLength <= 4
        }
        return newLength <= 16
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.vibrate(style: .soft)
        
        textField.resignFirstResponder()
        
        if textField == joinGroupPinTF {
            joinButtonPressed(self)
        }
        else {
            joinGroupPinTF.becomeFirstResponder()
        }
        
        return true
    }
    
    @IBAction func joinButtonPressed(_ sender: Any) {
        print("\(#fileID) \(#function)")
        
        self.vibrate(style: .soft)
        
        if let enteredName = joinGroupNameTF?.text {
            
            print("\(#fileID) \(#function): entered name = \(enteredName)")
            
            let name = enteredName.trimmingCharacters(in: .whitespaces)
            print("\(#fileID) \(#function): name = \(name)")
            
            if name.count < 4 {
                print("\(#fileID) \(#function): not enough name chars")
                joinGroupNameTF?.text = ""
                statusLabel.textColor = .systemRed
                statusLabel.text = "name must be atleast 4 chars"
                
                self.vibrate(style: .heavy)
                return
            }
            
            guard let enteredPin = joinGroupPinTF.text else {
                print("\(#fileID) \(#function): empty pin")
                joinGroupPinTF?.text = ""
                statusLabel.textColor = .systemRed
                statusLabel.text = "pin required"
                
                self.vibrate(style: .heavy)
                return
            }
            
            let pin = enteredPin.trimmingCharacters(in: .whitespaces)
            print("\(#fileID) \(#function): pin = \(pin)")
            
            if pin.count != 4 {
                print("\(#fileID) \(#function): not enough pin chars")
                joinGroupPinTF?.text = ""
                statusLabel.textColor = .systemRed
                statusLabel.text = "pin must be 4 digits"
                
                self.vibrate(style: .heavy)
                return
            }
            
            checkIfGroupNameExists(name: name) {(groupNameExists, _group) in
                
                //joining group
                if groupNameExists {
                    print("\(#fileID) \(#function): JOINING_GROUP: group name exists")
                    
                    if pin != _group.pin {
                        print("\(#fileID) \(#function): JOINING_GROUP: incorrect pin")
                        self.joinGroupPinTF.text = ""
                        self.statusLabel.textColor = .systemRed
                        self.statusLabel.text = "incorrect pin"
                        
                        self.vibrate(style: .heavy)
                        return
                    }
                    
                    self.statusLabel.textColor = .systemGreen
                    self.statusLabel.text = "joining group " + name
                    
                    self.addGroupToUserFirestore(newGroup: _group)
                    
                    //let destViewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "playerChatTabBarView") as UIViewController
                    
                    let destViewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "playerView") as UIViewController
                   
                    destViewController.modalTransitionStyle = .coverVertical
                    group = _group
                    self.present(destViewController, animated: true, completion: nil)
                }
                else {
                    print("\(#fileID) \(#function): JOINING_GROUP: group name not exists")
                    self.joinGroupNameTF?.text = ""
                    self.joinGroupNameTF.clearsOnBeginEditing = true
                    self.joinGroupPinTF.text = ""
                    self.statusLabel.textColor = .systemRed
                    self.statusLabel.text = "group " + name + " doesn't exist"
                    
                    self.vibrate(style: .heavy)
                }
                
            }
        }
    }
    
    @IBAction func createGroupButtonPressed(_ sender: Any) {
        print("\(#fileID) \(#function)")
        
        self.vibrate(style: .soft)
        
        let destViewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createGroupView") as UIViewController
        
        //destViewController.modalTransitionStyle = .flipHorizontal
        //self.present(destViewController, animated: true, completion: nil)
        
       // self.navigationController?.pushViewController(destViewController, animated: true)
        
    }
    
    func checkIfGroupNameExists(name:String, completion: @escaping (Bool, Group) -> Void){
        print("\(#fileID) \(#function)")
        
        firebaseDBGroupsRef?.document(name).getDocument(completion: { (snapshot, error) in
            if let nameExists = snapshot?.exists {
                print("\(#fileID) \(#function): name = \(name) : exists = \(nameExists)")
                
                if let data = snapshot?.data() {
                    guard let pin = data["pin"] as? String else {
                        print("\(#fileID) \(#function): error retrieving pin")
                        self.statusLabel.textColor = .systemRed
                        self.statusLabel.text = "error retrieving data, try later"
                        return
                    }
                    do {
                        if let _group = try snapshot?.data(as: Group.self) {
                            print("\(#fileID) \(#function): group = \(_group)")
                            completion(nameExists,_group)
                        }
                    } catch let error as NSError {
                        print("\(#fileID) \(#function): error: \(error.localizedDescription)")
                    }
                    
                }
                else {
                    completion(nameExists,Group(groupName: nil,
                                                pin: nil,
                                                songURL: nil,
                                                songName: nil,
                                                songStartTime: nil,
                                                isPlaying: nil,
                                                masterSync: nil,
                                                lastTimeSongPlaybackWasStarted: nil,
                                                lastMessage: nil,
                                                creationDate: nil,
                                                usersCurrentlyJoined: nil,
                                                usernamesCurrentlyJoined: nil))
                }
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
}
