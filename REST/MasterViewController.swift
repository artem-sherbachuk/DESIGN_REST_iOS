//
//  MasterViewController.swift
//  REST
//
//  Created by Artem Sherbachuk (UKRAINE) on 10/31/16.
//  Copyright © 2016 ArtemSherbachuk. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

final class MasterViewController: UITableViewController, NVActivityIndicatorViewable {

    @IBOutlet var gistsTableView: GistsTableView!
    @IBOutlet weak var pullToRefresh: UIRefreshControl!
    @IBOutlet weak var gistsAccsesSegmentControl: GistsSegmentedControl!
    
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
    
    private func loadGistsFromNetwork() {
        
        func fetch(req: GistRouter) {
            startAnimating(CGSize(width: 50, height: 50), message: "loading", type: .ballTrianglePath, color: .yellow)
            GitHubAPIService.fetchGists(url: req) { [weak self] result in
                self?.stopAnimating()
                guard let s = self, result.error == nil else {
                    self?.handleLoadGistsError(result.error!)
                    return
                }
                if let fetchedGists = result.value {
                    s.gists = s.gists + fetchedGists
                }
                
                if s.pullToRefresh.isRefreshing {
                    s.pullToRefresh.endRefreshing()
                }
            }
        }
        
        
        if gistsAccsesSegmentControl.isPublicGistsSelected() {
            let publicGists = GistRouter.getPublic()
            fetch(req: publicGists)
            return
        }
        
        if gistsAccsesSegmentControl.isPrivateGistsSelected() {
            let userGists = gistsAccsesSegmentControl.selectedSegmentIndex == 1 ? GistRouter.getUserGists() : GistRouter.getStarredGists()
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
    
    private func handleLoadGistsError(_ error: Error) {
        self.gists.removeAll()
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    @objc private func insertNewObject(_ sender: Any) {
        let alert = UIAlertController(title: "Not Implemented",
                                      message: "Can't create new gists yet, will implement later",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func pullToRefresh(_ sender: UIRefreshControl) {
        GitHubAPIService.clearAllCache()
        self.gists.removeAll()
        self.loadGistsFromNetwork()
    }
    
    @IBAction func gistsAcsessAction(_ sender: GistsSegmentedControl) {
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

