//
//  AddTableViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/4/16.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit

class AddTableViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    var isSearching: Bool = false {
        didSet {
            tableView.reloadData()
        }
    }
    
    var searchViewController: UISearchController!
    
    var searchResultsController: ResultsTableViewController {
        return searchViewController.searchResultsController as! ResultsTableViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchResultsController = UIStoryboard(name: "B", bundle: nil).instantiateViewController(withIdentifier: "ResultsTableViewController") as! ResultsTableViewController
        searchViewController = SearchController(searchResultsController: searchResultsController)
        searchResultsController.searchVC = searchViewController
        searchViewController.dimsBackgroundDuringPresentation = false
        searchViewController.searchBar.autocapitalizationType = .none
        searchViewController.searchBar.placeholder = NSLocalizedString("PHONE", comment: "Searchbar placeholder is phone")
        searchViewController.searchBar.delegate = self
        searchViewController.delegate = self
        searchViewController.searchResultsUpdater = self
        definesPresentationContext = true
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return isSearching ? 0 : 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isSearching = true
        navigationItem.searchController = searchViewController
        navigationItem.searchController?.isActive = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchResultsController.search()
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        searchResultsController.reset()
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        navigationItem.searchController = nil
        isSearching = false
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else {
            searchResultsController.reset()
            return
        }
        searchResultsController.update(input: text)
    }
    
}


class SearchController: UISearchController {
    
    private var viewIsHiddenObserver: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewIsHiddenObserver = self.searchResultsController?.view.observe(\.hidden, changeHandler: { [weak self] (view, _) in
            guard let searchController = self else { return }
            searchController.searchBar.becomeFirstResponder()
            if view.isHidden && searchController.searchBar.isFirstResponder {
                view.isHidden = false
            }
        })
    }
}


