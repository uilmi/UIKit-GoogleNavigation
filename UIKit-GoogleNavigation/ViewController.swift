//
//  ViewController.swift
//  UIKit-GoogleNavigation
//
//  Created by Ulul I. on 02/11/22.
//

import UIKit
import GoogleMaps
import CoreLocation

class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var lblDistances: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawGoogleApiDirection()
    }
    
    func drawGoogleApiDirection() {
        
        let origin = "\(24.871941),\(66.988660)"
        let destination = "\(24.885950),\(67.026744)"
        
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destionation=\(destination)&mode=transit&key=\(googleApiKey)"
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("Error!")
                
            } else {
                
                DispatchQueue.main.async {
                    self.mapView.clear()
                    self.addSourceDestionationMarkers()
                }
                
                do {
                    let json = try JSONSerialization.jsonObject (with: data!, options:.allowFragments) as! [String : AnyObject]
                    let routes = json["routes"] as! NSArray
                    //self.mapView.clear()
                    self.getTotalDistance()
                    
                    OperationQueue.main.addOperation({
                        for route in routes {
                            let routeOverviewPolyline:NSDictionary = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
                            
                            let points = routeOverviewPolyline.object(forKey: "points")
                            let path = GMSPath.init(fromEncodedPath: points! as! String)
                            let polyline = GMSPolyline.init (path: path)
                            polyline.strokeWidth = 3
                            polyline.strokeColor = UIColor(red: 50/255, green: 165/255, blue: 102/255, alpha: 1.0)
                            let bounds = GMSCoordinateBounds(path: path!)
                            self.mapView!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
                            
                            polyline.map = self.mapView
                        }
                    })
                } catch let error as NSError {
                    print("error: \(error)")
                }
            }
        }).resume()
    }
    
    
    func addSourceDestionationMarkers() {
        
        let markerSource = GMSMarker()
        markerSource.position = CLLocationCoordinate2D(latitude: 24.871941, longitude: 66.988060)
        markerSource.icon = UIImage(named: "markera")
        markerSource.title = "Point A"
        markerSource.map = mapView
        
        let markerDestionation = GMSMarker()
        markerDestionation.position = CLLocationCoordinate2D(latitude: 24.885950, longitude: 67.0226744)
        markerDestionation.icon = UIImage(named: "markerb")
        markerDestionation.title = "Point B"
        markerDestionation.map = mapView
        
        
    }
    
    func getTotalDistance(){

        
        let origin = "\(-6.209675277806892),\(106.85025771231817)"
        let destination = "\(-6.209675277806892),\(106.85025771231817)"


        let urlString = "https://maps.googleapis.com/maps/api/distancematrix/json?origin=\(origin)&destionation=\(destination)&units=metricmode&mode=transit&language=en-EN&sensor=false&key=\(googleApiKey)"
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("Error!")
                
            } else {
                
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    let rows = json["rows"] as! NSArray
                    print(rows)
                    
                    let dic = rows[0] as! Dictionary<String, Any>
                    let elements = dic["elements"] as! NSArray
                    let dis = elements[0] as! Dictionary<String, Any>
                    let distanceKm = dis["disatance"] as! Dictionary<String, Any>
                    let km = distanceKm["text"]! as! String
                    
                    let timeRide = dis["duration"] as! Dictionary<String, Any>
                    let finalTime = timeRide["text"]! as! String
                    
                    DispatchQueue.main.async {
                        self.lblDistances.text = "Total Distance = \(km)"//.replacingOccurrences(of: " km", with: "")
                        self.lblTime.text = "Time = \(finalTime)"
                        print("\(String(describing: self.lblDistances.text))")
                    }
                    
                    
                    
                    
                    
                } catch let error as NSError {
                    print("error: \(error)")
                }
            }
        }).resume()
        
    }


}

