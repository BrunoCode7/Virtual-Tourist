//
//  FlickerClient.swift
//  Virtual Tourist
//
//  Created by Baraa Hesham on 5/13/19.
//  Copyright © 2019 Baraa Hesham. All rights reserved.
//

import Foundation
import MapKit

struct resoponseObejct : Codable{
    var photos:photos?
}
struct photos : Codable{
    var photo:[photosUrl]?
}
struct photosUrl :Codable{
    var url_m:String
}

class FlickerClient{
    
    static func getPhotosArrayFromLocation(coordinates: CLLocationCoordinate2D, completionHandler:@escaping (_ photosUrlArray:[photosUrl]?)->Void){
        let randomPage = Int.random(in: 1...10)
        let photosUrl = URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=827690026b30bbc71adf95e7da741116&lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&per_page=20&page=\(randomPage)&format=json&nojsoncallback=1&extras=url_m")!
        
        let task = URLSession.shared.dataTask(with: photosUrl) { (data, response, error) in
            
            if let urlsData = data {
                do{
                    let photosUrlSession = try JSONDecoder().decode(resoponseObejct.self, from: urlsData)
                    
                    guard let photosUrlArray = photosUrlSession.photos!.photo else {
                        completionHandler(nil)
                        return
                    }
                    completionHandler(photosUrlArray)
                }catch{
                    print(error.localizedDescription)
                }
            }
            
        }
        task.resume()
        
    }
    
    static func getImageFromUrl(photoUrlString:String, completionHandler:(_ image:UIImage?) -> Void){
        let photoUrl = URL(string: photoUrlString)!
        var Image = UIImage()
        do {
            Image = UIImage(data: try Data(contentsOf: photoUrl))!
            completionHandler(Image)
        }catch{
            completionHandler(nil)
            print(error.localizedDescription)
        }
    }
}
