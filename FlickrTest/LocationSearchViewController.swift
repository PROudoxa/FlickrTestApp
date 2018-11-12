//
//  LocationSearchViewController.swift
//  FlickrTest
//
//  Created by Alex Voronov on 12.11.18.
//  Copyright © 2018 Alex Voronov. All rights reserved.
//

import UIKit
import CoreLocation

class LocationSearchViewController: UIViewController {

    let locationManager = CLLocationManager()
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var networkManager = NetworkManager()
    var photos: [Photo] = []
    var pageSize = 50
    var page = 1
    
    var radius: Int {
        get {
            return Int(self.slider.value)
        }
    }
    
    
    // MARK: @IBOutlets
    @IBOutlet weak var labelRadius: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupLocationManager()
        
        self.collectionView.register(UINib(nibName: PhotoCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: PhotoCollectionViewCell.reuseCellIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // TODO: implement cache
        
        self.addObservers()
        
        // TODO: consider put it to background thread
        
        self.searchButtonTapped(nil)
        //self.networkManager.updateDataForLocationSearch(lat: "\(self.latitude)", lon: "\(self.longitude)", radius: 31, pageSize: 4, pageNumber: 2)
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
            self.collectionView.reloadData()
        } else if keyPath == #keyPath(networkManager.errorMessage) {
            //print(networkManager.errorMessage ?? "No error")
            // TODO: implement handling error
        }
    }
    
    deinit {
        self.removeObservers()
    }
}

    // MARK: @IBActions

extension LocationSearchViewController {
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        // TODO: move to observer
        self.labelRadius.text = "radius \(self.radius) km"
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton?) {
        self.networkManager.updateDataForLocationSearch(lat: "\(self.latitude)", lon: "\(self.longitude)", radius: self.radius, pageSize: self.pageSize, pageNumber: 1)
        self.page = 1
    }
}


// MARK: Private funcs

private extension LocationSearchViewController {
    
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

extension LocationSearchViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
        
        let orientation = UIApplication.shared.statusBarOrientation
        
        switch orientation {
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
            self.networkManager.updateDataForLocationSearch(lat: "\(self.latitude)", lon: "\(self.longitude)", radius: self.radius, pageSize: self.pageSize, pageNumber: self.page + 1)
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

    // MARK: CLLocation delagate

extension LocationSearchViewController: CLLocationManagerDelegate {
    
    func setupLocationManager() {
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.latitude = locValue.latitude
        self.longitude = locValue.longitude
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
}
