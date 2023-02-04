import Vapor
import Ether
import UIKit
import NIOFoundationCompat

class Server: ObservableObject {
    var app: Application
    let port: Int
    
    init(port: Int) {
        self.port = port
        app = Application(.development)
        configure(app)
    }
    
    private func configure(_ app: Application) {
        app.http.server.configuration.hostname = "0.0.0.0"
        app.http.server.configuration.port = port
        
        app.routes.defaultMaxBodySize = "50MB"
    }
    
    func start() {
        Task(priority: .background) {
            setupRoutes()
            
            do {
                try app.start()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func setupRoutes() {
        app.routes.get(Routes.Echoes().pathComponent) { request -> Echo in
            let polo = try request.query.decode(Echo.self)
            return polo
        }
        
        app.routes.get(Routes.Echoes().pathComponent, ":count") { request -> [Echo] in
            let polo = try request.query.decode(Echo.self)
            
            var echoes: [Echo] = []
            
            let echoCount = request.parameters.get("count") ?? SharedData.maxEchoes
            
            for _ in 0..<echoCount {
                echoes.append(polo)
            }
            
            return echoes
        }
        
        app.routes.get(Routes.EchoesInWeirdContainer().pathComponent) { request -> WeirdContainer<Echo> in
            let polo = try request.query.decode(Echo.self)
            return WeirdContainer(someWeirdKey: polo)
        }
        
        app.routes.get(Routes.EchoesInWeirdContainer().pathComponent, ":count") { request -> WeirdContainer<[Echo]> in
            let polo = try request.query.decode(Echo.self)
            
            var echoes: [Echo] = []
            
            let echoCount = request.parameters.get("count") ?? SharedData.maxEchoes
            
            for _ in 0..<echoCount {
                echoes.append(polo)
            }
            
            return WeirdContainer(someWeirdKey: echoes)
        }
        
        app.routes.post(Routes.POSTAComplicatedStruct().pathComponent) { request -> SomewhatComplicatedStruct in
            let thePOSTedStruct = try request.content.decode(SomewhatComplicatedStruct.self)
            
            if thePOSTedStruct == SomewhatComplicatedStruct.aSomewhatComplicatedInstance {
                return thePOSTedStruct // Bounce it back, so that the response matches what Ether believes it sent. We can use this for verification of POST reponses at some point, as that has now been added into Ether. For now, the fact that it returns a non-error response means it passes.
            } else {
                throw Abort(.expectationFailed)
            }
        }
        
        app.routes.post(Routes.POSTAMultipartForm().pathComponent) { request -> ImageWrapper in
            let multipartData = try request.content.decode(MultipartDataExample.self)
            
            let uploadedPicData = Data(buffer: multipartData.你好.data)
            
            if uploadedPicData == SharedData.Multipart.MultipartData.imageWrapper.image.pngData() {
                return ImageWrapper(image: UIImage(data: uploadedPicData)!) // Bounce the image wrapper back
            } else {
                throw Abort(.expectationFailed)
            }
        }
        
        app.routes.get(Routes.GETAnImage().pathComponent) { request -> String in
            return SharedData.RawData.imageData.base64EncodedString()
        }
    }
}

enum ServerError: Error {
    case missingParameter
}

struct Echo: Content, Equatable, Ether.Fetchable {
    static func singularRoute(id: String?) -> Ether.Route {
        Routes.Echoes()
    }
    
    static func pluralRoute(filters: Ether.FetchableFilters?) -> Ether.Route {
        Routes.Echoes(count: SharedData.maxEchoes)
    }
    
    var marco: String
}

// Another type, because we need to provide another route (EchoesInWeirdContainer) that returns a container for the unit tests.
// It will behave to the same way as Echo, though, as it has the same "marco" string.
struct AnotherEcho: Content, Equatable, Ether.Fetchable {
    static func singularRoute(id: String?) -> Ether.Route {
        Routes.EchoesInWeirdContainer()
    }
    
    static func pluralRoute(filters: Ether.FetchableFilters?) -> Ether.Route {
        Routes.EchoesInWeirdContainer(count: SharedData.maxEchoes)
    }
    
    var marco: String
}

struct WeirdContainer<T: Codable>: Codable, Content {
    var someWeirdKey: T
}

// Vapor wants things to conform to "Content" to be usable as content…
extension SomewhatComplicatedStruct: Content {
    
}

// …or as responses! (Content conforms to ResponseEncodable)
extension ImageWrapper: Content {
    
}

// Make these fields match what's in SharedData.Multipart.multipartFormFields!
fileprivate struct MultipartDataExample: Codable {
    var hello: String
    var 你好: File
}
