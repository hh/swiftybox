import Foundation

/// Printenv command - Print all or part of environment
/// Usage: printenv [VARIABLE]...
/// Print the values of environment variables
/// With no arguments, print all environment variables
struct PrintenvCommand {
    static func main(_ args: [String]) -> Int32 {
        let environment = ProcessInfo.processInfo.environment

        if args.count == 1 {
            // No arguments - print all environment variables
            for (key, value) in environment.sorted(by: { $0.key < $1.key }) {
                print("\(key)=\(value)")
            }
            return 0
        } else {
            // Print specific variables
            var exitCode: Int32 = 0
            for i in 1..<args.count {
                let varName = args[i]
                if let value = environment[varName] {
                    print(value)
                } else {
                    exitCode = 1
                }
            }
            return exitCode
        }
    }
}
