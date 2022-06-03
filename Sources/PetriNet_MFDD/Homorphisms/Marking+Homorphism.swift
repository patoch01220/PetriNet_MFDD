import DDKit
import PetriNet
import Foundation

extension MFDD where Key: Place, Value == Key.Content {
    
    public class PreMarking: Morphism, MFDDSaturable{
        /// Class that allows us to create a new MFDD (from an original one) and where preconditions of a transition has been applied
        /// - Parameters:
        ///             - factory: the factory of the MFDD on which we would like to apply the pre operation
        ///             - preconditions: list of tuples like (placeKey: precoditionValue)
        
        public typealias DD = MFDD
        
        /// preconditions needed to fire a transition
        public var preconditions: [(key: Key, value: Value)]
        public let factory: MFDDFactory<Key, Value>
        
        /// The morphism's cache.
        private var cache: [MFDD.Pointer: MFDD.Pointer] = [:]
        
        public var lowestRelevantKey: Key { preconditions.min(by: { a, b in a.key < b.key })!.key }
        
        /// Initialization
        init(preconditions: [(key: Key, value: Value)], factory: MFDDFactory<Key, Value>) {
            self.preconditions = preconditions
            self.factory = factory
        }
        
        
        public func apply(on pointer: MFDD.Pointer) -> MFDD.Pointer {
            
            // Trivial case: if the MFDD is simply Top or Bottom
            if factory.isTerminal(pointer) {
                return pointer
            }
            // If the list of precondition is empty
            if self.preconditions.isEmpty{
                return pointer
            }
            
            // Query the cache.
            if let result = cache[pointer] {
                return result
            }
            
            let result: MFDD.Pointer
            
            // We check that the key is in the list of preconditions. If this is the case we will apply the pre on the arcs
            // Else we simply continue the exploration
            if let index = preconditions.firstIndex(where: { $0.0 == pointer.pointee.key}){
                var take: [Value: MFDD.Pointer] = [:]
                
                // We iterate on all arcs
                for (key, pointer) in pointer.pointee.take {
                    // if the preconditon is satisfied on a sub-MFDD, then we add to the variable take the sub-MFDD where its value on the arc is reduced by the value of the precondition
                    if key >= preconditions[index].value{
                        let tokensNeeded = preconditions[index].value
                        take[key-tokensNeeded] = pointer
                    }// if key < precondition.value, we do nothing as the condition isn't validated (the arc is simply not taking into account and so will not even appear in our new MFDD)
                }
                
                // if we applied the last precondition, we can simply return the whole take
                if preconditions[index].key == preconditions.last?.key {
                    // Building the new MFDD
                    result = factory.node(
                        key: pointer.pointee.key,
                        take: take,
                        skip: factory.zero.pointer
                    )
                }
                // if not, then we have to continue the filter operation on the successors
                else{
                    // Building the new MFDD
                    result = factory.node(
                        key: pointer.pointee.key,
                        take: take.mapValues(apply(on:)),
                        skip: factory.zero.pointer
                    )
                }
                
            }else{
                // We continue the exploration as the actual key isn't a precondition
                result = factory.node(
                    key: pointer.pointee.key,
                    take: pointer.pointee.take.mapValues(apply(on:)),
                    skip: factory.zero.pointer
                )
            }
            cache[pointer] = result
            
            return result
        }
  
        // So PreMarking is hashable
        public func hash(into hasher: inout Hasher) {
            for (key, value) in preconditions {
                hasher.combine(key)
                hasher.combine(value)
            }
        }
        
        // So PreMarking is Equatable
        public static func == (lhs: PreMarking, rhs:  PreMarking) -> Bool {
            lhs === rhs
        }
    }
    
    public class PostMarking: Morphism, MFDDSaturable{
        /// Class that allows us to create a new MFDD (from an original one) and where postcondition of a transition has been added
        /// - Parameters:
        ///             - factory: the factory of the MFDD on which we would like to apply the post operation
        ///             - postconditions: list of tuples like (placeKey: postconditionsValue)
        
        public typealias DD = MFDD
        
        /// postconditions we need to add after firing a transition
        public var postconditions: [(key: Key, value: Value)]
        public let factory: MFDDFactory<Key, Value>
        
        /// The morphism's cache.
        private var cache: [MFDD.Pointer: MFDD.Pointer] = [:]
        
        public var lowestRelevantKey: Key { postconditions.min(by: { a, b in a.key < b.key })!.key }
        
        /// Initialization
        init(postconditions: [(key: Key, value: Value)], factory: MFDDFactory<Key, Value>) {
            self.postconditions = postconditions
            self.factory = factory
        }
        
        
        public func apply(on pointer: MFDD.Pointer) -> MFDD.Pointer {
            
            // Trivial case: if the MFDD is simply Top or Bottom
            if factory.isTerminal(pointer) {
                return pointer
            }
            // If the list of postcondition is empty
            if self.postconditions.isEmpty{
                return pointer
            }
            
            // Query the cache.
            if let result = cache[pointer] {
                return result
            }
            
            let result: MFDD.Pointer
            
            // We check that the key is in the list of postcondition. If this is the case we will apply the pre on the arcs
            // Else we simply continue the exploration
            if let index = postconditions.firstIndex(where: { $0.0 == pointer.pointee.key}){
            
                var take: [Value: MFDD.Pointer] = [:]

                // We iterate on all arcs
                for (key, pointer) in pointer.pointee.take {
                    // Adding the new arc to the takes (previous arc + postcondition)
                    let tokensNeeded = postconditions[index].value
                    take[key+tokensNeeded] = pointer
                }
                
                // if we applied the last postcondition, we can simply return the whole take
                if postconditions[index].key == postconditions.last?.key {
                    // Building the new MFDD
                    result = factory.node(
                        key: pointer.pointee.key,
                        take: take,
                        skip: factory.zero.pointer
                    )
                }
                // if not, then we have to continue the post operation on the successors
                else{
                    // Building the new MFDD
                    result = factory.node(
                        key: pointer.pointee.key,
                        take: take.mapValues(apply(on:)),
                        skip: factory.zero.pointer
                    )
                }
            }
            else {
                // We continue the exploration as the actual key isn't a postcondition
                result = factory.node(
                    key: pointer.pointee.key,
                    take: pointer.pointee.take.mapValues(apply(on:)),
                    skip: factory.zero.pointer
                )
            }
            
            cache[pointer] = result
            
            return result
        }
        
        // So the PostMarking is hashable
        public func hash(into hasher: inout Hasher) {
            for (key, value) in postconditions {
                hasher.combine(key)
                hasher.combine(value)
            }
        }
        
        // So the PostMarking is Equatable
        public static func == (lhs: PostMarking, rhs:  PostMarking) -> Bool {
            lhs === rhs
        }
    }
    
    public class FilterMarking: Morphism, MFDDSaturable{
        /// Class that allows us to Filter a MFDD given some preconditions
        /// - Parameters:
        ///             - factory: the factory of the MFDD we would like to filter
        ///             - preconditions: list of tuples like (placeKey: precoditionValue)
        
        public typealias DD = MFDD
        
        /// preconditions needed to fire a transition
        public var preconditions: [(key: Key, value: Value)]
        public let factory: MFDDFactory<Key, Value>
        
        /// The morphism's cache.
        private var cache: [MFDD.Pointer: MFDD.Pointer] = [:]
        
        public var lowestRelevantKey: Key { preconditions.min(by: { a, b in a.key < b.key })!.key }
        
        /// Initialization
        init(preconditions: [(key: Key, value: Value)], factory: MFDDFactory<Key, Value>) {
            self.preconditions = preconditions
            self.factory = factory
        }
        
        
        public func apply(on pointer: MFDD.Pointer) -> MFDD.Pointer {
            
            // Trivial case: if the MFDD is simply Top or Bottom
            if factory.isTerminal(pointer) {
                return pointer
            }
            // If the list of precondition is empty
            if self.preconditions.isEmpty{
                return pointer
            }
            
            // Query the cache.
            if let result = cache[pointer] {
                return result
            }
            
            // Case where k < k'
            let result: MFDD.Pointer
            
            // We check that the key is in the list of preconditions. If this is the case we will apply the pre on the arcs
            // Else we simply continue the exploration
            if let index = preconditions.firstIndex(where: { $0.0 == pointer.pointee.key}){
                var take: [Value: MFDD.Pointer] = [:]
                
                // We iterate on all arcs
                for (key, pointer) in pointer.pointee.take {
                    // if the preconditon is satisfied on a sub-MFDD, then we add to the variable take the sub-MFDD where its value on the arc is reduced by the value of the precondition
                    if key >= preconditions[index].value{
                        take[key] = pointer
                    }// if key < precondition.value, we do nothing as the condition isn't validated (the arc is simply not taking into account and so will not even appear in our new MFDD)
                }
                
                // if we applied the last precondition, we can simply return the whole take
                if preconditions[index].key == preconditions.last?.key {
                    // Building the new MFDD
                    result = factory.node(
                        key: pointer.pointee.key,
                        take: take,
                        skip: factory.zero.pointer
                    )
                }
                // if not, then we have to continue the filter operation on the successors
                else{
                    // Building the new MFDD
                    result = factory.node(
                        key: pointer.pointee.key,
                        take: take.mapValues(apply(on:)),
                        skip: factory.zero.pointer
                    )
                }
                
            }else{
                // We continue the exploration as the actual key isn't a precondition
                result = factory.node(
                    key: pointer.pointee.key,
                    take: pointer.pointee.take.mapValues(apply(on:)),
                    skip: factory.zero.pointer
                )
            }
            cache[pointer] = result
            
            return result
        }
        
        // So FilterMarking is hashable
        public func hash(into hasher: inout Hasher) {
            for (key, value) in preconditions {
                hasher.combine(key)
                hasher.combine(value)
            }
        }
        
        // So FilterMarking is Equatable
        public static func == (lhs: FilterMarking, rhs:  FilterMarking) -> Bool {
            lhs === rhs
        }
    }
}

extension MFDDMorphismFactory where Key: Place, Value == Key.Content {
    public func filterMarking(include preconditions: [(key: Key, value: Value)]) -> MFDD<Key, Value>.FilterMarking
    {
        return MFDD.FilterMarking(preconditions: preconditions, factory: nodeFactory)
    }
    
    public func preMarking(include preconditions: [(key: Key, value: Value)]) -> MFDD<Key, Value>.PreMarking
    {
        return MFDD.PreMarking(preconditions: preconditions, factory: nodeFactory)
    }
    
    public func postMarking(include postconditions: [(key: Key, value: Value)]) -> MFDD<Key, Value>.PostMarking
    {
        return MFDD.PostMarking(postconditions: postconditions, factory: nodeFactory)
    }
    
}
