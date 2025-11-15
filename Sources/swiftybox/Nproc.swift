import Foundation

/// Nproc command - Print the number of processing units available
/// Usage: nproc [--all] [--ignore=N]
/// Print the number of available processing units
struct NprocCommand {
    static func main(_ args: [String]) -> Int32 {
        var showAll = false
        var ignore = 0

        // Parse arguments
        for i in 1..<args.count {
            let arg = args[i]
            if arg == "--all" {
                showAll = true
            } else if arg.hasPrefix("--ignore=") {
                if let num = Int(arg.dropFirst("--ignore=".count)) {
                    ignore = num
                }
            }
        }

        // Get processor count
        let processorCount = ProcessInfo.processInfo.processorCount

        // Calculate available processors
        let available = max(1, processorCount - ignore)

        print(available)
        return 0
    }
}
