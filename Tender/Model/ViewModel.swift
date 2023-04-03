//
//  ViewModel.swift
//  Tender
//
//  Created by Daniel Widjaja on 21/03/23.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage

class ViewModel: ObservableObject {
    @Published var imageUploaded: Bool = false
    
    init() {
        self.getProfilesData()
        self.updateProfileStatus()
    }
    
    
    @Published var sport = [
        "⚽️ Soccer",
        "🏀 Basketball",
        "🏋🏻 Gym",
        "🏸 Badminton",
        "🏐 Volley",
        "🥋 Martial Arts",
        "⛳️ Golf",
        "🏊🏻‍♂️ Swimming"
    ]
    
    @Published var movie = [
        "💕 Romance",
        "🤡 Comedy",
        "👻 Horror",
        "🎭 Drama",
        "☘️ Slice of life",
        "🔫 Crime",
        "🎬 Documentary",
        "🪦 History "
    ]
    
    @Published var music = [
        "🎶 Pop",
        "🎶 RnB",
        "🎶 Hip Hop",
        "🎶 Jazz",
        "🎶 Rock",
        "🎶 Classical",
        "🎶 Kpop",
        "🎶 EDM",
        "🎶 Indie"
    ]
    
    @Published var pets = [
        "🐱 Cat",
        "🐶 Dog",
        "🐹 Hamster",
        "🦜 Birds",
        "🦎 Reptile",
        "🐠 Fish",
        "🐰 Rabbit",
    ]
    
    @Published var creativity = [
        "🎨 Painting",
        "🧵 Crafting",
        "📹 Video Editing",
        "💃🏻 Dancing",
        "🎙️ Singing",
        "📝 Writing",
        "📸 Photography",
        "💄 Makeup"
    ]
    
    @Published var goingOut = [
        "☕ Cafe-hopping️",
        "🌠 Sky Gazing",
        "🖼️ Museum & Galleries",
        "🎬 Cinema",
        "🎊 Festivals",
        "🎫 Concert",
        "🎤 Karaoke"
    ]
    
    @Published var profileList: [ProfileModel] = []
    
    func addProfile(profile: ProfileModel) {
        let db = Firestore.firestore()
        let docRef = db.collection("profiles").addDocument(
            data: ["name":profile.name,
                   "age":profile.age,
                   "role":profile.role,
                   "photoUrl":profile.photoUrl,
                   "interests":profile.interests])
        { error in
            if error == nil {
                self.getProfilesData()
                self.updateProfileStatus()
            } else {
                
            }
        }
        self.attachDocIdToProfile(docRef: docRef.documentID)
    }
    
    func editProfile(profile: ProfileModel) {
        let db = Firestore.firestore()
        let docRef = db.collection("profiles").document(profile.id ?? "")
        docRef.updateData([
            "name": profile.name,
            "age": profile.age,
            "role": profile.role,
            "photoUrl": profile.photoUrl,
            "interests": profile.interests
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                self.getProfilesData()
            }
        }
    }
    
    func getProfilesData() {
        
        let db = Firestore.firestore()
        
        db.collection("profiles").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    DispatchQueue.main.async {
                        self.profileList = snapshot.documents.map { d in
                            
                            return ProfileModel(id: d.documentID,
                                                name: d["name"] as? String ?? "",
                                                age: d["age"] as? Int ?? 0,
                                                role: d["role"] as? String ?? "",
                                                photoUrl: d["photoUrl"] as? String ?? "",
                                                interests: d["interests"] as? [String] ?? [])
                        }
                    }
                }
            } else {
                // handle error
            }
            
        }
    }
    
    @Published var profileImageDownloaded: UIImage?
    
    func retrieveProfilePhoto(photoUrl: String) {
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child(photoUrl)
        imageRef.getData(maxSize: (5 * 1024 * 1024)) { (data, error) in
            if let err = error {
                print(err)
            } else {
                if let image = data {
                    self.profileImageDownloaded = UIImage(data: image)
                }
            }
        }
    }
    
    
    @Published var profileExist: Bool = false
    
    func updateProfileStatus() {
        let myProfile : ProfileModel? = UserDefaults.standard.retrieveCodable(for: "myProfile")
        if myProfile != nil {
            self.profileExist = true
            self.imageUploaded = true
        } else {
            self.profileExist = false
            self.imageUploaded = false
        }
    }
    
    func attachDocIdToProfile(docRef: String) {
        var myProfile : ProfileModel? = UserDefaults.standard.retrieveCodable(for: "myProfile")
        if myProfile != nil {
            myProfile?.id = docRef
            UserDefaults.standard.storeCodable(myProfile, key: "myProfile")
        }
    }
}
