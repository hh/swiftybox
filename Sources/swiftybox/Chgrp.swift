import Foundation

/// Chgrp command - Change group ownership
/// Usage: chgrp [OPTIONS] GROUP FILE...
/// Change the group ownership of each FILE to GROUP
struct ChgrpCommand {
    static func main(_ args: [String]) -> Int32 {
        var recursive = false
        var verbose = false
        var group: String? = nil
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
                        FileHandle.standardError.write("chgrp: invalid option -- '\(c)'\n".data(using: .utf8)!)
                        return 1
                    }
                }
            } else if group == nil {
                group = arg
            } else {
                files.append(arg)
            }
            i += 1
        }

        guard let groupStr = group else {
            FileHandle.standardError.write("chgrp: missing operand\n".data(using: .utf8)!)
            return 1
        }

        guard !files.isEmpty else {
            FileHandle.standardError.write("chgrp: missing operand after '\(groupStr)'\n".data(using: .utf8)!)
            return 1
        }

        var exitCode: Int32 = 0
        for file in files {
            if chgrpFile(file, group: groupStr, recursive: recursive, verbose: verbose) != 0 {
                exitCode = 1
            }
        }

        return exitCode
    }

    static func chgrpFile(_ path: String, group: String, recursive: Bool, verbose: Bool) -> Int32 {
        let fileManager = FileManager.default

        do {
            // Convert group name to GID
            let gid: UInt32
            if let groupGID = getGIDForGroup(group) {
                gid = groupGID
            } else if let numericGID = UInt32(group) {
                gid = numericGID
            } else {
                FileHandle.standardError.write("chgrp: invalid group: '\(group)'\n".data(using: .utf8)!)
                return 1
            }

            try fileManager.setAttributes([.groupOwnerAccountID: gid], ofItemAtPath: path)

            if verbose {
                print("group of '\(path)' changed to \(group)")
            }

            // Recurse if needed
            if recursive {
                var isDir: ObjCBool = false
                if fileManager.fileExists(atPath: path, isDirectory: &isDir) && isDir.boolValue {
                    if let contents = try? fileManager.contentsOfDirectory(atPath: path) {
                        for item in contents {
                            let fullPath = (path as NSString).appendingPathComponent(item)
                            _ = chgrpFile(fullPath, group: group, recursive: true, verbose: verbose)
                        }
                    }
                }
            }

            return 0
        } catch {
            FileHandle.standardError.write("chgrp: cannot access '\(path)': \(error.localizedDescription)\n".data(using: .utf8)!)
            return 1
        }
    }

    static func getGIDForGroup(_ groupname: String) -> UInt32? {
        guard let group = getgrnam(groupname) else { return nil }
        return group.pointee.gr_gid
    }
}
