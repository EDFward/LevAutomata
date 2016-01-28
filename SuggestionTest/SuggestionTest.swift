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
    let similarWords = Set(["nick", "wice", "nide", "niece", "nine", "unice", "nace", "mice", "nice", "tice", "dice", "pice", "sice", "Anice", "Bice", "bice", "Nice", "vice", "ice", "nife", "Vice", "rice", "fice", "niche"])
    let suggested = Set(sug.findSimilarWords("nice", allowedMismatch: 1))
    XCTAssertEqual(similarWords, suggested)
  }

  func testSuggestionNaive() {
    let similarWords = Set(["nick", "wice", "nide", "niece", "nine", "unice", "nace", "mice", "nice", "tice", "dice", "pice", "sice", "Anice", "Bice", "bice", "Nice", "vice", "ice", "nife", "Vice", "rice", "fice", "niche"])
    let suggestedDFA = Set(sug.findSimilarWordsNaive("nice", compileToDFA: true, allowedMismatch: 1))
    let suggestedNFA = Set(sug.findSimilarWordsNaive("nice", compileToDFA: false, allowedMismatch: 1))
    XCTAssertEqual(similarWords, suggestedDFA)
    XCTAssertEqual(similarWords, suggestedNFA)
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
