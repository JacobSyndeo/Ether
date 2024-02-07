import Foundation

internal extension URLRequest {
    /// Creates an instance with the specified `method` and `urlString.
    ///
    /// - parameter url:     The URL.
    /// - parameter method:  The HTTP method.
    ///
    /// - returns: The new `URLRequest` instance.
    init(url: URL, method: Ether.Method) throws {
        self.init(url: url)
        
        httpMethod = method.rawValue
    }
    
    /// Encodes a URLRequest, using URL encoding as defined in [RFC 3986](https://www.ietf.org/rfc/rfc3986.txt).
    /// - Parameter parameters: The ``Ether/Ether/Parameters`` to encode into the request as JSON.
    /// - Returns: A URL-encoded URLRequest.
    /// - Throws: An ``Ether/Ether/Error/badQueryItem(_:)`` if the parameters could not be encoded into a URL query item.
    /// - SeeAlso: https://developer.mozilla.org/en-US/docs/Glossary/percent-encoding
    /// - SeeAlso: https://datatracker.ietf.org/doc/html/rfc3986
    func urlEncoded(with parameters: Ether.Parameters = [:]) throws -> URLRequest {
        // Create a copy of the request
        var request = self

        guard url != nil else {
            throw Ether.Error.badURL(nil) // This shouldn't happen, but if it does, we ought to know about it.
        }

        // Set the content type
        request.allHTTPHeaderFields?["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8"
        
        // Build a URLComponents object from the URL.
        var components = URLComponents(url: request.url!, resolvingAgainstBaseURL: true)
        
        // Add the parameters as URLQueryItems to the URLComponents object.
        components?.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: "\(value)")
        }
        
        // Attempt to build a URL from the URLComponents object.
        // This really shouldn't fail, but if it does, we ought to know about it as well.
        guard let componentsURL = components?.url else {
            throw Ether.Error.badURL(request.url?.absoluteString)
        }
        request.url = componentsURL
        
        return request
    }
    
    /// Encodes a URLRequest, using JSON encoding of the parameters in the body as Data.
    /// Will also gZip said Data if requested.
    /// - Parameter parameters: The ``Ether/Ether/Parameters`` to encode into the request as JSON.
    /// - Parameter useGZip: Whether or not to gZip the JSON data.
    /// - Returns: A JSON-encoded URLRequest.
    func jsonEncoded(with parameters: Ether.Parameters = [:], usingGZip useGZip: Bool = false) throws -> URLRequest {
        // Create a copy of the urlRequest
        var urlRequest = self
        
        // Serialize the parameters into JSON
        do {
            let data = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            
            // Add the Content-Type header
            urlRequest.allHTTPHeaderFields?["Content-Type"] = "application/json; charset=utf-8"
            
            if useGZip {
                // Set the Content-Encoding header to "gzip"
                urlRequest.allHTTPHeaderFields?["Content-Encoding"] = "gzip"
                
                // Set the body of the request to the gZipped JSON data
                urlRequest.httpBody = try ((data as NSData).compressed(using: .zlib) as Data)
            } else {
                // Set the body of the request to the raw JSON data
                urlRequest.httpBody = data
            }
            
        } catch {
            if let error = error as? EncodingError {
                // If we failed to serialize the parameters into JSON, throw an error
                throw Ether.Error.jsonEncodingFailed(error)
//            } else if let error = error as? GzipError {
//                // If we failed to zip the JSON, throw an error
//                throw Ether.Error.gZipError(error)
            } else {
                // Something else went wrong during encoding
                throw Ether.Error.jsonEncodingFailed(nil)
            }
        }
        
        return urlRequest
    }
    
    func debugString() -> String {
        return """
        \(self.httpMethod!) \(url!)
        Query Items:
        \(URLComponents(url: url!, resolvingAgainstBaseURL: true)?.queryItems ?? [])
        Headers:
        \(self.allHTTPHeaderFields!)
        Body:
        \(String(data: httpBody ?? Data(), encoding: .utf8) ?? "")
        """
    }
}
