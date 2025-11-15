import Foundation

/// Which command - Locate a command in PATH
/// Usage: which COMMAND...
/// Shows the full path of commands
struct WhichCommand {
    static func main(_ args: [String]) -> Int32 {
        guard args.count > 1 else {
            FileHandle.standardError.write("which: missing operand\n".data(using: .utf8)!)
            return 1
        }

        let commands = Array(args[1...])
        var exitCode: Int32 = 0

        // Get PATH environment variable
        guard let pathEnv = ProcessInfo.processInfo.environment["PATH"] else {
            FileHandle.standardError.write("which: PATH not set\n".data(using: .utf8)!)
            return 1
        }

        let paths = pathEnv.split(separator: ":").map(String.init)

        for command in commands {
            var found = false

            // Check if command is already an absolute/relative path
            if command.contains("/") {
                if FileManager.default.isExecutableFile(atPath: command) {
                    print(command)
                    found = true
                }
            } else {
                // Search in PATH
                for path in paths {
                    let fullPath = (path as NSString).appendingPathComponent(command)
                    if FileManager.default.isExecutableFile(atPath: fullPath) {
                        print(fullPath)
                        found = true
                        break
                    }
                }
            }

            if !found {
                exitCode = 1
            }
        }

        return exitCode
    }
}
