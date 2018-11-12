//
//  Photo.swift
//  FlickrTest
//
//  Created by Alex Voronov on 11.11.18.
//  Copyright © 2018 Alex Voronov. All rights reserved.
//

import Foundation


class Photo: NSObject {
    
    init(name: String?, url: URL) {
        self.name = name ?? "Unnamed"
        self.url = url
    }
    
    @objc dynamic var name: String
    @objc dynamic var url: URL

}
