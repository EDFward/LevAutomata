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


// Credits: http://www.wordfrequency.info/free.asp
internal func loadVocabulary(fileName: String) -> [String] {
  let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "txt")
  guard let wordsString = try? String(contentsOfFile: path!, encoding: NSUTF8StringEncoding) else {
    fatalError("Could not open vocabulary file.")
  }
  return wordsString.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
}


public class Suggestion {

  let vocabulary: [String]

  init(dictName: String) {
    vocabulary = loadVocabulary(dictName).sort()
  }

  // Find all matches, algorithm from http://blog.notdot.net/2010/07/Damn-Cool-Algorithms-Levenshtein-Automata
  public func findSimilarWords(inputWord: String, allowedMismatch: Int = 1) -> [String] {
    let lev = LevAutomata(inputWord, maxAllowedMismatch: allowedMismatch, compileToDFA: true)
    var similarWords = [String]()
    var candidate: String? = lev.findNextValidWord(String(State.nullCharacter))

    var searched = 0
    while candidate != nil {
      #if DEBUG
        searched += 1
      #endif
      guard var next = binarySearch(vocabulary, target: candidate!) else {
        break
      }
      if next == candidate {
        similarWords.append(next)
        next.append(State.nullCharacter)
      }
      candidate = lev.findNextValidWord(next)
    }
    #if DEBUG
      print("input: \(inputWord), searched for \(searched) times.")
    #endif
    return similarWords
  }

  // Only for performance profiling. Search words one by one.
  internal func findSimilarWordsNaive(inputWord: String, compileToDFA: Bool, allowedMismatch: Int = 1) -> [String] {
    let lev = LevAutomata(inputWord, maxAllowedMismatch: allowedMismatch, compileToDFA: compileToDFA)
    return vocabulary.filter {
      lev.test($0)
    }
  }

}
