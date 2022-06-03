import XCTest
import DDKit
import PetriNet
import PetriNet_MFDD

class PN_DDKit_Packages_SimpleTests: XCTestCase {
    enum P: Place, Comparable{

      typealias Content = Int

      case p1, p2, p3, p4, p5
        
        public var description: String {
            switch self{
            case .p1:
                return "p1"
            case .p2:
                return "p2"
            case .p3:
                return "p3"
            case .p4:
                return "p4"
            case .p5:
                return "p5"
            }
        }
    }

    enum T: String, Transition, CustomStringConvertible {

      var description: String {
        self.rawValue
      }

      case t1, t2, t3

    }

    let pn = PetriNet<P, T>(

        // t1
        .pre(from: .p1, to: .t1),
        .pre(from: .p3, to: .t1),

        .post(from: .t1, to: .p2),
        .post(from: .t1, to: .p4),

        // t2
        .pre(from: .p1, to: .t2, labeled: 2),

        .post(from: .t2, to: .p2),

        // t3
        .pre(from: .p1, to: .t3),
        .pre(from: .p2, to: .t3),
        .pre(from: .p4, to: .t3),

        .post(from: .t3, to: .p2),
        .post(from: .t3, to: .p3)


    )

    let pn_initMarking: Marking<P> = [.p1: 2, .p2: 1, .p3: 1, .p4: 0, .p5: 1]

    
    func testOwnMFDD() {
        let factory = MFDDFactory<String, Int>()

        let MDFF_example = factory.encode(family: [["P1": 0, "P2": 2, "P3": 1, "P4": 0, "P5": 1], ["P1": 2, "P2": 1, "P3": 1, "P4": 0, "P5": 1], ["P1": 1, "P2": 2, "P3": 0, "P4": 1, "P5": 1]])

        XCTAssertEqual(
              MDFF_example,
              factory.encode(family: [["P1": 0, "P2": 2, "P3": 1, "P4": 0, "P5": 1], ["P1": 2, "P2": 1, "P3": 1, "P4": 0, "P5": 1], ["P1": 1, "P2": 2, "P3": 0, "P4": 1, "P5": 1]]))
    }

    func testPNMarkingToMFDDMarking() {
      
        let markingMFDDFactory = MFDDFactory<P, P.Content>()
        let pnMFDD = pn_initMarking.markingToMDFFMarking(markingMFDDFactory)

        let expected_MFDD = markingMFDDFactory.encode(family: [[P.p1: 2, P.p2: 1, P.p3: 1, P.p4: 0, P.p5: 1]])

        XCTAssertTrue(expected_MFDD == pnMFDD)
    }



  static var allTests = [
    ("testOwnMFDD", testOwnMFDD),
    ("testOwnPN", testPNMarkingToMFDDMarking),
  ]

}

