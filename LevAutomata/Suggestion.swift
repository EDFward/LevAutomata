import Foundation

public class Suggestion {

  var vocabulary: [String] = Suggestion.loadVocabulary()

  public func findSimilarWords(inputWord: String) -> [String] {
    let automaton = LevenshteinAutomaton(inputWord, maxAllowedMismatch: 1)
    var similarWords = [String]()
    // Make sure it's been initialized.
    for word in vocabulary {
      if similarWords.count >= 20 {
        break
      }
      if automaton.test(word) {
        similarWords.append(word)
      }
    }
    return similarWords
  }

  // Credits: http://www.wordfrequency.info/free.asp
  private static func loadVocabulary() -> [String] {
    let path = NSBundle.mainBundle().pathForResource("words", ofType: "txt")
    guard let wordsString = try? String(contentsOfFile: path!, encoding: NSUTF8StringEncoding) else {
      fatalError("Could not open vocabulary file.")
    }
    return wordsString.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
  }
  
}