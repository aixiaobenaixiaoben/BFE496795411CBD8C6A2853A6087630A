//
//  ResultsTableViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/4/17.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit
import Foundation

class ResultsTableViewController: UITableViewController {

    @IBOutlet weak var searchCell: UITableViewCell!
    @IBOutlet weak var resultCell: UITableViewCell!
    @IBOutlet weak var moreCell: UITableViewCell!
    
    weak var searchVC: UISearchController?
    
    var searchText: String? {
        didSet {
            if let searchText = searchText {
                let searchShowText = NSLocalizedString("SEARCH", comment: "Label prefix to Search contact") + ":" + searchText
                let searchAttributeString = NSMutableAttributedString(string: searchShowText)
                let searchRange = (searchShowText as NSString).range(of: searchText)
                searchAttributeString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blue, range: searchRange)
                searchCell.textLabel?.attributedText = searchAttributeString
            }
        }
    }
    
    var isInputing: Bool? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultCell.isUserInteractionEnabled = false
        moreCell.detailTextLabel?.text = NSLocalizedString("MINI PROGRAMS, OFFICIAL ACCOUNTS, ARTICLES, MOMENTS, AND STICKERS", comment: "Search more content")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let isInputing = isInputing else {
            return 0
        }
        return isInputing ? 1 : 3;
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNonzeroMagnitude
        }
        if let isInputing = isInputing, !isInputing, section == 1 {
            return CGFloat.leastNonzeroMagnitude
        }
        return super.tableView(tableView, heightForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let isInputing = isInputing, !isInputing, section == 0 {
            return CGFloat.leastNonzeroMagnitude
        }
        return super.tableView(tableView, heightForFooterInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let isInputing = isInputing, !isInputing, indexPath.section == 0 {
            return 0
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let searchVC = searchVC {
                searchVC.searchBar.resignFirstResponder()
            }
            search()
        } else if indexPath.section == 2 {
            self.tableView.makeToast(moreCell.detailTextLabel?.text)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func reset() {
        isInputing = nil
    }
    
    func update(input text: String) {
        if isInputing == nil {
            isInputing = true
        }
        searchText = text
    }
    
    func search() {
        guard let searchText = searchText else { return }
        
        let moreShowText = NSLocalizedString("SEARCH", comment: "Label prefix to Search contact") + " " + searchText
        let moreAttributeString = NSMutableAttributedString(string: moreShowText)
        let moreRange = (moreShowText as NSString).range(of: searchText)
        moreAttributeString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blue, range: moreRange)
        moreCell.textLabel?.attributedText = moreAttributeString
        
        //TODO: - find contact then open user detail
        self.tableView.makeToast("Search Contacts")
        
        //TODO: - not find contact
        isInputing = false
    }
    
}
