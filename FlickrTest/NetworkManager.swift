//
//  NetworkManager.swift
//  FlickrTest
//
//  Created by Alex Voronov on 10.11.18.
//  Copyright © 2018 Alex Voronov. All rights reserved.
//

import Foundation
import FlickrKit


class NetworkManager: NSObject {
    
    override init() {
        FlickrKit.shared().initialize(withAPIKey: self.apiKey, sharedSecret: self.sharedSecret)
    }
    
    let apiKey = "4b9733574084508c9e677b71a094f4ae"
    let sharedSecret = "6b925c605b8a67cf"
    let entityFKFlickrPhotosSearch = FKFlickrPhotosSearch()
    let flickrInteresting = FKFlickrInterestingnessGetList()
    
    // KVO tabBarController
    dynamic var errorMessage: String?
    dynamic var photos: [Photo] = []
    
//    func setFlickr() {
//        self.setFlickrInteresting()
//        self.setFlickrSearch()
//    }
//    
//    func setFlickrInteresting() {
//        self.flickrInteresting.per_page = "2"
//        self.flickrInteresting.page = "1"
//    }
//    
//    func setFlickrSearch() {
//        self.entityFKFlickrPhotosSearch.lon = "-73.935242"
//        self.entityFKFlickrPhotosSearch.lat = "40.730610"
//        self.entityFKFlickrPhotosSearch.radius = "31.0"
//        self.entityFKFlickrPhotosSearch.per_page = "3"
//        self.entityFKFlickrPhotosSearch.text = "Taxi"
//    }
    
    
    func updateDataForKeywordSearch(for text: String, pageSize: Int, pageNumber: Int) {
        
        guard
            text != "",
            pageSize >= 0,
            pageNumber >= 0 else { return }
        
        self.entityFKFlickrPhotosSearch.text = text
        self.entityFKFlickrPhotosSearch.per_page = "\(pageSize)"
        self.entityFKFlickrPhotosSearch.page = "\(pageNumber)"
        
        //self.flickrInteresting.per_page = "\(pageSize)"
        //self.flickrInteresting.page = "\(pageNumber)"
        
        self.updatePhotoData()
    }
    
    
    func updateDataForLocationSearch(lat: String?, lon: String?, radius: Int, pageSize: Int, pageNumber: Int) {
        guard
            pageSize >= 0,
            pageNumber >= 0 else { return }
        
        self.entityFKFlickrPhotosSearch.lon = lon
        self.entityFKFlickrPhotosSearch.lat = lat
        self.entityFKFlickrPhotosSearch.radius = "\(radius)"
        self.entityFKFlickrPhotosSearch.per_page = "\(pageSize)"
        self.entityFKFlickrPhotosSearch.page = "\(pageNumber)"
        
        self.updatePhotoData()
    }
    
    func updatePhotoData() {
        
        //self.setFlickr()
        
        FlickrKit.shared().call(self.entityFKFlickrPhotosSearch) { (response, error) -> Void in
            
            // TODO: implement throws
            self.errorMessage = error?.localizedDescription
            
            DispatchQueue.main.async(execute: { () -> Void in
                
                var photos: [Photo] = []
                
                guard
                    let response = response,
                    let topPhotos = response["photos"] as? [AnyHashable : Any],
                    let photoArray = topPhotos["photo"] as? [[AnyHashable: Any]] else { return }
                
                var i = 0
                
                for photoDictionary in photoArray {
                    let photoURL = FlickrKit.shared().photoURL(for: FKPhotoSize.small240, fromPhotoDictionary: photoDictionary)
                    let photoInfo = FlickrKit.shared().photoArray(fromResponse: response)
                    let photoName = photoInfo?[i]["title"] as? String
                    
                    i += 1
                    
                    let newPhoto = Photo(name: photoName, url: photoURL)
                    photos.append(newPhoto)
                }
                
                // update data in case smth has been changed
                if self.areDifferent(array1: self.photos, array2: photos) {
                    // TODO: finish pagination
                    self.photos = photos
                }
            })
        }
    }
}

private extension NetworkManager {
    func areDifferent(array1: [Photo], array2: [Photo]) -> Bool {
        
        if array1.count == array2.count {
            var i = 0
            for photo in array1 {
                if photo.url != array2[i].url {
                    return true
                }
                i += 1
            }
        } else {
            return true
        }
        
        return false
    }
}
