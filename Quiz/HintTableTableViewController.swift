//
//  HintTableTableViewController.swift
//  Quiz
//
//  Created by Alfonso  Jiménez Martínez on 22/11/2018.
//  Copyright © 2018 Alfonso  Jiménez Martínez. All rights reserved.
//

import UIKit

class HintTableTableViewController: UITableViewController {
    
    var hints: [String?]?

    override func viewDidLoad() {
        super.viewDidLoad()
    
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return hints?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell...
        let hint = hints![indexPath.row] 
        cell.textLabel?.text = hint

        return cell
    }
    

    

}
