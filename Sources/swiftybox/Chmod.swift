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

        var exitCode: Int32 = 0
        for file in files {
            if chmodFile(file, modeStr: modeStr, recursive: recursive, verbose: verbose) != 0 {
                exitCode = 1
            }
        }

        return exitCode
    }

    static func parseMode(_ mode: String, currentPerms: UInt16 = 0) -> UInt16? {
        // Try octal mode first (e.g., "755", "0644")
        if let octal = UInt16(mode, radix: 8) {
            return octal & 0o7777
        }

        // Parse symbolic mode (e.g., "u+x", "go-w", "a=r")
        return parseSymbolicMode(mode, currentPerms: currentPerms)
    }

    static func parseSymbolicMode(_ mode: String, currentPerms: UInt16) -> UInt16? {
        var result = currentPerms

        // Split by comma for multiple operations: u+x,go-w
        let operations = mode.split(separator: ",")

        for op in operations {
            let opStr = String(op)

            // Parse: [ugoa]*([-+=])[rwxXst]*
            var who: UInt16 = 0  // Which bits to affect
            var idx = opStr.startIndex

            // Parse who (u, g, o, a, or empty for a)
            var foundWho = false
            while idx < opStr.endIndex {
                let char = opStr[idx]
                if char == "u" {
                    who |= 0o4700  // user: rwxs
                    foundWho = true
                } else if char == "g" {
                    who |= 0o2070  // group: rwxs
                    foundWho = true
                } else if char == "o" {
                    who |= 0o1007  // other: rwxt
                    foundWho = true
                } else if char == "a" {
                    who |= 0o7777  // all
                    foundWho = true
                } else {
                    break
                }
                idx = opStr.index(after: idx)
            }

            // If no who specified, default to 'a' (all, respecting umask)
            if !foundWho {
                who = 0o0777  // Don't set special bits by default
            }

            // Parse operator (+, -, =)
            guard idx < opStr.endIndex else { return nil }
            let oper = opStr[idx]
            guard oper == "+" || oper == "-" || oper == "=" else { return nil }
            idx = opStr.index(after: idx)

            // Parse permissions (r, w, x, X, s, t)
            var perms: UInt16 = 0
            while idx < opStr.endIndex {
                let char = opStr[idx]
                if char == "r" {
                    perms |= 0o0444  // read for all classes
                } else if char == "w" {
                    perms |= 0o0222  // write for all classes
                } else if char == "x" {
                    perms |= 0o0111  // execute for all classes
                } else if char == "X" {
                    // Execute only if directory or already has execute for some user
                    if (currentPerms & 0o0111) != 0 {
                        perms |= 0o0111
                    }
                } else if char == "s" {
                    perms |= 0o6000  // setuid + setgid
                } else if char == "t" {
                    perms |= 0o1000  // sticky bit
                } else {
                    return nil  // Invalid permission character
                }
                idx = opStr.index(after: idx)
            }

            // Apply the operation
            // Mask perms to only affect the 'who' bits
            let maskedPerms = perms & who

            switch oper {
            case "+":
                result |= maskedPerms
            case "-":
                result &= ~maskedPerms
            case "=":
                result = (result & ~who) | maskedPerms
            default:
                return nil
            }
        }

        return result
    }

    static func chmodFile(_ path: String, modeStr: String, recursive: Bool, verbose: Bool) -> Int32 {
        let fileManager = FileManager.default

        do {
            // Get current permissions for symbolic mode parsing
            let attrs = try fileManager.attributesOfItem(atPath: path)
            let currentPerms = (attrs[.posixPermissions] as? UInt16) ?? 0o644

            guard let permissions = parseMode(modeStr, currentPerms: currentPerms) else {
                FileHandle.standardError.write("chmod: invalid mode: '\(modeStr)'\n".data(using: .utf8)!)
                return 1
            }

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
                            _ = chmodFile(fullPath, modeStr: modeStr, recursive: true, verbose: verbose)
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
