import Foundation

/// Mkdir command - Create directories
/// Usage: mkdir [-p] DIRECTORY...
/// Create the DIRECTORY(ies), if they do not already exist
struct MkdirCommand {
    static func main(_ args: [String]) -> Int32 {
        var createParents = false
        var dirs: [String] = []

        // Parse arguments
        for i in 1..<args.count {
            if args[i] == "-p" || args[i] == "--parents" {
                createParents = true
            } else if args[i].hasPrefix("-") {
                FileHandle.standardError.write("mkdir: invalid option '\(args[i])'\n".data(using: .utf8)!)
                return 1
            } else {
                dirs.append(args[i])
            }
        }

        if dirs.isEmpty {
            FileHandle.standardError.write("mkdir: missing operand\nTry 'mkdir --help' for more information.\n".data(using: .utf8)!)
            return 1
        }

        let fm = FileManager.default
        var exitCode: Int32 = 0

        for dir in dirs {
            do {
                try fm.createDirectory(atPath: dir, withIntermediateDirectories: createParents, attributes: nil)
            } catch {
                FileHandle.standardError.write("mkdir: cannot create directory '\(dir)': \(error.localizedDescription)\n".data(using: .utf8)!)
                exitCode = 1
            }
        }

        return exitCode
    }
}
