//
//  ViewController.swift
//  GoogleSearch
//
//  Created by Anastasia Markovets on 25.01.2019.
//  Copyright © 2019 Lonely Tree Std. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    @IBOutlet weak var googleSearchBar: UISearchBar!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var resultSearchTableView: UITableView!
    
    var activityIndicator: UIActivityIndicatorView!
    var backgroundIndicator = UIView()
    
    var results = [Result]() {
        didSet {
            self.resultSearchTableView.reloadData()
        }
    }
    
    let requestModel = RequestModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.googleSearchBar.delegate = self
        
        let noteNib = UINib(nibName: "ResultTableViewCell", bundle: nil)
        self.resultSearchTableView.register(noteNib, forCellReuseIdentifier: "resultCell")
        
        self.searchButton.layer.cornerRadius = 10
    }
    
    @IBAction func clickSearch(_ sender: Any) {
        self.searchMethod()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchMethod()
    }
    
    func searchMethod() {
        self.googleSearchBar.resignFirstResponder()
        
        if self.searchButton.currentTitle == "Google Search" {
            self.setStyleButton()
            self.setIndicator()
            activityIndicator.startAnimating()
            let searchText = self.googleSearchBar.text?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let searchBarText = searchText {
                requestModel.getData(searchText: searchBarText, success: { (results) in
                    self.results = results
                    self.setStyleButton()
                    self.stopIndicator()
                }, canceled: {
                    self.stopIndicator()
                }) { (err) in
                    self.showToast(message: err)
                    self.setStyleButton()
                    self.stopIndicator()
                }
            }
        } else {
            self.setStyleButton()
            self.requestModel.stopTask()
        }
    }
    
    func setStyleButton() {
        if self.searchButton.currentTitle == "Google Search" {
            self.searchButton.setTitle("Stop", for: .normal)
            self.searchButton.backgroundColor = UIColor(red: 235/255, green: 174/255, blue: 161/255, alpha: 1)
        } else {
            self.searchButton.setTitle("Google Search", for: .normal)
            self.searchButton.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 243/255, alpha: 1)
        }
    }
    
    func setIndicator() {
        self.backgroundIndicator = UIView(frame: self.resultSearchTableView.frame)
        self.backgroundIndicator.backgroundColor = .white
        self.view.addSubview(backgroundIndicator)
        
        self.activityIndicator = UIActivityIndicatorView(style: .gray)
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height / 2)
    }
    
    func stopIndicator() {
        self.activityIndicator.stopAnimating()

        UIView.animate(withDuration: 0.5, animations: {
            self.backgroundIndicator.alpha = 0
        }) { (bool) in
            self.backgroundIndicator.removeFromSuperview()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.resultSearchTableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! ResultTableViewCell
        cell.titleLabel.text = self.results[indexPath.row].title
        cell.urlLabel.text = self.results[indexPath.row].link
        cell.descLabel.text = self.results[indexPath.row].snippet
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
}


