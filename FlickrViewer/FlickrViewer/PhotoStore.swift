//
//  PhotoStore.swift
//  FlickrViewer
//
//  Created by Farhoud on 2020-03-27.
//  Copyright © 2020 Farhoud Talebi. All rights reserved.
//

import UIKit

enum ImageResult {
    case success(UIImage)
    case failure(Error)
}

enum PhotoError: Error {
    case imageCreationError
}

class PhotoStore {
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    func fetchRecentPhotos(completion: @escaping (PhotoResult) -> Void){
        let url = FlickrAPI.recentPhotosURL()
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
//            if let jsonData = data {
////                if let jsonString = String(data: jsonData, encoding: .utf8){
////                    print(jsonString)
////                }
//                do {
//                    let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
//                    print(jsonObject)
//                }
//                catch let error {
//                    print("Error parsing JSON data string: \(error)")
//                }
//
//            } else if let requestError = error {
//                print("ERROR: fetching recent photos: \(requestError)")
//            } else {
//                print("ERROR: unexpected error with request")
//            }
            let result = self.processRecentPhotosRequest(data: data, error: error)
            completion(result)
        }
        task.resume()
    }
    
    func processRecentPhotosRequest(data: Data?, error: Error?) -> PhotoResult {
        guard let jsonData = data
        else {
            return .failure(error!)
        }
        return FlickrAPI.photos(fromJSON: jsonData)
    }
    
    func fetchImage(for photo: Photo, completion: @escaping (ImageResult)->Void) {
        let photoURL = photo.remoteURL
        let request = URLRequest(url: photoURL)
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            let result = self.processImageRequest(data: data, error: error)
            
            if case let .success(image) = result {
                photo.image = image
            }
            completion(result)
        }
        task.resume()
    }
    
    private func processImageRequest(data: Data?, error: Error?) -> ImageResult {
        guard let imageData = data, let image = UIImage(data: imageData)
        else {
            //couldnt create image
            if data == nil { return .failure(error!) }
            else { return .failure(PhotoError.imageCreationError) }
        }
        return .success(image)
    }
    
}
