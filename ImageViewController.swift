//
//  ImageViewController.swift
//  Smashtag
//
//  Created by Diablo on 16/12/15.
//  Copyright © 2015 Diablo. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
        }
    }
    
    private var imageView: UIImageView? {
        didSet {
            updateUI()
            print("imageView set")
        }
    }
    
    var imageToDisplay: UIImage {
        get {
            return (imageView?.image)!
        }
        set {
            print("Image set")
            imageView = UIImageView(image: newValue)
        }
    }
    
    private func updateUI() {
        scrollView?.contentSize = imageView!.bounds.size
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View did load")
        updateUI()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}