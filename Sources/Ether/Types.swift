import Foundation

// Simpler/smaller types go here.
// Eventually, if they outgrow this space, they may be graduated into their own files.

extension Ether {
    /// A dictionary of headers to apply to a `URLRequest`.
    public typealias Headers = [String: String]
    /// A dictionary of parameters to apply to a `URLRequest`.
    public typealias Parameters = [String: String]
    
    /// An enum defining preferred behavior of error messaging alerts.
    /// Currently/primarily used for Authentication/Login Status alerts.
    public enum AlertBehavior {
        /// Never show alerts for failed requests.
        /// This can be used for unimportant background tasks.
        case never
        
        /// Only show alerts if the user hasn't asked for them to be muted.
        /// This is preferred for important background reload tasks.
        case ifUserHasntMuted
        
        /// Override the user's mute request.
        /// Use this if the action is user-initiated, such as pushing a reload button.
        case evenIfMuted
    }
    
    // TODO: Consider refactoring AlertBehavior into "Importance" or something.
    /// It'd be along the lines of Async Task priority.
    /// e.g. `.never` would be `.bgUnimportant`
    /// `.ifUserHasntMuted` would be `.bgImportant`
    /// `.evenIfMuted` would be `.userInitiated`
    
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
        /// Encoding of parameters as JSON in the HTTP request's body.
        case gZip
        /// Custom encoding. The caller is expected to manually provide a ``Ether/Ether/RequestBody`` for the request, and to provide a MIME type string (corresponding to the provided body) here.
        case custom(contentType: String)
    }
    
    public enum CacheBehavior {
        case alwaysUseIfAvailable
        case useIfTimePassedIsLessThan(seconds: Int)
        case onlyUseIfOffline
        case neverUse
    }
    
    public enum RequestBody {
        case encodable(Encodable, encoder: JSONEncoder = JSONEncoder())
        case rawData(Data)
        case plainText(String)
    }
    
    public enum FormValue {
        case text(String)
        case file(MultipartFormItem)
        
        public struct MultipartFormItem {
            var fileName: String
            var fileData: Data
            var mimeType: String
            
            // Explicitly public
            public init(fileName: String, fileData: Data, mimeType: String) {
                self.fileName = fileName
                self.fileData = fileData
                self.mimeType = mimeType
            }
        }
    }
    
    public struct _DummyTypeUsedWhenNoDecodableIsRequested: Codable {
        
    }
}
