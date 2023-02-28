import Foundation
import Ether

enum SWRoutes: Ether.Route {
    case people(Int)
    
    var asURL: URL {
        let host = "https://swapi.dev/"
        
        let urlString: String
        
        switch self {
        case let .people(personID):
            urlString = host + "/api/people/\(personID)"
        }
    }
}
