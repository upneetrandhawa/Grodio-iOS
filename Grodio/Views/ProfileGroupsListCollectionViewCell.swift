//
//  ProfileGroupsListCollectionViewCell.swift
//  Grodio
//
//  Created by Upneet  Randhawa on 2022-09-02.
//  Copyright © 2022 USR. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class ProfileGroupsListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var playingStatusLabel: UILabel!
    @IBOutlet weak var noOfListenersLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    
    var groupName: String?
    var firestoreGroup: Group?
    
    var firebaseDB:Firestore?
    var firebaseDBGroupsRef:CollectionReference?
    var firestoreGroupDocumentListener:ListenerRegistration?
    
    var songNameLabelMarqueeTimer:Timer? = Timer()//Timer used for marquee , right to left effect for the label
    
    func setup(_groupName: String){
        print("\(#fileID) \(#function): _groupName = ", _groupName)
        
        groupName = _groupName
        
        //configureData (_group: nil)
        
        initFirebase()
        
        fetchGroupFromFirestore()
        
        attachListenerToFirestoreDocument()
        
        self.containerView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.9, shadowOffset: CGSize(width: 0.0, height: 5.0), shadowRadius: 1.0)
        
        self.containerView.layer.cornerRadius = 15.0
    }
    
    func configureData(_group: Group?){
        print("\(#fileID) \(#function): _groupName = ", groupName)
        
        guard let group = _group else {
            print("\(#fileID) \(#function): invalid group returning")
                        
            return
        }
        
        firestoreGroup = group
        
        //set animations to noOfListenersLabel and playingStatusLabel when value is updated
        let animation: CATransition = CATransition()
        animation.duration = 0.8
        animation.type = CATransitionType.fade
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        songNameLabel.layer.add(animation, forKey: "changeTextTransition")
        noOfListenersLabel.layer.add(animation, forKey: "changeTextTransition")
        playingStatusLabel.layer.add(animation, forKey: "changeTextTransition")
        
        self.groupNameLabel.text = group.groupName?.capitalized
        self.songNameLabel.text = group.songName
        self.noOfListenersLabel.text = String(group.usersCurrentlyJoined ?? 0)
        if let isPlaying = group.isPlaying {
            self.playingStatusLabel.text = isPlaying ? "Broadcasting" : "Paused"
        }
        
        self.layoutIfNeeded()
        
        startSongNameLabelMarqueeEffect()
        
    }
    
    func initFirebase(){
        print("\(#fileID) \(#function): _groupName = ", groupName)
        
        firebaseDB = Firestore.firestore()
        firebaseDBGroupsRef = firebaseDB?.collection("groups")
    }
    
    func fetchGroupFromFirestore(){
        print("\(#fileID) \(#function): _groupName = ", groupName)
        
        firebaseDBGroupsRef?.document(groupName!).getDocument(completion: { (snapshot, error) in
            
            if let _ = snapshot?.data() {
                do {
                    if let _group = try snapshot?.data(as: Group.self) {
                        //print("\(#fileID) \(#function): group = \(_group)")
                        self.configureData(_group: _group)
                    }
                } catch let error as NSError {
                    print("\(#fileID) \(#function): error: \(error.localizedDescription)")
                }
                
            }
            else {
                print("\(#fileID) \(#function): invalid group returning")
                return
            }
            
            
        })
    }
    
    func attachListenerToFirestoreDocument(){
        print("\(#fileID) \(#function): _groupName = ", groupName)
        
        firestoreGroupDocumentListener =  firebaseDBGroupsRef?.document(self.groupName!).addSnapshotListener(includeMetadataChanges: true
            , listener: { (documentSnapshot, error) in
                
                if let snapshot = documentSnapshot {
                    do {
                        if let updatedGroup = try snapshot.data(as: Group.self) {
                            //print("\(#fileID) \(#function): CUSTOM updatedGroup = \(updatedGroup)")
                            
                            self.configureData(_group: updatedGroup)
                        }
                    } catch let error as NSError {
                        print("\(#fileID) \(#function): error: \(error.localizedDescription)")
                    }
                }
                else {
                    print("\(#fileID) \(#function): snapshot doesnt exist")
                }
            })
        
    }
    
    @objc func marqueeEffectForSongNameLabel(){
        
        if let _ = firestoreGroup, firestoreGroup?.songName == nil || firestoreGroup?.songName == "" {
            return
        }
        //if label text char count is 1 then reset it to the original songName
        if let labelText = songNameLabel.text, labelText.count < 2{
            songNameLabel.text = firestoreGroup?.songName
            if songNameLabelMarqueeTimer != nil {
                songNameLabelMarqueeTimer?.invalidate()
                songNameLabelMarqueeTimer = nil
            }
            Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.startSongNameLabelMarqueeEffect), userInfo: nil, repeats: false)
            return
        }
        //else remove the first character of the current text in the label and then display the updated string
        let str = songNameLabel.text!
        let indexSecond = str.index(str.startIndex, offsetBy: 1)
        songNameLabel.text = String(str.suffix(from: indexSecond))
      }
    
    @objc func startSongNameLabelMarqueeEffect(){
        if songNameLabelMarqueeTimer != nil {
            songNameLabelMarqueeTimer?.invalidate()
            songNameLabelMarqueeTimer = nil
        }
            self.songNameLabelMarqueeTimer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(self.marqueeEffectForSongNameLabel), userInfo: nil, repeats: true)
    }
    
    public func getFirestoreGroupObject() -> Group?{
        print("\(#fileID) \(#function): _groupName = ", groupName)
        
        return firestoreGroup
    }
    
//    override func layoutSubviews() {
//        print("\(#fileID) \(#function)")
//        super.layoutSubviews()
//        self.layoutIfNeeded()
//
//
//
//
//    }
    
    override func prepareForReuse() {
        print("\(#fileID) \(#function): _groupName = ", groupName)
        
        configureData(_group: nil)
        firestoreGroupDocumentListener?.remove()
        if songNameLabelMarqueeTimer != nil {
            songNameLabelMarqueeTimer?.invalidate()
            songNameLabelMarqueeTimer = nil
        }
    }
    
    deinit {
        print("\(#fileID) \(#function): _groupName = ", groupName)
        firestoreGroupDocumentListener?.remove()
        if songNameLabelMarqueeTimer != nil {
            songNameLabelMarqueeTimer?.invalidate()
            songNameLabelMarqueeTimer = nil
        }
    }
    
    
    
}
