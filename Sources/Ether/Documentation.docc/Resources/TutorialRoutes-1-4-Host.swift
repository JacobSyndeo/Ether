import Foundation
import Ether

enum SWRoutes: Ether.Route {
    case people(Int)
    
    var asURL: URL {
        let host = "https://swapi.dev/"
    }
}
