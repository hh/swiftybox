import Foundation

/// Yes command - Output a string repeatedly until killed
/// Usage: yes [STRING]
/// Default: Outputs "y" infinitely
struct YesCommand {
    static func main(_ args: [String]) -> Int32 {
        let message = args.count > 1 ? args[1...].joined(separator: " ") : "y"

        // Print infinitely (will be stopped by SIGPIPE or SIGINT)
        while true {
            print(message)
        }
    }
}
