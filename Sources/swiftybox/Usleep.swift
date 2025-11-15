import Foundation

/// Usleep command - Suspend execution for microsecond intervals
/// Usage: usleep MICROSECONDS
/// Pause for MICROSECONDS microseconds (1/1000000 of a second)
struct UsleepCommand {
    static func main(_ args: [String]) -> Int32 {
        guard args.count > 1 else {
            FileHandle.standardError.write("usleep: missing operand\n".data(using: .utf8)!)
            return 1
        }

        guard let microseconds = UInt32(args[1]) else {
            FileHandle.standardError.write("usleep: invalid time interval '\(args[1])'\n".data(using: .utf8)!)
            return 1
        }

        usleep(microseconds)
        return 0
    }
}
