//
//  CoordinatesHandler.swift
//  BlackRockApp
//
//  Created by Salvatore Capuozzo on 26/05/2020.
//  Copyright © 2020 Salvatore Capuozzo. All rights reserved.
//

import Foundation
import CoreLocation

enum LatitudeZone {
    case zoneGlob
    case zoneNHem
    case zoneSHem
    case zone24N90N
    case zone24S24N
    case zone90S24S
    case zone64N90N
    case zone44N64N
    case zone24N44N
    case zoneEQU24N
    case zone24SEQU
    case zone44S24S
    case zone64S44S
    case zone90S64S
    
    func getCoordsAndWeight(from zone: LatitudeZone) -> (CLLocation, Float) {
        switch self {
        case .zoneGlob:
            return (CLLocation(latitude: 0, longitude: 0), 4.0)
        case .zoneNHem:
            return (CLLocation(latitude: 44, longitude: 0), 3.0)
        case .zoneSHem:
            return (CLLocation(latitude: -44, longitude: 0), 3.0)
        case .zone24N90N:
            return (CLLocation(latitude: 54, longitude: 0), 2.0)
        case .zone24S24N:
            return (CLLocation(latitude: 0, longitude: 0), 2.0)
        case .zone90S24S:
            return (CLLocation(latitude: -54, longitude: 0), 2.0)
        case .zone64N90N:
            return (CLLocation(latitude: 77, longitude: 0), 1.0)
        case .zone44N64N:
            return (CLLocation(latitude: 54, longitude: 0), 1.0)
        case .zone24N44N:
            return (CLLocation(latitude: 34, longitude: 0), 1.0)
        case .zoneEQU24N:
            return (CLLocation(latitude: 12, longitude: 0), 1.0)
        case .zone24SEQU:
            return (CLLocation(latitude: -12, longitude: 0), 1.0)
        case .zone44S24S:
            return (CLLocation(latitude: -34, longitude: 0), 1.0)
        case .zone64S44S:
            return (CLLocation(latitude: -54, longitude: 0), 1.0)
        case .zone90S64S:
            return (CLLocation(latitude: -77, longitude: 0), 1.0)
        }
    }
}
