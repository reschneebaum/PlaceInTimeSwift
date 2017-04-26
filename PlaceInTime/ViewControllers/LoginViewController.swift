//
//  LoginViewController.swift
//  PlaceInTime
//
//  Created by Rachel Schneebaum on 3/8/17.
//  Copyright © 2017 Rachel Schneebaum. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class LoginViewController: UIViewController {

    var user: User?

    @IBOutlet fileprivate weak var usernameTextField: UITextField!
    @IBOutlet fileprivate weak var passwordTextField: UITextField!
    @IBOutlet fileprivate weak var forgotPasswordInstructionsLabel: UILabel! {
        didSet {
            forgotPasswordInstructionsLabel.alpha = 0
        }
    }

    private var passwordResetTextField: UITextField?


    override func viewDidLoad() {
        super.viewDidLoad()

        usernameTextField.delegate = self
        passwordTextField.delegate = self

        // TEST
        usernameTextField.text = "newuser4@earlybird.co"
        passwordTextField.text = "secret123"
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }

    func loginUser(email: String, password: String) {
        FIRAuth.auth()?.signIn(withEmail: email,
                               password: password) { user, error in
            guard error == nil else {
                self.errorAlert(error!.localizedDescription, completion: nil)
                return
            }

            guard let authUser = user else { return print("error - no user") }
            let user = User(authData: authUser)
            print("logged in user: \(user.email)")
            self.goToRoot(user: user)
        }
    }

    @IBAction func onLoginButtonTapped(_ sender: UIButton) {
        guard let email = usernameTextField.text,
            let password = passwordTextField.text else {
            return
        }

        loginUser(email: email, password: password)
    }

    @IBAction func onSignupButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "SignupSegue", sender: self)
    }

    @IBAction func onForgotPasswordButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Forgot Password?",
            message: "Please enter the email address associated with your account:",
            preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "email address"
            self.passwordResetTextField = textField
        }
        let okAlert = UIAlertAction(title: "Ok", style: .default) { _ in
            guard let email = self.passwordResetTextField?.text else { return }

            FIRAuth.auth()?.sendPasswordReset(withEmail: email) { _ in
                UIView.animate(withDuration: 0.5) {
                    self.forgotPasswordInstructionsLabel.alpha = 1
                }
            }
        }
        alert.addAction(okAlert)

        present(alert, animated: true, completion: nil)
    }

    @IBAction func unwindFromLogout(segue: UIStoryboardSegue) {}

}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            guard let email = usernameTextField.text,
                let password = passwordTextField.text else {
                    return true
            }
            loginUser(email: email, password: password)
        }
        textField.endEditing(true)
        return true
    }
}
