import Foundation

public protocol EtherTypedRoute: EtherRoute {
//    associatedtype SingularType: Decodable
//    associatedtype PluralType: Decodable
    
    /// The `Decodable` type that the route's result is expected to decode to.
    associatedtype DecodedType: Decodable
}

extension Ether {
    /// A typealias for ``EtherTypedRoute``.
    ///
    /// Since it's a protocol, it requires a global namespace, but typealiases can be namespaced within other types.
    /// This lets it be accessed as `Ether.TypedRoute`, much like how ``Method`` is accessible as `Ether.Method`, as well as other subtypes.
    /// - SeeAlso: ``EtherTypedRoute``
    public typealias TypedRoute = EtherTypedRoute
}

// Add .get and such to TypedRoutes, e.g. SomeTypedRoute.get(_), SomeTypedRoute.post(_), etc.

extension EtherTypedRoute {
    /// Fires off a GET request to fetch data, using the current ``Ether/Ether/TypedRoute`` instance.
    ///
    /// - Parameters:
    ///   - parameters: A collection of key-value pairs to use as parameters. Defaults to empty.
    ///   - decoder: The `JSONDecoder` to use. You can create your own instance to customize its behavior before passing it in, if you'd like.
    ///   - showAlertIfFailed: An ``Ether/Ether/AlertBehavior`` enum specifying if/when to show an alert if a failure took place. Defaults to ``Ether/Ether/AlertBehavior/never``.
    /// - Returns: An instance of the `Decodable` type, decoded from the response recevied from the server.
    ///
    /// Compare with ``Ether/Ether/get(route:type:parameters:decoder:showAlertIfFailed:)``, the main version of this method.
    public func get(parameters: Ether.Parameters = [:],
                    /*cacheBehavior: CacheBehavior = .neverUse,*/ // TODO: Get caching working!
                    decoder: JSONDecoder = JSONDecoder(),
                    showAlertIfFailed: Ether.AlertBehavior = .never) async throws -> DecodedType {
        try await Ether.get(route: self,
                             type: DecodedType.self,
                             parameters: parameters,
                             /*cacheBehavior: cacheBehavior,*/
                             decoder: decoder,
                             showAlertIfFailed: showAlertIfFailed)
    }
    
    /// Fires off a POST request to send data.
    ///
    /// - Parameters:
    ///   - data: The ``Ether/Ether/RequestBody`` to send.
    ///   - encoding: The encoding to use. Defaults to ``Ether/Ether/ParameterEncoding/gZip``.
    ///   - responseFormat: The `Decodable` type we expect to receive back. Ether will attempt to decode the HTTP response into this type. If no type is provided, the response struct will contain raw, undecoded data.
    ///   - decoder: The `JSONDecoder` to use. You can create your own instance to customize its behavior before passing it in, if you'd like.
    ///   - showAlertIfFailed: An ``Ether/Ether/AlertBehavior`` enum specifying if/when to show an alert if a failure took place. Defaults to ``Ether/Ether/AlertBehavior/never``.
    /// - Returns: A ``Ether/Ether/Response`` struct containing the HTTP response, as well as the decoded struct (or raw data if no struct was requested).
    ///
    /// Compare with ``Ether/Ether/post(route:with:usingEncoding:responseFormat:decoder:showAlertIfFailed:)``, the main version of this method.
    public func post(with data: Ether.RequestBody,
                     usingEncoding encoding: Ether.ParameterEncoding = .gZip,
                     decoder: JSONDecoder = .init(),
                     showAlertIfFailed: Ether.AlertBehavior = .never) async throws -> Ether.Response<DecodedType> {
        try await Ether.post(route: self,
                              with: data,
                              usingEncoding: encoding,
                              responseFormat: DecodedType.self,
                              decoder: decoder,
                              showAlertIfFailed: showAlertIfFailed)
    }
    
    /// This method sends a multipart POST request to the given URL.
    ///
    /// - Parameters:
    ///   - formItems: The form items to include in the request. The key is the name of the form item, and the value is a `FormValue` that specifies the value of the form item.
    ///   - responseFormat: The type of data to bundle in the response. Defaults to `DummyTypeUsedWhenNoDecodableIsRequested`.
    ///   - decoder: The `JSONDecoder` to use. You can create your own instance to customize its behavior before passing it in, if you'd like.
    ///   - showAlertIfFailed: An ``Ether/Ether/AlertBehavior`` enum specifying if/when to show an alert if a failure took place. Defaults to ``Ether/Ether/AlertBehavior/never``.
    /// - Returns: The response from the server, bundled in a ``Ether/Ether/Response``.
    ///
    /// Compare with ``Ether/Ether/postMultipartForm(route:formItems:responseFormat:decoder:showAlertIfFailed:)``, the main version of this method.
    public func postMultipartForm(formItems: [String: Ether.FormValue] = [:],
                                  decoder: JSONDecoder = .init(),
                                  showAlertIfFailed: Ether.AlertBehavior = .never) async throws -> Ether.Response<DecodedType> {
        try await Ether.postMultipartForm(route: self,
                                           formItems: formItems,
                                           responseFormat: DecodedType.self,
                                           decoder: decoder,
                                           showAlertIfFailed: showAlertIfFailed)
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
    ///   - showAlertIfFailed: An ``Ether/Ether/AlertBehavior`` enum specifying if/when to show an alert if a failure took place. Defaults to ``Ether/Ether/AlertBehavior/never``.
    /// - Returns: The response from the server, bundled in a ``Ether/Ether/Response``.
    ///
    /// Compare with ``Ether/Ether/request(route:method:headers:parameters:body:responseFormat:usingEncoding:decoder:showAlertIfFailed:)``, the main version of this method.
    public func request(method: Ether.Method,
                        headers: Ether.Headers = [:],
                        parameters: Ether.Parameters = [:],
                        body: Ether.RequestBody? = nil,
                        usingEncoding encoding: Ether.ParameterEncoding = .urlQuery,
                        decoder: JSONDecoder = .init(),
                        showAlertIfFailed: Ether.AlertBehavior = .never) async throws -> Ether.Response<DecodedType> {
        try await Ether.request(route: self,
                                 method: method,
                                 headers: headers,
                                 parameters: parameters,
                                 body: body,
                                 responseFormat: DecodedType.self,
                                 usingEncoding: encoding,
                                 decoder: decoder,
                                 showAlertIfFailed: showAlertIfFailed)
    }
}
