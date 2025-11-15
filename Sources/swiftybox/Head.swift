import Foundation

/// Head command - Output the first part of files
/// Usage: head [-n NUM] [FILE...]
/// Print the first NUM lines of each FILE to standard output
/// With more than one FILE, precede each with a header giving the file name
/// With no FILE, or when FILE is -, read standard input
/// Default is 10 lines
struct HeadCommand {
    static func main(_ args: [String]) -> Int32 {
        var lineCount = 10
        var files: [String] = []

        // Parse arguments
        var i = 1
        while i < args.count {
            let arg = args[i]

            if arg == "-n" {
                // -n NUM format
                guard i + 1 < args.count else {
                    FileHandle.standardError.write("head: option requires an argument -- 'n'\n".data(using: .utf8)!)
                    return 1
                }
                i += 1
                guard let count = Int(args[i]) else {
                    FileHandle.standardError.write("head: invalid number of lines: '\(args[i])'\n".data(using: .utf8)!)
                    return 1
                }
                lineCount = count
            } else if arg.hasPrefix("-") && arg != "-" {
                // Check for -NUM shorthand
                let numStr = String(arg.dropFirst())
                if let count = Int(numStr) {
                    lineCount = count
                } else {
                    FileHandle.standardError.write("head: invalid option: '\(arg)'\n".data(using: .utf8)!)
                    return 1
                }
            } else {
                // It's a file
                files.append(arg)
            }
            i += 1
        }

        // If no files specified, read from stdin
        if files.isEmpty {
            files.append("-")
        }

        let multipleFiles = files.count > 1
        var isFirst = true

        // Process each file
        for file in files {
            // Print header for multiple files
            if multipleFiles {
                if !isFirst {
                    print() // Blank line between files
                }
                print("==> \(file == "-" ? "standard input" : file) <==")
                isFirst = false
            }

            let result = processFile(file, lineCount: lineCount)
            if result != 0 {
                return result
            }
        }

        return 0
    }

    private static func processFile(_ file: String, lineCount: Int) -> Int32 {
        let content: String

        if file == "-" {
            // Read from stdin
            guard let data = try? FileHandle.standardInput.readToEnd(),
                  let str = String(data: data, encoding: .utf8) else {
                FileHandle.standardError.write("head: error reading standard input\n".data(using: .utf8)!)
                return 1
            }
            content = str
        } else {
            // Read from file
            do {
                content = try String(contentsOfFile: file, encoding: .utf8)
            } catch {
                FileHandle.standardError.write("head: cannot open '\(file)' for reading: No such file or directory\n".data(using: .utf8)!)
                return 1
            }
        }

        // Split into lines and take first N
        let lines = content.components(separatedBy: "\n")
        let outputLines = lines.prefix(lineCount)

        // Print lines
        for (index, line) in outputLines.enumerated() {
            // Don't add newline after last line if original didn't have trailing newline
            if index == outputLines.count - 1 && !content.hasSuffix("\n") {
                print(line, terminator: "")
            } else {
                print(line)
            }
        }

        return 0
    }
}
