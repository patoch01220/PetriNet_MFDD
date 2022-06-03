import XCTest
import PetriNet
import PetriNet_MFDD

class PNTests: XCTestCase {
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
    
    
    func testConvertPre() {
        var res = pn.convertPreTransToList(trans: T.t1)
        var expectedRes = [(P.p1, 1), (P.p3, 1)]
        var resBool = res.elementsEqual(expectedRes, by: { $0 == $1 })
        XCTAssertTrue(resBool)
        
        res = pn.convertPreTransToList(trans: T.t2)
        expectedRes = [(P.p1, 2)]
        resBool = res.elementsEqual(expectedRes, by: { $0 == $1 })
        XCTAssertTrue(resBool)
        
        res = pn.convertPreTransToList(trans: T.t3)
        expectedRes = [(P.p1, 1), (P.p2, 1), (P.p4, 1)]
        resBool = res.elementsEqual(expectedRes, by: { $0 == $1 })
        XCTAssertTrue(resBool)
    }
    
    func testConvertPost() {
        
        var res = pn.convertPostTransToList(trans: T.t1)
        var expectedRes = [(P.p2, 1), (P.p4, 1)]
        var resBool = res.elementsEqual(expectedRes, by: { $0 == $1 })
        XCTAssertTrue(resBool)
        
        res = pn.convertPostTransToList(trans: T.t2)
        expectedRes = [(P.p2, 1)]
        resBool = res.elementsEqual(expectedRes, by: { $0 == $1 })
        XCTAssertTrue(resBool)
        
        res = pn.convertPostTransToList(trans: T.t3)
        expectedRes = [(P.p2, 1), (P.p3, 1)]
        resBool = res.elementsEqual(expectedRes, by: { $0 == $1 })
        XCTAssertTrue(resBool)
    }


}

