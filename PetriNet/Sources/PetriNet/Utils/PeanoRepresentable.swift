/// A type that has can be mapped onto a Peano-like representation.
///
/// This protocol is used for types that can be represented with three constructors:
/// - a constant `zero`,
/// - a `successor` function sending a value to the next one,
/// - a `predecessor` function sending a value to the previous one.
///
/// This representation is reminiscent of Peano numbers (hence the name of the protocol), although
/// not completely analoguous. In particular, it does not assume `zero` to be the lowest bound.
public protocol PeanoRepresentable: Equatable {

  /// The zero value.
  static var zero: Self { get }

  /// The successor of an element.
  static func successor(of: Self) -> Self

  /// The predecessor of an element.
  static func predecessor(of: Self) -> Self

  /// Returns whether the value of the first argument is less than that of the second argument.
  ///
  /// - Parameters:
  ///   - lhs: A value to compare.
  ///   - rhs: Another value to compare.
  static func < (lhs: Self, rhs: Self) -> Bool

  /// Returns whether the value of the first argument is less than or equal to that of the second
  /// argument.
  ///
  /// - Parameters:
  ///   - lhs: A value to compare.
  ///   - rhs: Another value to compare.
  static func <= (lhs: Self, rhs: Self) -> Bool

}

extension PeanoRepresentable {

  static func <= (lhs: Self, rhs: Self) -> Bool {
    return lhs == rhs || lhs < rhs
  }

}

extension Int: PeanoRepresentable {

  public static func successor(of i: Int) -> Int {
    return i + 1
  }

  public static func predecessor(of i: Int) -> Int {
    return i - 1
  }

}
