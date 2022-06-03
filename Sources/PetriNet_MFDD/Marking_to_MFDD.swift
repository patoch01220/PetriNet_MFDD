import PetriNet
import DDKit


extension Marking where PlaceType.Content: Hashable, PlaceType: Comparable {
    public typealias KeyMarking = PlaceType
    public typealias ValueMarking = PlaceType.Content
    
    public typealias MarkingMFDD = MFDD<KeyMarking,ValueMarking>
    public typealias MarkingMFDDFactory = MFDDFactory<KeyMarking, ValueMarking>
    
    public func markingToMDFFMarking(_ markingMFDDFactory: MarkingMFDDFactory) -> MarkingMFDD{
        /// This function converts the Marking (of a Petri Net) to its corresponding MFDD
        ///  - Parameters:
        ///             - markingMFDDFactory: The factory of the MFDD
        ///  - Returns: The corresponding MFDD of the marking
        
        var markingMFDD = [KeyMarking: ValueMarking]()
        for (place, marking) in self {
            markingMFDD[place] = marking
        }
        let MFDD_res = markingMFDDFactory.encode(family: [markingMFDD])
            
        return MFDD_res
    }

}
