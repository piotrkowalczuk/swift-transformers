import XCTest

@testable import Hub
@testable import Tokenizers

class NormalizerTests: XCTestCase {

    func testLowercaseNormalizer() {
        let testCases: [(String, String)] = [
            ("Café", "café"),
            ("François", "françois"),
            ("Ωmega", "ωmega"),
            ("über", "über"),
            ("háček", "háček"),
            ("Häagen-Dazs", "häagen-dazs"),
            ("你好!", "你好!"),
            ("𝔄𝔅ℭ⓵⓶⓷︷,︸,i⁹,i₉,㌀,¼", "𝔄𝔅ℭ⓵⓶⓷︷,︸,i⁹,i₉,㌀,¼"),
            ("\u{00C5}", "\u{00E5}"),
        ]

        for (arg, expect) in testCases {
            let config = Config()
            let normalizer = LowercaseNormalizer(config: config)
            XCTAssertEqual(normalizer.normalize(text: arg), expect)
        }

        let config = Config(dictionary: ["type": NormalizerType.Lowercase.rawValue] as [BinaryDistinctString: Sendable])
        XCTAssertNotNil(NormalizerFactory.fromConfig(config: config) as? LowercaseNormalizer)
    }

    func testNFDNormalizer() {
        let testCases: [(String, String)] = [
            ("caf\u{65}\u{301}", "cafe\u{301}"),
            ("François", "François"),
            ("Ωmega", "Ωmega"),
            ("über", "über"),
            ("háček", "háček"),
            ("Häagen-Dazs", "Häagen-Dazs"),
            ("你好!", "你好!"),
            ("𝔄𝔅ℭ⓵⓶⓷︷,︸,i⁹,i₉,㌀,¼", "𝔄𝔅ℭ⓵⓶⓷︷,︸,i⁹,i₉,㌀,¼"),
            ("\u{00C5}", "\u{0041}\u{030A}"),
        ]

        for (arg, expect) in testCases {
            let config = Config()
            let normalizer = NFDNormalizer(config: config)
            XCTAssertEqual(normalizer.normalize(text: arg), expect)
        }

        let config = Config(dictionary: ["type": NormalizerType.NFD.rawValue] as [BinaryDistinctString: Sendable])
        XCTAssertNotNil(NormalizerFactory.fromConfig(config: config) as? NFDNormalizer)
    }

    func testNFCNormalizer() {
        let testCases: [(String, String)] = [
            ("café", "café"),
            ("François", "François"),
            ("Ωmega", "Ωmega"),
            ("über", "über"),
            ("háček", "háček"),
            ("Häagen-Dazs", "Häagen-Dazs"),
            ("你好!", "你好!"),
            ("𝔄𝔅ℭ⓵⓶⓷︷,︸,i⁹,i₉,㌀,¼", "𝔄𝔅ℭ⓵⓶⓷︷,︸,i⁹,i₉,㌀,¼"),
            ("\u{00C5}", "\u{00C5}"),
        ]

        for (arg, expect) in testCases {
            let normalizer = NFCNormalizer(config: .init())
            XCTAssertEqual(normalizer.normalize(text: arg), expect)
        }

        let config = Config(dictionary: ["type": NormalizerType.NFC.rawValue] as [BinaryDistinctString: Sendable])
        XCTAssertNotNil(NormalizerFactory.fromConfig(config: config) as? NFCNormalizer)
    }

    func testNFKDNormalizer() {
        let testCases: [(String, String)] = [
            ("café", "cafe\u{301}"),
            ("François", "François"),
            ("Ωmega", "Ωmega"),
            ("über", "über"),
            ("háček", "háček"),
            ("Häagen-Dazs", "Häagen-Dazs"),
            ("你好!", "你好!"),
            ("𝔄𝔅ℭ⓵⓶⓷︷,︸,i⁹,i₉,㌀,¼", "ABC⓵⓶⓷{,},i9,i9,アパート,1⁄4"),
            ("\u{00C5}", "Å"),
        ]

        for (arg, expect) in testCases {
            let normalizer = NFKDNormalizer(config: .init())
            XCTAssertEqual(normalizer.normalize(text: arg), expect)
        }

        let config = Config(dictionary: ["type": NormalizerType.NFKD.rawValue] as [BinaryDistinctString: Sendable])
        XCTAssertNotNil(NormalizerFactory.fromConfig(config: config) as? NFKDNormalizer)
    }

    func testNFKCINormalizer() {
        let testCases: [(String, String)] = [
            ("café", "café"),
            ("François", "François"),
            ("Ωmega", "Ωmega"),
            ("über", "über"),
            ("háček", "háček"),
            ("Häagen-Dazs", "Häagen-Dazs"),
            ("你好!", "你好!"),
            ("𝔄𝔅ℭ⓵⓶⓷︷,︸,i⁹,i₉,㌀,¼", "ABC⓵⓶⓷{,},i9,i9,アパート,1⁄4"),
            ("\u{00C5}", "\u{00C5}"),
        ]

        for (arg, expect) in testCases {
            let normalizer = NFKCNormalizer(config: .init())
            XCTAssertEqual(normalizer.normalize(text: arg), expect)
        }

        let config = Config(dictionary: ["type": NormalizerType.NFKC.rawValue] as [BinaryDistinctString: Sendable])
        XCTAssertNotNil(NormalizerFactory.fromConfig(config: config) as? NFKCNormalizer)
    }

    func testStripAccents() {
        let testCases: [(String, String)] = [
            ("département", "departement"),
        ]

        //TODO: test combinations with/without lowercase
        let config = Config(dictionary: ["stripAccents":true] as [BinaryDistinctString: Sendable])
        let normalizer = BertNormalizer(config: config)
        for (arg, expect) in testCases {
            XCTAssertEqual(normalizer.normalize(text: arg), expect)
        }
    }

    func testBertNormalizer() {
        let testCases: [(String, String)] = [
            ("Café", "café"),
            ("François", "françois"),
            ("Ωmega", "ωmega"),
            ("über", "über"),
            ("háček", "háček"),
            ("Häagen\tDazs", "häagen dazs"),
            ("你好!", " 你  好 !"),
            ("𝔄𝔅ℭ⓵⓶⓷︷,︸,i⁹,i₉,㌀,¼", "𝔄𝔅ℭ⓵⓶⓷︷,︸,i⁹,i₉,㌀,¼"),
            ("\u{00C5}", "\u{00E5}"),
        ]

        for (arg, expect) in testCases {
            let config = Config(dictionary: ["stripAccents":false] as [BinaryDistinctString: Sendable])
            let normalizer = BertNormalizer(config: config)
            XCTAssertEqual(normalizer.normalize(text: arg), expect)
        }

        let config = Config(dictionary: ["type": NormalizerType.Bert.rawValue] as [BinaryDistinctString: Sendable])
        XCTAssertNotNil(NormalizerFactory.fromConfig(config: config) as? BertNormalizer)
    }

    func testBertNormalizerDefaults() {
        // Python verification: t._tokenizer.normalizer.normalize_str("Café")
        let testCases: [(String, String)] = [
            ("Café", "cafe"),
            ("François", "francois"),
            ("Ωmega", "ωmega"),
            ("über", "uber"),
            ("háček", "hacek"),
            ("Häagen\tDazs", "haagen dazs"),
            ("你好!", " 你  好 !"),
            ("𝔄𝔅ℭ⓵⓶⓷︷,︸,i⁹,i₉,㌀,¼", "𝔄𝔅ℭ⓵⓶⓷︷,︸,i⁹,i₉,㌀,¼"),
            ("Å", "a"),
        ]

        for (arg, expect) in testCases {
            let normalizer = BertNormalizer(config: .init())
            XCTAssertEqual(normalizer.normalize(text: arg), expect)
        }

        let config = Config(dictionary: ["type": NormalizerType.Bert.rawValue] as [BinaryDistinctString: Sendable])
        XCTAssertNotNil(NormalizerFactory.fromConfig(config: config) as? BertNormalizer)
    }

    func testPrecompiledNormalizer() {
        let testCases: [(String, String)] = [
            ("café", "café"),
            ("François", "François"),
            ("Ωmega", "Ωmega"),
            ("über", "über"),
            ("háček", "háček"),
            ("Häagen-Dazs", "Häagen-Dazs"),
            ("你好!", "你好!"),
            ("𝔄𝔅ℭ⓵⓶⓷︷,︸,i⁹,i₉,㌀,¼", "ABC⓵⓶⓷{,},i9,i9,アパート,1⁄4"),
            ("\u{00C5}", "\u{00C5}"),
            ("™\u{001e}g", "TMg"),
            ("full-width～tilde", "full-width～tilde"),
        ]

        for (arg, expect) in testCases {
            let normalizer = PrecompiledNormalizer(config: .init())
            XCTAssertEqual(normalizer.normalize(text: arg), expect)
        }

        let config = Config(dictionary: ["type": NormalizerType.Precompiled.rawValue] as [BinaryDistinctString: Sendable])
        XCTAssertNotNil(NormalizerFactory.fromConfig(config: config) as? PrecompiledNormalizer)
    }

    func testStripAccentsINormalizer() {
        let testCases: [(String, String)] = [
            ("café", "café"),
            ("François", "François"),
            ("Ωmega", "Ωmega"),
            ("über", "über"),
            ("háček", "háček"),
            ("Häagen-Dazs", "Häagen-Dazs"),
            ("你好!", "你好!"),
            ("𝔄𝔅ℭ⓵⓶⓷︷,︸,i⁹,i₉,㌀,¼", "ABC⓵⓶⓷{,},i9,i9,アパート,1⁄4"),
            ("\u{00C5}", "\u{00C5}"),
        ]

        for (arg, expect) in testCases {
            let normalizer = StripAccentsNormalizer(config: .init())
            XCTAssertEqual(normalizer.normalize(text: arg), expect)
        }

        let config = Config(dictionary: ["type": NormalizerType.StripAccents.rawValue] as [BinaryDistinctString: Sendable])
        XCTAssertNotNil(NormalizerFactory.fromConfig(config: config) as? StripAccentsNormalizer)
    }

    func testStripNormalizer() {
        let testCases: [(String, String, Bool, Bool)] = [
            ("  hello  ", "hello", true, true),
            ("  hello  ", "hello  ", true, false),
            ("  hello  ", "  hello", false, true),
            ("  hello  ", "  hello  ", false, false),
            ("\t\nHello\t\n", "Hello", true, true),
            ("   ", "", true, true),
            ("", "", true, true),
        ]

        for (input, expected, leftStrip, rightStrip) in testCases {
            let config = Config(dictionary: [
                "type": NormalizerType.Strip.rawValue,
                "stripLeft": leftStrip,
                "stripRight": rightStrip,
            ] as [BinaryDistinctString: Sendable])
            let normalizer = StripNormalizer(config: config)
            XCTAssertEqual(
                normalizer.normalize(text: input), expected,
                "Failed for input: '\(input)', leftStrip: \(leftStrip), rightStrip: \(rightStrip)")
        }

        let config = Config(dictionary: [BinaryDistinctString("type"): NormalizerType.Strip.rawValue])
        XCTAssertNotNil(NormalizerFactory.fromConfig(config: config) as? StripNormalizer)
    }

}
