import Foundation

/// Readlink command - Print value of a symbolic link or canonical file name
/// Usage: readlink [-f] FILE...
/// Print the target of a symbolic link
/// With -f: canonicalize by following every symlink recursively
struct ReadlinkCommand {
    static func main(_ args: [String]) -> Int32 {
        var canonicalize = false
        var files: [String] = []

        // Parse arguments
        var i = 1
        while i < args.count {
            let arg = args[i]
            if arg == "-f" || arg == "--canonicalize" {
                canonicalize = true
            } else if !arg.hasPrefix("-") {
                files.append(arg)
            }
            i += 1
        }

        guard !files.isEmpty else {
            FileHandle.standardError.write("readlink: missing operand\n".data(using: .utf8)!)
            return 1
        }

        var exitCode: Int32 = 0

        for file in files {
            if canonicalize {
                // Resolve to canonical path
                let url = URL(fileURLWithPath: file)
                let resolved = url.resolvingSymlinksInPath()
                print(resolved.path)
            } else {
                // Just read the symlink target
                do {
                    let destination = try FileManager.default.destinationOfSymbolicLink(atPath: file)
                    print(destination)
                } catch {
                    FileHandle.standardError.write("readlink: \(file): \(error.localizedDescription)\n".data(using: .utf8)!)
                    exitCode = 1
                }
            }
        }

        return exitCode
    }
}
