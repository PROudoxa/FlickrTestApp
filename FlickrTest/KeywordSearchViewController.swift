//
//  KeywordSearchViewController.swift
//  FlickrTest
//
//  Created by Alex Voronov on 11.11.18.
//  Copyright © 2018 Alex Voronov. All rights reserved.
//

import UIKit


class KeywordSearchViewController: UIViewController {
    
    var networkManager = NetworkManager()
    var photos: [Photo] = []
    let pageSize = 50
    var page = 1
    
    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var search: UISearchBar!
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.viewWillLayoutSubviews()
        
        if self.collectionView != nil {
            self.collectionView.reloadData()
        }
    }
    
    // TODO: consider implementing protocol for using one collectionView in case the collectionView and its sibling from Location are similar to each other
    
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.register(UINib(nibName: PhotoCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: PhotoCollectionViewCell.reuseCellIdentifier)
        
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // TODO: implement cache
        
        self.addObservers()
        
        // TODO: consider put it to background thread
        self.networkManager.updatePhotoData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.removeObservers()
    }
    
    // MARK: KVO: get data
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(networkManager.photos) {
            // check if response has any changes
            self.photos = self.networkManager.photos
            
            // TODO: add empty result label
            
            self.collectionView.reloadData()
        } else if keyPath == #keyPath(networkManager.errorMessage) {
            print(networkManager.errorMessage ?? "No error")
            // TODO: implement handling error
        }
    }
    
    deinit {
        self.removeObservers()
    }
}

// MARK: Private funcs

private extension KeywordSearchViewController {
    
    func addObservers() {
        addObserver(self, forKeyPath: #keyPath(networkManager.photos), options: [.old, .new], context: nil)
        addObserver(self, forKeyPath: #keyPath(networkManager.errorMessage), options: [.old, .new], context: nil)
    }
    
    func removeObservers() {
        removeObserver(self, forKeyPath: #keyPath(networkManager.photos))
        removeObserver(self, forKeyPath: #keyPath(networkManager.errorMessage))
    }
    
    func changeBackButtonTitle(to newTitle: String) {
        let backItem = UIBarButtonItem()
        backItem.title = newTitle
        self.navigationItem.backBarButtonItem = backItem
    }
}

// MARK: CollectionView: dataSource, delegate, flowLayout

extension KeywordSearchViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell: PhotoCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.reuseCellIdentifier, for: indexPath) as? PhotoCollectionViewCell else { return UICollectionViewCell() }
        
        cell.configureCell(for: photos[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        let orient = UIApplication.shared.statusBarOrientation
        
        switch orient {
        case .portrait:
            let width = self.collectionView.frame.width / 3 - 1
            return CGSize(width: width, height: width + 20) // 20 = name label height
            
        case .landscapeLeft,.landscapeRight:
            let height = self.collectionView.frame.height / 3 - 1
            return CGSize(width: height, height: height + 20) // 20 = name label height
            
        default:
            break
        }
        
        let width = self.collectionView.frame.width / 3 - 1
        
        return CGSize(width: width, height: width + 20) // 20 = name label height
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let lastCellVisible: Bool = (indexPath.row == self.photos.count - 1)
        
        if lastCellVisible {
            // TODO: finish implementing pagination
            // FIXME: empty array after empty result call
            guard let text = self.search.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
                
            self.networkManager.updateDataForKeywordSearch(for: text, pageSize: self.pageSize, pageNumber: self.page + 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    // MARK: go to DetailViewController
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard
            let detailCV: DetailViewController = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController,
            let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell,
            let selectedImage = cell.imageView.image else { print("sorry, i can't go to detail..."); return }
        
        detailCV.image = selectedImage
        detailCV.name = self.photos[indexPath.row].name
        
        self.changeBackButtonTitle(to: "Search")
        
        self.navigationController?.pushViewController(detailCV, animated: true)
    }
}

    // MARK: Search delegate

extension KeywordSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), text != "" else { return }
        
        self.networkManager.updateDataForKeywordSearch(for: text, pageSize: self.pageSize, pageNumber: 1)
        searchBar.resignFirstResponder()
    }
}
