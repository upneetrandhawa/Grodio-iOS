//
//  LoginViewController.swift
//  Grodio
//
//  Created by Upneet  Randhawa on 2022-06-28.
//  Copyright © 2022 USR. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestoreSwift

class LoginViewController: UIViewController, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    
    
    @IBOutlet weak var appLabelTopFrontView: UIView!
    @IBOutlet weak var loginFrontView: UIView!
    @IBOutlet weak var speakerFrontView1: UIView!
    
    @IBOutlet weak var loginAsFrontView: UIView!
    @IBOutlet weak var createAccountFrontView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var loginAsLabel: UILabel!
    
    
    @IBOutlet weak var loginUsernameTF: UITextField!
    @IBOutlet weak var loginPasswordTF: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    @IBOutlet weak var loginIdsCollectionView: UICollectionView!
    
    @IBOutlet weak var loginAsFrontViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var screw1LoginFrontView: UIImageView!
    @IBOutlet weak var screw2LoginFrontView: UIImageView!
    @IBOutlet weak var screw3LoginFrontView: UIImageView!
    @IBOutlet weak var screw4LoginFrontView: UIImageView!
    
    
    var firebaseDB:Firestore?
    var firebaseDBUsersRef:CollectionReference?
    
    let displayNameCell = "displayNameCell"
    
    let localStorage = LocalStorage.sharedInstance
    let localAuthentication = DeviceLocalAuthentication.sharedInstance
    
    var statusBarStyle = UIStatusBarStyle.default { didSet { setNeedsStatusBarAppearanceUpdate() } }
    override var preferredStatusBarStyle: UIStatusBarStyle { statusBarStyle }
    
    override func viewDidLoad() {
        print("\(#fileID) \(#function)")
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        localStorage.isNewSession = false
        localStorage.updateDataToLocalStorage(updateType: .NEW_SESSION)
        
        //set statusbarstyle
        setStatusBarColor(traitCollection: traitCollection)
        
        //hide/show collection view based on data
        if localStorage.userLogins.count < 1 {
            loginAsFrontView.isHidden = true
            speakerFrontView1.layoutIfNeeded()
        }
        
        loginIdsCollectionView.delegate = self
        loginIdsCollectionView.dataSource = self
        loginIdsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        //set corner radius and borders for our views
        appLabelTopFrontView.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        loginFrontView.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        backgroundView.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        loginAsFrontView.addBorder(cornerRadius: 10, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        createAccountFrontView.addBorder(cornerRadius: 7.5, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        speakerFrontView1.addBorder(cornerRadius: 15.0, borderWidth: 5.0, borderColor: UIColor.systemGreen.cgColor)
        
        loginButton.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        createAccountButton.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        loginUsernameTF.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        loginPasswordTF.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        //add shadows
        appLabelTopFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 2.0)
        
        loginFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 2.0)
        
        loginAsFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 3.0), shadowRadius: 1.0)
        
        createAccountFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 4.0), shadowRadius: 1.0)
        
        
        loginButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 5.0), shadowRadius: 1.0)
        
        createAccountButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 3.0), shadowRadius: 1.0)
        
        
        //add dots to speakerFrontView
        speakerFrontView1.addCircleImageToAView(tintColor: UIColor.systemBackground)
        
        //add random rotation to our screws
        screw1LoginFrontView.rotateByRandomDegrees()
        screw2LoginFrontView.rotateByRandomDegrees()
        screw3LoginFrontView.rotateByRandomDegrees()
        screw4LoginFrontView.rotateByRandomDegrees()
        
        //set loginUsernameTF textField image
        loginUsernameTF.setLeftImage(image: UIImage(systemName: "person"))
        loginPasswordTF.setLeftImage(image: UIImage(systemName: "lock"))
        
        loginUsernameTF.delegate = self
        loginPasswordTF.delegate = self
        
       
        
        
        initFirebase()
        
        self.loginFrontView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(hideKeyboard)))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("\(#fileID) : \(#function): ")
        
        //setupAuthentication
        setupAuthentication()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // handle theme change here.
            print("\(#fileID) : \(#function): ")
            
            
            //set statusbarstyle
            setStatusBarColor(traitCollection: traitCollection)
            
            appLabelTopFrontView.layer.borderColor = UIColor.systemBackground.cgColor
            loginFrontView.layer.borderColor = UIColor.systemBackground.cgColor
            loginAsFrontView.layer.borderColor = UIColor.systemBackground.cgColor
            createAccountFrontView.layer.borderColor = UIColor.systemBackground.cgColor
            backgroundView.layer.borderColor = UIColor.systemBackground.cgColor
            
            //speakerFrontView1.layer.borderColor = UIColor.systemBackground.cgColor
            
            loginUsernameTF.layer.borderColor = UIColor.systemBackground.cgColor
            loginPasswordTF.layer.borderColor = UIColor.systemBackground.cgColor
            
            loginButton.layer.borderColor = UIColor.systemBackground.cgColor
            createAccountButton.layer.borderColor = UIColor.systemBackground.cgColor
            
            appLabelTopFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 1.0)
            
            loginFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 1.0)
            
            loginAsFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 1.0)
            
            createAccountFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 1.0)
            
            loginButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 5.0), shadowRadius: 1.0)
            
            createAccountButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 3.0), shadowRadius: 1.0)
            
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
        
        return localStorage.userLogins.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("\(#fileID) \(#function)")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: displayNameCell, for: indexPath) as! DisplayNameCollectionViewCell
        
        cell.nameLabel.text = localStorage.userLogins[indexPath.item].username
        cell.addBorder(cornerRadius: 10.0, borderWidth: 2.0, borderColor: UIColor.systemGreen.cgColor)
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
        
        if !localAuthentication.isAuthenticatedLocally {//only autofill login info if authenticated
            self.statusLabel.text = ""
            //ask for authentication
            localAuthentication.authenticate { (success) in
                print("\(#fileID) \(#function): success = ", success)
                
                DispatchQueue.main.async {
                    if !success {
                        self.statusLabel.textColor = .systemRed
                        self.statusLabel.text = "Authenticate to use Auto-fill Login"
                    }
                    else {
                        self.statusLabel.textColor = .systemGreen
                        self.statusLabel.text = "Logging in"
                        self.autofillLoginInfo(index: indexPath.item)
                    }
                }
            }
        }
        else {
            autofillLoginInfo(index: indexPath.item)
        }
    }
    
    func autofillLoginInfo(index: Int){
        loginUsernameTF.text = localStorage.userLogins[index].username
        loginPasswordTF.text = localStorage.userLogins[index].password
        
        localStorage.userSelected(arrayType: .USER_LOGIN, index: index)
        localStorage.updateDataToLocalStorage(updateType: .USER_LOGIN)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.loginButtonPressed(self)
        }
    }
    
    func setupAuthentication(){
        print("\(#fileID) \(#function)")
        self.statusLabel.text = ""
        
        localAuthentication.authenticate { (success) in
            print("\(#fileID) \(#function): success = ", success)
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
        
        loginIdsCollectionView.reloadData()
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
        
        self.vibrate(style: .soft)
        
        textField.resignFirstResponder()
        
        if textField == loginUsernameTF{
            loginPasswordTF.becomeFirstResponder()
        }
        else {
            loginButtonPressed(self)
        }
        
        return true
    }
    
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        print("\(#fileID) \(#function)")
        
        self.vibrate(style: .soft)
        
//        loginButton.transform = CGAffineTransform(translationX: 0.0, y: 5.0)
//
//            UIView.animate(withDuration: 0.5,
//                                       delay: 0,
//                                       animations: {
//                                        self.loginButton.transform = CGAffineTransform.identity
//
//                                        let animation = CABasicAnimation(keyPath: "shadowOpacity")
//                                        let shadowOpacity = self.loginButton.layer.shadowOpacity
//                                        animation.fromValue = 0.0
//                                         animation.toValue = shadowOpacity
//                                         animation.duration = 0.5
//                                        self.loginButton.layer.add(animation, forKey: animation.keyPath)
//                                        self.loginButton.layer.shadowOpacity = shadowOpacity
//                },
//                                       completion: { Void in()  }
//            )
        
        if let enteredUsername = loginUsernameTF?.text {
            
            print("\(#fileID) \(#function): entered username = \(enteredUsername)")
            
            let username = enteredUsername.trimmingCharacters(in: .whitespaces).lowercased()
            print("\(#fileID) \(#function): username = \(username)")
            
            if username.count < 4 {
                print("\(#fileID) \(#function): not enough name chars")
                loginUsernameTF?.text = ""
                statusLabel.textColor = .systemRed
                statusLabel.text = "username must be atleast 4 chars"
                
                self.vibrate(style: .heavy)
                return
            }
            
            guard let enteredPassword = loginPasswordTF.text else {
                print("\(#fileID) \(#function): empty password")
                loginPasswordTF?.text = ""
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
            
            checkIfUsernameExists(username: username) {(usernameExists, userFromServer) in
                
                //creating username
                if usernameExists {
                    print("\(#fileID) \(#function): LOGIN: username exists")
                    
                    guard let userPassword = userFromServer?.password else {
                        print("\(#fileID) \(#function): LOGIN: username exists")
                        self.statusLabel.textColor = .systemRed
                        self.statusLabel.text = "error fetching data, try again"
                        return
                    }
                    if password != userPassword {
                        print("\(#fileID) \(#function): LOGIN: incorrect password")
                        self.loginPasswordTF.text = ""
                        self.statusLabel.textColor = .systemRed
                        self.statusLabel.text = "incorrect password"
                        
                        self.vibrate(style: .heavy)
                        return
                    }
                    
                    self.addUserLoginToLocalStorage(username: username, password: password)
                    
                    self.statusLabel.textColor = .systemGreen
                    self.statusLabel.text = "creating account " + username
                    
                    user = userFromServer
                    
                    let destViewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "groupsProfileTabBarView") as UIViewController
                    
                    
                    destViewController.modalTransitionStyle = .coverVertical
                    self.present(destViewController, animated: true, completion: nil)
                    
                    
                }
                else {
                    print("\(#fileID) \(#function): LOGIN: username not exists")
                    
                    self.loginUsernameTF?.text = ""
                    self.loginUsernameTF?.clearsOnBeginEditing = true
                    self.loginPasswordTF.text = ""
                    self.statusLabel.textColor = .systemRed
                    self.statusLabel.text = "username " + username + " doesn't exist"
                    
                    self.vibrate(style: .heavy)
                }
                
            }
        }
    }
    
    
    @IBAction func createAccountPressed(_ sender: Any) {
        print("\(#fileID) \(#function)")
        
        self.vibrate(style: .soft)
        
        let destViewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createAccountView") as UIViewController
        
        destViewController.modalTransitionStyle = .flipHorizontal
        self.present(destViewController, animated: true, completion: nil)
    }
    
    func checkIfUsernameExists(username:String, completion: @escaping (Bool, User?) -> Void){
            print("\(#fileID) \(#function)")
            
            firebaseDBUsersRef?.document(username).getDocument(completion: { (snapshot, error) in
                print("\(#fileID) \(#function) error = ", error)
                let result = Result {
                      try snapshot?.data(as: User.self)
                }
                switch result {
                case .success(let userFromServer):
                    if let userFromServer = userFromServer {
                        print("\(#fileID) \(#function): User: \(userFromServer)")
                        completion(true,userFromServer)
                    } else {
                        print("Document does not exist")
                        completion(false,nil)
                    }
                case .failure(let error):
                    // A `City` value could not be initialized from the DocumentSnapshot.
                    print("\(#fileID) \(#function): Error decoding user: \(error)")
                    self.statusLabel.textColor = .systemRed
                    self.statusLabel.text = "error fetching data, try again"
                }
                
            })
        }
    
}
