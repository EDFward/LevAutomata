import XCTest

class LevAutomataTest: XCTestCase {

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testFoodNFA() {
    let lev = LevAutomata("food", maxAllowedMismatch: 1)

    XCTAssertTrue(lev.test("food"))
    XCTAssertTrue(lev.test("good"))
    XCTAssertTrue(lev.test("fod"))
    XCTAssertTrue(lev.test("foods"))

    XCTAssertFalse(lev.test("goods"))
    XCTAssertFalse(lev.test("fods"))
  }

  func testFoodDFA() {
    let lev = LevAutomata("food", maxAllowedMismatch: 1, compileToDFA: true)

    XCTAssertTrue(lev.test("food"))
    XCTAssertTrue(lev.test("good"))
    XCTAssertTrue(lev.test("fod"))
    XCTAssertTrue(lev.test("foods"))

    XCTAssertFalse(lev.test("goods"))
    XCTAssertFalse(lev.test("fods"))
  }

  func testNiceNFA() {
    let lev = LevAutomata("nice", maxAllowedMismatch: 1)
    let similar = ["anice", "bice", "dice", "fice", "ice", "mice", "nace", "nice", "niche", "nick", "nide", "niece", "nife", "nile", "nine", "niue", "pice", "rice", "sice", "tice", "unice", "vice", "wice"]
    let dissimilar = ["bica", "ce", "", "nacea", "nceo"]
    for word in similar {
      XCTAssertTrue(lev.test(word))
    }
    for word in dissimilar {
      XCTAssertFalse(lev.test(word))
    }
  }

  func testNiceDFA() {
    let lev = LevAutomata("nice", maxAllowedMismatch: 1, compileToDFA: true)
    let similar = ["anice", "bice", "dice", "fice", "ice", "mice", "nace", "nice", "niche", "nick", "nide", "niece", "nife", "nile", "nine", "niue", "pice", "rice", "sice", "tice", "unice", "vice", "wice"]
    let dissimilar = ["bica", "ce", "", "nacea", "nceo"]
    for word in similar {
      XCTAssertTrue(lev.test(word))
    }
    for word in dissimilar {
      XCTAssertFalse(lev.test(word))
    }
  }

  // Due to the exponential run time of DFA building, I explicitly omit testing DFA on this one.
  func testLongDistanceNFA() {
    // Examples are from https://github.com/rawrgrr/Levenshtein.jl/blob/master/test/runtests.jl
    var lev: LevAutomata

    lev = LevAutomata("Hi, my name is", maxAllowedMismatch: 4)
    XCTAssertTrue(lev.test("my name is"))
    lev = LevAutomata("Hi, my name is", maxAllowedMismatch: 3)
    XCTAssertFalse(lev.test("my name is"))

    lev = LevAutomata("%^@!^@#^@#!! Snoooooooop", maxAllowedMismatch: 21)
    XCTAssertTrue(lev.test("Dro!p it!!!! like it's hot"))
    lev = LevAutomata("%^@!^@#^@#!! Snoooooooop", maxAllowedMismatch: 20)
    XCTAssertFalse(lev.test("Dro!p it!!!! like it's hot"))

    lev = LevAutomata("Alborgów", maxAllowedMismatch: 7)
    XCTAssertTrue(lev.test("amoniak"))
    lev = LevAutomata("Alborgów", maxAllowedMismatch: 6)
    XCTAssertFalse(lev.test("amoniak"))
  }


  func testFindNextWord1() {
    let lev = LevAutomata("food", maxAllowedMismatch: 1, compileToDFA: true)
    XCTAssertEqual(lev.findNextValidWord("food"), "food")
    XCTAssertEqual(lev.findNextValidWord("foogle"), "fooh")
  }

  func testFindNextWord2() {
    let lev = LevAutomata("hel", maxAllowedMismatch: 1, compileToDFA: true)
    XCTAssertEqual(lev.findNextValidWord("he"), "he")
    XCTAssertEqual(lev.findNextValidWord("hd"), "hdel")
    XCTAssertEqual(lev.findNextValidWord("h"), "hAel")
    XCTAssertEqual(lev.findNextValidWord("a"), "ael")
  }

}
