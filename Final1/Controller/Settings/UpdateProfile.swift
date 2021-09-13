//
//  LoginController+handlers.swift
//  gameofchats
//
//  Created by Brian Voong on 7/4/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import Firebase

extension EditProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func handleSelectProfileImageView() {
        let picker = UIImagePickerController()

        picker.delegate = self
        picker.allowsEditing = true

        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)


        var selectedImageFromPicker: UIImage?

        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {

            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            updateFirebaseStorage(selectedImage)
        }

        
        dismiss(animated: true, completion: nil)

    }
    
    func updateFirebaseStorage (_ selectedImageFromPicker: UIImage) {
        let firImage = ProfileImage(image: selectedImageFromPicker)
        let resizedImage = firImage.image.resize()
        if let imageData = resizedImage.jpegData(compressionQuality: 0.9) {
            // 1. get the reference
            // Each user will have only 1 profile picture
            firImage.ref = FIRStorageReference.profileImages.referene().child(user.username!)
            
            // 2. save that to the reference
            firImage.ref.putData(imageData, metadata: nil, completion: { (_, error) in
                
                if let error = error {
                    print(error)
                    return
                }
                
                firImage.ref.downloadURL(completion: { (url, err) in
                    if let err = err {
                        print(err)
                        return
                    }
                    
                    guard let url = url else { return }
                    self.user.profileImageURL = url.absoluteString
                    self.user.save()
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                })
                
            })
        }
        
        
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

