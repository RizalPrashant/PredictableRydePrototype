//
//  ViewController.swift
//  PredictableRydePrototype
//
//  Created by Prashant Rizal on 2/10/19.
//  Copyright © 2019 Prashant Rizal. All rights reserved.
//

import UIKit
import MapKit
import UserNotifications

class customPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(pinTitle: String, pinSubtitle:String, location:CLLocationCoordinate2D){
        self.title = pinTitle
        self.subtitle = pinSubtitle
        self.coordinate = location
    }
}

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //Basic notification content
        
        let content = UNMutableNotificationContent()
        content.title="Local Notification"
        content.body = "It works"
        content.sound = UNNotificationSound.default
        //trigger for notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        //request for notification
        let request = UNNotificationRequest(identifier: "testIdentifier", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        
        let sourceLocation = CLLocationCoordinate2D(latitude: 43.615021, longitude: -116.202316)
        let destinationLocation = CLLocationCoordinate2D(latitude: 43.585320, longitude: -116.573578)
        
        let sourcePin = customPin(pinTitle: "Boise", pinSubtitle: "", location: sourceLocation)
        
        let destinationPin = customPin(pinTitle: "Nampa", pinSubtitle: "", location: destinationLocation)
        self.mapView.addAnnotation(sourcePin)
        self.mapView.addAnnotation(destinationPin)
        
        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation)
        
        let directionRequest = MKDirections.Request()
        
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        
        directionRequest.transportType = .automobile
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResponse = response else{
                if let error = error{
                    print("error getting directions")
                }
                return
            }
            
            let route = directionResponse.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            
        }
        
        self.mapView.delegate = self
    }
    
    //MARK:= MapKit delegates
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        return renderer
    }
}

