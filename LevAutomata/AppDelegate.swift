import Cocoa
import ReactiveCocoa

enum Event {
  case ClearScreen
  case ShowSuggestion(String)
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet weak var window: NSWindow!

  let inputField = NSTextField(frame: NSMakeRect(20, 360, 200, 25))

  let suggestionInfo = NSTextView(frame: NSMakeRect(20, 20, 200, 320))

  let suggestion = Suggestion(dictName: "morewords")

  func applicationDidFinishLaunching(aNotification: NSNotification) {
    window.setContentSize(NSSize(width: 240, height: 400))
    window.styleMask = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask
    window.opaque = false
    window.center()
    window.title = "Spell Correction"

    // Let RAC flow!
    let inputStrings = inputField
      .rac_textSignal()
      .throttle(0.3)
      .distinctUntilChanged()
      .toSignalProducer()
      .map { text in text as! String }

    let events = inputStrings
      .map({ (s: String) -> Event in
        if s.characters.count < 4 {
          return Event.ClearScreen
        } else {
          return Event.ShowSuggestion(s)
        }
      })

    // More events could be added or merged.
    events
      .startWithNext { e in
        switch e {
        case .ClearScreen:
          self.suggestionInfo.string = ""
        case .ShowSuggestion(let s):
          self.suggestionInfo.string = self.suggestion.findSimilarWords(s, allowedMismatch: 2).joinWithSeparator("\n")
        }
      }

    // Configure & add subviews.
    suggestionInfo.editable = false
    window.contentView!.addSubview(inputField)
    window.contentView!.addSubview(suggestionInfo)
  }

  func applicationWillTerminate(aNotification: NSNotification) {
    
  }
}

