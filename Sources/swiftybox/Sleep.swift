import Foundation

/// Sleep command - Delay for a specified amount of time
/// Usage: sleep NUMBER[SUFFIX]
/// SUFFIX may be 's' for seconds (default), 'm' for minutes, 'h' for hours, or 'd' for days
struct SleepCommand {
    static func main(_ args: [String]) -> Int32 {
        guard args.count > 1 else {
            FileHandle.standardError.write("usage: sleep seconds\n".data(using: .utf8)!)
            return 1
        }

        let input = args[1]
        var duration: Double = 0

        // Parse duration with optional suffix
        if input.hasSuffix("s") {
            duration = Double(input.dropLast()) ?? 0
        } else if input.hasSuffix("m") {
            duration = (Double(input.dropLast()) ?? 0) * 60
        } else if input.hasSuffix("h") {
            duration = (Double(input.dropLast()) ?? 0) * 3600
        } else if input.hasSuffix("d") {
            duration = (Double(input.dropLast()) ?? 0) * 86400
        } else {
            duration = Double(input) ?? 0
        }

        guard duration > 0 else {
            FileHandle.standardError.write("sleep: invalid time interval '\(input)'\n".data(using: .utf8)!)
            return 1
        }

        Thread.sleep(forTimeInterval: duration)
        return 0
    }
}
