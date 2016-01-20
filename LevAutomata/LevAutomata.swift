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

  var hashValue: Int {
    get {
      return ObjectIdentifier(self).hashValue
    }
  }
}

func ==(lhs: State, rhs: State) -> Bool {
  return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

public class LevAutomata {

  /// Don't allow star (*) in the source string.
  let src: String

  // Default NFA.
  let nfa: (start: State, terminals: Set<State>)
  // Optional DFA.
  var dfa: (start: State, terminals: Set<State>)?

  init(_ src: String, maxAllowedMismatch: Int, compileToDFA: Bool = false) {
    if src.containsString("*") {
      fatalError("Doesn't allow stars (*) in source string.")
    } else {
      self.src = src
    }

    // Build states of size `(len(src)+1) * (maxAllowedMismatch+1)`.
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
    var alphabet = Set([Character](self.src.characters))
    // Add the star * to the alphabet to indicate any.
    alphabet.insert("*")

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
    let initNFAStates = self.nfa.start.getClosure()
    self.dfa = (start: findOrInsert(initNFAStates), terminals: Set<State>())
    var nfaStatesStack: [Set<State>] = [initNFAStates]
    var nfaStatesVisited: Set<Set<State>> = []
    while !nfaStatesStack.isEmpty {
      let poppedNFAStates = nfaStatesStack.removeLast()
      if nfaStatesVisited.contains(poppedNFAStates) { continue }

      nfaStatesVisited.insert(poppedNFAStates)
      let poppedDFAState = findOrInsert(poppedNFAStates)
      // Mark terminal if containing terminal NFA state.
      if !poppedNFAStates.isDisjointWith(self.nfa.terminals) {
        self.dfa!.terminals.insert(poppedDFAState)
      }

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

  public func test(s: String) -> Bool {
    if dfa == nil {
      return matchNFA(s)
    } else {
      return matchDFA(s)
    }
  }
}