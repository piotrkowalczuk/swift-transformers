import Foundation

/// BinaryDistinctString helps to overcome limitations of both String and NSString types. Where the prior is performing unicode normalization and the following is not Sendable. For more reference [Modifying-and-Comparing-Strings](https://developer.apple.com/documentation/swift/string#Modifying-and-Comparing-Strings).
public struct BinaryDistinctString: Equatable, Hashable, Sendable, CustomStringConvertible, ExpressibleByStringLiteral {
    private let value: [UInt8]

    public var nsString: NSString {
        return NSString(data: Data(self.value), encoding: String.Encoding.utf8.rawValue)!
    }

    public var string: String {
        return String(self.nsString)
    }

    /// Satisfies ``CustomStringConvertible`` protocol.
    public var description: String {
        return self.string
    }

    public init(_ str: NSString) {
        if let data = str.data(using: String.Encoding.utf8.rawValue) {
            self.value = [UInt8](data)

            return
        }

        self.value = []
    }

    public init(_ str: String) {
        self.init(str as NSString)
    }

    /// Satisfies ``ExpressibleByStringLiteral`` protocol.
    public init(stringLiteral value: String) {
        self.init(value)
    }

    public static func == (lhs: BinaryDistinctString, rhs: BinaryDistinctString) -> Bool {
        return lhs.value == rhs.value
    }
}

extension BinaryDistinctString: Collection {
    // Collection Protocol Conformance
    public typealias Index = Int
    public typealias Element = String

    public var startIndex: Index { value.startIndex }
    public var endIndex: Index { value.endIndex }

    public func index(after i: Index) -> Index {
        return value.index(after: i)
    }

    public subscript(position: Index) -> Element {
        return Element(value[position])
    }
}

public struct BinaryDistinctDictionary<V>: Collection, ExpressibleByDictionaryLiteral, Sendable where V: Any, V: Sendable, V: Hashable {
    public typealias Key = BinaryDistinctString

    public var storage: [Key: V] = [:]

    // MARK: - Initializers
    public init(_ dictionary: [Key: V] = [:]) {
        self.storage = dictionary
    }

    /// Initializes from `[String: Value]`
    public init(_ dictionary: [String: V]) {
        self.storage = Dictionary(uniqueKeysWithValues: dictionary.map { (BinaryDistinctString($0.key), $0.value) })
    }

    /// Initializes from `[NSString: Value]`
    public init(_ dictionary: [NSString: V]) {
        self.storage = Dictionary(uniqueKeysWithValues: dictionary.map { (BinaryDistinctString($0.key), $0.value) })
    }

    public init(dictionaryLiteral elements: (Key, V)...) {
        self.storage = Dictionary(uniqueKeysWithValues: elements)
    }

    // MARK: - Dictionary Operations
    public subscript(key: Key) -> V? {
        get { return storage[key] }
        set { storage[key] = newValue }
    }

    public var keys: [Key] {
        return Array(storage.keys)
    }

    public var values: [V] {
        return Array(storage.values)
    }

    // MARK: - Collection Conformance
    public typealias Index = Dictionary<Key, V>.Index
    public typealias Element = (key: Key, value: V)

    public var startIndex: Index { storage.startIndex }
    public var endIndex: Index { storage.endIndex }

    public func index(after i: Index) -> Index {
        return storage.index(after: i)
    }

    public subscript(position: Index) -> Element {
        return storage[position]
    }

    /// Returns a new dictionary with keys mapped to the requested type.
    public func mapKeys<K: StringConvertible>(_ type: K.Type) -> [K: V] {
        return Dictionary(
            uniqueKeysWithValues: storage.map {
                (K.self == String.self ? $0.key.string as! K : $0.key.nsString as! K, $0.value)
            }
        )
    }

    // MARK: - Merging Methods

    /// Merges another `BinaryDistinctDictionary` into this one
    public mutating func merge(_ other: BinaryDistinctDictionary<Value>, strategy: (V, V) -> V = { _, new in new }) {
        self.storage.merge(other.storage, uniquingKeysWith: strategy)
    }

    /// Merges a `[String: Value]` dictionary into this one
    public mutating func merge(_ other: [String: V], strategy: (V, V) -> V = { _, new in new }) {
        let converted = Dictionary(uniqueKeysWithValues: other.map { (BinaryDistinctString($0.key), $0.value) })
        self.storage.merge(converted, uniquingKeysWith: strategy)
    }

    /// Merges a `[NSString: Value]` dictionary into this one
    public mutating func merge(_ other: [NSString: V], strategy: (V, V) -> V = { _, new in new }) {
        let converted = Dictionary(uniqueKeysWithValues: other.map { (BinaryDistinctString($0.key), $0.value) })
        self.storage.merge(converted, uniquingKeysWith: strategy)
    }

    /// Returns a new dictionary by merging `other` while keeping the current dictionary unchanged.
    public func merging(_ other: BinaryDistinctDictionary<V>, strategy: (V, V) -> V = { _, new in new }) -> BinaryDistinctDictionary {
        var newDict = self
        newDict.merge(other, strategy: strategy)
        return newDict
    }

    public func merging(_ other: [String: V], strategy: (V, V) -> V = { _, new in new }) -> BinaryDistinctDictionary {
        var newDict = self
        newDict.merge(other, strategy: strategy)
        return newDict
    }

    public func merging(_ other: [NSString: V], strategy: (V, V) -> V = { _, new in new }) -> BinaryDistinctDictionary {
        var newDict = self
        newDict.merge(other, strategy: strategy)
        return newDict
    }

    public func invert() -> [V: BinaryDistinctString] {
        var inverted: [V: BinaryDistinctString] = [:]
        for (k, v) in self.storage {
            inverted[v] = k
        }
        return inverted
    }
}

public protocol StringConvertible: ExpressibleByStringLiteral {}

extension BinaryDistinctString: StringConvertible {}
extension String: StringConvertible {}
extension NSString: StringConvertible {}
