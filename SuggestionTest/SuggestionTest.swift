import XCTest

class SuggestionTest: XCTestCase {

  let sug: Suggestion = Suggestion(dictName: "morewords")

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testSuggestion() {
    let similarWords = ["niche", "nide", "niece", "nine", "unice", "nice", "mice", "tice", "dice", "pice", "sice", "wice", "bice", "vice", "ice", "nife", "rice", "fice", "nick"]
    let suggested = sug.findSimilarWords("nice", allowedMismatch: 1)
    XCTAssertEqual(Set(similarWords), Set(suggested))
  }

  func testSuggestionNaive() {
    let suggestedDFA = sug.findSimilarWordsNaive("nice", compileToDFA: true, allowedMismatch: 1)
    let suggestedNFA = sug.findSimilarWordsNaive("nice", compileToDFA: false, allowedMismatch: 1)
    XCTAssertEqual(suggestedDFA, suggestedNFA)
  }


  func testSimpleAllowMismatch1() {
    self.measureBlock {
      self.sug.findSimilarWords("hell", allowedMismatch: 1)
    }
  }

  func testSimpleAllowMismatch2() {
    self.measureBlock {
      self.sug.findSimilarWords("hell", allowedMismatch: 2)
    }
  }

  func testSimpleAllowMismatch3() {
    self.measureBlock {
      self.sug.findSimilarWords("hell", allowedMismatch: 3)
    }
  }

  // Too slow!
  func testSimpleAllowMismatch3NaiveDFA() {
    self.measureBlock {
      self.sug.findSimilarWordsNaive("hell", compileToDFA: true, allowedMismatch: 3)
    }
  }

  // Timeout...
  /*
  func testSimpleAllowMismatch3NaiveNFA() {
    self.measureBlock {
      self.sug.findSimilarWordsNaive("hell", compileToDFA: false, allowedMismatch: 3)
    }
  }
  */

  func testLong1AllowMismatch2() {
    self.measureBlock {
      self.sug.findSimilarWords("nicetomeetyou", allowedMismatch: 2)
    }
  }

  // Too slow!
  func testLong1AllowMismatch2NaiveDFA() {
    self.measureBlock {
      self.sug.findSimilarWordsNaive("nicetomeetyou", compileToDFA: true, allowedMismatch: 2)
    }
  }

  func testLong1AllowMismatch2NaiveNFA() {
    self.measureBlock {
      self.sug.findSimilarWordsNaive("nicetomeetyou", compileToDFA: false, allowedMismatch: 2)
    }
  }

  func testLong2AllowMismatch2() {
    self.measureBlock {
      self.sug.findSimilarWords("helloworld", allowedMismatch: 2)
    }
  }

  func testLong3AllowMismatch2() {
    self.measureBlock {
      self.sug.findSimilarWords("narcissism", allowedMismatch: 2)
    }
  }

  func testSuperLongAllowMismatch2() {
    self.measureBlock {
      self.sug.findSimilarWords("aaaaaaaaaaaaaaaaaa", allowedMismatch: 2)
    }
  }

}
