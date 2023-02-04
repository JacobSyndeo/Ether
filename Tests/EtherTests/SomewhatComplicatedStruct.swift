import Foundation

public struct SomewhatComplicatedStruct: Codable, Equatable {
    // Properties
    // If you add or change anything in these, PLEASE make sure you update the number and/or names in the extension below. Thank you!
    public var string: String?
    public var int: Int?
    public var double: Double?
    public var nestedStruct: NestedStruct
    
    // Nested Struct definition
    public struct NestedStruct: Codable, Equatable {
        public let nestedString: String
    }
    
    // The instance
    public static let aSomewhatComplicatedInstance = SomewhatComplicatedStruct(string: "Hi",
                                                                               int: 1,
                                                                               double: 1.5,
                                                                               nestedStruct: SomewhatComplicatedStruct.NestedStruct(nestedString: "Hello"))
}

// Manually-confirmed values to aid in unit testing.
// These are computed properties, so they don't count as "real" properties for the sake of counting; they're functions with syntactic sugar.
public extension SomewhatComplicatedStruct {
    static var numberOfProperties: Int { // Non-computed only. See above!
        return 4 // KEEP THIS UP TO DATE, BY HAND. Unit tests depend on it!
    }
    
    static var nestedStructName: String {
        return "nestedStruct" // KEEP THIS UP TO DATE, BY HAND. Unit tests depend on it!
    }
    
    static var numberOfPropertiesInNestedStruct: Int { // Non-computed only. See above!
        return 1 // KEEP THIS UP TO DATE, BY HAND. Unit tests depend on it!
    }
    
    static var nestedStructNestedStringName: String {
        return "nestedString" // KEEP THIS UP TO DATE, BY HAND. Unit tests depend on it!
    }
}
