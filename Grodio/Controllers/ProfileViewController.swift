//
//  ProfileViewController.swift
//  Grodio
//
//  Created by Upneet  Randhawa on 2022-07-01.
//  Copyright © 2022 USR. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class ProfileViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var profileFrontView: UIView!
    @IBOutlet weak var GroupsFrontView: UIView!
    
    @IBOutlet weak var screw1View: UIImageView!
    @IBOutlet weak var screw2View: UIImageView!
    @IBOutlet weak var screw3View: UIImageView!
    @IBOutlet weak var screw4View: UIImageView!
    @IBOutlet weak var screw5View: UIImageView!
    @IBOutlet weak var screw6View: UIImageView!
    @IBOutlet weak var screw7View: UIImageView!
    @IBOutlet weak var screw8View: UIImageView!
    
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let profileGroupsListCellIdentifier = "profileGroupListCell"
    
    let localStorage = LocalStorage.sharedInstance
    
    var firebaseDB:Firestore?
    var firebaseDBUsersRef:CollectionReference?
    
    var statusBarStyle = UIStatusBarStyle.default { didSet { setNeedsStatusBarAppearanceUpdate() } }
    override var preferredStatusBarStyle: UIStatusBarStyle { statusBarStyle }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(#fileID) \(#function)")

        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        
        //set statusbarstyle
        setStatusBarColor(traitCollection: traitCollection)
        
        //set corner radius and borders for our views
        backgroundView.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        profileFrontView.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        GroupsFrontView.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        moreButton.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
        
        //add shadows
        profileFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 2.0)
        
        GroupsFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 2.0)
        
        moreButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 5.0), shadowRadius: 1.0)
        
        //add random rotation to our screws
        screw1View.rotateByRandomDegrees()
        screw2View.rotateByRandomDegrees()
        screw3View.rotateByRandomDegrees()
        screw4View.rotateByRandomDegrees()
        screw5View.rotateByRandomDegrees()
        screw6View.rotateByRandomDegrees()
        screw7View.rotateByRandomDegrees()
        screw8View.rotateByRandomDegrees()
        
        addMenuToButton(button: moreButton)
        
        self.usernameLabel.text = user?.username?.capitalized
        
        initFirebase()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\(#fileID) : \(#function): ")
        
        
        collectionView.reloadData()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // handle theme change here.
            print("\(#fileID) : \(#function): ")
            
            //reload collection view for shadow update
            collectionView.reloadData()
            
            //set statusbarstyle
            setStatusBarColor(traitCollection: traitCollection)
            
            //set corner radius and borders for our views
            backgroundView.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
            
            profileFrontView.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
            
            GroupsFrontView.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
            
            moreButton.addBorder(cornerRadius: 15.0, borderWidth: 2.0, borderColor: UIColor.systemBackground.cgColor)
            
            //add shadows
            profileFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 2.0)
            
            GroupsFrontView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 2.0), shadowRadius: 2.0)
            
            moreButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 5.0), shadowRadius: 1.0)
            
        }
        
    }
    
    
    @IBAction func moreButtonPressed(_ sender: Any) {
        print("\(#fileID) \(#function)")
        
        self.vibrate(style: .soft)

        let message = NSLocalizedString("Menu", comment: "Choose")
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alert.view.tintColor = .systemGreen
        
        alert.addAction(UIAlertAction(title: "Sign out", style: .default) { [unowned self] _ in
            
            let destViewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginView") as UIViewController

            destViewController.modalTransitionStyle = .coverVertical
            self.present(destViewController, animated: true, completion: nil)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return user?.groupsJoined.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileGroupsListCellIdentifier, for: indexPath) as! ProfileGroupsListCollectionViewCell
        
        cell.setup(_groupName: user?.groupsJoined[indexPath.item].groupName ?? "")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 130.00)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(#fileID) : \(#function): item = ", indexPath.item)
        //MARK: launch get Group object for each name and add to a dict DS
        
        return
//
//        self.vibrate(style: .soft)
//
//        let destViewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "playerChatTabBarView") as UIViewController
//
//        destViewController.modalTransitionStyle = .coverVertical
//        self.present(destViewController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let context = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (action) -> UIMenu? in
                    
                    let joinGroupAction = UIAction(title: "Join Group",
                                        image: UIImage(systemName: "person.3"),
                                        identifier: nil,
                                        discoverabilityTitle: nil,
                                        state: .off)
                    { (_) in
                        print("\(#fileID) \(#function): joinGroupAction on ceollection view cell, groupname = ", user?.groupsJoined[indexPath.item].groupName)
                        
                        let destViewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "playerChatTabBarView") as UIViewController
                       
                        destViewController.modalTransitionStyle = .coverVertical
                        let cell = collectionView.cellForItem(at: indexPath) as! ProfileGroupsListCollectionViewCell
                        group = cell.getFirestoreGroupObject()
                        self.present(destViewController, animated: true, completion: nil)
                        
                        
                    }
                    let removeGroupAction = UIAction(title: "Remove Group",
                                                     image: UIImage(systemName: "trash"),
                                                     identifier: nil,
                                                     discoverabilityTitle: nil,
                                                     attributes: .destructive,
                                                     state: .off)
                    { (_) in
                        print("\(#fileID) \(#function): removeGroupAction on ceollection view cell, groupname = ", user?.groupsJoined[indexPath.item].groupName)
                        
                        self.removeGroupFromUserFirestore(groupToRemove: (user?.groupsJoined[indexPath.item])!)
                    }
                    
                    return UIMenu(title: "Options", image: nil, identifier: nil, options: UIMenu.Options.displayInline, children: [joinGroupAction,removeGroupAction])
                    
                }
                return context
    }
    
//    @available(iOS 14.0, *)
//    func addSwipeActionsToCollectionView(){
//        print("\(#fileID) \(#function)")
//
//        var configuration = UICollectionLayoutListConfiguration(appearance: .sidebarPlain)
//        configuration.backgroundColor = .systemGreen
//
//        configuration.leadingSwipeActionsConfigurationProvider = { [unowned self] indexPath in
//
//            let joinGroupAction = UIContextualAction(style: .normal, title: "Join Group") { action, sourceView, actionPerformed in
//                // custom favorite action here
//
//                print("\(#fileID) \(#function): join action on ceollection view cell, groupname = ", localStorage.getCurrentUsersGroupLogins()[indexPath.item].groupname)
//                action.backgroundColor = .systemGray
//                actionPerformed(true)
//            }
//            return .init(actions: [joinGroupAction])
//        }
//
//        configuration.trailingSwipeActionsConfigurationProvider = { [unowned self] indexPath in
//
//            let removeGroupAction = UIContextualAction(style: .destructive, title: "Remove Group") { action, sourceView, actionPerformed in
//                // custom favorite action here
//
//                print("\(#fileID) \(#function): remove action on ceollection view cell, groupname = ", localStorage.getCurrentUsersGroupLogins()[indexPath.item].groupname)
//                action.backgroundColor = .systemRed
//                actionPerformed(true)
//            }
//            return .init(actions: [removeGroupAction])
//        }
//
//        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
//        collectionView.setCollectionViewLayout(layout, animated: true)
//
//    }
    
    func initFirebase(){
        print("\(#fileID) \(#function)")
        
        firebaseDB = Firestore.firestore()
        firebaseDBUsersRef = firebaseDB?.collection("users")
    }
    
    func addLongPressGestureToCollectionView(){
        print("\(#fileID) \(#function)")
        
        //MARK: TODO
    }
    
    func setStatusBarColor(traitCollection: UITraitCollection){
        print("\(#fileID) \(#function)")
        
        switch traitCollection.userInterfaceStyle {
            case .unspecified: statusBarStyle = .default
            case .light: statusBarStyle = .lightContent
            case .dark: statusBarStyle = .darkContent
        }
    }
    
    func addMenuToButton(button: UIButton){
        print("\(#fileID) : \(#function): ")
        
        let signOutAction = UIAction(title: "Sign Out",
                                       image: UIImage(systemName: "person.crop.circle.badge.xmark")?.withTintColor(.systemGreen,
                                       renderingMode: .alwaysOriginal),
                                       attributes: [],
                                       state: .off,
                                       handler: { (action) -> Void in
                                        print("\(#fileID) : \(#function): signOutAction pressed")
                                        self.vibrate(style: .soft)
                                        
                                        let destViewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginView") as UIViewController
                                        
                                        destViewController.modalTransitionStyle = .coverVertical
                                        self.present(destViewController, animated: true, completion: nil)
            
        })
        
        let elements: [UIAction] = [signOutAction]
        
        let menu:UIMenu = UIMenu(title: "Menu", children: elements)
        
        if #available(iOS 14.0, *) {
            button.showsMenuAsPrimaryAction = true
            button.menu = menu
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    func removeGroupFromUserFirestore(groupToRemove: Group){
        print("\(#fileID) \(#function)")
        
        var updatedUser = user
        let updatesGroups = user?.groupsJoined.filter{$0.groupName != groupToRemove.groupName}
        updatedUser?.groupsJoined = updatesGroups ?? []
        
        do {
            try self.firebaseDBUsersRef?.document((user?.username)!).setData(from: updatedUser, completion: { (error) in
                if let _ = error {
                    print("\(#fileID) \(#function): Error writing user to Firestore: \(String(describing: error))")
                }
                else {
                    print("\(#fileID) \(#function): updated user \((user?.username)!) successful")
                    
                    user = updatedUser
                    
                    self.collectionView.reloadData()
                }
            })
        }
        catch let error {
            print("\(#fileID) \(#function): Error writing user to Firestore: \(error)")
        }
    }

}
