import DDKit
import PetriNet
 
 
extension PetriNet where PlaceType.Content: Hashable{
    public typealias Place = PlaceType
    public typealias PlaceContent = PlaceType.Content
 
    public typealias factoryMFDD = MFDDFactory<Place, PlaceContent>
    public typealias MarkingMFDD = MFDD<Place, PlaceContent>
 
    public func fireMFDD(_ factory: factoryMFDD, _ markingDD: MarkingMFDD, _ t: TransitionType) -> MFDD<Place, PlaceContent> {
        /// This function fire the transition using MFDD
        ///  - Parameters:
        ///             - factory: the factory of the MFDD
        ///             - markingDD: the current MFDD
        ///             - t: the transition to fire
        ///  - Returns: The updated MFDD after firing the transition
    
        let preconditions: [(Place, PlaceContent)] = self.convertPreTransToList(trans: t)
        let postconditions: [(Place, PlaceContent)] = self.convertPostTransToList(trans: t)
 
 
        let pre = factory.morphisms.preMarking(include: preconditions).apply(on: markingDD)
 
        let post = factory.morphisms.postMarking(include: postconditions).apply(on: pre)
 
        let res = markingDD.union(post)
 
        return res
 
    }
 
    public func computeStateSpac(_ factory: factoryMFDD, _ initDD: MarkingMFDD) -> MFDD<Place, PlaceContent> {
        /// This function computes the state space of the Petri Net using MFDD
        ///  - Parameters:
        ///             - factory: the factory of the MFDD
        ///             - markingDD: the initial MFDD (from the initial marking)
        ///  - Returns: The final MFDD with full state space
 
        var curr_dd = initDD
 
        let all_trans = self.getAllTransitions()
        
        var old_DD = curr_dd
        repeat {
            old_DD = curr_dd
            for t in all_trans {
                curr_dd = fireMFDD(factory, curr_dd, t)
            }
        } while old_DD != curr_dd;
                    
        return curr_dd
    }
 
 
}
