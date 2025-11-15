import Foundation

/// Unexpand command - Convert spaces to tabs
/// Usage: unexpand [OPTIONS] [FILE...]
/// Converts sequences of spaces to tabs at tab stop boundaries
struct UnexpandCommand {
    static func main(_ args: [String]) -> Int32 {
        var tabstop = 8
        var allBlanks = true  // Default: convert all blanks (BusyBox-compatible)
        var files: [String] = []

        var i = 1
        while i < args.count {
            let arg = args[i]
            if arg == "-t" || arg == "--tabs" {
                i += 1
                if i < args.count, let t = Int(args[i]) {
                    tabstop = t
                }
            } else if arg.hasPrefix("-t") {
                if let t = Int(arg.dropFirst(2)) {
                    tabstop = t
                }
            } else if arg == "-a" || arg == "--all" {
                allBlanks = true
            } else if !arg.hasPrefix("-") {
                files.append(arg)
            }
            i += 1
        }

        if files.isEmpty {
            files = ["-"]
        }

        for file in files {
            let content: String
            if file == "-" {
                guard let data = try? FileHandle.standardInput.readToEnd(),
                      let str = String(data: data, encoding: .utf8) else {
                    FileHandle.standardError.write("unexpand: error reading stdin\n".data(using: .utf8)!)
                    return 1
                }
                content = str
            } else {
                guard let data = try? String(contentsOfFile: file, encoding: .utf8) else {
                    FileHandle.standardError.write("unexpand: \(file): No such file or directory\n".data(using: .utf8)!)
                    return 1
                }
                content = data
            }

            let lines = content.split(separator: "\n", omittingEmptySubsequences: false)
            for (index, line) in lines.enumerated() {
                // Skip empty last line if content ends with newline
                if index == lines.count - 1 && line.isEmpty && content.hasSuffix("\n") {
                    continue
                }

                let result = unexpandLine(String(line), tabstop: tabstop, allBlanks: allBlanks)
                print(result)
            }
        }

        return 0
    }

    /// Convert spaces to tabs in a single line
    private static func unexpandLine(_ line: String, tabstop: Int, allBlanks: Bool) -> String {
        var result = ""
        var col = 0
        var pendingSpaces = 0
        var seenNonBlank = false

        for char in line {
            if char == " " {
                // Accumulate spaces
                pendingSpaces += 1
                col += 1

                // Check if we should convert spaces to tab
                if col % tabstop == 0 {
                    // We've reached a tab stop
                    if allBlanks || !seenNonBlank {
                        // Convert all pending spaces to a tab
                        result.append("\t")
                        pendingSpaces = 0
                    } else {
                        // Not converting, flush spaces
                        result.append(String(repeating: " ", count: pendingSpaces))
                        pendingSpaces = 0
                    }
                }
            } else if char == "\t" {
                // When we see a tab, spaces before it can be collapsed
                // The tab will move us to the next tab stop anyway
                if pendingSpaces > 0 && (allBlanks || !seenNonBlank) {
                    // The spaces + tab combination moves to next tab stop
                    // We can just use a single tab to achieve the same result
                    pendingSpaces = 0
                } else if pendingSpaces > 0 {
                    // Not converting - flush the spaces
                    result.append(String(repeating: " ", count: pendingSpaces))
                    pendingSpaces = 0
                }

                result.append("\t")
                // Move to next tab stop
                col = ((col / tabstop) + 1) * tabstop
                seenNonBlank = true
            } else {
                // Non-blank character
                // Flush pending spaces
                if pendingSpaces > 0 {
                    result.append(String(repeating: " ", count: pendingSpaces))
                    pendingSpaces = 0
                }

                result.append(char)
                // Handle multi-byte characters properly
                col += 1
                seenNonBlank = true
            }
        }

        // Flush any remaining spaces at end of line
        if pendingSpaces > 0 {
            result.append(String(repeating: " ", count: pendingSpaces))
        }

        return result
    }
}
