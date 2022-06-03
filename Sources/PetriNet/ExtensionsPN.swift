extension PetriNet where PlaceType: Place, TransitionType: Transition{
    

    public func convertPreTransToList(trans: TransitionType) -> [(PlaceType, PlaceType.Content)]{
        /// This function gets all preconditions from a given transition
        ///  - Parameters:
        ///             - trans: the transition
        ///  - Returns: An ordered list (according to the keys) of the preconditions
        
        var res = [(PlaceType, PlaceType.Content)]()
        
        for tr in self.input {
            if tr.0 == trans {
                let sortedByValueDictionary = tr.1.sorted { $0.0 < $1.0 }
                for (pl, mark) in sortedByValueDictionary {
                    res.append((pl, mark))
                }
                return res
            }
        }

        return res

    }
    
    public func convertPostTransToList(trans: TransitionType) -> [(PlaceType, PlaceType.Content)]{
        /// This function gets all postcondition from a given transition
        ///  - Parameters:
        ///             - trans: the transition
        ///  - Returns: An ordered list (according to the keys) of the postconditions
        
        var res = [(PlaceType, PlaceType.Content)]()
        
        for tr in self.output {
            if tr.0 == trans {
                let sortedByValueDictionary = tr.1.sorted { $0.0 < $1.0 }
                for (pl, mark) in sortedByValueDictionary {
                    res.append((pl, mark))
                }
                return res
            }
        }

        return res

    }
    
    public func getAllTransitions() -> Set<TransitionType> {
        ///Initializes a new bicycle with the provided parts and specifications.
        /// - Returns: A Set containing all transitions.
        
        var res = Set<TransitionType>()
        
        for tr in self.input {
            res.insert(tr.0)
        }
        
        for tr in self.output {
            res.insert(tr.0)
        }
        
        return res
    }

}


