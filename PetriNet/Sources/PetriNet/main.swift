enum P: String, Place, CustomStringConvertible {
  
  var description: String {
    self.rawValue
  }
  
  typealias Content = Int
  
  case p0, p1
  
}

enum T: String, Transition, CustomStringConvertible {
  
  var description: String {
    self.rawValue
  }
  
  case t
  
}

let net = PetriNet<P, T>(.transition(.t, arcs: .pre(from: .p0), .post(to: .p1)))

let initMarking: Marking<P> = [.p0: 1, .p1: 0]

print(initMarking)

let nextMarking = net.fire(transition: .t, from: initMarking)

print(nextMarking!)

