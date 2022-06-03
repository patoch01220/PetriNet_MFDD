extension PetriNet {

  /// Compute this model's marking graph, from the given initial marking.
  ///
  /// - Parameter marking: The model from for which the marking graph is created.
  ///
  /// - Returns: A marking graph is the model is bounded, or `nil` otherwise.
  public func markingGraph(from marking: Marking<PlaceType>)
    -> Graph<PlaceType, TransitionType>?
  {
    // The root of the graph is the initial marking.
    let root = Node<PlaceType, TransitionType>(marking: marking)

    // Create arrays to keep track of the nodes that have been created, and the ones that have yet
    // to be traversed by the algorithm.
    var created = [root]
    var unprocessed = [root]

    while let node = unprocessed.popLast() {
      for transition in TransitionType.allCases {
        // Compute the current marking's successors for all fireable transitions.
        guard let nextMarking = fire(transition: transition, from: node.marking)
          else { continue }

        // Check if this particular successor has already been created.
        if let successor = created.first(where : { n in nextMarking == n.marking }) {
          node.successors[transition] = successor
          continue
        }

        // Check that the model is bounded.
        guard created.allSatisfy({ n in !(nextMarking > n.marking) })
          else { return nil }

        // The successor hasn't been created yet, so add it to the list of unprocessed nodes.
        let successor = Node<PlaceType, TransitionType>(marking: nextMarking)
        created.append(successor)
        unprocessed.append(successor)
        node.successors[transition] = successor
      }
    }

    return Graph(root: root)
  }

}
