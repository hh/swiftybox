import Foundation

/// Paste command - Merge lines of files
/// Usage: paste [OPTIONS] [FILE...]
struct PasteCommand {
    static func main(_ args: [String]) -> Int32 {
        var delimiter = "\t"
        var serial = false
        var files: [String] = []

        var i = 1
        while i < args.count {
            let arg = args[i]
            if arg == "-d" || arg == "--delimiters" {
                i += 1
                if i < args.count { delimiter = args[i] }
            } else if arg.hasPrefix("-d") {
                delimiter = String(arg.dropFirst(2))
            } else if arg == "-s" || arg == "--serial" {
                serial = true
            } else if !arg.hasPrefix("-") {
                files.append(arg)
            }
            i += 1
        }

        if files.isEmpty { files.append("-") }

        if serial {
            // Serial mode: one file per line
            for file in files {
                let lines = readFileLines(file)
                print(lines.joined(separator: delimiter))
            }
        } else {
            // Parallel mode: merge files side by side
            let allLines = files.map { readFileLines($0) }
            let maxLines = allLines.map { $0.count }.max() ?? 0

            for i in 0..<maxLines {
                var parts: [String] = []
                for lines in allLines {
                    parts.append(i < lines.count ? lines[i] : "")
                }
                print(parts.joined(separator: delimiter))
            }
        }

        return 0
    }

    static func readFileLines(_ file: String) -> [String] {
        if file == "-" {
            var lines: [String] = []
            while let line = readLine() { lines.append(line) }
            return lines
        } else {
            guard let content = try? String(contentsOfFile: file, encoding: .utf8) else {
                return []
            }
            return content.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        }
    }
}
