import Foundation

/// Tr command - Translate or delete characters
/// Usage: tr [-d] [-s] SET1 [SET2]
/// Translate characters from SET1 to SET2, or delete characters in SET1
struct TrCommand {
    static func main(_ args: [String]) -> Int32 {
        var deleteChars = false
        var squeezeRepeats = false
        var set1: String?
        var set2: String?

        // Parse arguments
        var i = 1
        while i < args.count {
            let arg = args[i]

            if arg.hasPrefix("-") && arg != "-" {
                // Parse flags
                for char in arg.dropFirst() {
                    switch char {
                    case "d": deleteChars = true
                    case "s": squeezeRepeats = true
                    default:
                        FileHandle.standardError.write("tr: invalid option: -\(char)\n".data(using: .utf8)!)
                        return 1
                    }
                }
            } else if set1 == nil {
                set1 = arg
            } else if set2 == nil {
                set2 = arg
            } else {
                FileHandle.standardError.write("tr: extra operand '\(arg)'\n".data(using: .utf8)!)
                return 1
            }
            i += 1
        }

        // Validate arguments
        guard let fromSet = set1 else {
            FileHandle.standardError.write("tr: missing operand\n".data(using: .utf8)!)
            return 1
        }

        if !deleteChars && set2 == nil {
            FileHandle.standardError.write("tr: missing operand\n".data(using: .utf8)!)
            return 1
        }

        // Read from stdin
        guard let data = try? FileHandle.standardInput.readToEnd(),
              let input = String(data: data, encoding: .utf8) else {
            FileHandle.standardError.write("tr: error reading standard input\n".data(using: .utf8)!)
            return 1
        }

        // Process input
        let output: String
        if deleteChars {
            output = deleteCharacters(input, set: fromSet, squeeze: squeezeRepeats)
        } else {
            output = translateCharacters(input, from: fromSet, to: set2!, squeeze: squeezeRepeats)
        }

        print(output, terminator: "")
        return 0
    }

    /// Get characters for a character class like [:alpha:], [:digit:], etc.
    private static func characterClass(_ className: String) -> Set<Character> {
        switch className {
        case "alpha": return Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
        case "upper": return Set("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        case "lower": return Set("abcdefghijklmnopqrstuvwxyz")
        case "digit": return Set("0123456789")
        case "alnum": return Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        case "space": return Set(" \t\n\r\u{0B}\u{0C}")  // space, tab, newline, CR, VT, FF
        case "blank": return Set(" \t")  // space and tab only
        case "punct": return Set("!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~")
        case "print": return Set((32...126).map { Character(UnicodeScalar($0)) })
        case "cntrl": return Set((0...31).map { Character(UnicodeScalar($0)) } + [Character(UnicodeScalar(127))])
        case "xdigit": return Set("0123456789abcdefABCDEF")
        default: return Set()
        }
    }

    private static func expandSet(_ set: String) -> Set<Character> {
        var expanded = Set<Character>()

        var i = set.startIndex
        while i < set.endIndex {
            let char = set[i]

            // Check for character class [:classname:]
            if char == "[" && set.index(after: i) < set.endIndex && set[set.index(after: i)] == ":" {
                // Find the closing :]
                // Look for the pattern ":]" after "[:"
                let searchStart = set.index(i, offsetBy: 2)
                if let closeIdx = set[searchStart...].range(of: ":]")?.lowerBound {
                    let className = String(set[searchStart..<closeIdx])
                    expanded.formUnion(characterClass(className))
                    i = set.index(after: set.index(after: closeIdx))
                    continue
                }
            }

            // Check for range pattern (a-z)
            let nextIdx = set.index(after: i)
            if nextIdx < set.endIndex && set[nextIdx] == "-" {
                let endIdx = set.index(after: nextIdx)
                if endIdx < set.endIndex {
                    let endChar = set[endIdx]
                    // Add range
                    if let startAscii = char.asciiValue, let endAscii = endChar.asciiValue {
                        for ascii in startAscii...endAscii {
                            expanded.insert(Character(UnicodeScalar(ascii)))
                        }
                    }
                    i = set.index(after: endIdx)
                    continue
                }
            }

            expanded.insert(char)
            i = set.index(after: i)
        }

        return expanded
    }

    private static func buildTranslationMap(from: String, to: String) -> [Character: Character] {
        var map: [Character: Character] = [:]

        let fromChars = expandSetToArray(from)
        let toChars = expandSetToArray(to)

        for (index, char) in fromChars.enumerated() {
            // If to is shorter, repeat last character
            let toChar = index < toChars.count ? toChars[index] : toChars.last!
            map[char] = toChar
        }

        return map
    }

    private static func expandSetToArray(_ set: String) -> [Character] {
        var expanded: [Character] = []

        var i = set.startIndex
        while i < set.endIndex {
            let char = set[i]

            // Check for character class [:classname:]
            if char == "[" && set.index(after: i) < set.endIndex && set[set.index(after: i)] == ":" {
                // Find the closing :]
                // Look for the pattern ":]" after "[:"
                let searchStart = set.index(i, offsetBy: 2)
                if let closeIdx = set[searchStart...].range(of: ":]")?.lowerBound {
                    let className = String(set[searchStart..<closeIdx])
                    // Add character class in sorted order for consistency
                    expanded.append(contentsOf: characterClass(className).sorted())
                    i = set.index(after: set.index(after: closeIdx))
                    continue
                }
            }

            // Check for range pattern (a-z)
            let nextIdx = set.index(after: i)
            if nextIdx < set.endIndex && set[nextIdx] == "-" {
                let endIdx = set.index(after: nextIdx)
                if endIdx < set.endIndex {
                    let endChar = set[endIdx]
                    // Add range
                    if let startAscii = char.asciiValue, let endAscii = endChar.asciiValue {
                        for ascii in startAscii...endAscii {
                            expanded.append(Character(UnicodeScalar(ascii)))
                        }
                    }
                    i = set.index(after: endIdx)
                    continue
                }
            }

            expanded.append(char)
            i = set.index(after: i)
        }

        return expanded
    }

    private static func deleteCharacters(_ input: String, set: String, squeeze: Bool) -> String {
        let deleteSet = expandSet(set)
        var result = ""
        var lastChar: Character?

        for char in input {
            if deleteSet.contains(char) {
                // Delete this character
                continue
            }

            // If squeezing, skip repeated characters
            if squeeze && lastChar == char {
                continue
            }

            result.append(char)
            lastChar = char
        }

        return result
    }

    private static func translateCharacters(_ input: String, from: String, to: String, squeeze: Bool) -> String {
        let translationMap = buildTranslationMap(from: from, to: to)
        var result = ""
        var lastChar: Character?

        for char in input {
            let outputChar = translationMap[char] ?? char

            // If squeezing, skip repeated characters
            if squeeze && lastChar == outputChar {
                continue
            }

            result.append(outputChar)
            lastChar = outputChar
        }

        return result
    }
}
