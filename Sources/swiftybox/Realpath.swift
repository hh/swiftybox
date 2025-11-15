import Foundation

/// Realpath command - Print the resolved absolute file name
/// Usage: realpath [-e|-m] FILE...
/// Print the canonical absolute path
/// -e: all components must exist (default)
/// -m: no components need exist
struct RealpathCommand {
    static func main(_ args: [String]) -> Int32 {
        var requireExists = true
        var files: [String] = []

        // Parse arguments
        var i = 1
        while i < args.count {
            let arg = args[i]
            if arg == "-e" || arg == "--canonicalize-existing" {
                requireExists = true
            } else if arg == "-m" || arg == "--canonicalize-missing" {
                requireExists = false
            } else if !arg.hasPrefix("-") {
                files.append(arg)
            }
            i += 1
        }

        guard !files.isEmpty else {
            FileHandle.standardError.write("realpath: missing operand\n".data(using: .utf8)!)
            return 1
        }

        var exitCode: Int32 = 0

        for file in files {
            let url = URL(fileURLWithPath: file)

            if requireExists {
                // Check if path exists
                if !FileManager.default.fileExists(atPath: file) {
                    FileHandle.standardError.write("realpath: \(file): No such file or directory\n".data(using: .utf8)!)
                    exitCode = 1
                    continue
                }

                do {
                    let resolved = try url.resolvingSymlinksInPath()
                    print(resolved.path)
                } catch {
                    FileHandle.standardError.write("realpath: \(file): \(error.localizedDescription)\n".data(using: .utf8)!)
                    exitCode = 1
                }
            } else {
                // Just resolve to absolute path, even if it doesn't exist
                let absoluteURL = url.absoluteURL
                print(absoluteURL.standardized.path)
            }
        }

        return exitCode
    }
}
