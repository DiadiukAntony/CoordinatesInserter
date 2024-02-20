// Creator Anton Diadiuk. Mysqadiam@gmail.com

import CoreLocation
import XCTest
import PlaygroundSupport

// Playground needs to wait for asynchronous code to finish execution
// This is for In-playground XCTestCases only.
PlaygroundPage.current.needsIndefiniteExecution = true

let startWpt = CLLocationCoordinate2D(latitude: -10.0, longitude: 0.0)
let finishWpt = CLLocationCoordinate2D(latitude: -20.0, longitude: 10.0)
let step = CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0)

extension CLLocationCoordinate2D {
    public static func == (leftHandEquitable: CLLocationCoordinate2D, rightHandEquitable: CLLocationCoordinate2D) -> Bool {
        return leftHandEquitable.latitude == rightHandEquitable.latitude && leftHandEquitable.longitude == rightHandEquitable.longitude
    }

    var isLatPositive: Bool {
        return latitude >= 0
    }

    var isLongPositive: Bool {
        return longitude < 0
    }
}

var coordinates = Array<Any>()
coordinates = getCoordinatesList(startWpt, finishWpt, step)

func getCoordinatesList(_ startWpt: CLLocationCoordinate2D, _ finishWpt: CLLocationCoordinate2D, _ step: CLLocationCoordinate2D) -> [CLLocationCoordinate2D] {
    var coordinates = [CLLocationCoordinate2D]()
    var currentWpt = startWpt

    let latChanged = startWpt.latitude != finishWpt.latitude
    let longChanged = startWpt.longitude != finishWpt.longitude

    while currentWpt.latitude != finishWpt.latitude || currentWpt.longitude != finishWpt.longitude {
        coordinates.append(currentWpt)

        if latChanged {
            if (currentWpt.isLatPositive && finishWpt.isLatPositive && currentWpt.latitude < finishWpt.latitude) ||
                (!currentWpt.isLatPositive && !finishWpt.isLatPositive && currentWpt.latitude < finishWpt.latitude) {
                currentWpt.latitude += step.latitude
            } else if (currentWpt.isLatPositive && finishWpt.isLatPositive && currentWpt.latitude > finishWpt.latitude) ||
                (!currentWpt.isLatPositive && !finishWpt.isLatPositive && currentWpt.latitude > finishWpt.latitude) {
                currentWpt.latitude -= step.latitude
            }
        }

        if longChanged {
            if (currentWpt.isLongPositive && finishWpt.isLongPositive && currentWpt.longitude < finishWpt.longitude) ||
                (!currentWpt.isLongPositive && !finishWpt.isLongPositive && currentWpt.longitude < finishWpt.longitude) {
                currentWpt.longitude += step.longitude
            } else if (currentWpt.isLongPositive && finishWpt.isLongPositive && currentWpt.latitude > finishWpt.latitude) ||
                (!currentWpt.isLongPositive && !finishWpt.isLongPositive && currentWpt.longitude > finishWpt.longitude) {
                currentWpt.longitude -= step.longitude
            }
        }
    }
    coordinates.append(finishWpt)
    print(coordinates)
    return coordinates
}

//__________________________________________________________________________________________

//class CoordinateGeneratorTests: XCTestCase {
//
//    func testStartFinishCoordinates() {
//        let start = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
//        let finish = CLLocationCoordinate2D(latitude: 10.0, longitude: 0.0)
//        let step = CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0)
//
//        let coordinates = getCoordinatesList(start, finish, step)
//
//        if coordinates.count > 0 {
//            XCTAssertEqual(coordinates[0], start, "List starts with a proper coordinate")
//        } else {
//            XCTFail("No coordinates generated")
//        }
//    }
//}
//
//let testSuite = CoordinateGeneratorTests.defaultTestSuite
//testSuite.run()

