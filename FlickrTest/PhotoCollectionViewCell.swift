//
//  PhotoCollectionViewCell.swift
//  FlickrTest
//
//  Created by Alex Voronov on 11.11.18.
//  Copyright © 2018 Alex Voronov. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {    
    
    static let reuseCellIdentifier = "photoCell"
    static let nibName = "PhotoCollectionViewCell"
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.configureViews()
        
        //let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.goToDetailVC))
        //self.imageView.addGestureRecognizer(tap)
        //self.imageView.isUserInteractionEnabled = true
    }
    
    private func configureViews() {
        self.imageView.layer.cornerRadius = 2
        self.layer.cornerRadius = 2
    }
    
    public func configureCell(for photo: Photo) {
        self.labelName.text = photo.name
        self.imageView.downloaded(url: photo.url)
        self.imageView.contentMode = .scaleAspectFill
    }
    
    // TODO: finish segue from cell to detailVC
    
//    @objc private func goToDetailVC() {
//        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        
//        guard
//            let detailCV: DetailViewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController,
//            let selectedImage = self.imageView.image else { print("sorry, i can't go to detail..."); return }
//        
//        detailCV.image = selectedImage
//        detailCV.name = self.labelName.text
//        
//        
//        UINavigationController().pushViewController(detailCV, animated: true)
    
        //self.changeBackButtonTitle(to: "Search")
        
        //self.navigationController?.pushViewController(detailCV, animated: true)
//    }
    
//    private func changeBackButtonTitle(to newTitle: String) {
//        let backItem = UIBarButtonItem()
//        backItem.title = newTitle
//        self.navigationItem.backBarButtonItem = backItem
//    }
}
