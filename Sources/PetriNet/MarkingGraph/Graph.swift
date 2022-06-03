/// A marking or coverability graph.
public struct Graph<PlaceType, TransitionType>
  where PlaceType: Place, TransitionType: Transition
{

  /// The root of the graph.
  public let root: Node<PlaceType, TransitionType>

  /// Creates a marking graph from the given root.
  ///
  /// - Parameter root: The root of the marking graph.
  public init(root: Node<PlaceType, TransitionType>) {
    self.root = root
  }

}

extension Graph: Sequence {

  public func makeIterator() -> AnyIterator<Node<PlaceType, TransitionType>> {
    var unprocessed = Set([root])
    var processed: Set<Node<PlaceType, TransitionType>> = []

    return AnyIterator {
      guard let node = unprocessed.popFirst()
        else { return nil }

      processed.insert(node)
      unprocessed.formUnion(Set(node.successors.values).subtracting(processed))
      assert(processed.intersection(unprocessed).isEmpty)
      return node
    }
  }

  /// The number of states in the graph.
  public var count: Int {
    return reduce(0) { result, _ in result + 1 }
  }

}
