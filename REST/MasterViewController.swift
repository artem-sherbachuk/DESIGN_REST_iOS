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
    @IBOutlet weak var pullToRefresh: UIRefreshControl!
    @IBOutlet weak var gistsAccsesSegmentControl: UISegmentedControl!
    
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
    
    func loadGistsFromNetwork() {
        
        func fetch(req: GistRouter) {
            GitHubAPIService.fetchGists(url: req) { result in
                if let error = result.error {
                    self.handleLoadGistsError(error)
                }
                if let fetchedGists = result.value {
                    self.gists = self.gists + fetchedGists
                }
                
                if self.pullToRefresh.isRefreshing {
                    self.pullToRefresh.endRefreshing()
                }
            }
        }
        
        
        if gistsAccsesSegmentControl.selectedSegmentIndex == 0 {
            let publicGists = GistRouter.getPublic()
            fetch(req: publicGists)
            return
        }
        
        if gistsAccsesSegmentControl.selectedSegmentIndex == 1 {
            let userGists = GistRouter.getUserGists()
            if !GitHubAPIService.isHasOAuthToken() {
                GitHubAPIService.OAuth2Login(fromVC: self) { error in
                    if error != nil {
                        self.handleLoadGistsError(error!)
                    } else {
                        fetch(req: userGists)
                    }
                }
            } else {
                fetch(req: userGists)
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

    @IBAction func pullToRefresh(_ sender: UIRefreshControl) {
        GitHubAPIService.clearAllCache()
        self.gists.removeAll()
        self.loadGistsFromNetwork()
    }
    
    @IBAction func gistsAcsessAction(_ sender: UISegmentedControl) {
        self.gists.removeAll()
        self.loadGistsFromNetwork()
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

