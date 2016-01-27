import Foundation

// From http://stackoverflow.com/a/31904569/2849480
internal func binarySearch<T : Comparable>(array: [T], target: T) -> T? {
  var left = 0
  var right = array.count - 1

  while (left <= right) {
    let mid = (left + right) / 2
    let value = array[mid]

    if (value == target) {
      return value
    }

    if (value < target) {
      left = mid + 1
    }

    if (value > target) {
      right = mid - 1
    }
  }

  if left < array.count {
    return array[left]
  } else {
    return nil
  }
}

public class Suggestion {

  var vocabulary: [String] = Suggestion.loadVocabulary().sort()

  // Find all matches, algorithm from http://blog.notdot.net/2010/07/Damn-Cool-Algorithms-Levenshtein-Automata
  public func findSimilarWords(inputWord: String, allowedMismatch: Int = 1) -> [String] {
    let lev = LevAutomata(inputWord, maxAllowedMismatch: allowedMismatch, compileToDFA: true)
    var similarWords = [String]()
    var candidate: String? = lev.findNextValidWord("a")
    while candidate != nil {
      guard var next = binarySearch(vocabulary, target: candidate!) else {
        break
      }
      if next == candidate {
        similarWords.append(next)
        next += "a"
      }
      candidate = lev.findNextValidWord(next)
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