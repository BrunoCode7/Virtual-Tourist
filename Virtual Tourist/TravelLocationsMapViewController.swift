//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Baraa Hesham on 5/12/19.
//  Copyright © 2019 Baraa Hesham. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var dataController : DataController!
    var gcoordinates = CLLocationCoordinate2D()
    var gAnnotations = [MKPointAnnotation]()
    var gPin:Pin!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        gAnnotations=getFetchedAnnotations()
        mapView.addAnnotations(gAnnotations)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print(view.annotation?.coordinate)
        gcoordinates = (view.annotation?.coordinate)!
        gPin = testFetch(latitude: (view.annotation?.coordinate.latitude)!)
        self.performSegue(withIdentifier: "showAlbum", sender: self)
        mapView.deselectAnnotation(view.annotation, animated: true)
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
    
    
    private func getFetchedAnnotations() -> [MKPointAnnotation]{
        var annotations = [MKPointAnnotation]()
        let fetchedRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchedRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchedRequest) {
            print(result.debugDescription)
            for pinL in result{
                let annotation = MKPointAnnotation()
                annotation.coordinate.latitude = pinL.latitude
                annotation.coordinate.longitude = pinL.longitude
                annotations.append(annotation)
            }
        }
        return annotations
    }
    
    private func addAnnotation(coordinates: CLLocationCoordinate2D){
        let pin = Pin(context: dataController.viewContext)
        pin.creationDate = Date()
        pin.latitude = coordinates.latitude
        pin.longitude = coordinates.longitude
        try? dataController.viewContext.save()
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = pin.latitude
        annotation.coordinate.longitude = pin.longitude
        gAnnotations.insert(annotation, at: 0)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAlbum"{
            let photoAlbumeController = segue.destination as! PhotoAlbumViewController
            photoAlbumeController.chosencoordinates = gcoordinates
            photoAlbumeController.dataController = dataController
            photoAlbumeController.pin = gPin
        }
    }
    
    @IBAction func onMapLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UILongPressGestureRecognizer.State.began{
            let location = sender.location(in: self.mapView)
            
            let coordinates = self.mapView.convert(location, toCoordinateFrom: self.mapView)
            
            addAnnotation(coordinates: coordinates)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            
            self.mapView.addAnnotation(annotation)
        }
        
    }
    
    private func testFetch(latitude:Double)-> Pin?{
        let fetchrequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let lat = NSNumber.init(value: latitude)
        let predicate = NSPredicate(format: "latitude == %@", lat)
        fetchrequest.predicate = predicate

        guard let results = try? dataController.viewContext.fetch(fetchrequest) else{
                        print("the result is nil")
            return nil

        }
        if results.count > 0 {
            return results[0]
        }else{
            print("empty result array")
            return nil
        }
        
    }
}

