//
//  TVC1.swift
//  TestTabBarGesture
//
//  Created by george on 17/06/2020.
//  Copyright © 2020 George Nicolaou. All rights reserved.
//

import UIKit

class TVC1: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id") ?? UITableViewCell(style: .default, reuseIdentifier: "id")
        cell.textLabel?.text = "Index path: \(indexPath)"
        return cell
    }
}
