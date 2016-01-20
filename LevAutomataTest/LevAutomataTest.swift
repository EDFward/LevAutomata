import XCTest

class LevAutomataTest: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testFood() {
      let lev = LevAutomata("food", maxAllowedMismatch: 1)
      XCTAssertTrue(lev.test("food"))
      XCTAssertTrue(lev.test("good"))
      XCTAssertTrue(lev.test("fod"))
      XCTAssertTrue(lev.test("foods"))

      XCTAssertFalse(lev.test("goods"))
      XCTAssertFalse(lev.test("fods"))
    }
}
