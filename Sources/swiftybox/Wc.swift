import Foundation

/// Wc command - Print newline, word, and byte counts
/// Usage: wc [-l] [-w] [-c] [-L] [FILE...]
/// Count lines, words, and bytes in files or stdin
struct WcCommand {
    static func main(_ args: [String]) -> Int32 {
        var showLines = false
        var showWords = false
        var showBytes = false
        var showMaxLineLength = false
        var files: [String] = []

        // Parse arguments
        var i = 1
        while i < args.count {
            let arg = args[i]
            if arg.hasPrefix("-") && arg != "-" {
                // Parse flags
                for char in arg.dropFirst() {
                    switch char {
                    case "l": showLines = true
                    case "w": showWords = true
                    case "c": showBytes = true
                    case "L": showMaxLineLength = true
                    default:
                        FileHandle.standardError.write("wc: invalid option: -\(char)\n".data(using: .utf8)!)
                        return 1
                    }
                }
            } else {
                files.append(arg)
            }
            i += 1
        }

        // If no flags specified, show all (but not -L)
        if !showLines && !showWords && !showBytes && !showMaxLineLength {
            showLines = true
            showWords = true
            showBytes = true
        }

        // If no files, read from stdin
        if files.isEmpty {
            files.append("-")
        }

        var totalLines = 0
        var totalWords = 0
        var totalBytes = 0
        var totalMaxLineLength = 0

        for file in files {
            let content: String
            if file == "-" {
                // Read from stdin
                guard let data = try? FileHandle.standardInput.readToEnd(),
                      let str = String(data: data, encoding: .utf8) else {
                    return 1
                }
                content = str
            } else {
                // Read from file
                guard let data = try? String(contentsOfFile: file, encoding: .utf8) else {
                    FileHandle.standardError.write("wc: \(file): No such file or directory\n".data(using: .utf8)!)
                    return 1
                }
                content = data
            }

            // Count statistics
            let lines = content.isEmpty ? 0 : content.components(separatedBy: "\n").count - (content.hasSuffix("\n") ? 1 : 0)
            let words = content.split(whereSeparator: { $0.isWhitespace || $0.isNewline }).count
            let bytes = content.utf8.count

            // Calculate max line length
            let maxLineLength: Int
            if showMaxLineLength {
                let contentLines = content.split(separator: "\n", omittingEmptySubsequences: false)
                maxLineLength = contentLines.map { $0.count }.max() ?? 0
            } else {
                maxLineLength = 0
            }

            totalLines += lines
            totalWords += words
            totalBytes += bytes
            totalMaxLineLength = max(totalMaxLineLength, maxLineLength)

            // Print counts
            var output = ""
            // Determine if we should use formatting (multiple columns or file specified)
            let useFormatting = (showLines && showWords) || (showLines && showBytes) || (showWords && showBytes) || (showLines && showMaxLineLength) || (showWords && showMaxLineLength) || (showBytes && showMaxLineLength) || file != "-"

            if useFormatting {
                if showLines { output += String(format: "%8d", lines) }
                if showWords { output += String(format: "%8d", words) }
                if showBytes { output += String(format: "%8d", bytes) }
                if showMaxLineLength { output += String(format: "%8d", maxLineLength) }
                if file != "-" {
                    output += " \(file)"
                }
            } else {
                // Single column from stdin - no formatting
                if showLines { output = "\(lines)" }
                else if showWords { output = "\(words)" }
                else if showBytes { output = "\(bytes)" }
                else if showMaxLineLength { output = "\(maxLineLength)" }
            }
            print(output)
        }

        // Print total if multiple files
        if files.count > 1 && !files.contains("-") {
            var output = ""
            if showLines { output += String(format: "%8d", totalLines) }
            if showWords { output += String(format: "%8d", totalWords) }
            if showBytes { output += String(format: "%8d", totalBytes) }
            if showMaxLineLength { output += String(format: "%8d", totalMaxLineLength) }
            output += " total"
            print(output)
        }

        return 0
    }
}
