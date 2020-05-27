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

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, GMSMapViewDelegate {
    @IBOutlet var dateSlider: UISlider!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var backView: UIView!
    @IBOutlet var titleLabel: UILabel!
    
    var map: GMSMapView!
    
    var locmanager = CLLocationManager()

    var list = [GMUWeightedLatLng]()
    var currentPlace = ["Morocco", "Algeria", "Libya"]
    private var heatmapLayer: GMUHeatmapTileLayer!
    private var gradientColors = [UIColor.blue, UIColor.cyan, UIColor.white, UIColor.yellow,  UIColor.red]
    private var gradientStartPoints = [0.2, 0.4, 0.6, 0.8, 1.0] as [NSNumber]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        heatmapLayer = GMUHeatmapTileLayer()
        heatmapLayer.radius = 150
        heatmapLayer.opacity = 0.3
        heatmapLayer.gradient = GMUGradient(colors: gradientColors, startPoints: gradientStartPoints, colorMapSize: 256)
        
        //
        self.backView.layer.cornerRadius = 20
        self.backView.layer.masksToBounds = true
        self.dateSlider.isContinuous = false
        self.dateLabel.text = "6-2003"
        map = GMSMapView(frame: CGRect(x: self.backView.frame.origin.x, y: 160, width: self.backView.frame.size.width, height: view.frame.size.height/2))
        let camera = GMSCameraPosition.camera(withLatitude: 34.0, longitude: 5.0, zoom: 4.0)
        map = GMSMapView.map(withFrame: map.frame, camera: camera)
        if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
            do {
                map.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } catch {
                NSLog("Unable to find style.json")
            }
        } else {
            NSLog("Unable to find style.json")
        }
        map.delegate = self
        self.backView.addSubview(map)
        heatmapLayer.map = map
        
        self.titleLabel.text = "Temperature in Baghred"
        self.addHeatmap(from: "90toNow", withExt: "csv", countries: ["Morocco", "Algeria", "Libya"], year: 2003, month: 6)
        
        self.view.addSubview(map)
        // Do any additional setup after loading the view.
    }
    
    func addHeatmap(from csvName: String, withExt: String, countries: [String], year: Int, month: Int) {
        var data = CSVHandler.readDataFromCSV(fileName: csvName, fileType: withExt)
        data = CSVHandler.cleanRows(file: data!)
        let csvRows = CSVHandler.csv(data: data!)

        var chosenMonth: Dictionary<String,(Double,CLLocationCoordinate2D)> = [:]
        var chosenArray: [Dictionary<String,(Double,CLLocationCoordinate2D)>] = [[:]]
        for i in 1..<csvRows.count-1 {
            let date = csvRows[i][0]
            var trueCondition = false
            for country in countries {
                if csvRows[i][3] == country {
                    trueCondition = true
                }
            }
            var monthString = ""
            if month<10 {
                monthString = "0\(month)"
            } else {
                monthString = "\(month)"
            }
            if date == "\(year)-\(monthString)-01" && trueCondition {
                var averAndLoc: (Double,CLLocationCoordinate2D)
                
                var lat = csvRows[i][4]
                var latNum = 0.0
                if lat.last == "N" {
                    lat.removeLast()
                    latNum = Double(lat)!
                } else {
                    lat.removeLast()
                    latNum = -Double(lat)!
                }
                
                var lon = csvRows[i][5]
                var lonNum = 0.0
                if lon.last == "E" {
                    lon.removeLast()
                    lonNum = Double(lon)!
                } else {
                    lon.removeLast()
                    lonNum = -Double(lon)!
                }

                if let val = Double(csvRows[i][1]) {
                    averAndLoc = (round(100*val)/100, CLLocationCoordinate2DMake(latNum,lonNum))
                    chosenMonth.updateValue(averAndLoc, forKey: csvRows[i][2])
                }
            }
        }
        //print(chosenMonth)

        self.list.removeAll()
        for val in chosenMonth {
            let coords = GMUWeightedLatLng(coordinate: CLLocationCoordinate2DMake(val.value.1.latitude, val.value.1.longitude), intensity: Float(val.value.0))
            self.list.append(coords)

            self.heatmapLayer.clearTileCache()
            self.heatmapLayer.weightedData = self.list
            self.heatmapLayer.map = self.map

        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
            ActivityView.remove()
        }
        
        print(chosenMonth.count)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(self.list.count)
        self.heatmapLayer.weightedData = self.list
        self.heatmapLayer.map = self.map

    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        
        let year = 1990 + currentValue/12
        let month = currentValue%12
        dateLabel.text = "\(month+1)-\(year)"
        DispatchQueue.main.async {
            ActivityView.show()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.addHeatmap(from: "90toNow", withExt: "csv", countries: self.currentPlace, year: year, month: month+1)
        }
    }
    
    // MARK: - LocationManager Delegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            self.locmanager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways, .authorizedWhenInUse:
            //self.addHeatmap(from: "GlobalLandTemperaturesByCountry", withExt: "csv")
            break
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
    
    // MARK: - MapView Delegate
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
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
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 5.0)
        map.camera = camera
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        location.fetchCountry {
            (country, error) in
            if error == nil {
                if let country = country {
                    print(country)
                    self.titleLabel.text = "Temperature in \(country)"
                    self.currentPlace = [country]
                    DispatchQueue.main.async {
                        ActivityView.show()
                    }
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                        self.addHeatmap(from: "90toNow", withExt: "csv", countries: [country], year: 1990+Int(self.dateSlider.value), month: Int(self.dateSlider.value)%12+1)
                    }
                }
            }
        }
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

extension CLLocation {
    func fetchCountry(completion: @escaping (_ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.country, $1) }
    }
}
