//
//  ProfileCard.swift
//  Tender
//
//  Created by Daniel Widjaja on 22/03/23.
//

import SwiftUI
import FirebaseStorage

struct ProfileCard: View {
    
    var name: String
    var age: Int
    var role: String
    var imageData: Data?
    var photoUrl: String
    var downloadUrl: URL?
    
    @Binding var myInterest: [String]
    
    var interestList: [String]
    
    @State var imageUrl = ""
    
    var body: some View {
        VStack (alignment: .leading){
            HStack {
                if imageUrl != "" {
                    AsyncImage(url: URL(string: imageUrl)!) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } placeholder: {
                        Image(systemName: "photo.fill")
                    }
                    .frame(width: 100, height: 100)
                } else {
                    VStack {
                        Image(systemName: "person.crop.circle.badge.exclamationmark.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        
                        Text("I'm sorry but my Firebase limit has run out 😩, Check again tomorrow")
                            .font(.caption)
                    }
                    .frame(width: 130, height: 150)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.black, lineWidth: 1)
                    )
                }
                
                VStack (alignment: .leading){
                    Text("\(name), \(age)")
                        .font(.title3)
                    Text("\(role)")
                        .font(.caption)
                }
            }
            .onAppear {
                let storageRef = Storage.storage().reference()
                let imageRef = storageRef.child(photoUrl)
                imageRef.downloadURL { url, error in
                    if error == nil {
                        imageUrl = url?.absoluteString ?? ""
                    } else {
                        // error
                    }
                }
            }
            
            Divider()
            TagView(myInterest: $myInterest, tags: interestList)
        }
        .padding(8)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}

//struct ProfileCard_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileCard(name: .constant("Daniel"), age: .constant(12), role: .constant("Programmer"), myInterest: .constant(["Cat", "Dog"]), interestList: .constant(["Cat", "Dog", "Gym"]))
//    }
//}
