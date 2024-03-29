//
//  Ether.swift
//
//  Created by Jacob Pritchett on 12/15/21.
//

import Foundation
import OSLog

/// The core of Ether. All the core functions and types are namespaced under this.
public struct Ether {
    /// Here, you can set custom headers for specific domains.
    /// That way, you can stay authenticated by passing a session token, specific to a domain, so that it's not leaked out to other domains you may access.
	public static var domainHeaders: [String: Headers] = [:]

    /// If true, Ether will log all requests to the console, 
    /// NOTE: This will log sensitive data, such as auth tokens, to the console, and therefore, this option is ignored in non-debug builds.
    public static var logRequestsForDebugBuilds: Bool = false
    
    internal static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Ether.self)
    )
    
    /// Fires off a GET request to fetch data.
    ///
    /// - Parameters:
    ///   - route: The ``Route`` to use to request data.
    ///   - type: The `Decodable` type you expect to receive back.
    ///   - parameters: A collection of key-value pairs to use as parameters. Defaults to empty.
    ///   - decoder: The `JSONDecoder` to use. You can create your own instance to customize its behavior before passing it in, if you'd like.
    /// - Returns: An instance of the `Decodable` type, decoded from the response recevied from the server.
    /// - Throws: An ``Ether/Ether/Error``, or any error thrown by the `URLSession` data task, if the request fails.
    ///
    /// Compare with ``Ether/EtherRoute/get(type:parameters:decoder:)``, a convenience version of this method.
    public static func get<T>(route: any Route,
                              type: T.Type,
                              parameters: Parameters = [:],
                              decoder: JSONDecoder = JSONDecoder()) async throws -> T where T: Decodable {
        
        let response = try await request(route: route,
                                         method: Method.get,
                                         parameters: parameters,
                                         responseFormat: type,
                                         usingEncoding: .urlQuery, // Using URL encoding is the standard, acceptable way to do GET requests. We intentionally don't expose the encoding setting on `get`. If a user REALLY wants to use a GET request with a different encoding, they build it using the `request` function directly. Interesting discussion here: https://stackoverflow.com/questions/978061/http-get-with-request-body
                                         decoder: decoder)
        
        switch response.data {
        case let .decoded(data):
            return data
        default:
            throw Error.jsonDecodingFailed(nil) // TODO: Improve this
        }
    }
    
    /// Fires off a POST request to send data.
    ///
    /// - Parameters:
    ///   - route: The ``Ether/Ether/Route`` to which to send data.
    ///   - data: The ``Ether/RequestBody`` to send.
    ///   - encoding: The encoding to use. Defaults to ``ParameterEncoding/gZip``.
    ///   - responseFormat: The `Decodable` type we expect to receive back. Ether will attempt to decode the HTTP response into this type. If no type is provided, the response struct will contain raw, undecoded data.
    ///   - decoder: The `JSONDecoder` to use. You can create your own instance to customize its behavior before passing it in, if you'd like.
    /// - Returns: A ``Response`` struct containing the HTTP response, as well as the decoded struct (or raw data if no struct was requested).
    /// - Throws: An ``Ether/Ether/Error``, or any error thrown by the `URLSession` data task, if the request fails.
    ///
    /// Compare with ``Ether/EtherRoute/post(with:usingEncoding:responseFormat:decoder:)``, a convenience version of this method.
    @discardableResult
    public static func post<T>(route: any Route,
                               with data: RequestBody,
                               usingEncoding encoding: ParameterEncoding = .gZip,
                               responseFormat: T.Type = _DummyTypeUsedWhenNoDecodableIsRequested.self,
                               decoder: JSONDecoder = JSONDecoder()) async throws -> Response<T> {
        return try await request(route: route,
                                 method: .post,
                                 parameters: [:],
                                 body: data,
                                 responseFormat: responseFormat,
                                 usingEncoding: encoding,
                                 decoder: decoder)
    }
    
    /// Fires off a multipart POST request to the given URL.
    ///
    /// - Parameters:
    ///   - route: The ``Ether/Ether/Route`` to which to send data.
    ///   - formItems: The form items to include in the request. The key is the name of the form item, and the value is a `FormValue` that specifies the value of the form item.
    ///   - responseFormat: The type of data to bundle in the response. Defaults to `DummyTypeUsedWhenNoDecodableIsRequested`.
    ///   - decoder: The `JSONDecoder` to use. You can create your own instance to customize its behavior before passing it in, if you'd like.
    /// - Returns: The response from the server, bundled in a ``Ether/Ether/Response``.
    /// - Throws: An ``Ether/Ether/Error``, or any error thrown by the `URLSession` data task, if the request fails.
    ///
    /// Compare with ``Ether/EtherRoute/postMultipartForm(formItems:responseFormat:decoder:)``, a convenience version of this method.
    @discardableResult
    public static func postMultipartForm<T>(route: any Route,
                                            formItems: [String: FormValue] = [:],
                                            responseFormat: T.Type = _DummyTypeUsedWhenNoDecodableIsRequested.self,
                                            decoder: JSONDecoder = JSONDecoder()) async throws -> Response<T> {
        // Create the body of the request
        let httpBody = NSMutableData()
                
        /// Add the form fields to the body of the request.
        /// A quick explanation of how multipart form data works:
        /// • Each field is separated by a boundary.
        /// • The boundary is a string that looks like this: --Boundary-<UUID>
        /// • The first boundary is followed by two newlines: \r\n
        /// • The rest of the boundaries are followed by two newlines and two dashes: \r\n--
        /// • The last boundary is followed by two dashes: --

        // Create the boundary that will be used to separate the different parts of the body
        let boundary = "Boundary-\(UUID().uuidString)"

        // Add the form fields to the body of the request
        // TODO: This logic could be simplified, as both are appending strings to the body of the request. The second one is just appending the string as Data instead of a String.
        for (name, formValue) in formItems {
            switch formValue {
            case let .text(text):
                // Add the text fields to the body of the request

                var fieldString = "--\(boundary)\r\n"
                fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
                fieldString += "\r\n"
                fieldString += "\(text)\r\n"

                httpBody.appendString(fieldString)
            case let .file(item):
                // Add the file fields to the body of the request

                let data = NSMutableData()
                
                data.appendString("--\(boundary)\r\n")
                data.appendString("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(item.fileName)\"\r\n")
                data.appendString("Content-Type: \(item.mimeType)\r\n\r\n")
                data.append(item.fileData)
                data.appendString("\r\n")

                httpBody.append(data as Data)
            }
        }
                
        // Add the boundary that marks the end of the body of the request
        httpBody.appendString("--\(boundary)--")
                
        // Make the request
        return try await request(route: route,
                                 method: .post,
                                 headers: [:],
                                 parameters: [:],
                                 body: RequestBody.rawData(httpBody as Data),
                                 responseFormat: responseFormat,
                                 usingEncoding: .custom(contentType: "multipart/form-data; boundary=\(boundary)"),
                                 decoder: decoder)
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
    ///   - decoder: The `JSONDecoder` to use. You can create your own instance to customize its behavior before passing it in, if you'd like.
    /// - Returns: The response from the server, bundled in a ``Ether/Ether/Response``.
    /// - Throws: An ``Ether/Ether/Error``, or any error thrown by the `URLSession` data task, if the request fails.
    ///
    /// Compare with ``Ether/EtherRoute/request(method:headers:parameters:body:responseFormat:usingEncoding:decoder:)``, a convenience version of this method.
    @discardableResult
    public static func request<T>(route: any Route,
                                  method: Method,
                                  headers: Headers = [:],
                                  parameters: Parameters = [:],
                                  body: RequestBody? = nil,
                                  responseFormat: T.Type? = _DummyTypeUsedWhenNoDecodableIsRequested.self,
                                  usingEncoding encoding: ParameterEncoding = .urlQuery,
                                  decoder: JSONDecoder = JSONDecoder()) async throws -> Response<T> where T: Decodable {
        // These are just here to make sure we're actually using all of these!
        let route = route
        let method = method
        let headers = headers
        let parameters = parameters
        let body = body
        let responseFormat = responseFormat
        let encoding = encoding
        
        let session = URLSession.shared
        
        // Create the request, extracting the actual URL from the route
        var request = try URLRequest(url: route.asURL, method: method)
        
        // Attach an expectation on the type to receive back, if any
        if responseFormat != nil {
            request.allHTTPHeaderFields?["Accept"] = "application/json"
        }
        
        // Attach headers if it's a known/trusted domain
        // Be careful here; these may be auth tokens. Don't leak them to other domains!
        var knownDomain: String?
        if let host = try? route.asURL.host,
           let headersForHost = domainHeaders[host] {
            knownDomain = host
            for header in headersForHost {
                request.allHTTPHeaderFields?[header.key] = header.value
            }
        }
        
        // Attach provided headers
        for header in headers {
            // Show warnings if there's something potentially wrong with the request.
            checkForHeaderIssues(headerKey: header.key,
                                 headerValue: header.value,
                                 knownDomain: knownDomain)
            
            request.allHTTPHeaderFields?[header.key] = header.value
        }
        
        // Apply encoding
        switch encoding {
        case .urlQuery:
            request = try request.urlEncoded(with: parameters)
        case .json:
            request = try request.jsonEncoded(with: parameters, usingGZip: false)
        case .gZip:
            request = try request.jsonEncoded(with: parameters, usingGZip: true)
        case let .custom(contentType: contentType):
            request.allHTTPHeaderFields?["Content-Type"] = contentType
        }
        
        // Set the body
        switch body {
        case let .encodable(encodable, encoder: encoder):
            // Encode the encodable object into JSON and set it as the request's body
            request.httpBody = try encoder.encode(encodable)
        case let .rawData(data):
            // Set the request's body to the raw data
            request.httpBody = data
        case let .plainText(text):
            // Set the request's body to the plain text
            request.httpBody = text.data(using: .utf8)
        case .none:
            // Do nothing
            break
        }
        
        // If logging is enabled and the app is in debug mode, log the request!
        if logRequestsForDebugBuilds {
            #if DEBUG
                logger.debug("Requesting: \(request.debugString())")
            #endif
        }
        
        // Fire off the request!
        let data: Data
        let response: URLResponse
        if #available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15, macCatalyst 15, *) {
            (data, response) = try await session.data(for: request, delegate: nil)
        } else {
            (data, response) = try await withCheckedThrowingContinuation({ continuation in
                session.dataTask(with: request) { data, response, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else if let data, let response {
                        continuation.resume(returning: (data, response))
                    }
                }.resume()
            })
        }
        
        // Check if the response is an HTTPURLResponse, which lets us check the status code
        guard let response = response as? HTTPURLResponse else {
            throw Error.responseNotHTTP
        }
        
        // Checks if the status code is between 200 and 299 (inclusive)
        if (200..<300).contains(response.statusCode) {
            if let responseFormat = responseFormat, type(of: responseFormat.self) != _DummyTypeUsedWhenNoDecodableIsRequested.Type.self {
                // If the response format (set by the caller) is not nil, attempt to decode the response data into the response format
                return Response(data: .decoded(try decoder.decode(responseFormat.self, from: data)),
                                response: response)
            } else {
                // Otherwise, just return the raw data
                return Response(data: .raw(data),
                                response: response)
            }
        } else {
            let error = Error.badResponseCode(response.statusCode)
            
            logger.error("""
                🛑🛑🛑 Ether ERROR :( 🛑🛑🛑
                \(error.errorDescription ?? "")
                \(error.failureReason ?? "")
                \(error.recoverySuggestion ?? "")
                The request that triggered the error:
                \(request.debugString())
                """)
            
            throw error
        }
    }
}
