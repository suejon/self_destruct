//
//  LoginController.swift
//  Self Destruct
//
//  Created by Jono Sue on 31/12/16.
//  Copyright © 2016 Remote Hamster. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class LoginController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return UIStatusBarStyle.lightContent
        }
    }
    
    var messagesController: MessagesController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.green
        setupView()
    }
    
    var loginView: LoginView?
    
    func setupView() {
        loginView = LoginView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        view = loginView
        loginView?.usernameTextfield.delegate = self
        loginView?.usernameTextfield.tag = 0
        loginView?.emailTextfield.delegate = self
        loginView?.emailTextfield.tag = 1
        loginView?.passwordTextfield.delegate = self
        loginView?.passwordTextfield.tag = 2
        
        loginView?.loginRegisterButton.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        
        loginView?.profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImage)))
        loginView?.profileImageView.isUserInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextTextField.becomeFirstResponder()
        } else {
        textField.resignFirstResponder()
        }
        return true
    }
    
    func handleSelectProfileImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func handleLoginRegister() {
        if loginView?.loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            // handle login
            guard let email = loginView?.emailTextfield.text, let password = loginView?.passwordTextfield.text else {
                print("Form contains invalid input")
                return
            }
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error != nil {
                    print("Failed to sign in: ", error!)
                    return
                }
                // setup user for the messages controller
                self.messagesController?.fetchUserAndSetupNavBarTitle()
                self.dismiss(animated: true, completion: nil)
            })
            
            
        } else {
            // handle register
            guard let name = loginView?.usernameTextfield.text, let email = loginView?.emailTextfield.text, let password = loginView?.passwordTextfield.text else {
                print("Form contains invalid input")
                return
            }
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                if error != nil {
                    print(error!)
                    return
                }
                
                guard let uid = user?.uid else {
                    return
                }
                
                if let profileImage = self.loginView?.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                    let imageName = NSUUID().uuidString
                    let storageRef = FIRStorage.storage().reference().child("profile-images").child("\(imageName).jpg")
                    
                    storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                        if error != nil {
                            print("Failed to upload picture: ", error!)
                            return
                        }
                        if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                            let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                            self.registerUserIntoDatabaseUsing(uid: uid, values: values as [String: AnyObject])
                        }
                    })
                }
            })
            
        }
    }
    
    private func registerUserIntoDatabaseUsing(uid: String, values: [String: AnyObject]) {
        let userReference = FIRDatabase.database().reference().child("users").child(uid)
        
        userReference.updateChildValues(values) { (error, databaseReference) in
            if error != nil {
                print("Failed to upload user: ", error!)
                return
            }
            
            let user = User()
            user.name = values["name"] as? String
            user.email = values["email"] as? String
            user.profileImageUrl = values["profileImageUrl"] as? String
            
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    // MARK: - imagePickerControllerDelegate Functions
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImg: UIImage?
        
        if let editedImg = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImg = editedImg
        } else if let originalImg = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImg = originalImg
        }
        
        if let confirmedImg = selectedImg {
            loginView?.profileImageView.image = confirmedImg
            loginView?.profileImageView.layer.cornerRadius = 60
        }
        dismiss(animated: true, completion: nil)
    }
    
}
