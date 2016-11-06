//
//  DetailViewController.swift
//  REST
//
//  Created by Artem Sherbachuk (UKRAINE) on 10/31/16.
//  Copyright © 2016 ArtemSherbachuk. All rights reserved.
//

import UIKit

final class DetailViewController: UIViewController {

    var gist: Gist?
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var descriptionLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let file = gist?.files?.first, let fileURL = file.rawURL, let fileName = file.fileName {
            let req = URLRequest(url: URL(string: fileURL)!)
            webView.loadRequest(req)
            descriptionLabel.text = fileName
        }
    }
}

