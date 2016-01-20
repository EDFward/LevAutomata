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

  // TODO: DFA stepping.
  func step(ch: Character) -> State? {
    guard let index = neighbors.indexOf({ edge in
      switch edge.type {
      case .Normal(ch): return true
      default: return false
      }
    }) else {
      return nil
    }

    return neighbors[index].dest
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

  let nfa: (start: State, terminals: Set<State>)

  init(_ src: String, maxAllowedMismatch: Int) {
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

  public func test(s: String) -> Bool {
    return matchNFA(s)
  }
}