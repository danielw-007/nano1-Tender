//
//  HomeView.swift
//  Tender
//
//  Created by Daniel Widjaja on 22/03/23.
//

import SwiftUI
import FirebaseStorage

struct HomeView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    let myProfile : ProfileModel? = UserDefaults.standard.retrieveCodable(for: "myProfile")
    @State var myInterest: [String] = []
    @State var imageDownloadUrl = ""
    @State var searchText = ""
    
    init() {
        _myInterest = State(initialValue: myProfile?.interests ?? [])
    }
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                
                HStack (alignment: .center) {
                    // TODO: id nya kosong
                    Text("Hi, \(myProfile?.name ?? "") 🙌")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    
                    NavigationLink(destination: ProfileView()) {
                        if imageDownloadUrl != "" {
                            AsyncImage(url: URL(string: imageDownloadUrl)!) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(Circle())
                            } placeholder: {
                                Image(systemName: "photo.fill")
                            }
                            .frame(width: 50, height: 50)
                        } else {
                            Image(systemName: "person.crop.circle.badge.exclamationmark.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                        }
                    }
                    
                }
                .offset(y: 10)
                .onReceive(viewModel.$imageUploaded, perform: { out in
                    if out == true {
                        let storageRef = Storage.storage().reference()
                        let imageRef = storageRef.child(myProfile?.photoUrl ?? "")
                        imageRef.downloadURL { url, error in
                            if error == nil {
                                imageDownloadUrl = url?.absoluteString ?? ""
                            } else {
                                // error
                            }
                        }
                    }
                })
                
                NavigationView {
                    ScrollView (showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(filteredCards, id: \.self) { p in
                                if p.id != myProfile?.id {
                                    ProfileCard(name: p.name, age: p.age, role: p.role, photoUrl: p.photoUrl, myInterest: $myInterest, interestList: p.interests)
                                }
                            }
                        }
                    }
                    .refreshable {
                        viewModel.getProfilesData()
                    }
                    .frame( maxWidth: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .listStyle(.plain)
                    .offset(y: 10)
                    
                    .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Stalk Here 😶‍🌫️")
                    .background(.white)
                }
            }
        }
    }
    
    
    var filteredCards: [ProfileModel] {
        if searchText.isEmpty {
            return viewModel.profileList
        } else {
            return viewModel.profileList.filter(
                {
                    ($0.name.localizedCaseInsensitiveContains(searchText))
                }
            )
            
        }
    }
        
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(ViewModel())
    }
}
