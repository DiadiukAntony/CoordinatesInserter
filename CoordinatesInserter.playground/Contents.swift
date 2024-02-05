// Creator Anton Diadiuk. Mysqadiam@gmail.com
// This is a simple approach, that doesn't use Srtide function and strictly get only CLLocationCoordinate2D value types.

// TODO
// 1. Adjust getCoordinatesList to increment Negative values (as coordinates could be negative). Now it works with only with >0.
// 2. Continue on extension of this feature to get more than 2 points. Func should operate with more input coordinates.
// 3. Export this Playground to a Console app -> Move functions / values / tests in a separate files.
// 4. Add "import from file" function to pass .gpx files to this Console app.
// 5. Add more tests.
// 6. Test and release :)



import CoreLocation
import XCTest
import PlaygroundSupport

// Playground needs to wait for asynchronous code to finish execution
// This is for In-playground XCTestCases only.
PlaygroundPage.current.needsIndefiniteExecution = true

let start = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
let finish = CLLocationCoordinate2D(latitude: 10.0, longitude: 0.0)
let step = CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0)

extension CLLocationCoordinate2D: Equatable {
    public static func == (leftHandEquitable: CLLocationCoordinate2D, rightHandEquitable: CLLocationCoordinate2D) -> Bool {
        return leftHandEquitable.latitude == rightHandEquitable.latitude && leftHandEquitable.longitude == rightHandEquitable.longitude
    }
}

func getCoordinatesList(_ start: CLLocationCoordinate2D, _ finish: CLLocationCoordinate2D, _ step: CLLocationCoordinate2D) -> [CLLocationCoordinate2D] {
    var coordinates = [CLLocationCoordinate2D]()
    var current = start

    let didLatChange = abs(start.latitude - finish.latitude)
    let didLongChange = abs(start.longitude - finish.longitude)

    if (didLatChange != 0 && didLongChange == 0) {
        while current.latitude <= finish.latitude {
            coordinates.append(current)
            current.latitude = current.latitude + step.latitude
        }
    } else if (didLatChange == 0 && didLongChange != 0) {
        while current.longitude <= finish.longitude {
            coordinates.append(current)
            current.longitude = current.longitude + step.longitude
        }
    } else {
        while current.latitude <= finish.latitude && current.longitude <= finish.longitude {
            coordinates.append(current)
            current.latitude = current.latitude + step.latitude
            current.longitude = current.longitude + step.longitude
        }
    }
    return coordinates
}

print(getCoordinatesList(start, finish, step))

//__________________________________________________________________________________________

class CoordinateGeneratorTests: XCTestCase {

    func testStartFinishCoordinates() {
        let start = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        let finish = CLLocationCoordinate2D(latitude: 10.0, longitude: 0.0)
        let step = CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0)

        let coordinates = getCoordinatesList(start, finish, step)

        if coordinates.count > 0 {
            XCTAssertEqual(coordinates[0], start, "List starts with a proper coordinate")
        } else {
            XCTFail("No coordinates generated")
        }
    }
}

let testSuite = CoordinateGeneratorTests.defaultTestSuite
testSuite.run()
