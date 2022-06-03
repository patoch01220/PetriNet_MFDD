import XCTest
import DDKit
import PetriNet
import PetriNet_MFDD

class StateSpaceTests: XCTestCase {
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
    
    // ------------------------------------------------------------------------
    
    /// Place in the model implementing the Smokers' Problem.
    public enum SmokerPlace: Place {
        
        public typealias Content = Int
        
        
        // MARK: Places representing the state of the table.
        
        /// Indicates that there's tobacco on the table.
        case tobacco
        /// Indicates that there isn't any tobacco on the table.
        case tobaccoEmpty
        /// Indicates that there's paper on the table.
        case paper
        /// Indicates that there isn't any paper on the table.
        case paperEmpty
        /// Indicates that there's a match on the table.
        case match
        /// Indicates that there isn't any match on the table.
        case matchEmpty
        /// Bounds the maximum number of ingredients placed on the table.
        case freeSpace
        
        // MARK: Places representing the state of the smoker who's got rolling paper.
        
        case smokerWithPaperWaitsForBoth
        case smokerWithPaperWaitsForMatch
        case smokerWithPaperWaitsForTobacco
        
        // MARK: Places representing the state of the smoker who's got tobacco.
        
        case smokerWithTobaccoWaitsForBoth
        case smokerWithTobaccoWaitsForMatch
        case smokerWithTobaccoWaitsForPaper
        
        // MARK: Places representing the state of the smoker who's got matches.
        
        case smokerWithMatchesWaitsForBoth
        case smokerWithMatchesWaitsForPaper
        case smokerWithMatchesWaitsForTobacco
        
    }
    
    /// Transition in the model implementing the Smokers' Problem.
    public enum SmokerTransition: String, Transition, CustomStringConvertible {
        
        public var description: String {
            return rawValue
        }
        
        // MARK: Transitions representing the referee's behavior.
        
        /// Puts a unit of tobacco on the table.
        case putTobacco
        /// Puts a sheet of rolling paper on the table.
        case putPaper
        /// Puts a match on the table.
        case putMatch
        
        // MARK: Transitions representing the behavior of the smoker who's got rolling paper.
        
        case smokerWithPaperTakesTobaccoFirst
        case smokerWithPaperTakesTobaccoSecond
        case smokerWithPaperTakesMatchFirst
        case smokerWithPaperTakesMatchSecond
        
        // MARK: Transitions representing the behavior of the smoker who's got tobacco.
        
        case smokerWithTobaccoTakesMatchFirst
        case smokerWithTobaccoTakesMatchSecond
        case smokerWithTobaccoTakesPaperFirst
        case smokerWithTobaccoTakesPaperSecond
        
        // MARK: Transitions representing the behavior of the smoker who's got matches.
        
        case smokerWithMatchesTakesTobaccoFirst
        case smokerWithMatchesTakesTobaccoSecond
        case smokerWithMatchesTakesPaperFirst
        case smokerWithMatchesTakesPaperSecond
        
    }
    
    /// The model of the Smokers' Problem.
    ///
    /// Complete the definition to implement the behavior of the two missing smokers.
    public let smokerModel = PetriNet<SmokerPlace, SmokerTransition>.init(
        .transition(.putTobacco, arcs:
                            .pre (from: .freeSpace),
                    .pre (from: .tobaccoEmpty),
                    .post(to  : .tobacco)),
        
            .transition(.putMatch, arcs:
                                .pre (from: .freeSpace),
                        .pre (from: .matchEmpty),
                        .post(to  : .match)),
        
            .transition(.putPaper, arcs:
                                .pre (from: .freeSpace),
                        .pre (from: .paperEmpty),
                        .post(to  : .paper)),
        
        // MARK: Smoker with Paper
        .transition(.smokerWithPaperTakesTobaccoFirst, arcs:
                            .pre (from: .tobacco),
                    .pre (from: .smokerWithPaperWaitsForBoth),
                    .post(to  : .freeSpace),
                    .post(to  : .tobaccoEmpty),
                    .post(to  : .smokerWithPaperWaitsForMatch)),
        
            .transition(.smokerWithPaperTakesMatchFirst, arcs:
                                .pre (from: .match),
                        .pre (from: .smokerWithPaperWaitsForBoth),
                        .post(to  : .freeSpace),
                        .post(to  : .matchEmpty),
                        .post(to  : .smokerWithPaperWaitsForTobacco)),
        
            .transition(.smokerWithPaperTakesTobaccoSecond, arcs:
                                .pre (from: .tobacco),
                        .pre (from: .smokerWithPaperWaitsForTobacco),
                        .post(to  : .freeSpace),
                        .post(to  : .tobaccoEmpty),
                        .post(to  : .smokerWithPaperWaitsForBoth)),
        
            .transition(.smokerWithPaperTakesMatchSecond, arcs:
                                .pre (from: .match),
                        .pre (from: .smokerWithPaperWaitsForMatch),
                        .post(to  : .freeSpace),
                        .post(to  : .matchEmpty),
                        .post(to  : .smokerWithPaperWaitsForBoth)),
        
        
        // MARK: Smoker with Tobacco
        .transition(.smokerWithTobaccoTakesMatchFirst, arcs:
                            .pre (from: .match),
                    .pre (from: .smokerWithTobaccoWaitsForBoth),
                    .post(to  : .freeSpace),
                    .post(to  : .matchEmpty),
                    .post(to  : .smokerWithTobaccoWaitsForPaper)),
        
            .transition(.smokerWithTobaccoTakesPaperFirst, arcs:
                                .pre (from: .paper),
                        .pre (from: .smokerWithTobaccoWaitsForBoth),
                        .post(to  : .freeSpace),
                        .post(to  : .paperEmpty),
                        .post(to  : .smokerWithTobaccoWaitsForMatch)),
        
            .transition(.smokerWithTobaccoTakesMatchSecond, arcs:
                                .pre (from: .match),
                        .pre (from: .smokerWithTobaccoWaitsForMatch),
                        .post(to  : .freeSpace),
                        .post(to  : .matchEmpty),
                        .post(to  : .smokerWithTobaccoWaitsForBoth)),
        
            .transition(.smokerWithTobaccoTakesPaperSecond, arcs:
                                .pre (from: .paper),
                        .pre (from: .smokerWithTobaccoWaitsForPaper),
                        .post(to  : .freeSpace),
                        .post(to  : .paperEmpty),
                        .post(to  : .smokerWithTobaccoWaitsForBoth)),
        
        
        // MARK: Smoker with matches
        .transition(.smokerWithMatchesTakesTobaccoFirst, arcs:
                            .pre (from: .tobacco),
                    .pre (from: .smokerWithMatchesWaitsForBoth),
                    .post(to  : .freeSpace),
                    .post(to  : .tobaccoEmpty),
                    .post(to  : .smokerWithMatchesWaitsForPaper)),
        
            .transition(.smokerWithMatchesTakesPaperFirst, arcs:
                                .pre (from: .paper),
                        .pre (from: .smokerWithMatchesWaitsForBoth),
                        .post(to  : .freeSpace),
                        .post(to  : .paperEmpty),
                        .post(to  : .smokerWithMatchesWaitsForTobacco)),
        
            .transition(.smokerWithMatchesTakesTobaccoSecond, arcs:
                                .pre (from: .tobacco),
                        .pre (from: .smokerWithMatchesWaitsForTobacco),
                        .post(to  : .freeSpace),
                        .post(to  : .tobaccoEmpty),
                        .post(to  : .smokerWithMatchesWaitsForBoth)),
        
            .transition(.smokerWithMatchesTakesPaperSecond, arcs:
                                .pre (from: .paper),
                        .pre (from: .smokerWithMatchesWaitsForPaper),
                        .post(to  : .freeSpace),
                        .post(to  : .paperEmpty),
                        .post(to  : .smokerWithMatchesWaitsForBoth)))
    
    
    
    /// The initial marking of the model implementing Smokers' Problem.
    public let smokerModelInitialMarking = Marking<SmokerPlace>(partial: [
        .freeSpace                    : 2,
        .tobaccoEmpty                 : 1,
        .matchEmpty                   : 1,
        .paperEmpty                   : 1,
        .smokerWithPaperWaitsForBoth  : 1,
        .smokerWithTobaccoWaitsForBoth: 1,
        .smokerWithMatchesWaitsForBoth: 1,
        
    ])
    

    
    func testComputeStateSpace(){
        let facto = MFDDFactory<P, P.Content>()
        let pnToMFDD = pn_initMarking.markingToMDFFMarking(facto)
        
        let res = pn.computeStateSpac(facto, pnToMFDD)
        let expectedMFDD = facto.encode(family: [[.p3: 0, .p1: 1, .p4: 1, .p5: 1, .p2: 2], [.p3: 1, .p2: 2, .p4: 0, .p5: 1, .p1: 0], [.p3: 1, .p2: 1, .p4: 0, .p5: 1, .p1: 2]])
        XCTAssertEqual(res, expectedMFDD)
        
    }
    
    
    
    func testComputeStateSpaceSmoker(){
        let facto = MFDDFactory<SmokerPlace, SmokerPlace.Content>()
        let pnToMFDD = smokerModelInitialMarking.markingToMDFFMarking(facto)
        
        var start = DispatchTime.now() // <<<<<<<<<< Start time
        let res = smokerModel.computeStateSpac(facto, pnToMFDD)
        var end = DispatchTime.now()   // <<<<<<<<<<   end time
        
        print("--------")
        var nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
        var timeInterval = Double(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests
        print("Computation time using MFDD:\t\t \(timeInterval)")
        
        start = DispatchTime.now() // <<<<<<<<<< Start time
        let res2 = smokerModel.markingGraph(from: smokerModelInitialMarking)
        end = DispatchTime.now()   // <<<<<<<<<<   end time
        
        nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
        timeInterval = Double(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests
        print("Computation Time using PetriNet:\t \(timeInterval)")
        
        print("StateSpace size using MFDD:\t\t\t \(res.count)")
        print("StateSpace size using Petri Net:\t \(String(describing: res2?.count))")
        print("--------")
        
        XCTAssertEqual(res2?.count, res.count)
        
    }
    
}

