import UIKit

public struct ImageWrapper: Codable, Equatable {
    enum CodingError: Error {
        case encodingFailed
        case decodingFailed
    }

    public let image: UIImage

    public enum CodingKeys: String, CodingKey {
        case image
    }

    public init(image: UIImage) {
        self.image = image
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.decode(Data.self, forKey: CodingKeys.image)
        guard let image = UIImage(data: data) else {
            throw CodingError.decodingFailed
        }

        self.image = image
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        guard let data = image.pngData() else {
            throw CodingError.encodingFailed
        }

        try container.encode(data, forKey: CodingKeys.image)
    }
}

// Shoutout to S̶i̶m̶p̶l̶e̶F̶l̶i̶p̶s̶
// This: https://stackoverflow.com/a/73109547
