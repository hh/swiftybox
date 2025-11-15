import Foundation

/// Mktemp command - Create a temporary file or directory
/// Usage: mktemp [OPTIONS] [TEMPLATE]
struct MktempCommand {
    static func main(_ args: [String]) -> Int32 {
        var directory = false
        var tmpdir = "/tmp"
        var template = "tmp.XXXXXX"

        var i = 1
        while i < args.count {
            let arg = args[i]
            if arg == "-d" || arg == "--directory" {
                directory = true
            } else if arg == "-p" || arg == "--tmpdir" {
                i += 1
                if i < args.count { tmpdir = args[i] }
            } else if !arg.hasPrefix("-") {
                template = arg
            }
            i += 1
        }

        // Generate random name
        let randomSuffix = String((0..<6).map { _ in
            "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()!
        })

        let name = template.replacingOccurrences(of: "XXXXXX", with: randomSuffix)
        let fullPath = (tmpdir as NSString).appendingPathComponent(name)

        let fm = FileManager.default

        do {
            if directory {
                try fm.createDirectory(atPath: fullPath, withIntermediateDirectories: false)
            } else {
                _ = fm.createFile(atPath: fullPath, contents: nil, attributes: [.posixPermissions: 0o600])
            }
            print(fullPath)
            return 0
        } catch {
            FileHandle.standardError.write("mktemp: failed to create \(directory ? "directory" : "file"): \(error.localizedDescription)\n".data(using: .utf8)!)
            return 1
        }
    }
}
