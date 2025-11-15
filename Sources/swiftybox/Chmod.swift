import Foundation

/// Chmod command - Change file mode bits
/// Usage: chmod [OPTIONS] MODE FILE...
/// Change the mode of each FILE to MODE
struct ChmodCommand {
    static func main(_ args: [String]) -> Int32 {
        var recursive = false
        var verbose = false
        var mode: String? = nil
        var files: [String] = []

        // Parse arguments
        var i = 1
        while i < args.count {
            let arg = args[i]

            if arg == "-R" || arg == "--recursive" {
                recursive = true
            } else if arg == "-v" || arg == "--verbose" {
                verbose = true
            } else if arg.hasPrefix("-") && arg != "-" {
                for c in arg.dropFirst() {
                    switch c {
                    case "R": recursive = true
                    case "v": verbose = true
                    default:
                        FileHandle.standardError.write("chmod: invalid option -- '\(c)'\n".data(using: .utf8)!)
                        return 1
                    }
                }
            } else if mode == nil {
                mode = arg
            } else {
                files.append(arg)
            }
            i += 1
        }

        guard let modeStr = mode else {
            FileHandle.standardError.write("chmod: missing operand\n".data(using: .utf8)!)
            return 1
        }

        guard !files.isEmpty else {
            FileHandle.standardError.write("chmod: missing operand after '\(modeStr)'\n".data(using: .utf8)!)
            return 1
        }

        guard let permissions = parseMode(modeStr) else {
            FileHandle.standardError.write("chmod: invalid mode: '\(modeStr)'\n".data(using: .utf8)!)
            return 1
        }

        var exitCode: Int32 = 0
        for file in files {
            if chmodFile(file, permissions: permissions, recursive: recursive, verbose: verbose) != 0 {
                exitCode = 1
            }
        }

        return exitCode
    }

    static func parseMode(_ mode: String) -> UInt16? {
        // Try octal mode first (e.g., "755", "0644")
        if let octal = UInt16(mode, radix: 8) {
            return octal & 0o7777
        }

        // TODO: Implement symbolic mode parsing (e.g., "u+x", "go-w")
        // For now, just support octal
        return nil
    }

    static func chmodFile(_ path: String, permissions: UInt16, recursive: Bool, verbose: Bool) -> Int32 {
        let fileManager = FileManager.default

        do {
            // Set permissions
            try fileManager.setAttributes([.posixPermissions: permissions], ofItemAtPath: path)

            if verbose {
                print("mode of '\(path)' changed to \(String(format: "%o", permissions))")
            }

            // Recurse if needed
            if recursive {
                var isDir: ObjCBool = false
                if fileManager.fileExists(atPath: path, isDirectory: &isDir) && isDir.boolValue {
                    if let contents = try? fileManager.contentsOfDirectory(atPath: path) {
                        for item in contents {
                            let fullPath = (path as NSString).appendingPathComponent(item)
                            _ = chmodFile(fullPath, permissions: permissions, recursive: true, verbose: verbose)
                        }
                    }
                }
            }

            return 0
        } catch {
            FileHandle.standardError.write("chmod: cannot access '\(path)': \(error.localizedDescription)\n".data(using: .utf8)!)
            return 1
        }
    }
}
