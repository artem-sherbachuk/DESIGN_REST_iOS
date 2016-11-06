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
    
    typealias LoadMoreGistsEventCompletion = (Void) -> Void
    private var loadMoreGistsEventCompletion: LoadMoreGistsEventCompletion?
    
    typealias SelectedGistEventCompletion = (_ gist: Gist) -> Void
    private var selectedGistEventCompletion: SelectedGistEventCompletion?
    
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedGistEventCompletion?(gists[indexPath.row])
    }
    
    
    //MARK: Public API
    func onLoadMoreGistsEvent(comletion: @escaping LoadMoreGistsEventCompletion) {
        self.loadMoreGistsEventCompletion = comletion
    }
    
    func onSelectGistEvent(completion: @escaping SelectedGistEventCompletion) {
        self.selectedGistEventCompletion = completion
    }
}
