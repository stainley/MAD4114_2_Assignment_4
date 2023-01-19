//
//  ViewController.swift
//  MAD4114_assign_4
//
//  Created by Stainley A Lebron R on 2023-01-15.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    
    var locationManager = CLLocationManager()
    var places: [Place] = []
    //var annotations: [MKAnnotation] = [MKAnnotation]()
    var numberTap: Int = 0
    var numbersOfAnnotations: Int = 0
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        map.isZoomEnabled = false
        map.showsUserLocation = false
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //let latitude: CLLocationDegrees = 43.64312520699445
        //let longitude: CLLocationDegrees = -79.38692805397866
        
        let oneTapPress = UITapGestureRecognizer(target: self, action: #selector(addOneTapAnnotation))
        oneTapPress.delaysTouchesBegan = true
        map.addGestureRecognizer(oneTapPress)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(removeAnnotation))
        longPress.delaysTouchesBegan = true
        //longPress.numberOfTapsRequired = 2
        map.addGestureRecognizer(longPress)
        
        map.delegate = self
                        
    }
    
    @IBAction func drawRoute(sender: UIButton) {
        map.removeOverlays(map.overlays)
        
        var nextIndex = 0
        for index in 0 ... 2{
            if index == 2 {
                nextIndex = 0
            } else {
                nextIndex = index + 1
            }
            
            let source = MKPlacemark(coordinate: map.annotations[index].coordinate)
            let destination = MKPlacemark(coordinate: map.annotations[nextIndex].coordinate)
            
            let directionRequest = MKDirections.Request()
            
            directionRequest.source = MKMapItem(placemark: source)
            directionRequest.destination = MKMapItem(placemark: destination)
            
            directionRequest.transportType = .automobile
            
            let directions = MKDirections(request: directionRequest)
            directions.calculate(completionHandler: { (response, error) in
                guard let directionResponse = response else {
                    return
                }
                
                let route = directionResponse.routes[0]
                self.map.addOverlay(route.polyline, level: .aboveRoads)
                
                let rect = route.polyline.boundingMapRect
                self.map.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
            })
        }
        
    }

    //MARK: show updating location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        displayLocation(latitude: latitude, longitude: longitude)
    }

    //MARK: Display my current location
    func displayLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        
        let latitudeDelta: CLLocationDegrees = 0.7
        let longitudeDelta: CLLocationDegrees = 0.7
        
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, span: span)
        
        map.setRegion(region, animated: true)
    }
    
    //MARK: Add Polyne
    func addPolyline() {
        //self.places.append(places[0])
        
        //let locations = places.map { $0.coordinate }
        //let locations = map.annotations.map( { $0.coordinate; $0.title})
        var myAnnotations: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        for (index, anno) in map.annotations.enumerated() {
            /*
            if anno.title == "My Location" {
                continue
            }
            */
            myAnnotations.append(anno.coordinate)
        }
        myAnnotations.append(myAnnotations[0])
        
        let polyline = MKPolyline(coordinates: myAnnotations, count: myAnnotations.count)
        polyline.title = "DONE"
        map.addOverlay(polyline, level: .aboveRoads)
        
        
        var nextIndex = 0
        for index in 0 ... 2{
            if index == 2 {
                nextIndex = 0
            } else {
                nextIndex = index + 1
            }
            print(map.annotations.count)
            
            
            
            let distance: Double = getDistance(from: map.annotations[index].coordinate, to:  map.annotations[nextIndex].coordinate)
            
            //print("\(Double( round(distance * 0.001))) Km")
            //polyline.title = "\(distance) Km"
            
            let distanceAnnotation = MKPointAnnotation()
            

            //let midPointLat = (map.annotations[index].coordinate.latitude - map.annotations[nextIndex].coordinate.latitude) / 2
            //let midPointLong = (map.annotations[index].coordinate.longitude - map.annotations[nextIndex].coordinate.longitude) / 2
      
        
            //distanceAnnotation.coordinate = CLLocationCoordinate2DMake(midPointLat, midPointLong)
            //var place = Place(coordinate: distanceAnnotation.coordinate)
            //place.title = "\(Double( round(distance * 0.001))) Km"
            //map.addAnnotation(place)
            
            distanceMarket(distance: distance, polyline: polyline)
            
        }
        
      
    }
    
    private func distanceMarket(distance: Double, polyline: MKPolyline) {
        
        let pin = MKPointAnnotation()
        pin.title = "distance"
        
        let point: CGPoint = map.convert(polyline.coordinate, toPointTo: map)
        
        pin.coordinate = map.convert(point, toCoordinateFrom: map)
        
        //var place = Place(coordinate: polyline.coordinate)
        //place.title = "\(Double( round(distance * 0.001))) Km)"
        //map.addAnnotation(pin)
        print(pin.coordinate)
        print("\(round(distance)) ms")
    }
    
    
    @objc func removeAnnotation(point: UITapGestureRecognizer) {
        print("\(map.annotations.count) NUMBERS OF ANNOTATIONS")

        var isRemoved: Bool = false

        let pointTouched: CGPoint = point.location(in: map)
        
        let coord =  map.convert(pointTouched, toCoordinateFrom: map)
        let loc: CLLocationCoordinate2D = coord
        
        //let myAnnotationTitle = map.annotations.map({$0.title})
          
        // from coordinate get city name
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: loc.latitude, longitude: loc.longitude), completionHandler: { (placemarks, error) in
            if error != nil {
                print(error)
            } else {
                DispatchQueue.main.async {
                    if let placeMark = placemarks?[0] {
                        
                        if placeMark.locality != nil {
                            
                            for (index, myAnnotation) in self.map.annotations.enumerated() {
                                
                                if myAnnotation.title == placeMark.locality {
                                    isRemoved = true
                                    self.removeOverlays()
                                    self.map.removeAnnotation(myAnnotation)

                                }
                            }
                        }
                        print("\(self.map.annotations.count) NUMBERS OF ANNOTATIONS")

                    }
                }
            }
            
        })
        //let areaSelection = MKCircle(center: coord, radius: 10)
            
        /*
        let selectedAnnotation: [MKAnnotation] = map.selectedAnnotations
        
        for ann in selectedAnnotation {
            
            for allAnnotation in map.annotations {
                if ann.title == allAnnotation.title {
                    print("\(String(describing: ann.title!)) TITLE")
                    
                    
                    for (index, place) in places.enumerated() {
                        if place.title! == ann.title! {
                            print("\(String(describing: place.title))  and \(String(describing: ann.title) )")
                            print("\(place)  and \(index)")
                            places.remove(at: index)
                            print("\(places.count) NEW ARRAY CAPACITY")
                            break
                        }
                    }
                }
            }
            //places.removeFirst()
            print("\(String(describing: ann.title!))  -> REMOVE THIS")
            
            removeOverlays()
            map.removeAnnotation(ann)
        }
        */
    }
    
    func removeOverlays() {
        for polygon in map.overlays {
            map.removeOverlay(polygon)
        }
    }
    
    func addPolygon() {
        //let coordinates = places.map { $0.coordinate }
        
        //let coordinates = map.annotations.map( { $0.coordinate })
        
        //let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
       
        var myAnnotations: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        if map.annotations is MKAnnotation {
            
        }
        for (index, anno) in map.annotations.enumerated() {
            if anno.title == "My Location" {
                continue
            }
            myAnnotations.append(anno.coordinate)
        }
        myAnnotations.append(myAnnotations[0])
        let polygon = MKPolygon(coordinates: myAnnotations, count: myAnnotations.count)
        
        map.addOverlay(polygon)
    }
    
    func removePin() {
        for annotation in map.annotations {

            map.removeAnnotation(annotation)
        }
    }
    
    //MARK: Add MKPoint Annotation to the map
    @objc func addOneTapAnnotation(gestureRecognizer: UIGestureRecognizer) {
        
        numbersOfAnnotations = map.annotations.count
        
        let touchPoint = gestureRecognizer.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
        
        let geoCoder = CLGeocoder()
               
        geoCoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), completionHandler: {(placemarks, error) in
            
            if error != nil {
                print(error!)
            } else {
                DispatchQueue.main.async {
                    if let placeMark = placemarks?[0] {
                        
                        if placeMark.locality != nil {
                            print(placeMark.locality!)
                            let place = Place(title: placeMark.locality!,coordinate: coordinate)

                            if self.numbersOfAnnotations <= 2 {
                                self.map.addAnnotation(place)
                                                         
                            }
                            
                            if self.numbersOfAnnotations == 2 {
                                self.addPolyline()
                                self.addPolygon()
                            }
                        }
                    }
                }
            }
        })
      
    }
}

func getDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
    let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
    let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
    
    return from.distance(from: to)
}


extension ViewController: CLLocationManagerDelegate {
    
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        switch annotation.title {
            case "distance":
            let annotationView = map.dequeueReusableAnnotationView(withIdentifier: "customPin") ?? MKMarkerAnnotationView()
                annotationView.image = UIImage(systemName: "trash")
              
                return annotationView
            default:
                return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

       
        if overlay is MKPolyline {
            
            print(overlay.title!!)
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.polyline.title = overlay.title ?? ""
            renderer.polyline.subtitle = overlay.title ?? ""
            renderer.strokeColor = .green
            renderer.lineWidth = 5
            return renderer
        } else if overlay is MKPolygon {
            let renderer = MKPolygonRenderer(overlay: overlay)
            renderer.fillColor = .red.withAlphaComponent(0.5)
            renderer.polygon.title = overlay.title ?? ""
            return renderer
            
        } else if overlay is MKPointAnnotation {
            
        }
        return MKOverlayRenderer()
    }
    
}
