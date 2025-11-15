import Foundation

/// Seq command - Print a sequence of numbers
/// Usage: seq [FIRST [INCREMENT]] LAST
/// Print numbers from FIRST to LAST, in steps of INCREMENT
struct SeqCommand {
    static func main(_ args: [String]) -> Int32 {
        guard args.count >= 2 else {
            FileHandle.standardError.write("usage: seq [first [incr]] last\n".data(using: .utf8)!)
            return 1
        }

        let start: Double
        let step: Double
        let end: Double

        // Parse arguments based on count
        switch args.count {
        case 2:
            // seq LAST
            start = 1
            step = 1
            guard let last = Double(args[1]) else {
                FileHandle.standardError.write("seq: invalid number: '\(args[1])'\n".data(using: .utf8)!)
                return 1
            }
            end = last

        case 3:
            // seq FIRST LAST
            guard let first = Double(args[1]), let last = Double(args[2]) else {
                FileHandle.standardError.write("seq: invalid number\n".data(using: .utf8)!)
                return 1
            }
            start = first
            step = 1
            end = last

        case 4:
            // seq FIRST INCREMENT LAST
            guard let first = Double(args[1]),
                  let incr = Double(args[2]),
                  let last = Double(args[3]) else {
                FileHandle.standardError.write("seq: invalid number\n".data(using: .utf8)!)
                return 1
            }
            start = first
            step = incr
            end = last

        default:
            FileHandle.standardError.write("seq: too many arguments\n".data(using: .utf8)!)
            return 1
        }

        // Generate sequence
        var current = start

        if step > 0 {
            while current <= end {
                // Print as integer if it's a whole number, otherwise as decimal
                if current == floor(current) {
                    print(Int(current))
                } else {
                    print(current)
                }
                current += step
            }
        } else if step < 0 {
            while current >= end {
                if current == floor(current) {
                    print(Int(current))
                } else {
                    print(current)
                }
                current += step
            }
        } else {
            FileHandle.standardError.write("seq: invalid increment: 0\n".data(using: .utf8)!)
            return 1
        }

        return 0
    }
}
