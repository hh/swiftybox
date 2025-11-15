import Foundation

/// Fold command - Wrap each input line to fit in specified width
/// Usage: fold [OPTIONS] [FILE...]
struct FoldCommand {
    static func main(_ args: [String]) -> Int32 {
        var width = 80
        var breakSpaces = false
        var files: [String] = []

        var i = 1
        while i < args.count {
            let arg = args[i]
            if arg == "-s" || arg == "--spaces" {
                breakSpaces = true
            } else if arg == "-w" || arg == "--width" {
                i += 1
                if i < args.count, let w = Int(args[i]) {
                    width = w
                }
            } else if arg.hasPrefix("-w") {
                if let w = Int(arg.dropFirst(2)) { width = w }
            } else if !arg.hasPrefix("-") {
                files.append(arg)
            }
            i += 1
        }

        if files.isEmpty { files.append("-") }

        for file in files {
            let content: String
            if file == "-" {
                let data = (try? FileHandle.standardInput.readToEnd()) ?? Data()
                content = String(data: data, encoding: .utf8) ?? ""
            } else {
                guard let data = try? String(contentsOfFile: file, encoding: .utf8) else {
                    FileHandle.standardError.write("fold: \(file): No such file or directory\n".data(using: .utf8)!)
                    return 1
                }
                content = data
            }

            // Process line by line
            var lines = content.components(separatedBy: "\n")
            // Remove trailing empty string if content ends with newline
            if content.hasSuffix("\n") && lines.last?.isEmpty == true {
                lines.removeLast()
            }

            for line in lines {
                var current = String(line)
                while current.count > width {
                    var breakPoint = width
                    if breakSpaces {
                        if let lastSpace = current[..<current.index(current.startIndex, offsetBy: width)].lastIndex(of: " ") {
                            breakPoint = current.distance(from: current.startIndex, to: lastSpace)
                        }
                    }
                    print(current.prefix(breakPoint))
                    current = String(current.dropFirst(breakPoint))
                    if breakSpaces && current.hasPrefix(" ") {
                        current = String(current.dropFirst())
                    }
                }
                print(current)
            }
        }

        return 0
    }
}
