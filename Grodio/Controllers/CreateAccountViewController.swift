//
//  CreateAccountViewController.swift
//  Grodio
//
//  Created by Upneet  Randhawa on 2022-06-28.
//  Copyright © 2022 USR. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestoreSwift

var user:User?

class CreateAccountViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var appLabelTopFrontView: UIView!
    @IBOutlet weak var createFrontView: UIView!
    @IBOutlet weak var speakerFrontView: UIView!
    @IBOutlet weak var loginFrontView: UIView!
    
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var createAccountUsernameTF: UITextField!
    @IBOutlet weak var createAccountPasswordTF: UITextField!
    @IBOutlet weak var createAccountConfirmPasswordTF: UITextField!
    
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var LoginButton: UIButton!
    
    @IBOutlet weak var screw1CreateFrontView: UIImageView!
    @IBOutlet weak var screw2CreateFrontView: UIImageView!
    @IBOutlet weak var screw3CreateFrontView: UIImageView!
    @IBOutlet weak var screw4CreateFrontView: UIImageView!
    
    var statusBarStyle = UIStatusBarStyle.default { didSet { setNeedsStatusBarAppearanceUpdate() } }
    override var preferredStatusBarStyle: UIStatusBarStyle { statusBarStyle }
    
    
    var firebaseDB:Firestore?
    var firebaseDBUsersRef:CollectionReference?
    
    let localStorage = LocalStorage.sharedInstance
    
    override func viewDidLoad() {
        print("\(#fileID) \(#function)")
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //set corner radius and borders for our views
        appLabelTopFrontView.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        createFrontView.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        backgroundView.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        loginFrontView.addBorder(cornerRadius: 7.5, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        speakerFrontView.addBorder(cornerRadius: 15.0, borderWidth: 5.0, borderColor: UIColor.systemGreen.cgColor)
        
        createButton.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        LoginButton.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        createAccountUsernameTF.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        createAccountPasswordTF.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        createAccountConfirmPasswordTF.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        //add shadows
        appLabelTopFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 2.0)
        
        loginFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 2.0)
        
        createFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 2.0)
        
        createButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 5.0), shadowRadius: 1.0)
        
        LoginButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 3.0), shadowRadius: 1.0)
        
        //add dots to speakerFrontView
        speakerFrontView.addCircleImageToAView(tintColor: UIColor.systemBackground)
        
        //add random rotation to our screws
        screw1CreateFrontView.rotateByRandomDegrees()
        screw2CreateFrontView.rotateByRandomDegrees()
        screw3CreateFrontView.rotateByRandomDegrees()
        screw4CreateFrontView.rotateByRandomDegrees()
        
        //set textfields textField image
        createAccountUsernameTF.setLeftImage(image: UIImage(systemName: "person"))
        createAccountPasswordTF.setLeftImage(image: UIImage(systemName: "lock"))
        createAccountConfirmPasswordTF.setLeftImage(image: UIImage(systemName: "lock"))
        
        createAccountUsernameTF.delegate = self
        createAccountPasswordTF.delegate = self
        createAccountConfirmPasswordTF.delegate = self
        
        initFirebase()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(hideKeyboard)))
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // handle theme change here.
            print("\(#fileID) : \(#function): ")
            
            //set statusbarstyle
            setStatusBarColor(traitCollection: traitCollection)
            
            //set statusbarstyle
            setStatusBarColor(traitCollection: traitCollection)
            
            appLabelTopFrontView.layer.borderColor = UIColor.systemBackground.cgColor
            loginFrontView.layer.borderColor = UIColor.systemBackground.cgColor
            createFrontView.layer.borderColor = UIColor.systemBackground.cgColor
            backgroundView.layer.borderColor = UIColor.systemBackground.cgColor
            
            createAccountUsernameTF.layer.borderColor = UIColor.systemBackground.cgColor
            createAccountPasswordTF.layer.borderColor = UIColor.systemBackground.cgColor
            createAccountConfirmPasswordTF.layer.borderColor = UIColor.systemBackground.cgColor
            
            createButton.layer.borderColor = UIColor.systemBackground.cgColor
            LoginButton.layer.borderColor = UIColor.systemBackground.cgColor
            
            appLabelTopFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 2.0)
            
            loginFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 2.0)
            
            createFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 2.0)
            
            createButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 5.0), shadowRadius: 1.0)
            
            LoginButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 3.0), shadowRadius: 1.0)
            
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
        firebaseDBUsersRef = firebaseDB?.collection("users")
    }
    
    func addUserLoginToLocalStorage(username: String, password: String){
        localStorage.addUserLogin(_username: username, _password: password)
        localStorage.updateDataToLocalStorage(updateType: .USER_LOGIN)
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
        
        return newLength <= 16
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        self.vibrate(style: .soft)
        
        if textField == createAccountUsernameTF{
            createAccountPasswordTF.becomeFirstResponder()
        }
        else if textField == createAccountPasswordTF{
            createAccountConfirmPasswordTF.becomeFirstResponder()
        }
        else {
            createButtonPressed(self)
        }
        
        return true
    }
    
    
    @IBAction func createButtonPressed(_ sender: Any) {
        print("\(#fileID) \(#function)")
        
        self.vibrate(style: .soft)
        
        if let enteredUsername = createAccountUsernameTF?.text {
            
            print("\(#fileID) \(#function): entered username = \(enteredUsername)")
            
            let username = enteredUsername.trimmingCharacters(in: .whitespaces).lowercased()
            print("\(#fileID) \(#function): username = \(username)")
            
            if username.count < 4 {
                print("\(#fileID) \(#function): not enough name chars")
                createAccountUsernameTF?.text = ""
                statusLabel.textColor = .systemRed
                statusLabel.text = "username must be atleast 4 chars"
                
                self.vibrate(style: .heavy)
                return
            }
            
            guard let enteredPassword = createAccountPasswordTF.text else {
                print("\(#fileID) \(#function): empty password")
                createAccountPasswordTF?.text = ""
                statusLabel.textColor = .systemRed
                statusLabel.text = "password required"
                
                self.vibrate(style: .heavy)
                return
            }
            
            let password = enteredPassword.trimmingCharacters(in: .whitespaces)
            print("\(#fileID) \(#function): password = \(password)")
            
            if password.count < 4 {
                print("\(#fileID) \(#function): not enough pin chars")
                statusLabel.textColor = .systemRed
                statusLabel.text = "password must be 4 digits"
                
                self.vibrate(style: .heavy)
                return
            }
            
            guard let enteredConfirmPassword = createAccountConfirmPasswordTF.text else {
                print("\(#fileID) \(#function): empty confirm password")
                statusLabel.textColor = .systemRed
                statusLabel.text = "confirm password required"
                
                self.vibrate(style: .heavy)
                return
            }
            
            let confimPassword = enteredConfirmPassword.trimmingCharacters(in: .whitespaces)
            print("\(#fileID) \(#function): confimPassword = \(confimPassword)")
            
            if confimPassword.count < 1 {
                print("\(#fileID) \(#function): empty confirm password")
                statusLabel.textColor = .systemRed
                statusLabel.text = "confirm password required"
                
                self.vibrate(style: .heavy)
                return
            }
            
            if password != confimPassword {
                print("\(#fileID) \(#function): passwords dont match")
                statusLabel.textColor = .systemRed
                statusLabel.text = "passwords dont match"
                
                self.vibrate(style: .heavy)
                return
            }
            
            
            
            
            
            checkIfUsernameExists(username: username) {(usernameExists) in
                
                //creating group
                if usernameExists {
                    print("\(#fileID) \(#function): CREATING_ACCOUNT: username already exists")
                    self.createAccountUsernameTF?.text = ""
                    self.createAccountUsernameTF?.clearsOnBeginEditing = true
                    self.statusLabel.textColor = .systemRed
                    self.statusLabel.text = "username " + username + " already exists"
                    
                    self.vibrate(style: .heavy)
                }
                else {
                    print("\(#fileID) \(#function): CREATING_ACCOUNT: username available")
                    
                    
                    
                    self.createAccountUsernameTF?.text = ""
                    self.createAccountPasswordTF?.text = ""
                    self.createAccountConfirmPasswordTF?.text = ""
                    self.statusLabel.textColor = .systemGreen
                    self.statusLabel.text = "creating account " + username
                    
                    let newUser = User(username: username, password: password, creationDate: Timestamp.init().dateValue(), groupsJoined: [])
                    
                    do {
                        try self.firebaseDBUsersRef?.document(username).setData(from: newUser, completion: { (error) in
                            if let _ = error {
                                print("\(#fileID) \(#function): Error writing user to Firestore: \(String(describing: error))")
                            }
                            else {
                                print("\(#fileID) \(#function): create user \(username) successful")
                                
                                self.addUserLoginToLocalStorage(username: username, password: password)
                                
                                user = newUser
                                
                                let destViewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "groupsProfileTabBarView") as UIViewController
                                
                                destViewController.modalTransitionStyle = .coverVertical
                                self.present(destViewController, animated: true, completion: nil)
                                
                            }
                        })
                    }
                    catch let error {
                        print("\(#fileID) \(#function): Error writing user to Firestore: \(error)")
                    }
                }
                
            }
        }
        
        
    }
    
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        print("\(#fileID) \(#function)")
        
        self.vibrate(style: .soft)
        
        let destViewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginView") as UIViewController
        
        destViewController.modalTransitionStyle = .flipHorizontal
        self.present(destViewController, animated: true, completion: nil)
    }
    
    
    func checkIfUsernameExists(username:String, completion: @escaping (Bool) -> Void){
        print("\(#fileID) \(#function)")
        
        firebaseDBUsersRef?.document(username).getDocument(completion: { (snapshot, error) in
            if let usernameExists = snapshot?.exists {
                print("\(#fileID) \(#function): username = \(username) : exists = \(usernameExists)")
                completion(usernameExists)
            }
            
        })
    }
    
}
