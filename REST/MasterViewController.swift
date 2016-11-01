//
//  MasterViewController.swift
//  REST
//
//  Created by Artem Sherbachuk (UKRAINE) on 10/31/16.
//  Copyright © 2016 ArtemSherbachuk. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    @IBOutlet var gistsTableView: GistsTableView!
    var detailViewController: DetailViewController? = nil
    var gists = [Gist]()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        func loadGists() {
            let gist1 = Gist()
            gist1.description = "The first gist"
            gist1.ownerLogin = "gist1Owner"
            let gist2 = Gist()
            gist2.description = "The second gist"
            gist2.ownerLogin = "gist2Owner"
            let gist3 = Gist()
            gist3.description = "The third gist"
            gist3.ownerLogin = "gist3Owner"
            gists = [gist1, gist2, gist3]
            self.gistsTableView.gists = gists
        }
        loadGists()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GitHubAPIService.sharedInstance.printPublicGist()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

