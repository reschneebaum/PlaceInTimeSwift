//
//  SignupViewController.swift
//  PlaceInTime
//
//  Created by Rachel Schneebaum on 3/8/17.
//  Copyright © 2017 Rachel Schneebaum. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class SignupViewController: UIViewController {

    @IBOutlet fileprivate weak var usernameTextField: UITextField!
    @IBOutlet fileprivate weak var passwordTextField: UITextField!
    @IBOutlet fileprivate weak var confirmPasswordTextField: UITextField!
    @IBOutlet fileprivate weak var emailTextField: UITextField!
    @IBOutlet fileprivate weak var nameTextField: UITextField!

    fileprivate var textFields: [UITextField] = []
    private var ref: FIRDatabaseReference?


    override func viewDidLoad() {
        super.viewDidLoad()

        textFields = [usernameTextField,
                      passwordTextField,
                      confirmPasswordTextField,
                      emailTextField,
                      nameTextField]
        textFields.forEach { textField in
            textField.delegate = self
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        textFields.forEach { textField in
            textField.resignFirstResponder()
        }
    }

    func registerUser() {
        var complete = true
        textFields.forEach { textField in
            if !textField.hasText { complete = false }
        }
        guard complete else { return }

        FIRAuth.auth()?.createUser(
            withEmail: emailTextField.text!,
            password: passwordTextField.text!) { user, error in
                guard error == nil else {
                    return self.errorAlert(error!.localizedDescription,
                                           completion: nil)
                }

                guard let authUser = user else { return print("error - no user") }
                print("new user registered")

                let newUser = User(authData: authUser)
                let newUserInfo = UserInfo(authUser: newUser,
                                           name: self.nameTextField.text!,
                                           username: self.usernameTextField.text!)

                self.ref = FIRDatabase.database().reference().child("userinfo").child(authUser.uid)
                self.ref?.setValue(newUserInfo.toAnyObject()) { error, _ in
                    print("new user info created")
                    self.goToRoot(user: newUser)
                }
//                self.ref?.child("username").setValue(self.usernameTextField.text!)
//                self.ref?.child("name").setValue(self.nameTextField.text!)
//                self.ref?.child("email").setValue(self.emailTextField.text!)

                print("new user: \(newUser.email)")
        }
    }

    @IBAction func onSignupButtonTapped(_ sender: UIButton) {
        registerUser()
    }

    @IBAction func onCancelButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "LoginSegue", sender: self)
    }

}


// MARK: - UITextFieldDelegate
extension SignupViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField != textFields.last else {
            registerUser()
            return true
        }

        for i in 0..<textFields.count {
            if textField == textFields[i] {
                textFields[i+1].becomeFirstResponder()
            }
        }
        textField.endEditing(true)
        return true
    }
}

