import Foundation

/// Ln command - Create links between files
/// Usage: ln [OPTIONS] TARGET LINK_NAME
/// Create hard links by default, symbolic links with -s
struct LnCommand {
    static func main(_ args: [String]) -> Int32 {
        var symbolic = false
        var force = false
        var targetDirectory: String? = nil
        var arguments: [String] = []

        // Parse arguments
        var i = 1
        while i < args.count {
            let arg = args[i]

            if arg == "-s" || arg == "--symbolic" {
                symbolic = true
            } else if arg == "-f" || arg == "--force" {
                force = true
            } else if arg == "-t" || arg == "--target-directory" {
                i += 1
                if i < args.count {
                    targetDirectory = args[i]
                } else {
                    FileHandle.standardError.write("ln: option requires an argument -- 't'\n".data(using: .utf8)!)
                    return 1
                }
            } else if arg.hasPrefix("-") && arg != "-" {
                // Handle combined short options like -sf
                for c in arg.dropFirst() {
                    switch c {
                    case "s": symbolic = true
                    case "f": force = true
                    default:
                        FileHandle.standardError.write("ln: invalid option -- '\(c)'\n".data(using: .utf8)!)
                        return 1
                    }
                }
            } else {
                arguments.append(arg)
            }
            i += 1
        }

        // Validate arguments
        if let targetDir = targetDirectory {
            // ln -t DIR TARGET...
            guard !arguments.isEmpty else {
                FileHandle.standardError.write("ln: missing file operand\n".data(using: .utf8)!)
                return 1
            }

            var exitCode: Int32 = 0
            for target in arguments {
                let linkName = (targetDir as NSString).appendingPathComponent((target as NSString).lastPathComponent)
                if createLink(target: target, linkName: linkName, symbolic: symbolic, force: force) != 0 {
                    exitCode = 1
                }
            }
            return exitCode
        } else {
            // ln TARGET LINK_NAME or ln TARGET... DIRECTORY
            guard arguments.count >= 1 else {
                FileHandle.standardError.write("ln: missing file operand\n".data(using: .utf8)!)
                return 1
            }

            if arguments.count == 1 {
                // ln TARGET (create in current directory)
                let target = arguments[0]
                let linkName = (target as NSString).lastPathComponent
                return createLink(target: target, linkName: linkName, symbolic: symbolic, force: force)
            } else if arguments.count == 2 {
                // ln TARGET LINK_NAME
                let target = arguments[0]
                let linkName = arguments[1]

                // Check if linkName is a directory
                var isDir: ObjCBool = false
                if FileManager.default.fileExists(atPath: linkName, isDirectory: &isDir) && isDir.boolValue {
                    // Create link inside directory
                    let finalLink = (linkName as NSString).appendingPathComponent((target as NSString).lastPathComponent)
                    return createLink(target: target, linkName: finalLink, symbolic: symbolic, force: force)
                } else {
                    return createLink(target: target, linkName: linkName, symbolic: symbolic, force: force)
                }
            } else {
                // ln TARGET... DIRECTORY
                let directory = arguments.last!
                var isDir: ObjCBool = false

                guard FileManager.default.fileExists(atPath: directory, isDirectory: &isDir) && isDir.boolValue else {
                    FileHandle.standardError.write("ln: \(directory): Not a directory\n".data(using: .utf8)!)
                    return 1
                }

                var exitCode: Int32 = 0
                for target in arguments.dropLast() {
                    let linkName = (directory as NSString).appendingPathComponent((target as NSString).lastPathComponent)
                    if createLink(target: target, linkName: linkName, symbolic: symbolic, force: force) != 0 {
                        exitCode = 1
                    }
                }
                return exitCode
            }
        }
    }

    static func createLink(target: String, linkName: String, symbolic: Bool, force: Bool) -> Int32 {
        let fileManager = FileManager.default

        // If force, remove existing file
        if force && fileManager.fileExists(atPath: linkName) {
            do {
                try fileManager.removeItem(atPath: linkName)
            } catch {
                FileHandle.standardError.write("ln: cannot remove '\(linkName)': \(error.localizedDescription)\n".data(using: .utf8)!)
                return 1
            }
        }

        do {
            if symbolic {
                // Create symbolic link
                try fileManager.createSymbolicLink(atPath: linkName, withDestinationPath: target)
            } else {
                // Create hard link
                try fileManager.linkItem(atPath: target, toPath: linkName)
            }
            return 0
        } catch {
            FileHandle.standardError.write("ln: failed to create link '\(linkName)' -> '\(target)': \(error.localizedDescription)\n".data(using: .utf8)!)
            return 1
        }
    }
}
