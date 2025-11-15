import Foundation

/// Printf command - Format and print data
/// Usage: printf FORMAT [ARGUMENT]...
/// Format and print ARGUMENT(s) according to FORMAT
struct PrintfCommand {
    static func main(_ args: [String]) -> Int32 {
        guard args.count > 1 else {
            FileHandle.standardError.write("printf: missing format string\n".data(using: .utf8)!)
            return 1
        }

        let format = args[1]
        let arguments = args.count > 2 ? Array(args[2...]) : []

        do {
            let output = try formatString(format, arguments: arguments)
            print(output, terminator: "")
            return 0
        } catch {
            FileHandle.standardError.write("printf: \(error.localizedDescription)\n".data(using: .utf8)!)
            return 1
        }
    }

    static func formatString(_ format: String, arguments: [String]) throws -> String {
        var result = ""
        var argIndex = 0
        var i = format.startIndex

        while i < format.endIndex {
            if format[i] == "\\" && format.index(after: i) < format.endIndex {
                // Handle escape sequences
                i = format.index(after: i)
                switch format[i] {
                case "n": result += "\n"
                case "t": result += "\t"
                case "r": result += "\r"
                case "\\": result += "\\"
                case "a": result += "\u{07}" // bell
                case "b": result += "\u{08}" // backspace
                case "f": result += "\u{0C}" // form feed
                case "v": result += "\u{0B}" // vertical tab
                default: result.append(format[i])
                }
                i = format.index(after: i)
            } else if format[i] == "%" && format.index(after: i) < format.endIndex {
                i = format.index(after: i)
                if format[i] == "%" {
                    result += "%"
                    i = format.index(after: i)
                } else {
                    // Handle format specifiers
                    var specifier = "%"

                    // Skip flags, width, precision for simplicity
                    while i < format.endIndex && "0123456789.-+# ".contains(format[i]) {
                        specifier.append(format[i])
                        i = format.index(after: i)
                    }

                    if i < format.endIndex {
                        specifier.append(format[i])

                        // Get next argument
                        let arg = argIndex < arguments.count ? arguments[argIndex] : ""
                        argIndex += 1

                        switch format[i] {
                        case "s":
                            // For string, just append directly (Swift doesn't support %s with String(format:))
                            if specifier == "%s" {
                                result += arg
                            } else {
                                // Handle width/precision if present - simplified
                                result += arg
                            }
                        case "d", "i":
                            let value = Int(arg) ?? 0
                            result += String(format: specifier, value)
                        case "u":
                            let value = UInt(arg) ?? 0
                            result += String(format: specifier, value)
                        case "x", "X":
                            let value = Int(arg, radix: 16) ?? Int(arg) ?? 0
                            result += String(format: specifier, value)
                        case "o":
                            let value = Int(arg, radix: 8) ?? Int(arg) ?? 0
                            result += String(format: specifier, value)
                        case "f", "e", "E", "g", "G":
                            let value = Double(arg) ?? 0.0
                            result += String(format: specifier, value)
                        case "c":
                            if let first = arg.first {
                                result.append(first)
                            }
                        default:
                            result += arg
                        }

                        i = format.index(after: i)
                    }
                }
            } else {
                result.append(format[i])
                i = format.index(after: i)
            }
        }

        return result
    }
}
