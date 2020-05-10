//
//  FlickrAPI.swift
//  FlickrViewer
//
//  Created by Farhoud on 2020-03-27.
//  Copyright © 2020 Farhoud Talebi. All rights reserved.
//

import Foundation

enum Method: String {
    case RecentPhotos = "flickr.photos.getRecent"
}

enum PhotoResult {
    case success([Photo])
    case failure(Error)
}

enum FlickrError: Error {
    case invalidJSONData
}


struct FlickrAPI {
    private static let baseURLString = "https://api.flickr.com/services/rest"
    private static let APIKey = "f9c0354fa5b3162e29045a4b74924f5e" //use our own key
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
       
    private static func flickrURL(method: Method, parameters: [String:String]?) -> URL {
        var components = URLComponents(string: baseURLString)!
        var queryItems = [URLQueryItem]()
            
        if let additionalParams = parameters {
            for(key, value) in additionalParams {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
            
        }
        components.queryItems = queryItems
        return components.url!
    }
    
    
    static func recentPhotosURL()->URL {
           return flickrURL(method: .RecentPhotos, parameters: [
               "method": Method.RecentPhotos.rawValue,
               "format": "json",
               "nojsoncallback": "1",
               "api_key": APIKey,
               "extras": "url_h,date_taken"])
       }
    
    
    static func photos(fromJSON data: Data) -> PhotoResult {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            guard
                let jsonDictionary = jsonObject as? [AnyHashable:Any],
                let photos = jsonDictionary["photos"] as? [String:Any],
                let photosArray = photos["photo"] as? [[String:Any]]
            else {
                return .failure(FlickrError.invalidJSONData)
            }
            var finalPhotos = [Photo]()
            for photoJSON in photosArray {
                if let photo = photo(fromJSON: photoJSON) {
                    finalPhotos.append(photo)
                }
            }
            if finalPhotos.isEmpty && !photosArray.isEmpty {
                //not able to parse, maybe json format changed
                return .failure(FlickrError.invalidJSONData)
            }
            return .success(finalPhotos)
        }
        catch let error {
            return .failure(error)
        }
    }
    
    
    private static func photo(fromJSON json: [String:Any]) -> Photo? {
        guard
            let photoID = json["id"] as? String,
            let title = json["title"] as? String,
            let dateString = json["datetaken"] as? String,
            let photoURLString = json["url_h"] as? String,
            let url = URL(string: photoURLString),
            let dateTaken = dateFormatter.date(from: dateString)
        else {
            return nil
        }
        return Photo(title: title, photoID: photoID, remoteURL: url, dateTaken: dateTaken)
    }
    
}



