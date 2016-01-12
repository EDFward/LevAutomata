import Cocoa
import ReactiveCocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet weak var window: NSWindow!

  let inputField = NSTextField(frame: NSMakeRect(20, 360, 200, 25))

  let suggestionInfo = NSTextView(frame: NSMakeRect(20, 20, 200, 320))

  var vocabulary: [String]?

  // Credits: http://www.wordfrequency.info/free.asp
  private func loadVocabulary() -> [String] {
    let path = NSBundle.mainBundle().pathForResource("words", ofType: "txt")
    guard let wordsString = try? String(contentsOfFile: path!, encoding: NSUTF8StringEncoding) else {
      fatalError("Could not open vocabulary file.")
    }
    return wordsString.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
  }

  private func findSimilarWords(inputWord: String) -> [String] {
    let automaton = LevenshteinAutomaton(inputWord, maxAllowedMismatch: 1)
    var similarWords = [String]()
    // Make sure it's been initialized.
    for word in vocabulary! {
      if similarWords.count >= 10 {
        break
      }
      if automaton.test(word) {
        similarWords.append(word)
      }
    }
    return similarWords
  }

  func applicationDidFinishLaunching(aNotification: NSNotification) {
    window.setContentSize(NSSize(width: 240, height: 400))
    window.styleMask = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask
    window.opaque = false
    window.center()
    window.title = "Spell Correction"

    vocabulary = loadVocabulary()

    // Let RAC flow!
    let inputStrings = inputField
      .rac_textSignal()
      .throttle(0.3)
      .distinctUntilChanged()
      .toSignalProducer()
      .map { text in text as! String }
      .filter { $0.characters.count > 2 }

    inputStrings
      .startWithNext({
        self.suggestionInfo.string = self.findSimilarWords($0).joinWithSeparator("\n")
      })

    // Configure & add subviews.
    suggestionInfo.editable = false
    window.contentView!.addSubview(inputField)
    window.contentView!.addSubview(suggestionInfo)
  }

  func applicationWillTerminate(aNotification: NSNotification) {
    
  }
}

