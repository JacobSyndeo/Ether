extension Ether {
    internal static func checkForHeaderIssues(headerKey: String, headerValue: String, knownDomain: String?) {
        if ["Accept",
            "Authorization",
            "Content-Type",
            "Content-Encoding"].contains(headerKey) {
            
            let warningHeading = "⚠️⚠️⚠️ Ether WARNING :o ⚠️⚠️⚠️"
            
            switch headerKey {
            case "Accept":
                logger.warning("""
                    \(warningHeading)
                    Manually setting \(headerKey) in this request may cause the server to not return a decodable response!
                    Please only do this you have a *really* good reason to do so!
                    """)
            case "Authorization":
                if let knownDomain {
                    logger.warning("""
                        \(warningHeading)
                        Manually setting \(headerKey) in this request will cause your session data with \(knownDomain) to be disrupted!
                        Please only do this you have a *really* good reason to do so!
                        """)
                }
            case "Content-Type":
                let contentTypeSuggestion: String
                
                if headerValue.starts(with: "application/json") {
                    contentTypeSuggestion = "Since \(headerValue) is natively supported by Ether, please set `usingEncoding:` to `.json()`"
                } else {
                    contentTypeSuggestion = "Since \(headerValue) is not natively supported by Ether, please set `usingEncoding:` to `.custom(\(headerValue))"
                }
                
                logger.warning("""
                    \(warningHeading)
                    Manually setting the \(headerKey) via custom headers is not supported; any value set this way will be overwritten by the ParameterEncoding setting passed into the function.
                    \(contentTypeSuggestion), and remove the manually-set \(headerKey) header.
                    """)
            case "Content-Encoding":
                logger.warning("""
                    \(warningHeading)
                    Manually setting the \(headerKey) via custom headers is not supported; this value will be overwritten in certain cases, such as when gZipping a request.
                    Please only do this you have a *really* good reason to do so!
                    """)
            default:
                logger.warning("""
                    \(warningHeading)
                    Manually setting \(headerKey) can lead to weird, unexpected behavior, such as having it overwritten by other parameters (even default ones you didn't explicitly provide)! Please use the normal Ether ways of doing this, unless you have a *really* good reason NOT to.
                    """)
            }
        }
    }
}
