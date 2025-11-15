import Foundation

/// Env command - Display, set, or remove environment variables
/// Usage: env [NAME=VALUE]... [COMMAND [ARG]...]
/// With no COMMAND, print the environment (simple implementation)
struct EnvCommand {
    static func main(_ args: [String]) -> Int32 {
        // Simple implementation: just print all environment variables
        // Full implementation would support setting vars and running commands

        // Get all environment variables
        let environment = ProcessInfo.processInfo.environment

        // Sort for consistent output
        let sorted = environment.sorted { $0.key < $1.key }

        // Print in KEY=VALUE format
        for (key, value) in sorted {
            print("\(key)=\(value)")
        }

        return 0
    }
}
