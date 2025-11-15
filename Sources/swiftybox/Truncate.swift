import Foundation

/// Truncate command - Shrink or extend the size of files to specified size
/// Usage: truncate -s SIZE FILE...
/// Shrink or extend files to SIZE bytes
/// SIZE can be: number, +number (extend), -number (shrink), or with K/M/G suffix
struct TruncateCommand {
    static func main(_ args: [String]) -> Int32 {
        var size: Int64?
        var files: [String] = []

        // Parse arguments
        var i = 1
        while i < args.count {
            let arg = args[i]
            if arg == "-s" || arg == "--size" {
                if i + 1 < args.count {
                    i += 1
                    size = parseSize(args[i])
                } else {
                    FileHandle.standardError.write("truncate: option requires an argument -- 's'\n".data(using: .utf8)!)
                    return 1
                }
            } else if arg.hasPrefix("-s") {
                // -sSIZE format
                size = parseSize(String(arg.dropFirst(2)))
            } else if !arg.hasPrefix("-") {
                files.append(arg)
            }
            i += 1
        }

        guard let targetSize = size else {
            FileHandle.standardError.write("truncate: you must specify a size\n".data(using: .utf8)!)
            return 1
        }

        guard !files.isEmpty else {
            FileHandle.standardError.write("truncate: missing file operand\n".data(using: .utf8)!)
            return 1
        }

        var exitCode: Int32 = 0

        for file in files {
            do {
                let fileManager = FileManager.default

                // Create file if it doesn't exist
                if !fileManager.fileExists(atPath: file) {
                    _ = fileManager.createFile(atPath: file, contents: nil)
                }

                // Truncate to specified size
                let fileHandle = try FileHandle(forWritingTo: URL(fileURLWithPath: file))
                try fileHandle.truncate(atOffset: UInt64(targetSize))
                try fileHandle.close()
            } catch {
                FileHandle.standardError.write("truncate: \(file): \(error.localizedDescription)\n".data(using: .utf8)!)
                exitCode = 1
            }
        }

        return exitCode
    }

    static func parseSize(_ sizeStr: String) -> Int64? {
        var multiplier: Int64 = 1
        var numStr = sizeStr

        // Check for suffix
        if let last = sizeStr.last {
            switch last {
            case "K", "k":
                multiplier = 1024
                numStr = String(sizeStr.dropLast())
            case "M", "m":
                multiplier = 1024 * 1024
                numStr = String(sizeStr.dropLast())
            case "G", "g":
                multiplier = 1024 * 1024 * 1024
                numStr = String(sizeStr.dropLast())
            default:
                break
            }
        }

        guard let num = Int64(numStr) else {
            return nil
        }

        return num * multiplier
    }
}
