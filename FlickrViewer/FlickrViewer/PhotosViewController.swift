//
//  PhotosViewController.swift
//  FlickrViewer
//
//  Created by Farhoud on 2020-03-27.
//  Copyright © 2020 Farhoud Talebi. All rights reserved.
//

import Foundation
import UIKit

class PhotosViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!

    override func viewDidLoad() {
          super.viewDidLoad()
          print("running Fickr Viewer")
          let url = FlickrAPI.recentPhotosURL()
          print("request url:")
          print(url)
          let store = PhotoStore()
           
             store.fetchRecentPhotos() {
                  (photoResult) -> Void in
                  switch photoResult {
                  case let .success(photos):
                      print("Successfully found \(photos.count) recent photos")
                      
                      if let firstPhoto = photos.first {
                        store.fetchImage(for: firstPhoto) {
                              (imageResult) -> Void in
                              switch imageResult  {
                              case let .success(image):
                                 // self.imageView.image = image;
                                OperationQueue.main.addOperation {
                                    self.imageView.image = image
                                }
                              case let .failure(error):
                                  print("ERROR downloading actual image: \(error)")
                              }
                          }
                      }
                  case let .failure(error):
                      print("Error fetching recent photos: \(error)")
                  }
              }
          }
}
