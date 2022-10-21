//
//  MercadoListTableViewController.swift
//  Mercado
//
//  Created by Jessica Alves on 01/10/22.
//

import UIKit
import Firebase

class MercadoListTableViewController: UITableViewController {
    
    let listToUsers = "ListToUsers"
    let ref = Database.database().reference(withPath: "mercado-items")
    var refObservers: [DatabaseHandle] = []
    
    let usersRef = Database.database().reference(withPath: "online")
    var usersRefObservers: [DatabaseHandle] = []
    
    var items: [Item] = []
    var user: User?
    var onlineUserCount = UIBarButtonItem()
    var handle: AuthStateDidChangeListenerHandle?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
      return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelectionDuringEditing = false
        onlineUserCount = UIBarButtonItem(
          title: "1",
          style: .plain,
          target: self,
          action: #selector(onlineUserCountDidTouch))
        onlineUserCount.tintColor = .tintColor
        navigationItem.leftBarButtonItem = onlineUserCount
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      let completed = ref
        .queryOrdered(byChild: "completed")
        .observe(.value) { snapshot in
          var newItems: [Item] = []
          for child in snapshot.children {
            if
              let snapshot = child as? DataSnapshot,
              let groceryItem = Item(snapshot: snapshot) {
              newItems.append(groceryItem)
            }
          }
          self.items = newItems
          self.tableView.reloadData()
        }
      refObservers.append(completed)

      handle = Auth.auth().addStateDidChangeListener { _, user in
        guard let user = user else { return }
        self.user = User(authData: user)

        let currentUserRef = self.usersRef.child(user.uid)
        currentUserRef.setValue(user.email)
        currentUserRef.onDisconnectRemoveValue()
      }

      let users = usersRef.observe(.value) { snapshot in
        if snapshot.exists() {
          self.onlineUserCount.title = snapshot.childrenCount.description
        } else {
          self.onlineUserCount.title = "0"
        }
      }
      usersRefObservers.append(users)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(true)
      refObservers.forEach(ref.removeObserver(withHandle:))
      refObservers = []
      usersRefObservers.forEach(usersRef.removeObserver(withHandle:))
      usersRefObservers = []
      guard let handle = handle else { return }
      Auth.auth().removeStateDidChangeListener(handle)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let groceryItem = items[indexPath.row]

        cell.textLabel?.text = groceryItem.name
        cell.detailTextLabel?.text = groceryItem.addedByUser

        toggleCellCheckbox(cell, isCompleted: groceryItem.completed)

        return cell
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }


  
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
          let groceryItem = items[indexPath.row]
          groceryItem.ref?.removeValue()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      guard let cell = tableView.cellForRow(at: indexPath) else { return }
      let groceryItem = items[indexPath.row]
      let toggledCompletion = !groceryItem.completed
      toggleCellCheckbox(cell, isCompleted: toggledCompletion)
      groceryItem.ref?.updateChildValues(["completed": toggledCompletion])
    }
    
    func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
      if !isCompleted {
        cell.accessoryType = .none
        cell.textLabel?.textColor = .black
        cell.detailTextLabel?.textColor = .black
      } else {
        cell.accessoryType = .checkmark
        cell.textLabel?.textColor = .gray
        cell.detailTextLabel?.textColor = .gray
      }
    }

    @IBAction func addItem(_ sender: Any) {
        
        let alert = UIAlertController(
          title: "Itens do Mercado",
          message: "Adicione um Item",
          preferredStyle: .alert)

        let saveAction = UIAlertAction(title: "Salvar", style: .default) { _ in
          guard
            let textField = alert.textFields?.first,
            let text = textField.text,
            let user = self.user
          else { return }

          let groceryItem = Item(
            name: text,
            addedByUser: user.email,
            completed: false)

          let groceryItemRef = self.ref.child(text.lowercased())
          groceryItemRef.setValue(groceryItem.toAnyObject())
        }

        let cancelAction = UIAlertAction(
          title: "Cancelar",
          style: .cancel)

        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
    
    @objc func onlineUserCountDidTouch() {
      performSegue(withIdentifier: listToUsers, sender: nil)
    }
}
