//
//  SingleTweetTableViewController.swift
//  Smashtag
//
//  Created by Diablo on 15/12/15.
//  Copyright © 2015 Diablo. All rights reserved.
//

import UIKit

class SingleTweetTableViewController: UITableViewController {
    
    private enum Component {
        case Media(MediaItem)
        case Text(Tweet.IndexedKeyword)
        
        var stringType: String {
            get {
                switch self {
                case .Media(_):
                    return "Media"
                case .Text(let word):
                    let firstChar = word.keyword[word.keyword.startIndex]
                    switch firstChar {
                    case "#":
                        return "Hashtag"
                    case "@":
                        return "Mention"
                    case "h":
                        return "URL"
                    default:
                        return ""
                    }
                }
            }
        }
    }
    
    private struct Constants {
        private static let CELL_IDENTIFIERS = ["Media" : "Image Cell", "Hashtag" : "Text Cell", "Mention": "Text Cell", "URL" : "Text Cell"]
        private static let IMAGE_SEGUE_IDENTIFIER = "Show image"
        private struct SECTION_HEADERS {
            private static let IMAGES = "Images"
            private static let MENTIONS = "Users mentioned"
            private static let URLS = "URLs"
            private static let HASHTAGS = "Hashtags"
        }
    }

    private var tableShown = false
    
    private var tweetComponents: [[Component]] = [[Component]]()
    
    var tweet: Tweet? {
        didSet {
            updateModel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !tableShown {
            tableView.reloadData()
        }
    }
    
    private func updateModel() {
        var counter = 0
        if tweet?.media.count > 0 {
            tweetComponents.append([Component]())
            for media in tweet!.media {
                tweetComponents[counter].append(Component.Media(media))
            }
            counter++
        }
        if tweet?.hashtags.count > 0 {
            tweetComponents.append([Component]())
            for hashtag in tweet!.hashtags {
                tweetComponents[counter].append(Component.Text(hashtag))
            }
            counter++
        }
        if tweet?.userMentions.count > 0 {
            tweetComponents.append([Component]())
            for mention in tweet!.userMentions {
                tweetComponents[counter].append(Component.Text(mention))
            }
            counter++
        }
        if tweet?.urls.count > 0 {
            tweetComponents.append([Component]())
            for url in tweet!.urls {
                tweetComponents[counter].append(Component.Text(url))
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweetComponents.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetComponents[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let component = tweetComponents[indexPath.section][indexPath.row]
        let identifier = Constants.CELL_IDENTIFIERS[component.stringType]
        
        return cellForIdentifier(identifier!, andComponent: component, atIndexPath: indexPath)
    }
    
    private func cellForIdentifier(identifier: String, andComponent component:Component, atIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch component {
        case .Media(let media):
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! SingleTweetImageTableViewCell
            let url = media.url
            let imageData = NSData(contentsOfURL: url)
            cell.elementToDisplay = imageData != nil ? (UIImage(data: imageData!)!, media.aspectRatio) : nil
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            return cell
        case .Text(let content):
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! SingleTweetDefaultTableViewCell
            cell.contentLabel.text = content.keyword
            return cell
        }
    }
    
    /*
    private func conditionalReloadRowsAtIndexPaths(indexPath: [NSIndexPath], withRowAnimation rowAnimation: UITableViewRowAnimation, condition: Bool) {
        if condition {
            print("########################################YEE########################################")
            self.tableView.reloadRowsAtIndexPaths(indexPath, withRowAnimation: rowAnimation)
        }
    }*/
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let firstElementOfSection = tweetComponents[section][0]
        switch firstElementOfSection.stringType {
        case "Media":
            return Constants.SECTION_HEADERS.IMAGES
        case "Hashtag":
            return Constants.SECTION_HEADERS.HASHTAGS
        case "URL":
            return Constants.SECTION_HEADERS.URLS
        case "Mention":
            return Constants.SECTION_HEADERS.MENTIONS
        default:
            return firstElementOfSection.stringType
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let component = tweetComponents[indexPath.section][indexPath.row]
        switch component.stringType {
        case "Media":
            performSegueWithIdentifier(Constants.IMAGE_SEGUE_IDENTIFIER, sender: tableView.cellForRowAtIndexPath(indexPath))
        case "Hashtag", "Mention":
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! SingleTweetDefaultTableViewCell
            if let navController = navigationController {
                if let mainController = navController.viewControllers[0] as? TweetTableViewController {
                mainController.searchText = cell.contentLabel.text
                navController.popToRootViewControllerAnimated(true)
                }
            }
        case "URL":
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! SingleTweetDefaultTableViewCell
            UIApplication.sharedApplication().openURL(NSURL(string: cell.contentLabel.text!)!)
            cell.highlighted = false
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.IMAGE_SEGUE_IDENTIFIER {
            print("Hello!")
        }
    }
}