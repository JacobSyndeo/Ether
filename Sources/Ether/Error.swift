import Foundation

extension Ether {
    public enum Error: Swift.Error, LocalizedError {
        case requestFailed
        case responseNotHTTP
        case badURL(_ attemptedToConvertFrom: String)
        case badQueryItem(_ queryItem: URLQueryItem)
        case badResponseCode(_ responseCode: Int)
        case jsonEncodingFailed(_ error: EncodingError?)
        case jsonDecodingFailed(_ error: DecodingError?)
//        case compressionError(_ error: GzipError)
        case miscResponseIssue // For unknown/uncaught
        
        public var errorDescription: String? {
            switch self {
            case .requestFailed:
                return "The request failed."
            case .responseNotHTTP:
                return "The response was not valid HTTP!"
            case let .badURL(string):
                return "The string provided to Ether as an `Ether.Route` (for automatic conversion into a URL) is invalid: \(string)"
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
//            case let .compressionError(error):
//                return "An error occurred while trying to compress the request's data: \(error)"
            case .miscResponseIssue:
                return "An unknown miscellaneous error occurred. Please report this to Ether's maintainer."
            }
        }
        
        public var failureReason: String? {
            switch self {
            case .requestFailed:
                return nil
            case .responseNotHTTP:
                return "Ether can only handle proper, [RFC 2616]-spec HTTP responses."
            case let .badURL(string):
                return "The string provided to Ether as an `Ether.Route` (for automatic conversion into a URL) does not represent a valid [RFC 1738]-spec URL: \(string)"
            case .badQueryItem(_):
                return nil
            case let .badResponseCode(badCode):
                return "The status code in an HTTP response must be between 200 and 299 to be considered a standard, satisfactory response. Anything else, particularly in the 400-499 and 500-599 range, indicate that something unexpected happened. This time, the response was \(badCode)."
            case let .jsonEncodingFailed(error):
                return error?.failureReason
            case let .jsonDecodingFailed(error):
                return error?.failureReason
//            case let .gZipError(error):
//                return "Error kind: \(error.kind). \(error.message)"
            case .miscResponseIssue:
                return nil
            }
        }
        
        public var recoverySuggestion: String? {
            switch self {
            case .requestFailed:
                return nil
            case .responseNotHTTP:
                return "Try examining the response using a tool like Rested (on Mac App Store) or Postman. If something looks wrong with the response, consider contacting the server's administrator. Otherwise, there may be a bug in Ether; please open an issue ticket."
            case let .badURL(string):
                return "Double-check this URL and try to find the issue: \(string)"
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
//            case .gZipError(_):
//                return nil
            case .miscResponseIssue:
                return nil
            }
        }
    }
}
