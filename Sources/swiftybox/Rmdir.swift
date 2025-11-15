import Foundation

/// Rmdir command - Remove empty directories
/// Usage: rmdir DIRECTORY...
/// Remove the DIRECTORY(ies), if they are empty
struct RmdirCommand {
    static func main(_ args: [String]) -> Int32 {
        if args.count < 2 {
            FileHandle.standardError.write("rmdir: missing operand\nTry 'rmdir --help' for more information.\n".data(using: .utf8)!)
            return 1
        }

        let fm = FileManager.default
        var exitCode: Int32 = 0

        for dir in args.dropFirst() {
            // Skip option-like arguments
            if dir.hasPrefix("-") {
                FileHandle.standardError.write("rmdir: invalid option '\(dir)'\n".data(using: .utf8)!)
                exitCode = 1
                continue
            }

            do {
                // Check if directory is empty first (rmdir should only remove empty dirs)
                let contents = try fm.contentsOfDirectory(atPath: dir)
                if !contents.isEmpty {
                    FileHandle.standardError.write("rmdir: failed to remove '\(dir)': Directory not empty\n".data(using: .utf8)!)
                    exitCode = 1
                    continue
                }

                // Directory is empty, safe to remove
                try fm.removeItem(atPath: dir)
            } catch {
                FileHandle.standardError.write("rmdir: failed to remove '\(dir)': \(error.localizedDescription)\n".data(using: .utf8)!)
                exitCode = 1
            }
        }

        return exitCode
    }
}
