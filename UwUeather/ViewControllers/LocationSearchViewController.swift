//
//  LocationSearchViewController.swift
//  UwUeather
//
//  Created by Nick Zolnoor on 1/24/20.
//  Copyright © 2020 Nick Zolnoor. All rights reserved.
//

import UIKit

class LocationSearchViewController: UITableViewController {
    
    @IBOutlet weak var resultsTableView: UITableView!
    lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)

        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Location Search"
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
        resultsTableView.tableHeaderView = searchController.searchBar
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LocationSearchViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell.init(style: .default, reuseIdentifier: "holder")
    }
    
    
}

extension LocationSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        print("yeet")
    }
}
