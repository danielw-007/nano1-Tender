//
//  ProfileView.swift
//  Tender
//
//  Created by Daniel Widjaja on 21/03/23.
//

import SwiftUI
import PhotosUI
import FirebaseStorage
import FirebaseFirestore

struct ProfileView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var viewModel: ViewModel
    let myProfile : ProfileModel? = UserDefaults.standard.retrieveCodable(for: "myProfile")
    @State private var showModal = false
    @State var name = ""
    @State var age = 0
    @State var role = ""
    @State var showImagePicker = false
    @State var image: UIImage?
    @State var pickedInterest: [String] = []
    
    @State var profileImageUrl: String = ""
    
    init() {
        _pickedInterest = State(initialValue: myProfile?.interests ?? [])
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    Image("Logo")
                        .resizable()
                        .frame(width: 28, height: 28)
                    
                    Divider()
                        .padding(.bottom, 25)
                        .padding(.horizontal, -25)
                    
                    basicInformation(name: $name, age: $age, role: $role, myProfile: myProfile)
                    
                    VStack {
                        Text("My Photo")
                            .font(.title2)
                            .padding(.bottom)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fontWeight(.bold)
                        
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 170, height: 170)
                            
                        } else
                        if profileImageUrl != "" {
                            AsyncImage(url: URL(string: profileImageUrl)!) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } placeholder: {
                                Image(systemName: "photo.fill")
                            }
                            .frame(width: 170, height: 170)
                            .onAppear {
                                viewModel.retrieveProfilePhoto(photoUrl: profileImageUrl)
                            }
                            .onReceive(viewModel.$profileImageDownloaded) { out in
                                image = out
                            }
                        } else {
                            Text("No image selected")
                                .frame(width: 170, height: 170)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        }
                        
                        Button("Select a photo") {
                            showImagePicker = true
                        }
                    }
                    .padding(.top, 20)
                    .sheet(isPresented: $showImagePicker) {
                        ImagePickerView(image: $image)
                    }
                    
                    VStack {
                        HStack (alignment: .center) {
                            Text("My Interest")
                                .font(.title2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button {
                                showModal.toggle()
                            } label: {
                                Text("+ add")
                            }
                            .sheet(isPresented: $showModal) {
                                
                                ScrollView {
                                    
                                    VStack (alignment: .leading) {
                                        
                                        HStack (alignment: .center){
                                            Text("My Interest")
                                                .font(.title2)
                                                .bold()
                                            Spacer()
                                            Text("\(8 - $pickedInterest.count) left")
                                                .padding(8)
                                                .background(Color(hex: "DB9999"))
                                                .foregroundColor(.white)
                                                .font(.caption2)
                                                .cornerRadius(4)
                                        }
                                        .padding(.bottom, 10)
                                        
                                        Group {
                                            Text("Sport")
                                                .font(.title3)
                                            TagCloudView(pickedInterest: $pickedInterest, tags: viewModel.sport)
                                        }
                                        
                                        Group {
                                            Text("Favorite Movie Genre")
                                                .font(.title3)
                                            TagCloudView(pickedInterest: $pickedInterest, tags: viewModel.movie)
                                        }
                                        
                                        Group {
                                            Text("Favorite Music Genre")
                                                .font(.title3)
                                            TagCloudView(pickedInterest: $pickedInterest, tags: viewModel.music)
                                        }
                                        
                                        Group {
                                            Text("Pets")
                                                .font(.title3)
                                            TagCloudView(pickedInterest: $pickedInterest, tags: viewModel.pets)
                                        }
                                        
                                        Group {
                                            Text("Creativity")
                                                .font(.title3)
                                            TagCloudView(pickedInterest: $pickedInterest, tags: viewModel.creativity)
                                        }
                                        
                                        Group {
                                            Text("Going Out")
                                                .font(.title3)
                                            TagCloudView(pickedInterest: $pickedInterest, tags: viewModel.goingOut)
                                        }
                                        
                                    }
                                    .padding()
                                }
                                
                                Button {
                                    showModal.toggle()
                                } label: {
                                    Text("Save")
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(.orange)
                                        .foregroundColor(.white)
                                        .font(.headline)
                                        .cornerRadius(4)
                                }
                                .padding()
                                
                            }
                        }
                        
                        // List of selected interests
                        TagView(myInterest: $pickedInterest, tags: pickedInterest)
                    }
                    .padding(.top, 20)
                    
                    // Save Button
                    Button {
                        if checkEnableSaveButton() {
                            var newProfile: ProfileModel = ProfileModel(name: name, age: age, role: role, photoUrl: uploadPhoto(), interests: pickedInterest)

                            let existingProfile : ProfileModel? = UserDefaults.standard.retrieveCodable(for: "myProfile")
                            
                            if existingProfile != nil {
                                newProfile.id = existingProfile?.id
                                viewModel.editProfile(profile: newProfile)
                                UserDefaults.standard.storeCodable(newProfile, key: "myProfile")
                                deletePhoto(photoUrl: existingProfile?.photoUrl ?? "")
                            } else {
                                UserDefaults.standard.storeCodable(newProfile, key: "myProfile")
                                viewModel.addProfile(profile: newProfile)
                            }
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    } label: {
                        
                        Text("Save")
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background( checkEnableSaveButton() ? .orange : Color(hex: "B27A42") )
                            .foregroundColor(.white)
                            .font(.headline)
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                    
                }
                .onAppear {
                    let storageRef = Storage.storage().reference()
                    let imageRef = storageRef.child(myProfile?.photoUrl ?? "")
                    imageRef.downloadURL { url, error in
                        if error == nil {
                            profileImageUrl = url?.absoluteString ?? ""
                        } else {
                            // error
                        }
                    }
                }
            }
        }
    }
    
    func checkEnableSaveButton() -> Bool {
        if name != "" && age != 0 && role != "" && image != nil && $pickedInterest.count > 0 {
            return true
        }
        return false
    }
    
    func uploadPhoto() -> String {
        
        viewModel.imageUploaded = false
        let storageRef = Storage.storage().reference()
        
        let imageData = image!.jpegData(compressionQuality: 0.3)
        
        guard imageData != nil else {
            return ""
        }
        
        let path = "images/\(UUID().uuidString).jpg"
        let fileRef = storageRef.child(path)
        DispatchQueue.main.async {
            fileRef.putData(imageData!, metadata: nil) { (metadata, error) in
                guard error == nil else {
                    return
                }

                viewModel.imageUploaded = true
            }
        }
        
        return path
    }
    
    func deletePhoto(photoUrl: String) {
        
        let storageRef = Storage.storage().reference()
        
        let photoRef = storageRef.child(photoUrl)
        
        photoRef.delete { error in
            if error != nil {
                // Uh-oh, an error occurred!
            } else {
                // File deleted successfully
                
            }
        }
    }
    
}

//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView(, pickedInterest: <#[InterestModel]#>)
//    }
//}

struct basicInformation: View {
    
    @Binding var name: String
    @Binding var age: Int
    @Binding var role: String
    var myProfile: ProfileModel?
    
    var body: some View {
        VStack {
            Text("Basic Information")
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fontWeight(.bold)
            
            HStack {
                Text("Name")
                    .frame(width: 70, alignment: .leading)
                ZStack(alignment: .trailing)
                {
                    TextField("", text: $name)
                        .onAppear {
                            self.name = myProfile?.name ?? ""
                        }
                    if !name.isEmpty
                    {Button(action:{self.name = ""})
                        {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color(UIColor.opaqueSeparator))
                        }
                        .padding(.trailing, 8)
                    }
                }
            }
            .padding(5)
            Divider()
            HStack {
                Text("Age")
                    .frame(width: 70, alignment: .leading)
                ZStack(alignment: .trailing)
                {
                    TextField("", value: $age, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                        .onAppear {
                            self.age = myProfile?.age ?? 0
                        }
                    if age > 0
                    {Button(action:{self.age = 0})
                        {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color(UIColor.opaqueSeparator))
                        }
                        .padding(.trailing, 8)
                    }
                }
            }
            .padding(5)
            Divider()
            HStack {
                Text("Role")
                    .frame(width: 70, alignment: .leading)
                ZStack(alignment: .trailing)
                {
                    TextField("", text: $role)
                        .onAppear {
                            self.role = myProfile?.role ?? ""
                        }
                    if !role.isEmpty
                    {Button(action:{self.role = ""})
                        {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color(UIColor.opaqueSeparator))
                        }
                        .padding(.trailing, 8)
                    }
                }
            }
            .padding(5)
            Divider()
        }
    }
}

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> some UIViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: PHPickerViewControllerDelegate {
        let parent: ImagePickerView
        
        init(parent: ImagePickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let itemProvider = results.first?.itemProvider else {
                parent.presentationMode.wrappedValue.dismiss()
                return
            }
            
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self?.parent.image = image
                            self?.parent.presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            } else {
                parent.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

