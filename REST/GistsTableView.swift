//
//  GistsTableView.swift
//  REST
//
//  Created by Artem Sherbachuk (UKRAINE) on 11/1/16.
//  Copyright © 2016 ArtemSherbachuk. All rights reserved.
//

import UIKit

final class GistsTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    override func awakeFromNib() {
        self.dataSource = self
        self.delegate = self
        if let image = UIImage(named: "bgTextureDark") {
            self.backgroundColor = UIColor(patternImage: image)
        }
    }

    var gists: [Gist] = [] {
        didSet {
            self.reloadData()
        }
    }
    
    typealias EventCompletion = (Void) -> Void //event instead of delegate
    private var loadMoreGistsEventCompletion: EventCompletion?

    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GistCell", for: indexPath) as! GistTableViewCell
        cell.gist = gists[indexPath.row]
        
        if isNeedLoadMoreGists(indexPath: indexPath) {
            self.loadMoreGistsEventCompletion?()
        }
        return cell
    }
    private func isNeedLoadMoreGists(indexPath: IndexPath) -> Bool {
        let rowsLoaded = gists.count
        let rowsRemaining = rowsLoaded - indexPath.row
        let loadingThreshold = 5
        return (rowsRemaining <= loadingThreshold) && (gists.count > loadingThreshold)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            gists.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    
    //MARK: Public API
    func onLoadMoreGistsEvent(comletion: @escaping EventCompletion) {
        self.loadMoreGistsEventCompletion = comletion
    }
}
