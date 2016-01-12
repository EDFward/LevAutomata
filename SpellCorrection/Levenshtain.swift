struct State: Hashable {

  let offset: Int
  let allowedMismatch: Int

  init(_ offset: Int, allowedMismatch: Int) {
    self.offset = offset
    self.allowedMismatch = allowedMismatch
  }

  // From http://stackoverflow.com/questions/3934100/good-hash-function-for-list-of-2-d-positions
  var hashValue: Int {
    get {
      var hash = 17;
      hash = ((hash + offset) << 5) - (hash + offset);
      hash = ((hash + allowedMismatch) << 5) - (hash + allowedMismatch);
      return hash;
    }
  }
}

func ==(lhs: State, rhs: State) -> Bool {
  return lhs.offset == rhs.offset && lhs.allowedMismatch == rhs.allowedMismatch
}


// Levenshitein Automaton is also an NFA.
class LevenshteinAutomaton {

  let src: String
  let maxAllowedMismatch: Int

  init(_ src: String, maxAllowedMismatch: Int) {
    self.src = src
    self.maxAllowedMismatch = maxAllowedMismatch
  }

  private func initStates() -> Set<State> {
    return Set([State(0, allowedMismatch: maxAllowedMismatch)])
  }

  private func transition(currState: State, c: Character) -> Set<State> {
    var newStates = Set<State>()

    if currState.allowedMismatch > 0 {
      // Deletion of c.
      newStates.insert(State(currState.offset, allowedMismatch: currState.allowedMismatch - 1))

      // Substitution of c and `src[offset]`.
      newStates.insert(State(currState.offset + 1, allowedMismatch: currState.allowedMismatch - 1))
    }

    for var i = 0; i <= min(currState.allowedMismatch, src.characters.count - currState.offset - 1); i++ {
      let srcChar = src.characters[src.startIndex.advancedBy(currState.offset + i)]
      if c == srcChar {
        // If i == 0, continue matching; else delete *src[offset...offset + i)*.
        newStates.insert(State(currState.offset + i + 1, allowedMismatch: currState.allowedMismatch - i))
      }
    }
    return newStates
  }

  private func accept(state: State) -> Bool {
    return src.characters.count - state.offset < maxAllowedMismatch
  }

  func test(dest: String) -> Bool {
    var states = initStates()
    for c in dest.characters {
      var nextStates = Set<State>()
      for state in states {
        nextStates.unionInPlace(transition(state, c: c))
      }
      states = nextStates
    }

    // Check acceptance.
    for state in states {
      if accept(state) {
        return true
      }
    }
    return false
  }
}