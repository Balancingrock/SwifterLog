import XCTest
@testable import SwifterLog

class SwifterLogTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(SwifterLog().text, "Hello, World!")
    }


    static var allTests : [(String, (SwifterLogTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
