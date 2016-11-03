//
//  MasterViewController.swift
//  REST
//
//  Created by Artem Sherbachuk (UKRAINE) on 10/31/16.
//  Copyright © 2016 ArtemSherbachuk. All rights reserved.
//

import UIKit

final class MasterViewController: UITableViewController {

    @IBOutlet var gistsTableView: GistsTableView!
    
    var detailViewController: DetailViewController? = nil
    
    var gists = [Gist]() {
        didSet {
            self.gistsTableView.gists = gists
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        func setupNavigation() {
            self.navigationItem.leftBarButtonItem = self.editButtonItem
            
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
            self.navigationItem.rightBarButtonItem = addButton
            if let split = self.splitViewController {
                let controllers = split.viewControllers
                self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
            }
        }
        setupNavigation()
        
        loadGistsFromNetwork()
        
        gistsTableView.onLoadMoreGistsEvent { [weak self] in
            if let s = self {
                s.loadGistsFromNetwork()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadGistsFromNetwork() {
        GitHubAPIService.fetchPublicGists { result in
            if let error = result.error {
                self.handleLoadGistsError(error)
            }
            if let fetchedGists = result.value {
                self.gists = self.gists + fetchedGists
            }
        }
    }
    
    func handleLoadGistsError(_ error: Error) {
        // TODO: show error
    }

    func insertNewObject(_ sender: Any) {
        let alert = UIAlertController(title: "Not Implemented",
                                      message: "Can't create new gists yet, will implement later",
                                      preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let gist = gists[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.gist = gist
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
}

