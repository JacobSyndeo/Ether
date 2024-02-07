import Foundation

extension Ether {
    /// The data and metadata associated with the response to an HTTP protocol URL load request.
    public struct Response<T> where T: Decodable {
        /// The response's data.
        /// Contains either a `Decodable` instance, or raw data.
        /// - SeeAlso: Ether's Response Data type, ``Ether/Ether/Response/Data-swift.enum``, _not_ to be confused with `Foundation`'s `Data` type.
        public var data: Data<T>
        
        // Keep this internal, since the syntax of "response.response" is really dumb and messy.
        internal var response: HTTPURLResponse
        
        /// The response’s HTTP status code.
        ///
        /// See [RFC 2616](https://www.ietf.org/rfc/rfc2616.txt) for details.
        public var statusCode: Int {
            return response.statusCode
        }
        
        /// Returns a localized string suitable for displaying to users that describes this response's status code.
        public var localizedStringForStatusCode: String {
            return HTTPURLResponse.localizedString(forStatusCode: statusCode)
        }
        
        /// All HTTP header fields of the response.
        ///
        /// The value of this property is a dictionary that contains all the HTTP header fields received as part of the server’s response. By examining this dictionary, clients can see the “raw” header information returned by the HTTP server.
        ///
        /// The keys in this dictionary are the header field names, as received from the server. See [RFC 2616](https://www.ietf.org/rfc/rfc2616.txt) for a list of commonly used HTTP header fields.
        ///
        /// HTTP headers are case insensitive. To simplify your code, URL Loading System canonicalizes certain header field names into their standard form. For example, if the server sends a `content-length` header, it’s automatically adjusted to be `Content-Length`.
        public var allHeaderFields: [AnyHashable : Any] {
            return response.allHeaderFields
        }
        
        /// A container for response data.
        public enum Data<T> where T: Decodable {
            /// If a `responseFormat` was specified in the request, then this contains an instance of that specified `Decodable` type.
            case decoded(T)
            /// If a `responseFormat` was _not_ specified in the request, then this contains that data.
            case raw(Foundation.Data)
            
            /// Convenience computed function to access the decoded data without having to litter your code with switch statements.
            /// Comes at the cost of having to unwrap an optional.
            public var decoded: T? {
                switch self {
                case let .decoded(decodedData):
                    return decodedData
                default:
                    return nil
                }
            }
            
            /// Convenience computed function to access the raw data without having to litter your code with switch statements.
            /// Comes at the cost of having to unwrap an optional.
            public var raw: Foundation.Data? {
                switch self {
                case let .raw(data):
                    return data
                default:
                    return nil
                }
            }
        }
    }   
}
