import Foundation

// Adds TypedRoute support to Ether's core functions, e.g. Ether.get(_), Ether.post(_), etc.
// This differs from

extension Ether {
    /// Fires off a GET request to fetch data.
    ///
    /// - Parameters:
    ///   - route: The ``Route`` to use to request data.
    ///   - type: The `Decodable` type you expect to receive back.
    ///   - parameters: A collection of key-value pairs to use as parameters. Defaults to empty.
    ///   - decoder: The `JSONDecoder` to use. You can create your own instance to customize its behavior before passing it in, if you'd like.
    ///   - showAlertIfFailed: An ``AlertBehavior`` enum specifying if/when to show an alert if a failure took place. Defaults to ``AlertBehavior/never``.
    /// - Returns: An instance of the `Decodable` type, decoded from the response recevied from the server.
    ///
    /// Compare with ``Ether/EtherRoute/get(type:parameters:showAlertIfFailed:)``, a convenience version of this method.
    public static func get<T>(typedRoute: T,
                              parameters: Parameters = [:],
                              /*cacheBehavior: CacheBehavior = .neverUse,*/ // TODO: Get caching working!
                              decoder: JSONDecoder = JSONDecoder(),
                              showAlertIfFailed: AlertBehavior = .never) async throws -> T.DecodedType where T: TypedRoute {
        try await Ether.get(route: typedRoute,
                             type: T.DecodedType.self,
                             parameters: parameters,
                             /*cacheBehavior: cacheBehavior,*/
                             decoder: decoder,
                             showAlertIfFailed: showAlertIfFailed)
    }
    
    /// Fires off a POST request to send data.
    ///
    /// - Parameters:
    ///   - route: The ``Ether/Ether/Route`` to which to send data.
    ///   - data: The ``Ether/RequestBody`` to send.
    ///   - encoding: The encoding to use. Defaults to ``ParameterEncoding/gZip``.
    ///   - responseFormat: The `Decodable` type we expect to receive back. Ether will attempt to decode the HTTP response into this type. If no type is provided, the response struct will contain raw, undecoded data.
    ///   - decoder: The `JSONDecoder` to use. You can create your own instance to customize its behavior before passing it in, if you'd like.
    ///   - showAlertIfFailed: An ``AlertBehavior`` enum specifying if/when to show an alert if a failure took place. Defaults to ``AlertBehavior/never``.
    /// - Returns: A ``Response`` struct containing the HTTP response, as well as the decoded struct (or raw data if no struct was requested).
    ///
    /// Compare with ``Ether/EtherRoute/post(with:usingEncoding:responseFormat:showAlertIfFailed:)``, a convenience version of this method.
    @discardableResult
    public static func post<T: TypedRoute>(typedRoute: T,
                                           with data: RequestBody,
                                           usingEncoding encoding: ParameterEncoding = .gZip,
                                           decoder: JSONDecoder = JSONDecoder(),
                                           showAlertIfFailed: AlertBehavior = .never) async throws -> Response<T.DecodedType> {
        try await Ether.post(route: typedRoute,
                              with: data,
                              usingEncoding: encoding,
                              responseFormat: T.DecodedType.self,
                              decoder: decoder,
                              showAlertIfFailed: showAlertIfFailed)
    }
    
    /// Fires off a multipart POST request to the given URL.
    ///
    /// - Parameters:
    ///   - route: The ``Ether/Ether/Route`` to which to send data.
    ///   - formItems: The form items to include in the request. The key is the name of the form item, and the value is a `FormValue` that specifies the value of the form item.
    ///   - responseFormat: The type of data to bundle in the response. Defaults to `DummyTypeUsedWhenNoDecodableIsRequested`.
    ///   - decoder: The `JSONDecoder` to use. You can create your own instance to customize its behavior before passing it in, if you'd like.
    ///   - showAlertIfFailed: An ``AlertBehavior`` enum specifying if/when to show an alert if a failure took place. Defaults to ``AlertBehavior/never``.
    /// - Returns: The response from the server, bundled in a ``Ether/Ether/Response``.
    ///
    /// Compare with ``Ether/EtherRoute/postMultipartForm(formItems:responseFormat:showAlertIfFailed:)``, a convenience version of this method.
    @discardableResult
    public static func postMultipartForm<T: TypedRoute>(typedRoute: T,
                                                        formItems: [String: FormValue] = [:],
                                                        decoder: JSONDecoder = JSONDecoder(),
                                                        showAlertIfFailed: AlertBehavior = .never) async throws -> Response<T.DecodedType> {
        try await Ether.postMultipartForm(route: typedRoute,
                                           formItems: formItems,
                                           responseFormat: T.DecodedType.self,
                                           decoder: decoder,
                                           showAlertIfFailed: showAlertIfFailed)
    }
    
    /// Fires off a custom HTTP request.
    ///
    /// - Parameters:
    ///   - route: The `Route` to use.
    ///   - method: The HTTP method to use.
    ///   - headers: A collection of key-value pairs to use as headers. Defaults to empty.
    ///   - parameters: A collection of key-value pairs to use as parameters. Defaults to empty.
    ///   - body: The ``Ether/Ether/RequestBody`` to use. Defaults to `nil`.
    ///   - responseFormat: The type of data to bundle in the response.
    ///   - encoding: The encoding to use. Defaults to ``ParameterEncoding/urlQuery``.
    ///   - showAlertIfFailed: An ``AlertBehavior`` enum specifying if/when to show an alert if a failure took place. Defaults to ``AlertBehavior/never``.
    ///   - decoder: The `JSONDecoder` to use. You can create your own instance to customize its behavior before passing it in, if you'd like.
    /// - Returns: The response from the server, bundled in a ``Ether/Ether/Response``.
    ///
    /// Compare with ``Ether/EtherRoute/request(method:headers:parameters:body:responseFormat:usingEncoding:showAlertIfFailed:)``, a convenience version of this method.
    @discardableResult
    public static func request<T:TypedRoute>(typedRoute: T,
                                             method: Method,
                                             headers: Headers = [:],
                                             parameters: Parameters = [:],
                                             body: RequestBody? = nil,
                                             usingEncoding encoding: ParameterEncoding = .urlQuery,
                                             decoder: JSONDecoder = JSONDecoder(),
                                             showAlertIfFailed: AlertBehavior = .never) async throws -> Response<T.DecodedType> {
        try await Ether.request(route: typedRoute,
                                 method: method,
                                 headers: headers,
                                 parameters: parameters,
                                 body: body,
                                 responseFormat: T.DecodedType.self,
                                 usingEncoding: encoding,
                                 decoder: decoder,
                                 showAlertIfFailed: showAlertIfFailed)
    }
}
