import Foundation

/// Pure Swift implementation of the echo command
struct EchoCommand {
    static func main(args: [String]) -> Int32 {
        var printNewline = true
        var interpretEscapes = false
        var startIndex = 1

        // Parse flags
        while startIndex < args.count && args[startIndex].hasPrefix("-") && args[startIndex] != "-" {
            let arg = args[startIndex]
            if arg == "-n" {
                printNewline = false
                startIndex += 1
            } else if arg == "-e" {
                interpretEscapes = true
                startIndex += 1
            } else if arg == "-ne" || arg == "-en" {
                printNewline = false
                interpretEscapes = true
                startIndex += 1
            } else {
                break
            }
        }

        var output = args[startIndex...].joined(separator: " ")

        // Process escape sequences if -e flag is set
        if interpretEscapes {
            output = processEscapes(output)
        }

        if printNewline {
            print(output)
        } else {
            FileHandle.standardOutput.write(output.data(using: .utf8) ?? Data())
        }

        return 0
    }

    /// Process backslash escape sequences
    private static func processEscapes(_ input: String) -> String {
        var result = ""
        var i = input.startIndex

        while i < input.endIndex {
            if input[i] == "\\" && input.index(after: i) < input.endIndex {
                i = input.index(after: i)
                let nextChar = input[i]

                switch nextChar {
                case "n":
                    result.append("\n")
                    i = input.index(after: i)
                case "t":
                    result.append("\t")
                    i = input.index(after: i)
                case "r":
                    result.append("\r")
                    i = input.index(after: i)
                case "\\":
                    result.append("\\")
                    i = input.index(after: i)
                case "0", "1", "2", "3", "4", "5", "6", "7":
                    // Octal escape sequence: \0nnn (up to 3 octal digits)
                    var octalStr = ""
                    var count = 0
                    var idx = i

                    while idx < input.endIndex && count < 4 && input[idx].isOctalDigit {
                        octalStr.append(input[idx])
                        idx = input.index(after: idx)
                        count += 1
                    }

                    if let octalValue = Int(octalStr, radix: 8), octalValue <= 255 {
                        // Convert to character and append
                        if octalValue == 0 {
                            result.append("\0")
                        } else if let scalar = UnicodeScalar(octalValue) {
                            result.append(Character(scalar))
                        }
                        i = idx
                    } else {
                        // Invalid octal, treat backslash literally
                        result.append("\\")
                        result.append(nextChar)
                        i = input.index(after: i)
                    }
                default:
                    // Unknown escape, keep backslash and character
                    result.append("\\")
                    result.append(nextChar)
                    i = input.index(after: i)
                }
            } else {
                result.append(input[i])
                i = input.index(after: i)
            }
        }

        return result
    }
}

extension Character {
    var isOctalDigit: Bool {
        return self >= "0" && self <= "7"
    }
}
