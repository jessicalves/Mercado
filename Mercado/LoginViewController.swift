//
//  LoginViewController.swift
//  Mercado
//
//  Created by Jessica Alves on 01/10/22.
//

import UIKit
import Firebase
import Foundation


class LoginViewController: UIViewController {
    
    let loginToList = "LoginToList"
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var senha: UITextField!
    
    var handle: AuthStateDidChangeListenerHandle?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
      return .lightContent
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      email.delegate = self
      senha.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      navigationController?.setNavigationBarHidden(true, animated: false)
      handle = Auth.auth().addStateDidChangeListener { _, user in
        if user == nil {
          self.navigationController?.popToRootViewController(animated: true)
        } else {
          self.performSegue(withIdentifier: self.loginToList, sender: nil)
          self.email.text = nil
          self.senha.text = nil
        }
      }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(animated)
      guard let handle = handle else { return }
      Auth.auth().removeStateDidChangeListener(handle)
    }
    @IBAction func login(_ sender: Any) {
        
        guard
          let email = email.text,
          let password = senha.text,
          !email.isEmpty,
          !password.isEmpty
        else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
          if let error = error, user == nil {
            let alert = UIAlertController(
              title: "Falha ao Acessar",
              message: error.localizedDescription,
              preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
          }
        }
    }
    @IBAction func singUP(_ sender: Any) {
        
        guard
          let email = email.text,
          let password = senha.text,
          !email.isEmpty,
          !password.isEmpty
        else { return }

        Auth.auth().createUser(withEmail: email, password: password) { _, error in
          if error == nil {
            Auth.auth().signIn(withEmail: email, password: password)
          } else {
            print("Erro ao criar usuario: \(error?.localizedDescription ?? "")")
          }
        }
  }
    
}

extension LoginViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == email {
      email.becomeFirstResponder()
    }

    if textField == senha {
      textField.resignFirstResponder()
    }
    return true
  }
}
