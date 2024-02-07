import Foundation

// Simpler/smaller types go here.
// Eventually, if they outgrow this space, they may be graduated into their own files.

extension Ether {
    /// A dictionary of headers to apply to a `URLRequest`.
    public typealias Headers = [String: String]
    /// A dictionary of parameters to apply to a `URLRequest`.
    public typealias Parameters = [String: LosslessStringConvertible]
    
    /// An enum of HTTP methods.
    public enum Method: String {
        case options = "OPTIONS"
        case get     = "GET"
        case head    = "HEAD"
        case post    = "POST"
        case put     = "PUT"
        case patch   = "PATCH"
        case delete  = "DELETE"
        case trace   = "TRACE"
        case connect = "CONNECT"
    }
    
    /// An enum of encoding modes for parameters.
    public enum ParameterEncoding {
        /// [RFC 3986](https://www.ietf.org/rfc/rfc3986.txt)-style encoding of parameters as query items in the URL.
        /// See [MDN](https://developer.mozilla.org/en-US/docs/Glossary/percent-encoding) for more info!
        case urlQuery
        /// Encoding of parameters as JSON in the HTTP request's body.
        case json
        /// Encoding of parameters as gZipped JSON in the HTTP request's body.
        case gZip
        /// Custom encoding. The caller is expected to manually provide a ``Ether/Ether/RequestBody`` for the request, and to provide a MIME type string (corresponding to the provided body) here.
        case custom(contentType: String)
    }
    
    /// An enum of possible request bodies.
    public enum RequestBody {
        /// A JSON-encodable object.
        /// - Parameters:
        ///   - encodable: The object to encode.
        ///   - encoder: The `JSONEncoder` to use. You can create your own instance to customize its behavior before passing it in, if you'd like.
        case encodable(Encodable, encoder: JSONEncoder = JSONEncoder())
        /// A raw data object.
        /// - Parameters:
        ///   - data: The data to send.
        case rawData(Data)
        /// A plain text string.
        /// - Parameters:
        ///   - plainText: The string to send.
        case plainText(String)
    }
    
    /// An enum of possible form values.
    public enum FormValue {
        /// A plain text string.
        /// - Parameters:
        ///   - text: The string to send.
        case text(String)
        /// A file.
        /// - Parameters:
        ///   - file: The file (as a `MultipartFormItem`) to send.
        case file(MultipartFormItem)
        
        /// A struct representing a file to send.
        public struct MultipartFormItem {
            /// The name of the file.
            var fileName: String
            /// The data of the file.
            var fileData: Data
            /// The MIME type of the file.
            var mimeType: String
            
            // Explicitly public memberwise initializer.
            // Swift DOES synthesize these, however, they're internal by default.
            // But we need this to be instantiatable by users of Ether, so we have to do it ourselves.

            /// Creates a new `MultipartFormItem`.
            /// - Parameters:
            ///   - fileName: The name of the file.
            ///   - fileData: The data of the file.
            ///   - mimeType: The MIME type of the file.
            public init(fileName: String, fileData: Data, mimeType: String) {
                self.fileName = fileName
                self.fileData = fileData
                self.mimeType = mimeType
            }
        }
    }
    
    /// A dummy type to use when no decodable is requested.
    /// This is used in the `responseFormat` parameter of the `post` and `postMultipartForm` methods.
    ///
    /// It's been a while since I wrote this, but I think it's because it's easier to have a default type to use when no decodable is requested.
    /// 
    /// I believe it was less cumbersome than having it be an optional, and it also allowed for the `decoded` and `raw` properties of the `Response.Data` enum to be non-optional, IIRC.
    ///
    /// It's a bit of a hack, but I felt it was better than the alternatives. Sometimes using an uglier solution internally provides better ergonomics/DX for the user.
    public struct _DummyTypeUsedWhenNoDecodableIsRequested: Codable {

    }
}
