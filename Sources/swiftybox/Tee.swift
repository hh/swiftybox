import Foundation

/// Tee command - Read from stdin and write to stdout and files
/// Usage: tee [-a] [FILE...]
/// Copy standard input to each FILE, and also to standard output
struct TeeCommand {
    static func main(_ args: [String]) -> Int32 {
        var appendMode = false
        var files: [String] = []

        // Parse arguments
        var i = 1
        while i < args.count {
            let arg = args[i]

            if arg.hasPrefix("-") && arg != "-" {
                // Parse flags
                for char in arg.dropFirst() {
                    switch char {
                    case "a": appendMode = true
                    default:
                        FileHandle.standardError.write("tee: invalid option: -\(char)\n".data(using: .utf8)!)
                        return 1
                    }
                }
            } else {
                files.append(arg)
            }
            i += 1
        }

        // Read from stdin
        guard let inputData = try? FileHandle.standardInput.readToEnd() else {
            FileHandle.standardError.write("tee: error reading standard input\n".data(using: .utf8)!)
            return 1
        }

        // Write to stdout
        FileHandle.standardOutput.write(inputData)

        // Write to each file
        var hadError = false
        for file in files {
            do {
                if appendMode {
                    // Append mode
                    if FileManager.default.fileExists(atPath: file) {
                        let fileHandle = try FileHandle(forWritingTo: URL(fileURLWithPath: file))
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(inputData)
                        try fileHandle.close()
                    } else {
                        // File doesn't exist, create it
                        try inputData.write(to: URL(fileURLWithPath: file))
                    }
                } else {
                    // Overwrite mode
                    try inputData.write(to: URL(fileURLWithPath: file))
                }
            } catch {
                FileHandle.standardError.write("tee: \(file): \(error.localizedDescription)\n".data(using: .utf8)!)
                hadError = true
            }
        }

        return hadError ? 1 : 0
    }
}
