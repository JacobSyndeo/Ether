import Foundation

extension Ether {
    /// An error that can occur while using Ether.
    /// This can help give insight into what went wrong.
    /// As long as the issue wasn't server-side, network-related, or a bug in Ether, this should hopefully help you resolve the issue!
    /// If not, or if you suspect a bug in Ether, please [open an issue on GitHub](https://github.com/JacobSyndeo/Ether/issues/new), and I'll do my best to help you out!
    public enum Error: Swift.Error, LocalizedError {
        /// The request failed.
        case requestFailed
        /// The response was not valid HTTP!
        case responseNotHTTP
        /// The string provided to Ether as an `Ether.Route` (for automatic conversion into a URL) is invalid.
        /// - Parameters:
        ///   - attemptedToConvertFrom: The string that Ether attempted to convert into a URL.
        case badURL(_ attemptedToConvertFrom: String?)
        /// One of the provided query items is invalid.
        /// - Parameters:
        ///   - queryItem: The query item that Ether found to be invalid.
        case badQueryItem(_ queryItem: URLQueryItem)
        /// The server responded with a bad response code.
        /// - Parameters:
        ///   - responseCode: The response code that Ether found to be invalid.
        case badResponseCode(_ responseCode: Int)
        /// Encoding to JSON failed.
        /// - Parameters:
        ///   - error: The error that occurred while encoding to JSON.
        case jsonEncodingFailed(_ error: EncodingError?)
        /// Decoding from JSON failed.
        /// - Parameters:
        ///   - error: The error that occurred while decoding from JSON.
        case jsonDecodingFailed(_ error: DecodingError?)
        /// Some other, unknown issue occurred. [Please report this as an issue!](https://github.com/JacobSyndeo/Ether/issues/new)
        case miscResponseIssue // For unknown/uncaught
        
        /// A string describing the error.
        public var errorDescription: String? {
            switch self {
            case .requestFailed:
                return "The request failed."
            case .responseNotHTTP:
                return "The response was not valid HTTP!"
            case let .badURL(string):
                return "The string provided to Ether as an `Ether.Route` (for automatic conversion into a URL) is invalid: \(string ?? "(nil)")"
            case let .badQueryItem(queryItem):
                return "One of the provided query items is invalid: \(queryItem)"
            case let .badResponseCode(badCode):
                return "The server responded with a bad response code: \(badCode)"
            case let .jsonEncodingFailed(error):
                var message = "Encoding to JSON failed"
                
                if let errorDescription = error?.errorDescription {
                    message += ": " + errorDescription
                } else {
                    message += ", but no further information is available."
                }
                
                return message
            case let .jsonDecodingFailed(error):
                var message = "Decoding from JSON failed"
                
                if let errorDescription = error?.errorDescription {
                    message += ": " + errorDescription
                } else {
                    message += ", but no further information is available."
                }
                
                return message
            case .miscResponseIssue:
                return "An unknown miscellaneous error occurred. Please report this to Ether's maintainer."
            }
        }
        
        /// A string describing the reason for the error.
        public var failureReason: String? {
            switch self {
            case .requestFailed:
                return nil
            case .responseNotHTTP:
                return "Ether can only handle proper, [RFC 2616]-spec HTTP responses."
            case let .badURL(string):
                return "The string provided to Ether as an `Ether.Route` (for automatic conversion into a URL) does not represent a valid [RFC 1738]-spec URL: \(string ?? "(nil)")"
            case .badQueryItem(_):
                return nil
            case let .badResponseCode(badCode):
                return "The status code in an HTTP response must be between 200 and 299 to be considered a standard, satisfactory response. Anything else, particularly in the 400-499 and 500-599 range, indicate that something unexpected happened. This time, the response was \(badCode)."
            case let .jsonEncodingFailed(error):
                return error?.failureReason
            case let .jsonDecodingFailed(error):
                return error?.failureReason
            case .miscResponseIssue:
                return nil
            }
        }
        
        /// A string describing how to recover from the error.
        public var recoverySuggestion: String? {
            switch self {
            case .requestFailed:
                return nil
            case .responseNotHTTP:
                return "Try examining the response using a tool like Rested (on Mac App Store) or Postman. If something looks wrong with the response, consider contacting the server's administrator. Otherwise, there may be a bug in Ether; please open an issue ticket."
            case let .badURL(string):
                return "Double-check this URL and try to find the issue: \(string ?? "(nil)")"
            case .badQueryItem(_):
                return nil
            case let .badResponseCode(badCode):
                var message = ""
                
                switch badCode {
                case 400...499:
                    message += "Status code \(badCode) is in the 4xx range, indicating that the server is claiming something's wrong with the request we made, and is therefore refusing to service it."
                case 500...599:
                    message += "Status code \(badCode) is in the 5xx range, indicating that the server is encountering an error while attempting to service the request we made."
                default:
                    break
                }
                
                message += "Check https://en.wikipedia.org//wiki/List_of_HTTP_status_codes#\(badCode) to learn more about status code \(badCode)."
                
                return message
            case let .jsonEncodingFailed(error):
                return error?.recoverySuggestion
            case let .jsonDecodingFailed(error):
                return error?.recoverySuggestion
            case .miscResponseIssue:
                return nil
            }
        }
    }
}
