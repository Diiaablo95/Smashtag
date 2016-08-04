//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Diablo on 14/12/15.
//  Copyright © 2015 Diablo. All rights reserved.
//

import UIKit

class TweetTableViewController: UITableViewController, UITextFieldDelegate {

    private static let DETAIL_SEGUE_IDENTIFIER = "Show detail"
    
    @IBOutlet weak var searchQueryTextField: UITextField! {
        didSet {
            searchQueryTextField.delegate = self
            searchQueryTextField.text = searchText
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        searchQueryTextField.becomeFirstResponder()
    }
    
    private static let REUSE_IDENTIFIER = "tweetCell"
    
    var searchText: String? {
        didSet {
            lastSuccessfulRequest = nil
            searchQueryTextField?.text = searchText
            tweets.removeAll()
            tableView.reloadData()
            refresh()
        }
    }
    
    private lazy var tweets = [[Tweet]]()

    private var lastSuccessfulRequest: TwitterRequest?
    
    private var nextRequestToAttempt: TwitterRequest? {
        if lastSuccessfulRequest == nil {
            if searchText != nil {
                return TwitterRequest(search: searchText!, count: 100)
            } else {
                return nil
            }
        } else {
            return lastSuccessfulRequest!.requestForNewer
        }
    }
    
    @IBAction func refresh(sender: UIRefreshControl?) {
        if let request = nextRequestToAttempt {
            request.fetchTweets { (newTweets) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if newTweets.count > 0 {
                        self.lastSuccessfulRequest = request
                        self.tweets.insert(newTweets, atIndex: 0)
                        self.tableView.reloadData()
                    }
                    sender?.endRefreshing()
                }
            }
        } else {
            sender?.endRefreshing()
        }
    }
    
    private func refresh() {
        refreshControl?.beginRefreshing()
        refresh(refreshControl)
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("Before getting the cell by its identifier!")
        let cell = tableView.dequeueReusableCellWithIdentifier(TweetTableViewController.REUSE_IDENTIFIER, forIndexPath: indexPath) as! TweetTableViewCell
        print("In TweetTableViewController sets the tweet to handle!")
        cell.tweet = self.tweets[indexPath.section][indexPath.row]
        
        return cell
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchText = textField.text
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cellClicked = tableView.cellForRowAtIndexPath(indexPath) as! TweetTableViewCell
        
        performSegueWithIdentifier(TweetTableViewController.DETAIL_SEGUE_IDENTIFIER, sender: cellClicked)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == TweetTableViewController.DETAIL_SEGUE_IDENTIFIER {
            let cellClicked = sender as! TweetTableViewCell
            let tweetToShow = cellClicked.tweet
            
            if let singleTweetController = segue.destinationViewController as? SingleTweetTableViewController {     //This calls the "awakeFromNib" for the controller
                if tweetToShow != nil {
                    print("Setting the tweet for the cell selected!")
                    singleTweetController.tweet = tweetToShow
                    singleTweetController.title = tweetToShow!.user.name
                }
            }
        }
    }
}