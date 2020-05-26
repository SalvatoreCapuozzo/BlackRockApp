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

class ViewController: UIViewController {
    var map: GMSMapView!
    private var heatmapLayer: GMUHeatmapTileLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        heatmapLayer = GMUHeatmapTileLayer()
        map = GMSMapView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        heatmapLayer.map = map
        self.view.addSubview(map)
        addHeatmap(from: "ZonAnn.Ts+dSST", withExt: "csv")
        // Do any additional setup after loading the view.
    }
    
    func addHeatmap(from csvName: String, withExt: String) {
        var data = CSVHandler.readDataFromCSV(fileName: csvName, fileType: withExt)
        data = CSVHandler.cleanRows(file: data!)
        let csvRows = CSVHandler.csv(data: data!)
        print(csvRows[1][1])
        print(csvRows[1][2])
        print(csvRows[1][3])
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

