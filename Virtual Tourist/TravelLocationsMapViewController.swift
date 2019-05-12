//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Baraa Hesham on 5/12/19.
//  Copyright © 2019 Baraa Hesham. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var dataController : DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print(view.annotation?.coordinate)
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
    
    
    @IBAction func onMapLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UILongPressGestureRecognizer.State.began{
            let location = sender.location(in: self.mapView)
            
            let coordinates = self.mapView.convert(location, toCoordinateFrom: self.mapView)
            
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            
            self.mapView.addAnnotation(annotation)
        }
        
    }
}

