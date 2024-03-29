import Foundation

/// A custom protocol to which host apps can conform.
///
/// The recommended usage is a set of enums, one for each endpoint path, with associated values for endpoints with variables.
///
/// E.g. the home page's route would be `.home`, but a user's profile path would be `.users(id: 1)`.
///
/// The fullURL variable on the enum type would then be a computed property that would generate the URLs `https://domain.com/home` and `https://domain.com/users/1`, respectively.
///
/// For further convenience, both ``Swift/String`` and ``Foundation/URL`` are automatically conformed to this, so you can pass them directly into functions expecting `Route`s.
///
/// Typealiased to ``Ether/Ether/Route`` for better namespacing.
///
/// - SeeAlso: ``Ether/Ether/Route``
public protocol EtherRoute {
    /// Returns a URL that conforms to [RFC 2396](https://www.ietf.org/rfc/rfc2396.txt) or throws an `Error`.
    ///
    /// - throws: An `Error` if the type cannot be converted to a `URL`.
    ///
    /// - returns: A URL or throws an `Error`.
    var asURL: URL { get throws }
}

extension Ether {
    /// A typealias for ``EtherRoute``, namespaced under ``Ether/Ether``.
    ///
    /// Since it's a protocol, it requires a global namespace, but typealiases can be namespaced within other types.
    /// This lets it be accessed as `Ether.Route`, much like how ``Ether/Ether/Method`` is accessible as a type namespaced under ``Ether/Ether``, as well as other subtypes.
    /// - SeeAlso: ``EtherRoute``
    public typealias Route = EtherRoute
}

/// The following is clearly based on a trick from the networking-libary-that-shall-not-be-named.
/// We can conform String and URL to our type in order to get easy URL conversion for the former, and drop-in support for the latter, without maintaining separate method signatures for each, or using enums.

// Conform String to Route, so that we can use it.
extension String: Ether.Route {
    /// Returns a URL if `self` represents a valid URL string that conforms to [RFC 2396](https://www.ietf.org/rfc/rfc2396.txt) or throws an error.
    ///
    /// - Returns: A URL, if `self` is a valid URL string.
    /// - Throws: An ``Ether/Ether/Error/badURL(_:)`` if `self` is not a valid URL string.
    public var asURL: URL {
        get throws {
            guard let url = URL(string: self) else { throw Ether.Error.badURL(self) }
            return url
        }
    }
}

// Conform URL to Route, so that we can use it.
extension URL: Ether.Route {
    /// Returns self.
    /// Only "throws" because it's required by the protocol.
    public var asURL: URL {
        get throws {
            return self
        }
    }
}

// Convenience functions!
// I'd normally call this an extension on Ether.Route, but the current version of Swift DocC can't find these functions unless I make this extension on the non-typealiased version, EtherRoute.
// Thankfully, the typealiased version gets full access to these functions, so it makes no real-world difference.
// Additionally, DocC can even find the functions on the typealiased Ether.Route if I define the extension this way!
extension Ether.Route {
    /// Fires off a GET request to fetch data, using the current ``Ether/Ether/Route`` instance.
    ///
    /// - Parameters:
    ///   - type: The `Decodable` type you expect to receive back.
    ///   - parameters: A collection of key-value pairs to use as parameters. Defaults to empty.
    ///   - decoder: The `JSONDecoder` to use. You can create your own instance to customize its behavior before passing it in, if you'd like.
    /// - Returns: An instance of the `Decodable` type, decoded from the response recevied from the server.
    /// - Throws: An ``Ether/Ether/Error``, or any error thrown by the `URLSession` data task, if the request fails.
    ///
    /// Compare with ``Ether/Ether/get(route:type:parameters:decoder:)``, the main version of this method.
    public func get<T>(type: T.Type,
                       parameters: Ether.Parameters = [:],
                       decoder: JSONDecoder = .init()) async throws -> T where T: Decodable {
        try await Ether.get(route: self,
                             type: type,
                             parameters: parameters,
                             decoder: decoder)
    }
    
    /// Fires off a POST request to send data.
    ///
    /// - Parameters:
    ///   - data: The ``Ether/Ether/RequestBody`` to send.
    ///   - encoding: The encoding to use. Defaults to ``Ether/Ether/ParameterEncoding/gZip``.
    ///   - responseFormat: The `Decodable` type we expect to receive back. Ether will attempt to decode the HTTP response into this type. If no type is provided, the response struct will contain raw, undecoded data.
    ///   - decoder: The `JSONDecoder` to use. You can create your own instance to customize its behavior before passing it in, if you'd like.
    /// - Returns: A ``Ether/Ether/Response`` struct containing the HTTP response, as well as the decoded struct (or raw data if no struct was requested).
    /// - Throws: An ``Ether/Ether/Error``, or any error thrown by the `URLSession` data task, if the request fails.
    ///
    /// Compare with ``Ether/Ether/post(route:with:usingEncoding:responseFormat:decoder:)``, the main version of this method.
    @discardableResult
    public func post<T>(with data: Ether.RequestBody,
                        usingEncoding encoding: Ether.ParameterEncoding = .gZip,
                        responseFormat: T.Type = Ether._DummyTypeUsedWhenNoDecodableIsRequested.self,
                        decoder: JSONDecoder = .init()) async throws -> Ether.Response<T> {
        try await Ether.post(route: self,
                              with: data,
                              usingEncoding: encoding,
                              responseFormat: responseFormat,
                              decoder: decoder)
    }
    
    /// This method sends a multipart POST request to the given URL.
    ///
    /// - Parameters:
    ///   - formItems: The form items to include in the request. The key is the name of the form item, and the value is a `FormValue` that specifies the value of the form item.
    ///   - responseFormat: The type of data to bundle in the response. Defaults to `DummyTypeUsedWhenNoDecodableIsRequested`.
    ///   - decoder: The `JSONDecoder` to use. You can create your own instance to customize its behavior before passing it in, if you'd like.
    /// - Returns: The response from the server, bundled in a ``Ether/Ether/Response``.
    /// - Throws: An ``Ether/Ether/Error``, or any error thrown by the `URLSession` data task, if the request fails.
    ///
    /// Compare with ``Ether/Ether/postMultipartForm(route:formItems:responseFormat:decoder:)``, the main version of this method.
    @discardableResult
    public func postMultipartForm<T>(formItems: [String: Ether.FormValue] = [:],
                                     responseFormat: T.Type = Ether._DummyTypeUsedWhenNoDecodableIsRequested.self,
                                     decoder: JSONDecoder = .init()) async throws -> Ether.Response<T> {
        try await Ether.postMultipartForm(route: self,
                                           formItems: formItems,
                                           responseFormat: responseFormat,
                                           decoder: decoder)
    }
    
    /// Fires off a custom HTTP request.
    ///
    /// - Parameters:
    ///   - method: The HTTP method to use.
    ///   - headers: A collection of key-value pairs to use as headers. Defaults to empty.
    ///   - parameters: A collection of key-value pairs to use as parameters. Defaults to empty.
    ///   - body: The ``Ether/Ether/RequestBody`` to use. Defaults to `nil`.
    ///   - responseFormat: The type of data to bundle in the response.
    ///   - encoding: The encoding to use. Defaults to ``Ether/Ether/ParameterEncoding/urlQuery``.
    ///   - decoder: The `JSONDecoder` to use. You can create your own instance to customize its behavior before passing it in, if you'd like.
    /// - Returns: The response from the server, bundled in a ``Ether/Ether/Response``.
    /// - Throws: An ``Ether/Ether/Error``, or any error thrown by the `URLSession` data task, if the request fails.
    ///
    /// Compare with ``Ether/Ether/request(route:method:headers:parameters:body:responseFormat:usingEncoding:decoder:)``, the main version of this method.
    @discardableResult
    public func request<T>(method: Ether.Method,
                           headers: Ether.Headers = [:],
                           parameters: Ether.Parameters = [:],
                           body: Ether.RequestBody? = nil,
                           responseFormat: T.Type? = Ether._DummyTypeUsedWhenNoDecodableIsRequested.self,
                           usingEncoding encoding: Ether.ParameterEncoding = .urlQuery,
                           decoder: JSONDecoder = .init()) async throws -> Ether.Response<T> where T: Decodable {
        try await Ether.request(route: self,
                                 method: method,
                                 headers: headers,
                                 parameters: parameters,
                                 body: body,
                                 responseFormat: responseFormat,
                                 usingEncoding: encoding,
                                 decoder: decoder)
    }
}
