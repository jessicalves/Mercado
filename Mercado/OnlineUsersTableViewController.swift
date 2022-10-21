//
//  OnlineUsersTableViewController.swift
//  Mercado
//
//  Created by Jessica Alves on 01/10/22.
//

import UIKit
import Firebase

class OnlineUsersTableViewController: UITableViewController {
    
    let userCell = "UserCell"

    // MARK: Properties
    var currentUsers: [String] = []
    let usersRef = Database.database().reference(withPath: "online")
    var usersRefObservers: [DatabaseHandle] = []
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
      return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(true)
      let childAdded = usersRef
        .observe(.childAdded) { [weak self] snap in
          guard
            let email = snap.value as? String,
            let self = self
          else { return }
          self.currentUsers.append(email)
          let row = self.currentUsers.count - 1
          let indexPath = IndexPath(row: row, section: 0)
          self.tableView.insertRows(at: [indexPath], with: .top)
        }
      usersRefObservers.append(childAdded)

      let childRemoved = usersRef
        .observe(.childRemoved) {[weak self] snap in
          guard
            let emailToFind = snap.value as? String,
            let self = self
          else { return }

          for (index, email) in self.currentUsers.enumerated()
          where email == emailToFind {
            let indexPath = IndexPath(row: index, section: 0)
            self.currentUsers.remove(at: index)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
          }
        }
      usersRefObservers.append(childRemoved)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(true)
      usersRefObservers.forEach(usersRef.removeObserver(withHandle:))
      usersRefObservers = []
    }

    // MARK: UITableView Delegate methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return currentUsers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: userCell, for: indexPath)
      let onlineUserEmail = currentUsers[indexPath.row]
      cell.textLabel?.text = onlineUserEmail
      return cell
    }

    
    @IBAction func sindOut(_ sender: Any) {
        
        guard let user = Auth.auth().currentUser else { return }

        let onlineRef = Database.database().reference(withPath: "online/\(user.uid)")
        onlineRef.removeValue { error, _ in
          if let error = error {
            print("Remover online falhou: \(error)")
            return
          }
          do {
            try Auth.auth().signOut()
            self.navigationController?.popToRootViewController(animated: true)
          } catch let error {
            print("Sair falhou: \(error)")
          }
        }
    }
}
