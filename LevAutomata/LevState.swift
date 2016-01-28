// Labeled edge in automata.
struct Edge {

  enum EdgeType {
    case Epsilon
    case Any
    case Normal(Character)
  }

  let type: EdgeType
  let dest: State

  init(_ type: EdgeType, dest: State) {
    self.type = type
    self.dest = dest
  }
}

class State: Hashable, Equatable {

  private var neighbors: [Edge] = [Edge]()

  // Predecessor of character 'A'.
  internal static let nullCharacter: Character = Character(UnicodeScalar(64))

  func addEdge(edge: Edge) {
    neighbors.append(edge)
  }

  func getClosure() -> Set<State> {
    var closure: Set<State> = [self]
    // DFS with a stack.
    var stack: [State] = [self]
    while !stack.isEmpty {
      let poppedState = stack.removeLast()
      poppedState.neighbors
        .forEach({ edge in
          switch edge.type {
          case .Epsilon where !closure.contains(edge.dest):
            closure.insert(edge.dest)
            stack.append(edge.dest)
          default: break
          }
        })
    }
    return closure
  }

  // NFA stepping.
  func step(ch: Character) -> Set<State> {
    var nextStates = Set<State>()
    for state in getClosure() {
      state.neighbors
        .forEach({ edge in
          switch edge.type {
          case .Normal(ch), .Any:
            nextStates.insert(edge.dest)
          default: break
          }
        })
    }
    return nextStates
  }

  // DFA stepping.
  func step(ch: Character) -> State? {
    // Reject null character. Only will be used when checking lexicographically smallest outwards edge.
    if ch == State.nullCharacter {
      return nil
    }

    var candidate : State?
    for edge in neighbors {
      switch edge.type {
      case .Normal(ch):
        return edge.dest
      case .Any:
        candidate = edge.dest
      default:
        continue
      }
    }
    // If no exact match, return candidate, which is from edge of Any type.
    return candidate
  }

  /// Find lexicographically smallest edge from a state that's greater than input.
  func findNearestState(inputCh: Character) -> (Character, State)? {
    var candidate: (ch: Character, state: State, diff: UInt32)?
    let inputChAscii = inputCh.asciiValue

    loop: for edge in neighbors {
      switch edge.type {
      case .Normal(let ch):
        let chAscii = ch.asciiValue
        // Must ensure current char's ASCII value is bigger, otherwise will cause runtime error.
        if chAscii > inputChAscii &&
          (candidate == nil || chAscii - inputChAscii < candidate!.diff) {
            candidate = (ch, edge.dest, chAscii - inputChAscii)
        }
      case .Any:
        // Simply choose the nearest character.
        candidate = (Character(UnicodeScalar(inputChAscii + 1)), edge.dest, 0)
        break loop
      default:
        continue
      }
    }

    if let (ch, state, _) = candidate {
      return (ch, state)
    } else {
      return nil
    }
  }

  internal var hashValue: Int {
    get {
      return ObjectIdentifier(self).hashValue
    }
  }
}

internal func ==(lhs: State, rhs: State) -> Bool {
  return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

internal func generateAlphabet(states: Set<State>) -> Set<Character> {
  var alphabet: Set<Character> = []
  for state in states {
    for edge in state.neighbors {
      switch edge.type {
      case .Normal(let ch):
        alphabet.insert(ch)
      case .Any:
        alphabet.insert("*")
      default:
        continue
      }
    }
  }
  return alphabet
}
