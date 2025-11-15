import Foundation

/// Stat command - Display file or filesystem status
/// Usage: stat [OPTIONS] [FILE...]
struct StatCommand {
    static func main(_ args: [String]) -> Int32 {
        var formatString: String? = nil
        var followSymlinks = false
        var files: [String] = []

        // Parse arguments
        var i = 1
        while i < args.count {
            let arg = args[i]

            if arg == "-c" || arg == "--format" {
                // Next arg is format string
                i += 1
                if i < args.count {
                    formatString = args[i]
                } else {
                    FileHandle.standardError.write("stat: option requires an argument -- 'c'\n".data(using: .utf8)!)
                    return 1
                }
            } else if arg == "-L" || arg == "--dereference" {
                followSymlinks = true
            } else if arg.hasPrefix("-") {
                FileHandle.standardError.write("stat: invalid option -- '\(arg)'\n".data(using: .utf8)!)
                return 1
            } else {
                files.append(arg)
            }
            i += 1
        }

        guard !files.isEmpty else {
            FileHandle.standardError.write("stat: missing operand\n".data(using: .utf8)!)
            return 1
        }

        var exitCode: Int32 = 0
        for file in files {
            // Get file attributes
            var path = file
            if followSymlinks {
                // Resolve symlink if it exists
                if let resolved = try? FileManager.default.destinationOfSymbolicLink(atPath: file) {
                    path = resolved
                }
            }

            guard let attrs = try? FileManager.default.attributesOfItem(atPath: path) else {
                FileHandle.standardError.write("stat: cannot stat '\(file)': No such file or directory\n".data(using: .utf8)!)
                exitCode = 1
                continue
            }

            if let format = formatString {
                // Use custom format string
                print(formatOutput(format, file: file, attrs: attrs))
            } else {
                // Default verbose output
                printVerbose(file: file, attrs: attrs)
            }
        }

        return exitCode
    }

    static func formatOutput(_ format: String, file: String, attrs: [FileAttributeKey: Any]) -> String {
        var result = ""
        var i = format.startIndex

        while i < format.endIndex {
            let char = format[i]

            if char == "%" {
                i = format.index(after: i)
                if i < format.endIndex {
                    let spec = format[i]
                    result += formatSpecifier(spec, file: file, attrs: attrs)
                }
            } else if char == "\\" {
                i = format.index(after: i)
                if i < format.endIndex {
                    let escape = format[i]
                    switch escape {
                    case "n": result += "\n"
                    case "t": result += "\t"
                    case "\\": result += "\\"
                    default: result += String(escape)
                    }
                }
            } else {
                result += String(char)
            }

            i = format.index(after: i)
        }

        return result
    }

    static func formatSpecifier(_ spec: Character, file: String, attrs: [FileAttributeKey: Any]) -> String {
        let perms = (attrs[.posixPermissions] as? UInt16) ?? 0
        let size = (attrs[.size] as? Int64) ?? 0
        let uid = (attrs[.ownerAccountID] as? uid_t) ?? 0
        let gid = (attrs[.groupOwnerAccountID] as? gid_t) ?? 0

        switch spec {
        case "a":
            // Access rights in octal (without leading zero)
            return String(format: "%o", perms & 0o7777)
        case "A":
            // Access rights in human readable form
            return formatPermsFull(perms)
        case "F":
            // File type
            return fileType(attrs: attrs)
        case "n":
            // File name
            return file
        case "N":
            // Quoted file name with dereferencing
            return "\'\(file)\'"
        case "s":
            // Total size in bytes
            return String(size)
        case "u":
            // User ID
            return String(uid)
        case "g":
            // Group ID
            return String(gid)
        case "U":
            // User name
            return getUserName(uid: uid)
        case "G":
            // Group name
            return getGroupName(gid: gid)
        case "y":
            // Time of last modification, human-readable
            if let date = attrs[.modificationDate] as? Date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSSSS Z"
                return formatter.string(from: date)
            }
            return ""
        case "Y":
            // Time of last modification, seconds since Epoch
            if let date = attrs[.modificationDate] as? Date {
                return String(Int(date.timeIntervalSince1970))
            }
            return "0"
        case "%":
            // Literal %
            return "%"
        default:
            // Unknown specifier, return as-is
            return "%\(spec)"
        }
    }

    static func fileType(attrs: [FileAttributeKey: Any]) -> String {
        let type = attrs[.type] as? FileAttributeType
        if type == .typeDirectory {
            return "directory"
        } else if type == .typeSymbolicLink {
            return "symbolic link"
        } else if type == .typeRegular {
            return "regular file"
        } else if type == .typeBlockSpecial {
            return "block special file"
        } else if type == .typeCharacterSpecial {
            return "character special file"
        } else if type == .typeSocket {
            return "socket"
        } else {
            return "unknown"
        }
    }

    static func getUserName(uid: uid_t) -> String {
        if let passwd = getpwuid(uid) {
            return String(cString: passwd.pointee.pw_name)
        }
        return String(uid)
    }

    static func getGroupName(gid: gid_t) -> String {
        if let group = getgrgid(gid) {
            return String(cString: group.pointee.gr_name)
        }
        return String(gid)
    }

    static func printVerbose(file: String, attrs: [FileAttributeKey: Any]) {
        print("  File: \(file)")
        print("  Size: \(attrs[.size] ?? 0)\t\tBlocks: \((attrs[.size] as? Int64 ?? 0) / 512)")

        let type = attrs[.type] as? FileAttributeType
        let typeStr = type == .typeDirectory ? "directory" : type == .typeSymbolicLink ? "symbolic link" : "regular file"
        print("Device: \t\tInode: \t\tLinks: \((attrs[.referenceCount] as? Int) ?? 1)")
        print("Access: (\(String(format: "%04o", (attrs[.posixPermissions] as? UInt16) ?? 0))/\(formatPerms((attrs[.posixPermissions] as? UInt16) ?? 0)))  Uid: (\(attrs[.ownerAccountID] ?? 0))   Gid: (\(attrs[.groupOwnerAccountID] ?? 0))")

        if let date = attrs[.modificationDate] as? Date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            print("Modify: \(formatter.string(from: date))")
        }

        print()
    }

    static func formatPerms(_ perms: UInt16) -> String {
        var result = ""
        let bits = [(0o400, "r"), (0o200, "w"), (0o100, "x"), (0o040, "r"), (0o020, "w"), (0o010, "x"), (0o004, "r"), (0o002, "w"), (0o001, "x")]
        for (mask, char) in bits {
            result += (perms & UInt16(mask)) != 0 ? char : "-"
        }
        return result
    }

    static func formatPermsFull(_ perms: UInt16) -> String {
        var result = ""

        // File type (would need to check actual file type, using - for regular file as default)
        result += "-"

        // User permissions
        result += (perms & 0o400) != 0 ? "r" : "-"
        result += (perms & 0o200) != 0 ? "w" : "-"
        if (perms & 0o4000) != 0 {  // setuid
            result += (perms & 0o100) != 0 ? "s" : "S"
        } else {
            result += (perms & 0o100) != 0 ? "x" : "-"
        }

        // Group permissions
        result += (perms & 0o040) != 0 ? "r" : "-"
        result += (perms & 0o020) != 0 ? "w" : "-"
        if (perms & 0o2000) != 0 {  // setgid
            result += (perms & 0o010) != 0 ? "s" : "S"
        } else {
            result += (perms & 0o010) != 0 ? "x" : "-"
        }

        // Other permissions
        result += (perms & 0o004) != 0 ? "r" : "-"
        result += (perms & 0o002) != 0 ? "w" : "-"
        if (perms & 0o1000) != 0 {  // sticky bit
            result += (perms & 0o001) != 0 ? "t" : "T"
        } else {
            result += (perms & 0o001) != 0 ? "x" : "-"
        }

        return result
    }
}
