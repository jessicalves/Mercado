//
//  ViewController.swift
//  Mercado
//
//  Created by Jessica Alves on 20/10/22.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    let ref =  Database.database().reference(withPath: "items-mercado")
     var refObservers: [ DatabaseHandle ] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

