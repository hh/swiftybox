import Foundation

/// Rm command - Remove files or directories
/// Usage: rm [OPTIONS] FILE...
/// Remove (unlink) the FILE(s)
struct RmCommand {
    static func main(_ args: [String]) -> Int32 {
        var recursive = false
        var force = false
        var verbose = false
        var interactive = false
        var files: [String] = []

        // Parse arguments
        var i = 1
        while i < args.count {
            let arg = args[i]

            if arg == "-r" || arg == "-R" || arg == "--recursive" {
                recursive = true
            } else if arg == "-f" || arg == "--force" {
                force = true
            } else if arg == "-v" || arg == "--verbose" {
                verbose = true
            } else if arg == "-i" || arg == "--interactive" {
                interactive = true
            } else if arg.hasPrefix("-") && arg != "-" {
                for c in arg.dropFirst() {
                    switch c {
                    case "r", "R": recursive = true
                    case "f": force = true
                    case "v": verbose = true
                    case "i": interactive = true
                    default:
                        FileHandle.standardError.write("rm: invalid option -- '\(c)'\n".data(using: .utf8)!)
                        return 1
                    }
                }
            } else {
                files.append(arg)
            }
            i += 1
        }

        guard !files.isEmpty else {
            if !force {
                FileHandle.standardError.write("rm: missing operand\n".data(using: .utf8)!)
                return 1
            }
            return 0
        }

        var exitCode: Int32 = 0
        for file in files {
            if removeFile(file, recursive: recursive, force: force, verbose: verbose, interactive: interactive) != 0 {
                exitCode = 1
            }
        }

        return exitCode
    }

    static func removeFile(_ path: String, recursive: Bool, force: Bool, verbose: Bool, interactive: Bool) -> Int32 {
        let fileManager = FileManager.default

        // Check if file exists
        var isDir: ObjCBool = false
        guard fileManager.fileExists(atPath: path, isDirectory: &isDir) else {
            if !force {
                FileHandle.standardError.write("rm: cannot remove '\(path)': No such file or directory\n".data(using: .utf8)!)
                return 1
            }
            return 0
        }

        // Check if directory and recursive is needed
        if isDir.boolValue && !recursive {
            FileHandle.standardError.write("rm: cannot remove '\(path)': Is a directory\n".data(using: .utf8)!)
            return 1
        }

        // Interactive mode
        if interactive && !force {
            print("rm: remove '\(path)'? ", terminator: "")
            FileHandle.standardOutput.synchronizeFile()
            guard let response = readLine()?.lowercased(), response.hasPrefix("y") else {
                return 0
            }
        }

        do {
            try fileManager.removeItem(atPath: path)

            if verbose {
                print("removed '\(path)'")
            }

            return 0
        } catch {
            if !force {
                FileHandle.standardError.write("rm: cannot remove '\(path)': \(error.localizedDescription)\n".data(using: .utf8)!)
            }
            return 1
        }
    }
}
