import Foundation

internal extension NSMutableData {
    /// Lets you append a string as UTF-8 data.
    /// - Parameter string: The string to append as UTF-8 data.
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
