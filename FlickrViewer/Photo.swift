//
//  Photo.swift
//  FlickrViewer
//
//  Created by Farhoud on 2020-03-27.
//  Copyright © 2020 Farhoud Talebi. All rights reserved.
//

import UIKit

class Photo {
    let title: String
    let remoteURL: URL
    let photoID: String
    let dateTaken: Date
    var image: UIImage?
    
    init(title: String, photoID: String, remoteURL: URL, dateTaken: Date) {
        self.title = title
        self.photoID = photoID
        self.remoteURL = remoteURL
        self.dateTaken = dateTaken
    }
}
