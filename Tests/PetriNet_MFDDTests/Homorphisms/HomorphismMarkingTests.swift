import XCTest
import DDKit
import PetriNet
import PetriNet_MFDD


class HomorphimsMarkingTest: XCTestCase {
    enum P: Place, Hashable, Comparable{
        
        typealias Content = Int
        
        case p1, p2
        
        public var description: String {
            switch self{
            case .p1:
                return "p1"
            case .p2:
                return "p2"
            }
        }
        
    }
    
    enum T: String, Transition, CustomStringConvertible {
        
        var description: String {
            self.rawValue
        }
        
        case t1, t2
        
    }
    
    let pn = PetriNet<P, T>(
        // t1
        .pre(from: .p1, to: .t1),
        .post(from: .t1, to: .p2),
        
        // t2
        .pre(from: .p2, to: .t2)
        
    )
    
    let pn_initMarking: Marking<P> = [.p1: 1, .p2: 0]
    
    //--- Filter Test ----------------------------------------------------------------------
    
    func testEmptyFilterMFDD(){
        let markingMFDDFactory = MFDDFactory<P, P.Content>()
        let emptyMFDD = markingMFDDFactory.encode(family: [[]])
        
        var morphisms: MFDDMorphismFactory<P, P.Content> { markingMFDDFactory.morphisms }
        
        let filter = morphisms.filterMarking(include: [(key: .p1, value: 3)])
        
        XCTAssertEqual(filter.apply(on: emptyMFDD), emptyMFDD)
    }
    
    func testEmptyPrecondFilterMFDD(){
        let markingMFDDFactory = MFDDFactory<P, P.Content>()
        let pnToMFDD = markingMFDDFactory.encode(family: [[.p1: 1, .p2:1]])
        
        var morphisms: MFDDMorphismFactory<P, P.Content> { markingMFDDFactory.morphisms }
        
        let filter = morphisms.filterMarking(include: [])
        
        XCTAssertEqual(filter.apply(on: pnToMFDD), pnToMFDD)
    }
    
    
    func testFilterOneCaseOnSimpleMFDD(){
        let markingMFDDFactory = MFDDFactory<P, P.Content>()
        let pnToMFDD = markingMFDDFactory.encode(family: [[.p1: 1, .p2:1]])

        var morphisms: MFDDMorphismFactory<P, P.Content> { markingMFDDFactory.morphisms }
        
        var filterWorking_p1 = morphisms.filterMarking(include: [(key: .p1, value: 0)])
        XCTAssertEqual(filterWorking_p1.apply(on: pnToMFDD), pnToMFDD)
        
        filterWorking_p1 = morphisms.filterMarking(include: [(key: .p1, value: 1)])
        XCTAssertEqual(filterWorking_p1.apply(on: pnToMFDD), pnToMFDD)
        
        let filterNotWorking_p1 = morphisms.filterMarking(include: [(key: .p1, value: 2)])
        XCTAssertEqual(filterNotWorking_p1.apply(on: pnToMFDD), markingMFDDFactory.zero)
        
        var filterWorking_p2 = morphisms.filterMarking(include: [(key: .p2, value: 0)])
        XCTAssertEqual(filterWorking_p2.apply(on: pnToMFDD), pnToMFDD)
        
        filterWorking_p2 = morphisms.filterMarking(include: [(key: .p2, value: 1)])
        XCTAssertEqual(filterWorking_p2.apply(on: pnToMFDD), pnToMFDD)
        
        let filterNotWorking_p2 = morphisms.filterMarking(include: [(key: .p2, value: 2)])
        XCTAssertEqual(filterNotWorking_p2.apply(on: pnToMFDD), markingMFDDFactory.zero)
    }
    
    
    func testFilterTwoCasesOnSimpleMFDD(){
        let markingMFDDFactory = MFDDFactory<P, P.Content>()
        let pnToMFDD = markingMFDDFactory.encode(family: [[.p1: 1, .p2:1]])
        
        var morphisms: MFDDMorphismFactory<P, P.Content> { markingMFDDFactory.morphisms }
        
        let filterWorking = morphisms.filterMarking(include: [(key: .p1, value: 1), (key: .p2, value: 1)])
        XCTAssertEqual(filterWorking.apply(on: pnToMFDD), pnToMFDD)
        
        let filterNotWorking_p1 = morphisms.filterMarking(include: [(key: .p1, value: 2), (key: .p2, value: 1)])
        XCTAssertEqual(filterNotWorking_p1.apply(on: pnToMFDD), markingMFDDFactory.zero)
        
        let filterNotWorking_p2 = morphisms.filterMarking(include: [(key: .p1, value: 1), (key: .p2, value: 2)])
        XCTAssertEqual(filterNotWorking_p2.apply(on: pnToMFDD), markingMFDDFactory.zero)
        
    }
    
    //--- Pre Test ----------------------------------------------------------------------
    
    func testEmptyPreMFDD(){
        let markingMFDDFactory = MFDDFactory<P, P.Content>()
        let emptyMFDD = markingMFDDFactory.encode(family: [[]])
        
        var morphisms: MFDDMorphismFactory<P, P.Content> { markingMFDDFactory.morphisms }
        
        let pre = morphisms.preMarking(include: [(key: .p1, value: 3)])
        
        XCTAssertEqual(pre.apply(on: emptyMFDD), emptyMFDD)
    }
    
    func testEmptyPrecondPreMFDD(){
        let markingMFDDFactory = MFDDFactory<P, P.Content>()
        let pnToMFDD = markingMFDDFactory.encode(family: [[.p1: 1, .p2:1]])
        
        var morphisms: MFDDMorphismFactory<P, P.Content> { markingMFDDFactory.morphisms }
        
        let pre = morphisms.preMarking(include: [])
        
        XCTAssertEqual(pre.apply(on: pnToMFDD), pnToMFDD)
    }
    
    func testPreOneCaseOnSimpleMFDD(){
        let markingMFDDFactory = MFDDFactory<P, P.Content>()
        let pnToMFDD = markingMFDDFactory.encode(family: [[.p1: 1, .p2:1]])
        
        var morphisms: MFDDMorphismFactory<P, P.Content> { markingMFDDFactory.morphisms }
        
        var expectedMFDD = markingMFDDFactory.encode(family: [[.p1: 0, .p2:1]])
        let preWorking_p1 = morphisms.preMarking(include: [(key: .p1, value: 1)])
        XCTAssertEqual(preWorking_p1.apply(on: pnToMFDD), expectedMFDD)
        
        let preNotWorking_p1 = morphisms.preMarking(include: [(key: .p1, value: 2)])
        XCTAssertEqual(preNotWorking_p1.apply(on: pnToMFDD), markingMFDDFactory.zero)
        
        expectedMFDD = markingMFDDFactory.encode(family: [[.p1: 1, .p2:0]])
        let preWorking_p2 = morphisms.preMarking(include: [(key: .p2, value: 1)])
        XCTAssertEqual(preWorking_p2.apply(on: pnToMFDD), expectedMFDD)
        
        let preNotWorking_p2 = morphisms.preMarking(include: [(key: .p2, value: 2)])
        XCTAssertEqual(preNotWorking_p2.apply(on: pnToMFDD), markingMFDDFactory.zero)
        
    }
    
    func testPreTwoCasesOnSimpleMFDD(){
        let markingMFDDFactory = MFDDFactory<P, P.Content>()
        let pnToMFDD = markingMFDDFactory.encode(family: [[.p1: 1, .p2:1]])
        
        var morphisms: MFDDMorphismFactory<P, P.Content> { markingMFDDFactory.morphisms }
        
        let expectedMFDD = markingMFDDFactory.encode(family: [[.p1: 0, .p2:0]])
        let preWorking = morphisms.preMarking(include: [(key: .p1, value: 1), (key: .p2, value: 1)])
        XCTAssertEqual(preWorking.apply(on: pnToMFDD), expectedMFDD)
        
        let filterNotWorking_p1 = morphisms.filterMarking(include: [(key: .p1, value: 2), (key: .p2, value: 1)])
        XCTAssertEqual(filterNotWorking_p1.apply(on: pnToMFDD), markingMFDDFactory.zero)
        
        let filterNotWorking_p2 = morphisms.filterMarking(include: [(key: .p1, value: 1), (key: .p2, value: 2)])
        XCTAssertEqual(filterNotWorking_p2.apply(on: pnToMFDD), markingMFDDFactory.zero)
        
    }
    
    //--- Post Test ----------------------------------------------------------------------
    
    func testEmptyPostOnSimpleMFDD(){
        let markingMFDDFactory = MFDDFactory<P, P.Content>()
        let emptyMFDD = markingMFDDFactory.encode(family: [[]])
        
        var morphisms: MFDDMorphismFactory<P, P.Content> { markingMFDDFactory.morphisms }
        
        let post = morphisms.postMarking(include: [(key: .p1, value: 3)])
        
        XCTAssertEqual(post.apply(on: emptyMFDD), emptyMFDD)
    }
    
    func testEmptyPostcondPostMFDD(){
        let markingMFDDFactory = MFDDFactory<P, P.Content>()
        let pnToMFDD = markingMFDDFactory.encode(family: [[.p1: 1, .p2:1]])
        
        var morphisms: MFDDMorphismFactory<P, P.Content> { markingMFDDFactory.morphisms }
        
        let post = morphisms.postMarking(include: [])
        
        XCTAssertEqual(post.apply(on: pnToMFDD), pnToMFDD)
    }
    
    
    func testPostOnSimpleMFDD(){
        let markingMFDDFactory = MFDDFactory<P, P.Content>()
        let pnToMFDD = markingMFDDFactory.encode(family: [[.p1: 1, .p2:1]])
        
        var morphisms: MFDDMorphismFactory<P, P.Content> { markingMFDDFactory.morphisms }
        
        var expectedMFDD = markingMFDDFactory.encode(family: [[.p1: 2, .p2:1]])
        let postWorking_p1 = morphisms.postMarking(include: [(key: .p1, value: 1)])
        XCTAssertEqual(postWorking_p1.apply(on: pnToMFDD), expectedMFDD)
        
        expectedMFDD = markingMFDDFactory.encode(family: [[.p1: 1, .p2:2]])
        let postWorking_p2 = morphisms.postMarking(include: [(key: .p2, value: 1)])
        XCTAssertEqual(postWorking_p2.apply(on: pnToMFDD), expectedMFDD)
        
        expectedMFDD = markingMFDDFactory.encode(family: [[.p1: 2, .p2:2]])
        let postWorking_p1_p2 = morphisms.postMarking(include: [(key: .p1, value: 1), (key: .p2, value: 1)])
        XCTAssertEqual(postWorking_p1_p2.apply(on: pnToMFDD), expectedMFDD)
    }
    
}

