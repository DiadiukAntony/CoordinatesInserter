// Creator Anton Diadiuk. Mysqadiam@gmail.com

import CoreLocation
import XCTest
import PlaygroundSupport

// Playground needs to wait for asynchronous code to finish execution
// This is for In-playground XCTestCases only.

var waypoints = [CLLocationCoordinate2D]()

let location1 = CLLocationCoordinate2D(latitude: 37.791173, longitude: -122.44503)
let location2 = CLLocationCoordinate2D(latitude: 37.789397, longitude: -122.459332)
let step: CLLocationDistance = 100
//__________________________________________________________________________________________

var allWords = [String]()
var latLonPairs = [String]()
var coordinates: [CLLocationCoordinate2D] = []

func getCoordsFromFile(file named: String) -> Array<CLLocationCoordinate2D>{
    if let startWordsURL = Bundle.main.url(forResource: "inserter", withExtension: "gpx") {
        if let startWords = try? String(contentsOf: startWordsURL, encoding: .utf8) {
            allWords = startWords.components(separatedBy: "\n")
        }
    }
    
    if allWords.isEmpty {
        allWords = ["silkworm"]
    }
    
    // Regular expression to extract lat and lon
    let pattern = #"lat\s*=\s*"([^"]+)"\s*lon\s*=\s*"([^"]+)""#
    let regex = try! NSRegularExpression(pattern: pattern, options: [])
    
    // Array to collect lat and lon pairs
    var latLonPairs: [(String, String)] = []
    
    // Iterate through each element of the array
    for element in allWords {
        let range = NSRange(location: 0, length: element.utf16.count)
        if let match = regex.firstMatch(in: element, options: [], range: range) {
            if let latRange = Range(match.range(at: 1), in: element),
               let lonRange = Range(match.range(at: 2), in: element) {
                let lat = String(element[latRange])
                let lon = String(element[lonRange])
                latLonPairs.append((lat, lon))
            }
        }
    }
    
    // Print the collected lat and lon pairs
    for (lat, lon) in latLonPairs {
        if let latitude = Double(lat), let longitude = Double(lon) {
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            coordinates.append(coordinate)
        }
    }

    return(coordinates)
    
}

waypoints = getCoordsFromFile(file: "inserter")
print(waypoints)

//__________________________________________________________________________________________

extension CLLocationCoordinate2D {
    func distance(to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return to.distance(from: from)
    }
}
/// Just the number of fraction steps
extension CLLocationDistance {
    func countOfSteps(step: CLLocationDistance) -> Int {
        let steps = self / step
        return steps > 0 ? Int(steps) : 1
    }
}
extension CLLocationDegrees {
    func interpolate(to: CLLocationDegrees, with numberOfSteps: Int) -> [CLLocationDegrees] {
        guard numberOfSteps > 0 else { return [self, to] }
        let diff = abs(self - to)
        let offset = diff / Double(numberOfSteps)
        let fromLessThenTo = to < self
        return (0...numberOfSteps).map { step in
            if fromLessThenTo {
                return to + Double(step) * offset
            } else {
                return to - Double(step) * offset
            }
        }
    }
}
extension CLLocationCoordinate2D {
    func interpolate(to: CLLocationCoordinate2D, with distance: CLLocationDistance) -> [CLLocationCoordinate2D] {
        let steps = self.distance(to: to).countOfSteps(step: distance)
        let lats = self.latitude.interpolate(to: to.latitude, with: steps)
        let longs = self.longitude.interpolate(to: to.longitude, with: steps)
        let pair = zip(lats, longs)
        return pair.map { CLLocationCoordinate2D(latitude: $0, longitude: $1) }
    }
    static func interpolateArray(locations: [CLLocationCoordinate2D], with distance: CLLocationDistance) -> [CLLocationCoordinate2D] {
        guard locations.count > 1 else { return locations }
        var result: [CLLocationCoordinate2D] = []
        for i in 0..<locations.count - 1 {
            let start = locations[i]
            let end = locations[i + 1]
            let interpolated = start.interpolate(to: end, with: distance)
            if i > 0 {
                // Remove the first element to avoid duplicates
                result.append(contentsOf: interpolated.dropFirst())
            } else {
                result.append(contentsOf: interpolated)
            }
        }
        return result
    }
}
extension CLLocationCoordinate2D: @retroactive CustomDebugStringConvertible {
    public var debugDescription: String {
        let lat = String(format: "%.7f", self.latitude)
        let lon = String(format: "%.7f", self.longitude)
        return "[lat: \(lat) lon: \(lon)]"
    }
}

//let coordinatesArray = location1.interpolate(to: location2, with: step)
let coordinatesArray = CLLocationCoordinate2D.interpolateArray(locations: waypoints, with: step)
print (coordinatesArray)

//________________________________________________________________________________

func coordsToGPXstring(coords: Array<CLLocationCoordinate2D>) -> String {
    var resultString = ""
    
    for i in 0...coords.count-1 {
        resultString.append((String(format : "<wpt lat=\"%f\" lon=\"%f\"></wpt> \n", coords[i].latitude, coords[i].longitude)))
    }
    return(resultString)
}

//________________________________________________________________________________

let gpxHeader = """
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.0" creator="GPSBabel - https://www.gpsbabel.org" xmlns="http://www.topografix.com/GPX/1/0"> \n
"""
let gpxFooter = "</gpx>"
let completeGPXString = gpxHeader + coordsToGPXstring(coords: coordinatesArray) + gpxFooter

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

let filename = getDocumentsDirectory().appendingPathComponent("updated.gpx")

do {
    try completeGPXString.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
} catch {
    // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
}
