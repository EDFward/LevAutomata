/// Levenshtein Automata.
public class LevAutomata {

  // Default NFA.
  let nfa: (start: State, terminals: Set<State>)

  // Optional DFA.
  var dfa: (start: State, terminals: Set<State>)?

  init(_ src: String, maxAllowedMismatch: Int, compileToDFA: Bool = false) {
    // Don't allow star (*) in the source string.
    if src.containsString("*") {
      fatalError("Doesn't allow stars (*) in source string.")
    }

    // Build states of size (len(src)+1) * (maxAllowedMismatch+1).
    let cs = [Character](src.characters)
    let (rowCount, colCount) = (cs.count + 1, maxAllowedMismatch + 1)
    // Init 2D array with new states at each slot.
    let states: [[State]] = [Int](0..<rowCount).map { _ in
      [Int](0..<colCount).map { _ in State() }
    }
    nfa = (states[0][0], Set<State>(states.last!))

    // Lets add edges! http://blog.notdot.net/2010/07/Damn-Cool-Algorithms-Levenshtein-Automata
    for i in 0..<(rowCount - 1) {
      for j in 0..<colCount {
        let state = states[i][j]
        state.addEdge(Edge(.Normal(cs[i]), dest: states[i + 1][j]))
        if j < colCount - 1 {
          state.addEdge(Edge(.Any, dest: states[i][j + 1]))
          state.addEdge(Edge(.Any, dest:states[i + 1][j + 1]))
          state.addEdge(Edge(.Epsilon, dest: states[i + 1][j + 1]))
        }
      }
    }
    for i in 0..<(colCount - 1) {
      let state = states.last![i]
      state.addEdge(Edge(.Any, dest: states.last![i + 1]))
    }

    if compileToDFA {
      self.compileToDFA()
    }
  }

  private func compileToDFA() {
    // Mapping from NFA states to their corresponding DFA state.
    var nfa2dfa = Dictionary<Set<State>, State>()
    let findOrInsert = { (nfaStates: Set<State>) -> State in
      if let s = nfa2dfa[nfaStates] {
        return s
      } else {
        let dfaState = State()
        nfa2dfa[nfaStates] = dfaState
        return dfaState
      }
    }

    // Traverse by DFS to add edges within DFA states.
    let initNFAStates = nfa.start.getClosure()
    dfa = (start: findOrInsert(initNFAStates), terminals: Set<State>())
    var nfaStatesStack: [Set<State>] = [initNFAStates]
    var nfaStatesVisited: Set<Set<State>> = []
    while !nfaStatesStack.isEmpty {
      let poppedNFAStates = nfaStatesStack.removeLast()
      if nfaStatesVisited.contains(poppedNFAStates) { continue }

      nfaStatesVisited.insert(poppedNFAStates)
      let poppedDFAState = findOrInsert(poppedNFAStates)
      // Mark terminal if containing terminal NFA state.
      if !poppedNFAStates.isDisjointWith(nfa.terminals) {
        dfa!.terminals.insert(poppedDFAState)
      }

      // Extract edge lables from NFA states to avoid building duplicate DFA state.
      let alphabet = generateAlphabet(poppedNFAStates)
      for ch in alphabet {
        // Step.
        var nextNFAStates = poppedNFAStates.reduce(Set<State>(), combine: { (acc, state) in
          acc.union(state.step(ch))
        })
        // Then closure.
        nextNFAStates = nextNFAStates.reduce(Set<State>(), combine: { $0.union($1.getClosure()) })
        // Skip empty states.
        if nextNFAStates.isEmpty { continue }

        let nextDFAState = findOrInsert(nextNFAStates)
        // Note "*" always comes first if present.
        if ch == "*" {
          poppedDFAState.addEdge(Edge(.Any, dest: nextDFAState))
        } else {
          poppedDFAState.addEdge(Edge(.Normal(ch), dest: nextDFAState))
        }
        nfaStatesStack.append(nextNFAStates)
      }
    }
  }

  private func matchNFA(s: String) -> Bool {
    let (start, terminals) = nfa
    var states = start.getClosure()
    for ch in s.characters {
      states = states.reduce(Set<State>(), combine: { (acc, state) in
        acc.union(state.step(ch))
      })
      if states.isEmpty {
        return false
      }
    }
    // Get the final set of states included in their closures.
    states = states.reduce(Set<State>(), combine: { $0.union($1.getClosure()) })
    return !states.isDisjointWith(terminals)
  }


  private func matchDFA(s: String) -> Bool {
    let (start, terminals) = dfa!
    var state = start
    for ch in s.characters {
      if let newState: State = state.step(ch) {
        state = newState
      } else {
        return false
      }
    }
    return terminals.contains(state)
  }

  // Algorithm from http://blog.notdot.net/2010/07/Damn-Cool-Algorithms-Levenshtein-Automata
  public func findNextValidWord(s: String) -> String? {
    if dfa == nil {
      fatalError("DFA doesn't exist, can't find next valid word.")
    } else if s.isEmpty {
      fatalError("Empty word not allowed.")
    }

    let (start, terminals) = dfa!
    let cs = [Character](s.characters)

    typealias PathState = (state: State, inputCh: Character, acc: String)
    var stack: [PathState] = []
    var state: State? = start

    for (i, ch) in cs.enumerate() {
      // State can't be null. Otherwise the loop would have already terminated.
      stack.append((state!, ch, String(cs[0..<i])))
      state = state!.step(ch)
      if state == nil {
        break
      }
    }

    if state != nil {
      if terminals.contains(state!) {
        return s
      } else {
        // Loop ends normally, append final state and a dummy character
        // which will be used later to find lexicographically nearest edge / state.
        stack.append((state!, State.nullCharacter, String(cs[0..<stack.count])))
      }
    }

    while !stack.isEmpty {
      let (state, inputCh, path) = stack.popLast()!
      if let (nextCh, nextState) = findNextPossibleState(state, inputCh) {
        if terminals.contains(nextState) {
          var res = path
          res.append(nextCh)
          return res
        }

        stack.append((nextState, State.nullCharacter, path + String(nextCh)))
      }
    }
    return nil
  }

  private func findNextPossibleState(state: State, _ ch: Character) -> (Character, State)? {
    // Note that it works for null character from State, since its successor would be "A".
    let nextCh = Character(UnicodeScalar(ch.asciiValue + 1))
    if let nextState: State = state.step(nextCh) {
      return (nextCh, nextState)
    } else {
      return state.findNearestState(nextCh)
    }
  }

  public func test(s: String) -> Bool {
    if dfa == nil {
      return matchNFA(s)
    } else {
      return matchDFA(s)
    }
  }
}

extension Character {
  var asciiValue: UInt32 {
    return String(self).unicodeScalars.first!.value
  }
}