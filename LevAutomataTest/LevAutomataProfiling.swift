import XCTest

class LevAutomataProfiling: XCTestCase {

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testPerformanceNFA() {
    let lev = LevAutomata("nice", maxAllowedMismatch: 3)
    let distance1 = ["anice", "bice", "dice", "fice", "ice", "mice", "nace", "nice", "niche", "nick", "nide", "niece", "nife", "nile", "nine", "niue", "pice", "rice", "sice", "tice", "unice", "vice", "wice"]
    let distance2 = ["bica", "ce", "nacea", "nceo"]
    let distance3 = ["bbica", "c", "oonicez"]

    self.measureBlock {
      for word in distance1 {
        XCTAssertTrue(lev.test(word))
      }
      for word in distance2 {
        XCTAssertTrue(lev.test(word))
      }
      for word in distance3 {
        XCTAssertTrue(lev.test(word))
      }
    }
  }

  func testPerformanceDFA() {
    let lev = LevAutomata("nice", maxAllowedMismatch: 3, compileToDFA: true)
    let distance1 = ["anice", "bice", "dice", "fice", "ice", "mice", "nace", "nice", "niche", "nick", "nide", "niece", "nife", "nile", "nine", "niue", "pice", "rice", "sice", "tice", "unice", "vice", "wice"]
    let distance2 = ["bica", "ce", "nacea", "nceo"]
    let distance3 = ["bbica", "c", "oonicez"]

    self.measureBlock {
      for word in distance1 {
        XCTAssertTrue(lev.test(word))
      }
      for word in distance2 {
        XCTAssertTrue(lev.test(word))
      }
      for word in distance3 {
        XCTAssertTrue(lev.test(word))
      }
    }
  }

  func testConstructorNFA(){
    self.measureBlock {
      _ = LevAutomata("helloworld", maxAllowedMismatch: 3)
    }
  }

  func testConstructorDFA(){
    self.measureBlock {
      _ = LevAutomata("helloworld", maxAllowedMismatch: 3, compileToDFA: true)
    }
  }
}
