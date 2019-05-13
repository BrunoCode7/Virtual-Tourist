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
    var photos:photos
}
struct photos : Codable{
    var photo:[photosUrl]
}
struct photosUrl :Codable{
    var url_m:String
}

class FlickerClient{
    
    static func getPhotosForLocaion(coordinates: CLLocationCoordinate2D, completionHandler:@escaping (_ photoData:Photo?, _ error:Error?)->Void){
        
        let photosUrl = URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=827690026b30bbc71adf95e7da741116&lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&format=json&nojsoncallback=1&extras=url_m")!
        
        let task = URLSession.shared.dataTask(with: photosUrl) { (data, response, error) in
            
            if error == nil{
                do{
                    let photosUrlSession = try JSONDecoder().decode(resoponseObejct.self, from: data!)
                    print(photosUrlSession.photos.photo[0].url_m)
                    
                }catch{
                    print(error.localizedDescription)
                }
            }
            
        }
        task.resume()
        
    }
}
