import UIKit
import Ether
import Vapor

struct SharedData {
    static let maxEchoes = 8
    
    struct Multipart {
        // Let's ensure our unicode encoding is working properly too… Throw some non-ASCII characters in there!
        public struct MultipartData: Content {
            static var hello = "你好！"
            static var fileName = "你好.jpeg"
            static var imageWrapper: ImageWrapper {
                let url = Bundle.module.url(forResource: "你好", withExtension: "jpeg")!
                return ImageWrapper(image: UIImage(contentsOfFile: url.relativePath)!) // Force unwrapping is "okay"; this is a unit test, not production code. Crashes will be caught/fixed in unit tests. Besides, we *want* the test to fail if it can't find this.
            }
        }
        
        // Make the MultipartDataExample's properties in Server.swift match the field keys.
        static var multipartFormFields: [String: Ether.FormValue] = [
            "hello": .text(MultipartData.hello),
            "你好": .file(Ether.FormValue.MultipartFormItem(fileName: MultipartData.fileName,
                                                           fileData: MultipartData.imageWrapper.image.pngData()!, // See above note on force-unwrap rationale
                                                           mimeType: "image/jpeg"))
        ]
    }
    
    struct RawData {
        static var imageData: Foundation.Data {
            return Multipart.MultipartData.imageWrapper.image.pngData()!
        }
    }
}
