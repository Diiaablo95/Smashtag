//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Diablo on 14/12/15.
//  Copyright © 2015 Diablo. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            profileImageView.layer.cornerRadius = profileImageView.bounds.size.height / 2
            profileImageView.clipsToBounds = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    var tweet: Tweet? {
        didSet {
            updateUI()
        }
    }
    
    //Function called via a public variable, this means that it can be called even if the outlets are not set, hence use of "?" is required
    private func updateUI() {
        //Tweet could be nil, since it's optional
        if let tweet = self.tweet {
            //Always put "?" since the function can be called out off the screen, before outlets are set!
            setAttributedText()
            
            if self.postLabel?.text != nil {    //Nil if either postLabel is nil or text is nil
                for _ in tweet.media {
                    self.postLabel.text! += " 📷"
                }
            }
            
            self.nameLabel?.text = "\(tweet.user)" // tweet.user.description
            
            if let profileImageURL = tweet.user.profileImageURL {
                self.loadingSpinner.startAnimating()
                dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.rawValue), 0)) {
                    let imageData = NSData(contentsOfURL: profileImageURL)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.loadingSpinner.stopAnimating()
                        self.profileImageView.image = imageData != nil ? UIImage(data: imageData!) : nil
                    }
                }
            }
            
            let formatter = NSDateFormatter()
            if NSDate().timeIntervalSinceDate(tweet.created) > 24*60*60 {
                formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            } else {
                formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            }
            self.dateLabel?.text = formatter.stringFromDate(tweet.created)
        }
    }
    
    private func setAttributedText() {
        let tweet = self.tweet!
        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: tweet.text)
        
        for hashtag in tweet.hashtags {
            attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor(), range: hashtag.nsrange)
        }
        
        for mention in tweet.userMentions {
            attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.orangeColor(), range: mention.nsrange)
        }
        
        for url in tweet.urls {
            attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.brownColor(), range: url.nsrange)
        }
        
        self.postLabel.attributedText = attrString
    }
}