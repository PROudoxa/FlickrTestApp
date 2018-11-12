//
//  DetailViewController.swift
//  FlickrTest
//
//  Created by Alex Voronov on 11.11.18.
//  Copyright © 2018 Alex Voronov. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var name: String?
    var image = UIImage()
    
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.labelTitle.text = name ?? ""
        self.imageView.image = self.image
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.viewWillLayoutSubviews()
    }
    
    // MARK: Zoom
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.centerScrollViewContent()
    }
    
    private func centerScrollViewContent() {
        let boundsSize = self.scrollView.bounds.size
        var contentsFrame = self.imageView.frame
        
        // FIXME: fix bug with centering image after zooming
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2
        } else {
            contentsFrame.origin.x = 0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2
        } else {
            contentsFrame.origin.y = 0
        }
        
        self.imageView.frame = contentsFrame
    }
}
