import Foundation

// Adds TypedRoute support to Ether's core functions, e.g. Ether.get(_), Ether.post(_), etc.
// This differs from

extension Ether {
    /// Fires off a GET request to fetch data.
    ///
    /// - Parameters:
    ///   - typedRoute: The ``Ether/Ether/TypedRoute`` to use to request data.
    ///   - parameters: A collection of key-value pairs to use as parameters. Defaults to empty.
    ///   - decoder: The `JSONDecoder` to use. You can create your own instance to customize its behavior before passing it in, if you'd like.
    /// - Returns: An instance of the provided ``Ether/EtherTypedRoute``'s ``Ether/EtherTypedRoute/DecodedType`` type, decoded from the response recevied from the server.
    ///
    /// Compare with ``Ether/EtherRoute/get(type:parameters:decoder:)``, a convenience version of this method.
    public static func get<T>(typedRoute: T,
                              parameters: Parameters = [:],
                              /*cacheBehavior: CacheBehavior = .neverUse,*/ // TODO: Get caching working!
                              decoder: JSONDecoder = JSONDecoder()) async throws -> T.DecodedType where T: TypedRoute {
        try await Ether.get(route: typedRoute,
                             type: T.DecodedType.self,
                             parameters: parameters,
                             /*cacheBehavior: cacheBehavior,*/
                             decoder: decoder)
    }
    
    /// Fires off a POST request to send data.
    ///
    /// - Parameters:
    ///   - typedRoute: The ``Ether/Ether/TypedRoute`` to which to send data.
    ///   - data: The ``Ether/RequestBody`` to send.
    ///   - encoding: The encoding to use. Defaults to ``ParameterEncoding/gZip``.
    ///   - decoder: The `JSONDecoder` to use. You can create your own instance to customize its behavior before passing it in, if you'd like.
    /// - Returns: A ``Ether/Ether/Response`` struct containing the HTTP response, as well as the decoded struct (or raw data if no struct was requested).
    ///
    /// Compare with ``Ether/EtherRoute/post(with:usingEncoding:responseFormat:decoder:)``, a convenience version of this method.
    @discardableResult
    public static func post<T: TypedRoute>(typedRoute: T,
                                           with data: RequestBody,
                                           usingEncoding encoding: ParameterEncoding = .gZip,
                                           decoder: JSONDecoder = JSONDecoder()) async throws -> Response<T.DecodedType> {
        try await Ether.post(route: typedRoute,
                              with: data,
                              usingEncoding: encoding,
                              responseFormat: T.DecodedType.self,
                              decoder: decoder)
    }
    
    /// Fires off a multipart POST request to the given URL.
    ///
    /// - Parameters:
    ///   - typedRoute: The ``Ether/Ether/TypedRoute`` to which to send data.
    ///   - formItems: The form items to include in the request. The key is the name of the form item, and the value is a `FormValue` that specifies the value of the form item.
    ///   - decoder: The `JSONDecoder` to use. You can create your own instance to customize its behavior before passing it in, if you'd like.
    /// - Returns: The response from the server, bundled in a ``Ether/Ether/Response``.
    ///
    /// Compare with ``Ether/EtherRoute/postMultipartForm(formItems:responseFormat:decoder:)``, a convenience version of this method.
    @discardableResult
    public static func postMultipartForm<T: TypedRoute>(typedRoute: T,
                                                        formItems: [String: FormValue] = [:],
                                                        decoder: JSONDecoder = JSONDecoder()) async throws -> Response<T.DecodedType> {
        try await Ether.postMultipartForm(route: typedRoute,
                                           formItems: formItems,
                                           responseFormat: T.DecodedType.self,
                                           decoder: decoder)
    }
    
    /// Fires off a custom HTTP request.
    ///
    /// - Parameters:
    ///   - typedRoute: The ``Ether/Ether/TypedRoute`` to use.
    ///   - method: The HTTP method to use.
    ///   - headers: A collection of key-value pairs to use as headers. Defaults to empty.
    ///   - parameters: A collection of key-value pairs to use as parameters. Defaults to empty.
    ///   - body: The ``Ether/Ether/RequestBody`` to use. Defaults to `nil`.
    ///   - encoding: The encoding to use. Defaults to ``ParameterEncoding/urlQuery``.
    ///   - decoder: The `JSONDecoder` to use. You can create your own instance to customize its behavior before passing it in, if you'd like.
    /// - Returns: The response from the server, bundled in a ``Ether/Ether/Response``.
    ///
    /// Compare with ``Ether/EtherRoute/request(method:headers:parameters:body:responseFormat:usingEncoding:decoder:)``, a convenience version of this method.
    @discardableResult
    public static func request<T:TypedRoute>(typedRoute: T,
                                             method: Method,
                                             headers: Headers = [:],
                                             parameters: Parameters = [:],
                                             body: RequestBody? = nil,
                                             usingEncoding encoding: ParameterEncoding = .urlQuery,
                                             decoder: JSONDecoder = JSONDecoder()) async throws -> Response<T.DecodedType> {
        try await Ether.request(route: typedRoute,
                                 method: method,
                                 headers: headers,
                                 parameters: parameters,
                                 body: body,
                                 responseFormat: T.DecodedType.self,
                                 usingEncoding: encoding,
                                 decoder: decoder)
    }
}
