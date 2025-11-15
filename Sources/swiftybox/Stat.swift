import Foundation

/// Stat command - Display file or filesystem status
/// Usage: stat [FILE...]
struct StatCommand {
    static func main(_ args: [String]) -> Int32 {
        guard args.count > 1 else {
            FileHandle.standardError.write("stat: missing operand\n".data(using: .utf8)!)
            return 1
        }

        var exitCode: Int32 = 0
        for file in args[1...] {
            guard let attrs = try? FileManager.default.attributesOfItem(atPath: file) else {
                FileHandle.standardError.write("stat: cannot stat '\(file)': No such file or directory\n".data(using: .utf8)!)
                exitCode = 1
                continue
            }

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

        return exitCode
    }

    static func formatPerms(_ perms: UInt16) -> String {
        var result = ""
        let bits = [(0o400, "r"), (0o200, "w"), (0o100, "x"), (0o040, "r"), (0o020, "w"), (0o010, "x"), (0o004, "r"), (0o002, "w"), (0o001, "x")]
        for (mask, char) in bits {
            result += (perms & UInt16(mask)) != 0 ? char : "-"
        }
        return result
    }
}
