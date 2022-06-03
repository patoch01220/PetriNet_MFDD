/// A marking of a Petri net.
///
/// A marking is a mapping that associates the places of a Petri net to the tokens they contain.
///
/// An algebra is defined over markings. The following example illustrates how to perform
/// arithmetic operations of markings:
///
///     let m0: Marking<P> = [.p0: 1, .p1: 2]
///     let m1: Marking<P> = [.p0: 0, .p1: 2]
///     print(m0 + m1)
///     // Prints "[.p0: 1, .p1: 4]"
///     print(m0 > m1)
///     // Prints "True"
///
public struct Marking<PlaceType> where PlaceType: Place {

  /// The total map that backs this marking.
  fileprivate var storage: TotalMap<PlaceType, PlaceType.Content>

  /// Initializes a marking with a total map.
  ///
  /// - Parameter mapping: A total map representing this marking.
  public init(_ mapping: TotalMap<PlaceType, PlaceType.Content>) {
    self.storage = mapping
  }

  /// Initializes a marking with a dictionary.
  ///
  /// - Parameters:
  ///   - mapping: A dictionary representing this marking.
  ///
  /// The following example illustrates the use of this initializer:
  ///
  ///     let marking = Marking([.p0: 42, .p1: 1337])
  ///
  /// - Warning:
  ///   The given dictionary must be defined for all places, otherwise an error will be triggered
  ///   at runtime.
  public init(_ mapping: [PlaceType: PlaceType.Content]) {
    self.storage = TotalMap(mapping)
  }

  /// Initializes a marking with a function.
  ///
  /// - Parameter mapping: A function mapping places to the tokens they contain.
  ///
  /// The following example illustrates the use of this initializer:
  ///
  ///     let marking = Marking { place in
  ///       switch place {
  ///       case .p0: return 42
  ///       case .p1: return 1337
  ///       }
  ///     }
  ///
  public init(_ mapping: (PlaceType) throws -> PlaceType.Content) rethrows {
    self.storage = try TotalMap(mapping)
  }

  /// Accesses the tokens associated with the given place for reading and writing.
  public subscript(place: PlaceType) -> PlaceType.Content {
    get { return storage[place] }
    set { storage[place] = newValue }
  }

  /// A collection containing just the places of the marking.
  public var places: PlaceType.AllCases {
    return PlaceType.allCases
  }

}

extension Marking: ExpressibleByDictionaryLiteral {

  public init(dictionaryLiteral elements: (PlaceType, PlaceType.Content)...) {
    let mapping = Dictionary(uniqueKeysWithValues: elements)
    self.storage = TotalMap(mapping)
  }

}

extension Marking: Equatable {}

extension Marking: Hashable where PlaceType.Content: Hashable {}

extension Marking {

  /// Returns whether the first marking is less than the second one.
  ///
  /// - Parameters:
  ///   - lhs: A marking to compare.
  ///   - rhs: Another marking to compare.
  ///
  /// - Note: This operator does not denote a total order. More specifically, it does not satisfy
  ///   connexity (i.e., `m < n || n < m` does not necessarily hold).
  public static func < (lhs: Marking, rhs: Marking) -> Bool {
    var smaller = false
    for place in PlaceType.allCases {
      if lhs[place] < rhs[place] {
        smaller = true
      } else if lhs[place] != rhs[place] {
        return false
      }
    }
    return smaller
  }

  /// Returns whether the first marking is less than or equal to the second one.
  ///
  /// - Parameters:
  ///   - lhs: A marking to compare.
  ///   - rhs: Another marking to compare.
  public static func <= (lhs: Marking, rhs: Marking) -> Bool {
    return lhs < rhs || lhs == rhs
  }

  /// Returns whether the first marking is greater than the second one.
  ///
  /// - Parameters:
  ///   - lhs: A marking to compare.
  ///   - rhs: Another marking to compare.
  ///
  /// - Note: This operator does not denote a total order. More specifically, it does not satisfy
  ///   connexity (i.e., `m > n || n > m` does not necessarily hold).
  public static func > (lhs: Marking, rhs: Marking) -> Bool {
    var greater = false
    for place in PlaceType.allCases {
      if rhs[place] < lhs[place] {
        greater = true
      } else if lhs[place] != rhs[place] {
        return false
      }
    }
    return greater
  }

  /// Returns whether the first marking is greater than or equal to the second one.
  ///
  /// - Parameters:
  ///   - lhs: A marking to compare.
  ///   - rhs: Another marking to compare.
  public static func >= (lhs: Marking, rhs: Marking) -> Bool {
    return lhs > rhs || lhs == rhs
  }

}

extension Marking: AdditiveArithmetic {

  /// Initializes a marking with a dictionary, associating `PlaceType.Content.zero` for unassigned
  /// places.
  ///
  /// - Parameter mapping: A dictionary representing this marking.
  ///
  /// The following example illustrates the use of this initializer:
  ///
  ///     let marking = Marking([.p0: 42])
  ///     print(marking)
  ///     // Prints "[.p0: 42, .p1: 0]"
  ///
  public init(partial mapping: [PlaceType: PlaceType.Content]) {
    self.storage = TotalMap(partial: mapping, defaultValue: .zero)
  }

  /// A marking in which all places are associated with `PlaceType.Content.zero`.
  public static var zero: Marking {
    return Marking { _ in PlaceType.Content.zero }
  }

  public static func + (lhs: Marking, rhs: Marking) -> Marking {
    return Marking { key in lhs[key] + rhs[key] }
  }

  public static func += (lhs: inout Marking, rhs: Marking) {
    for place in PlaceType.allCases {
      lhs[place] += rhs[place]
    }
  }

  public static func - (lhs: Marking, rhs: Marking) -> Marking {
    return Marking { place in lhs[place] - rhs[place] }
  }

  public static func -= (lhs: inout Marking, rhs: Marking) {
    for place in PlaceType.allCases {
      lhs[place] -= rhs[place]
    }
  }

}

extension Marking: Collection {

  public typealias Index = TotalMap<PlaceType, PlaceType.Content>.Index

  public typealias Element = TotalMap<PlaceType, PlaceType.Content>.Element

  public var startIndex: Index {
    return storage.startIndex
  }

  public var endIndex: Index {
    return storage.endIndex
  }

  public func index(after i: Index) -> Index {
    return storage.index(after: i)
  }

  public subscript(position: Index) -> Element {
    storage[position]
  }

}

extension Marking: CustomStringConvertible {

  public var description: String {
    return String(describing: storage)
  }

}
