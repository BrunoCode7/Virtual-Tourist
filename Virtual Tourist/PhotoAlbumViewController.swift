//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Baraa Hesham on 5/12/19.
//  Copyright © 2019 Baraa Hesham. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController,MKMapViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate{
    
    
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionAlbum: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    var dataController:DataController!
    var chosencoordinates : CLLocationCoordinate2D!
    var pin : Pin!
    private var gPhotosArray = [photosUrl]()
    private var gNumberOfPhotos = Int()
    private var gFetchedPhotos = [Photo]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        collectionAlbum.delegate = self
        collectionAlbum.dataSource = self
        newCollectionButton.isEnabled = false
        addPhotoAnotation(coordinates: chosencoordinates)
        if let fetchedData = fetchPhotos(){
            if fetchedData.count > 0 {
                gNumberOfPhotos = fetchedData.count
                gFetchedPhotos = fetchedData
                self.noImagesLabel.isHidden = true
                newCollectionButton.isEnabled = true
            }else{
                FlickerClient.getPhotosArrayFromLocation(coordinates: chosencoordinates) { (photoData) in
                    if let photoUrlArray = photoData {
                        // do task with the url
                        if photoUrlArray.count > 0{
                            self.gNumberOfPhotos = photoUrlArray.count
                            self.gPhotosArray = photoUrlArray
                            DispatchQueue.main.async {
                                self.noImagesLabel.isHidden = true
                                self.collectionAlbum.reloadData()
                                self.newCollectionButton.isEnabled = true
                            }
                            print(photoUrlArray.count)
                            
                            for photoUrl in self.gPhotosArray{
                                FlickerClient.getImageFromUrl(photoUrlString: photoUrl.url_m) { (image) in
                                    if image != nil{
                                        DispatchQueue.main.async {
                                            self.addPhotoToCoreData(image: image!)
                                        }
                                    }
                                }
                            }
                            

                        }else{
                            DispatchQueue.main.async {
                                self.noImagesLabel.text = "No Images Found"
                            }
                        }
                        
                    }
                }
            }
            
        }
        
        let space:CGFloat = 3.0
        
        let width = (view.frame.size.width - (2 * space)) / 3.0
        let height = (view.frame.size.height - (2 * space)) / 4.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: width, height: height)
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.noImagesLabel.text = "Loading"
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gNumberOfPhotos
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! CollectionViewCell
//        if getDataFrom == "CoreData" {
//            cell.Image.image = UIImage(data: gFetchedPhotos[(indexPath as NSIndexPath).row].photoData!)
//            print("images from core data")
//        }else if getDataFrom == "Internet"{
//            print("images from internet")
//            FlickerClient.getImageFromUrl(photoUrlString: gPhotosArray[(indexPath as NSIndexPath).row].url_m) { (image) in
//                if image != nil{
//                    DispatchQueue.main.async {
//                        cell.Image.image = image
//                    }
//                }
//            }}
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        print(pin.debugDescription)
        let predicate = NSPredicate(format: "pin == %@", pin)
        
        fetchRequest.predicate = predicate
        if let results = try? dataController.viewContext.fetch(fetchRequest) {
            
            if results.count > 0{
                cell.Image.image = UIImage(data: results[(indexPath as NSIndexPath).row].photoData!)
                print("images from core data")
            }else{
                print("images from internet")
                FlickerClient.getImageFromUrl(photoUrlString: gPhotosArray[(indexPath as NSIndexPath).row].url_m) { (image) in
                    if image != nil{
                        DispatchQueue.main.async {
                            cell.Image.image = image
                        }
                    }
                }
            }

        }

    
        return cell
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    private func addPhotoAnotation(coordinates:CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
        annotation.coordinate=coordinates
        let regionRadius: CLLocationDistance = 30000
        let coordinateRegion = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.addAnnotation(annotation)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    private func fetchPhotos() -> [Photo]?{
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        print(pin.debugDescription)
        let predicate = NSPredicate(format: "pin == %@", pin)
        
        fetchRequest.predicate = predicate
        guard let results = try? dataController.viewContext.fetch(fetchRequest) else{
            print("No Photos in the store")
            return nil
        }
        print(results.debugDescription)
        return results
    }
    
    private func addPhotoToCoreData(image:UIImage){
        let photo = Photo(context: dataController.viewContext)
        let imgData = image.jpegData(compressionQuality: 1)
        photo.photoData = imgData
        photo.pin = pin
        do{
            try dataController.viewContext.save()
            print("photo saved to core data")
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        gNumberOfPhotos = gNumberOfPhotos - 1
        collectionView.deleteItems(at: [indexPath])
        gFetchedPhotos.remove(at: indexPath.item)
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        
        fetchRequest.predicate = predicate
        guard let results = try? dataController.viewContext.fetch(fetchRequest) else{
            print("No Photos in the store 12")
            return
        }
        
        dataController.viewContext.delete(results[indexPath.item])
        do{
            try dataController.viewContext.save()
        }catch{
            print(error.localizedDescription)
            print("exception")
        }
    }
    
    
    @IBAction func newCollectionButton(_ sender: Any) {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        
        fetchRequest.predicate = predicate
        guard let results = try? dataController.viewContext.fetch(fetchRequest) else{
            print("No Photos in the store 12")
            return
        }
        
        for photo in results{
            dataController.viewContext.delete(photo)
        }
        do{
            try dataController.viewContext.save()
        }catch{
            print(error.localizedDescription)
            print("exception")
        }
        
        
        FlickerClient.getPhotosArrayFromLocation(coordinates: chosencoordinates) { (photoData) in
            if let photoUrlArray = photoData {
                // do task with the url
                if photoUrlArray.count > 0{
                    self.gNumberOfPhotos = photoUrlArray.count
                    self.gPhotosArray = photoUrlArray
                    DispatchQueue.main.async {
                        self.noImagesLabel.isHidden = true
                        self.collectionAlbum.reloadData()
                        self.newCollectionButton.isEnabled = true
                    }
                    print(photoUrlArray.count)
                    
                    for photoUrl in self.gPhotosArray{
                        FlickerClient.getImageFromUrl(photoUrlString: photoUrl.url_m) { (image) in
                            if image != nil{
                                DispatchQueue.main.async {
                                    self.addPhotoToCoreData(image: image!)
                                }
                            }
                        }
                    }
                    
                    
                }else{
                    DispatchQueue.main.async {
                        self.noImagesLabel.text = "No Images Found"
                    }
                }
                
            }
        }
        
        
    }
}
