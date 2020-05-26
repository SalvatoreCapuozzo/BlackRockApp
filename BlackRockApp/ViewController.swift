//
//  ViewController.swift
//  BlackRockApp
//
//  Created by Salvatore Capuozzo on 26/05/2020.
//  Copyright © 2020 Salvatore Capuozzo. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps
import GoogleMapsUtils

class ViewController: UIViewController, GMSMapViewDelegate {
    var map: GMSMapView!
    private var heatmapLayer: GMUHeatmapTileLayer!
    private var gradientColors = [UIColor.blue, UIColor.cyan, UIColor.white, UIColor.yellow,  UIColor.red]
    private var gradientStartPoints = [0.2, 0.4, 0.6, 0.8, 1.0] as [NSNumber]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        heatmapLayer = GMUHeatmapTileLayer()
        heatmapLayer.radius = 300
        heatmapLayer.opacity = 0.8
        heatmapLayer.gradient = GMUGradient(colors: gradientColors, startPoints: gradientStartPoints, colorMapSize: 256)
        map = GMSMapView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        
        addHeatmap(from: "GlobalLandTemperaturesByCountry", withExt: "csv")
        heatmapLayer.map = map
        self.view.addSubview(map)
        // Do any additional setup after loading the view.
    }
    
    func addHeatmap(from csvName: String, withExt: String) {
        var data = CSVHandler.readDataFromCSV(fileName: csvName, fileType: withExt)
        data = CSVHandler.cleanRows(file: data!)
        let csvRows = CSVHandler.csv(data: data!)

        var chosenMonth: Dictionary<String,[Double]> = [:]
        for i in 1..<csvRows.count {
            let date = csvRows[i][0]
            if date == "2003-09-01" {
                var floatArray: [Double] = []
                for j in 1..<csvRows[0].count-1 {
                    if let val = Double(csvRows[i][j]) {
                        floatArray.append(round(100*val)/100)
                    }
                }
                chosenMonth.updateValue(floatArray, forKey: csvRows[i][csvRows[0].count-1])
            }
        }
        var list = [GMUWeightedLatLng]()
        for val in chosenMonth {
            print(val)
            getCoordinateFrom(address: val.key) {
                (location, error) in
                if error == nil {
                    if let location = location {
                        let coords = GMUWeightedLatLng(coordinate: CLLocationCoordinate2DMake(location.latitude, location.longitude), intensity: Float(val.value[0]))
                        list.append(coords)
                    }
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
            self.heatmapLayer.weightedData = list
        }
    }
    /*
    func addHeatmap(from csvName: String, withExt: String) {
        var data = CSVHandler.readDataFromCSV(fileName: csvName, fileType: withExt)
        data = CSVHandler.cleanRows(file: data!)
        let csvRows = CSVHandler.csv(data: data!)
        var years: Dictionary<String,[Float]> = [:]
        for i in 1..<csvRows.count-1 {
            var array: [Float] = []
            for j in 7..<csvRows[0].count {
                if let num = Float(csvRows[i][j]) {
                    array.append(num)
                }
            }
            let year = 1879+i
            years.updateValue(array, forKey: "\(year)")
        }
        print(years["1880"]!)
        print(years["2010"]!)
        var list = [GMUWeightedLatLng]()
        
        if let chosenYear = years["2019"] {
            print("2019 is not null")
            for i in 0..<chosenYear.count {
                let coordsVal = LatitudeZone.getZone(from: i).getCoordsAndWeight().0
                for j in 0..<20 {
                    let coords = GMUWeightedLatLng(coordinate: CLLocationCoordinate2DMake(coordsVal.coordinate.latitude, CLLocationDegrees(9*j)), intensity: 100*chosenYear[i])
                    list.append(coords)
                }
            }
            print(list)
            heatmapLayer.weightedData = list
        }
    }*/
    
    func getCoordinate( addressString : String,
            completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                        
                    completionHandler(location.coordinate, nil)
                    return
                }
            }
                
            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
    
    func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> () ) {
        CLGeocoder().geocodeAddressString(address) { completion($0?.first?.location?.coordinate, $1) }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
      print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
    }

    func addHeatmap()  {
      var list = [GMUWeightedLatLng]()
      do {
        // Get the data: latitude/longitude positions of police stations.
        if let path = Bundle.main.url(forResource: "police_stations", withExtension: "json") {
          let data = try Data(contentsOf: path)
          let json = try JSONSerialization.jsonObject(with: data, options: [])
          if let object = json as? [[String: Any]] {
            for item in object {
              let lat = item["lat"]
              let lng = item["lng"]
              let coords = GMUWeightedLatLng(coordinate: CLLocationCoordinate2DMake(lat as! CLLocationDegrees, lng as! CLLocationDegrees), intensity: 1.0)
              list.append(coords)
            }
          } else {
            print("Could not read the JSON.")
          }
        }
      } catch {
        print(error.localizedDescription)
      }
      // Add the latlngs to the heatmap layer.
      heatmapLayer.weightedData = list
    }
}

