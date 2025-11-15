import Foundation

/// Touch command - Update file timestamps or create empty files
/// Usage: touch FILE...
/// Update the access and modification times of each FILE to the current time.
/// A FILE argument that does not exist is created empty.
struct TouchCommand {
    static func main(_ args: [String]) -> Int32 {
        if args.count < 2 {
            FileHandle.standardError.write("touch: missing file operand\nTry 'touch --help' for more information.\n".data(using: .utf8)!)
            return 1
        }

        let fm = FileManager.default
        let now = Date()
        var exitCode: Int32 = 0

        for file in args.dropFirst() {
            // Skip option-like arguments
            if file.hasPrefix("-") {
                FileHandle.standardError.write("touch: invalid option '\(file)'\n".data(using: .utf8)!)
                exitCode = 1
                continue
            }

            if fm.fileExists(atPath: file) {
                // Update modification time
                do {
                    try fm.setAttributes([.modificationDate: now], ofItemAtPath: file)
                } catch {
                    FileHandle.standardError.write("touch: cannot touch '\(file)': \(error.localizedDescription)\n".data(using: .utf8)!)
                    exitCode = 1
                }
            } else {
                // Create empty file
                if !fm.createFile(atPath: file, contents: nil, attributes: nil) {
                    FileHandle.standardError.write("touch: cannot touch '\(file)': Unable to create file\n".data(using: .utf8)!)
                    exitCode = 1
                }
            }
        }

        return exitCode
    }
}
