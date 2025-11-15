import Foundation

/// Chown command - Change file owner and group
/// Usage: chown [OPTIONS] OWNER[:GROUP] FILE...
/// Change the owner and/or group of each FILE to OWNER and/or GROUP
struct ChownCommand {
    static func main(_ args: [String]) -> Int32 {
        var recursive = false
        var verbose = false
        var ownerGroup: String? = nil
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
                        FileHandle.standardError.write("chown: invalid option -- '\(c)'\n".data(using: .utf8)!)
                        return 1
                    }
                }
            } else if ownerGroup == nil {
                ownerGroup = arg
            } else {
                files.append(arg)
            }
            i += 1
        }

        guard let ownerGroupStr = ownerGroup else {
            FileHandle.standardError.write("chown: missing operand\n".data(using: .utf8)!)
            return 1
        }

        guard !files.isEmpty else {
            FileHandle.standardError.write("chown: missing operand after '\(ownerGroupStr)'\n".data(using: .utf8)!)
            return 1
        }

        // Parse owner:group or owner.group
        let parts = ownerGroupStr.split(whereSeparator: { $0 == ":" || $0 == "." }).map(String.init)
        let owner = parts.first
        let group = parts.count > 1 ? parts[1] : nil

        var exitCode: Int32 = 0
        for file in files {
            if chownFile(file, owner: owner, group: group, recursive: recursive, verbose: verbose) != 0 {
                exitCode = 1
            }
        }

        return exitCode
    }

    static func chownFile(_ path: String, owner: String?, group: String?, recursive: Bool, verbose: Bool) -> Int32 {
        let fileManager = FileManager.default

        do {
            var attrs: [FileAttributeKey: Any] = [:]

            // Convert owner name to UID
            if let ownerName = owner {
                if let uid = getUIDForUser(ownerName) {
                    attrs[.ownerAccountID] = uid
                } else if let uid = UInt32(ownerName) {
                    attrs[.ownerAccountID] = uid
                } else {
                    FileHandle.standardError.write("chown: invalid user: '\(ownerName)'\n".data(using: .utf8)!)
                    return 1
                }
            }

            // Convert group name to GID
            if let groupName = group {
                if let gid = getGIDForGroup(groupName) {
                    attrs[.groupOwnerAccountID] = gid
                } else if let gid = UInt32(groupName) {
                    attrs[.groupOwnerAccountID] = gid
                } else {
                    FileHandle.standardError.write("chown: invalid group: '\(groupName)'\n".data(using: .utf8)!)
                    return 1
                }
            }

            try fileManager.setAttributes(attrs, ofItemAtPath: path)

            if verbose {
                print("ownership of '\(path)' changed")
            }

            // Recurse if needed
            if recursive {
                var isDir: ObjCBool = false
                if fileManager.fileExists(atPath: path, isDirectory: &isDir) && isDir.boolValue {
                    if let contents = try? fileManager.contentsOfDirectory(atPath: path) {
                        for item in contents {
                            let fullPath = (path as NSString).appendingPathComponent(item)
                            _ = chownFile(fullPath, owner: owner, group: group, recursive: true, verbose: verbose)
                        }
                    }
                }
            }

            return 0
        } catch {
            FileHandle.standardError.write("chown: cannot access '\(path)': \(error.localizedDescription)\n".data(using: .utf8)!)
            return 1
        }
    }

    static func getUIDForUser(_ username: String) -> UInt32? {
        guard let passwd = getpwnam(username) else { return nil }
        return passwd.pointee.pw_uid
    }

    static func getGIDForGroup(_ groupname: String) -> UInt32? {
        guard let group = getgrnam(groupname) else { return nil }
        return group.pointee.gr_gid
    }
}
