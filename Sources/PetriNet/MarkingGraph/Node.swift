/// A node in a marking or coverability graph.
public class Node<PlaceType, TransitionType> where PlaceType: Place, TransitionType: Transition {

  /// The marking associated with this node.
  public let marking: Marking<PlaceType>

  /// This node's successors.
  public var successors: [TransitionType: Node] = [:]

  public init(marking: Marking<PlaceType>) {
    self.marking = marking
  }

}

extension Node: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }

  public static func == (lhs: Node, rhs: Node) -> Bool {
    return lhs === rhs
  }

}
