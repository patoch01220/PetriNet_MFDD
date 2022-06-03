import XCTest
import DDKit
import PetriNet
import PetriNet_MFDD

class FireTests: XCTestCase {
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

    
    
    func testSimpleFire(){
        let facto = MFDDFactory<P, P.Content>()
        let pnToMFDD = pn_initMarking.markingToMDFFMarking(facto)
        
        let res = pn.fireMFDD(facto, pnToMFDD, .t1)
        
        let expectedMFDD = facto.encode(family: [[.p1: 2, .p2: 1, .p3: 1, .p4: 0, .p5: 1], [.p1: 1, .p2: 2, .p3: 0, .p4: 1, .p5: 1]])
        
        XCTAssertEqual(res , expectedMFDD)
    }

    
}

