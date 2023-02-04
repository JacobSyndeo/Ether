import XCTest
@testable import Ether
import Vapor

let port = 8080
var server = Server(port: port)
var host = "http://localhost:\(port)/"

final class EtherTests: XCTestCase {
    let polo = "polo"
    lazy var echoParams = ["marco": polo]
    
    override class func setUp() {
        server.start()
        
        Thread.sleep(forTimeInterval: 1) // Give it a (literal) sec to spin up. My machine doesn't need this, but slow build servers might?
    }
    
    func testGETWithParamAndDecodeResponse() async throws {
        let echo = try await Ether.get(route: Routes.Echoes(),
                                        type: Echo.self,
                                        parameters: echoParams)
        
        XCTAssertEqual(echo.marco, polo) // Test the actual value within
    }
    
    func testRouteGETInstance() async throws {
        // Route
        let echo = try await Routes.Echoes().get(type: Echo.self,
                                                 parameters: echoParams)
        
        XCTAssertEqual(echo.marco, polo) // Test the actual value within
    }
    
    func testRouteGETArray() async throws {
        let count = 3
        
        // Route
        let echoes = try await Routes.Echoes(count: count).get(type: [Echo].self,
                                                 parameters: echoParams)
        
        // Make sure the count matches
        XCTAssertEqual(echoes.count, count)
        
        for echo in echoes {
            XCTAssertEqual(echo.marco, polo) // Test the actual values within
        }
    }
    
    // Typed Routes can't yet do singulars AND plurals. So we only test singular here.
    func testTypedRouteGET() async throws {
        let echo = try await Routes.Echoes().get(parameters: echoParams)
        
        XCTAssertEqual(echo.marco, polo) // Test the actual value within
    }
    
    func testSingularFetchableType() async throws {
        let echo = try await Echo.fetch(parameters: echoParams)

        XCTAssertEqual(echo.marco, polo) // Test the actual value within
    }
    
    func testPluralFetchableType() async throws {
        let echoes = try await Echo.fetchAll(parameters: echoParams)

        // Make sure the count matches
        XCTAssertEqual(echoes.count, SharedData.maxEchoes)

        for echo in echoes {
            XCTAssertEqual(echo.marco, polo) // Test the actual values within
        }
    }
    
    func testSingularFetchableTypeFromWeirdContainer() async throws {
        let echo = try await AnotherEcho.fetch(parameters: echoParams,
                                               container: WeirdContainer.self,
                                               keyPath: \.someWeirdKey)
        
        XCTAssertEqual(echo.marco, polo) // Test the actual value within
    }
    
    func testPluralFetchableTypeFromWeirdContainer() async throws {
        let echoes = try await AnotherEcho.fetchAll(parameters: echoParams,
                                                    container: WeirdContainer.self,
                                                    keyPath: \.someWeirdKey)
        
        // Make sure the count matches
        XCTAssertEqual(echoes.count, SharedData.maxEchoes)
        
        for echo in echoes {
            XCTAssertEqual(echo.marco, polo) // Test the actual values within
        }
    }
    
    func testPOSTingAComplicatedStructAsJSONAndDecodingResponse() async throws {
        /// At time of writing, when a `SomewhatComplicatedStruct` is POSTed to this URL, the server will return it back, but ONLY if it equals `SomewhatComplicatedStruct.aSomewhatComplicatedInstance`. That ensures that we're encoding it properly.
        /// Decoding the result back from the server and ensuring it still equals `SomewhatComplicatedStruct.aSomewhatComplicatedInstance` ensures that we're decoding it properly.
        
        // Try the longform way
        let result = try await Ether.post(route: Routes.POSTAComplicatedStruct(),
                                           with: .encodable(SomewhatComplicatedStruct.aSomewhatComplicatedInstance),
                                           usingEncoding: .json,
                                           responseFormat: SomewhatComplicatedStruct.self,
                                           showAlertIfFailed: .never)
        
        // Try the convenient way
        let result2 = try await Routes.POSTAComplicatedStruct().post(with: .encodable(SomewhatComplicatedStruct.aSomewhatComplicatedInstance),
                                                                   usingEncoding: .json,
                                                                   responseFormat: SomewhatComplicatedStruct.self,
                                                                   showAlertIfFailed: .never)
        
        XCTAssertEqual(result.data.decoded, result2.data.decoded) // Ensure the convenience wrapper is working properly
        XCTAssertEqual(result.data.decoded, SomewhatComplicatedStruct.aSomewhatComplicatedInstance) // Test the actual values within
    }
    
    func testMultipartPOST() async throws {
        // Try the longform way
        let result = try await Ether.postMultipartForm(route: Routes.POSTAMultipartForm(),
                                                        formItems: SharedData.Multipart.multipartFormFields,
                                                        responseFormat: ImageWrapper.self,
                                                        showAlertIfFailed: .never)
        // Try the convenient way
        let result2 = try await Routes.POSTAMultipartForm().postMultipartForm(formItems: SharedData.Multipart.multipartFormFields,
                                                                            responseFormat: ImageWrapper.self,
                                                                            showAlertIfFailed: .never)
        
        XCTAssertEqual(result.data.decoded?.image.pngData(), result2.data.decoded?.image.pngData()) // Ensure the convenience wrapper is working properly
        XCTAssertEqual(result.data.decoded?.image.pngData(), SharedData.Multipart.MultipartData.imageWrapper.image.pngData()) // Test the actual values within
    }
    
    func testRawDataRequest() async throws {
        // Try the longform way
        let result = try await Ether.request(route: Routes.GETAnImage(),
                                              method: .get,
                                              showAlertIfFailed: .never)

        let imageDataEncodedAsBase64String = String(data: result.data.raw!, encoding: .utf8)!
        
        let imageData = Data(base64Encoded: imageDataEncodedAsBase64String)!
        
        let imageResult = UIImage(data: imageData)!
        
        XCTAssertEqual(imageResult.pngData(), SharedData.RawData.imageData)
    }
}

struct Routes {
    struct Echoes: Ether.TypedRoute {
        typealias DecodedType = Echo
        
        var count: Int? = nil
        
        var asURL: URL {
            if let count {
                return URL(string: host + "echo/\(count)")!
            } else {
                return URL(string: host + "echo")!
            }
        }
    }
    
    struct EchoesInWeirdContainer: Ether.Route {
        var count: Int? = nil
        
        var asURL: URL {
            if let count {
                return URL(string: host + "echoWeird/\(count)")!
            } else {
                return URL(string: host + "echoWeird")!
            }
        }
    }
    
    struct POSTAComplicatedStruct: Ether.TypedRoute {
        typealias DecodedType = SomewhatComplicatedStruct
        
        var asURL: URL {
            return URL(string: host + "postComplicatedStruct")!
        }
    }
    
    struct POSTAMultipartForm: Ether.Route {
        var asURL: URL {
            return URL(string: host + "postMultipartForm")!
        }
    }
    
    struct GETAnImage: Ether.Route {
        var asURL: URL {
            return URL(string: host + "getImage")!
        }
    }
}

extension Ether.Route {
    var path: String {
        if #available(iOS 16.0, *) {
            return try! asURL.path()
        } else {
            return try! asURL.path
        }
    }
    
    var pathComponent: PathComponent {
        var pathString = path
        pathString.removeFirst() // Remove leading slash
        
        return PathComponent(stringLiteral: pathString)
    }
}
