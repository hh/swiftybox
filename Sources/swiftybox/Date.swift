import Foundation

/// Date command - Print or set the system date and time
/// Usage: date [OPTIONS] [+FORMAT]
struct DateCommand {
    static func main(_ args: [String]) -> Int32 {
        var utc = false
        var format: String? = nil

        for i in 1..<args.count {
            let arg = args[i]
            if arg == "-u" || arg == "--utc" || arg == "--universal" {
                utc = true
            } else if arg.hasPrefix("+") {
                format = String(arg.dropFirst())
            }
        }

        let date = Date()
        let formatter = DateFormatter()
        formatter.timeZone = utc ? TimeZone(identifier: "UTC") : TimeZone.current

        if let fmt = format {
            // Custom format
            let converted = convertFormat(fmt)
            formatter.dateFormat = converted
            print(formatter.string(from: date))
        } else {
            // Default format: "Day Mon DD HH:MM:SS TZ YYYY"
            formatter.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
            print(formatter.string(from: date))
        }

        return 0
    }

    static func convertFormat(_ format: String) -> String {
        var result = format
        result = result.replacingOccurrences(of: "%Y", with: "yyyy")
        result = result.replacingOccurrences(of: "%m", with: "MM")
        result = result.replacingOccurrences(of: "%d", with: "dd")
        result = result.replacingOccurrences(of: "%H", with: "HH")
        result = result.replacingOccurrences(of: "%M", with: "mm")
        result = result.replacingOccurrences(of: "%S", with: "ss")
        result = result.replacingOccurrences(of: "%a", with: "EEE")
        result = result.replacingOccurrences(of: "%A", with: "EEEE")
        result = result.replacingOccurrences(of: "%b", with: "MMM")
        result = result.replacingOccurrences(of: "%B", with: "MMMM")
        result = result.replacingOccurrences(of: "%Z", with: "zzz")
        result = result.replacingOccurrences(of: "%s", with: "UNIX_TIMESTAMP")
        return result
    }
}
