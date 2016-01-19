import XCTest

class LevAutomataProfiling: XCTestCase {

  var suggestion: Suggestion?

  override func setUp() {
    super.setUp()
    suggestion = Suggestion()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testPerformanceExample() {
    self.measureBlock {
      self.suggestion!.findSimilarWords("hellohello")
    }
  }
  
}
