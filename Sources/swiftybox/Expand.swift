import Foundation

/// Expand command - Convert tabs to spaces
/// Usage: expand [OPTIONS] [FILE...]
struct ExpandCommand {
    static func main(_ args: [String]) -> Int32 {
        var tabstop = 8
        var files: [String] = []

        var i = 1
        while i < args.count {
            let arg = args[i]
            if arg == "-t" || arg == "--tabs" {
                i += 1
                if i < args.count, let t = Int(args[i]) { tabstop = t }
            } else if arg.hasPrefix("-t") {
                if let t = Int(arg.dropFirst(2)) { tabstop = t }
            } else if !arg.hasPrefix("-") {
                files.append(arg)
            }
            i += 1
        }

        if files.isEmpty { files = ["-"] }

        for file in files {
            let content: String
            if file == "-" {
                var input = ""
                while let line = readLine() { input += line + "\n" }
                content = input
            } else {
                guard let data = try? String(contentsOfFile: file, encoding: .utf8) else {
                    FileHandle.standardError.write("expand: \(file): No such file or directory\n".data(using: .utf8)!)
                    return 1
                }
                content = data
            }

            for line in content.split(separator: "\n", omittingEmptySubsequences: false) {
                var col = 0
                var result = ""
                for char in line {
                    if char == "\t" {
                        let spaces = tabstop - (col % tabstop)
                        result += String(repeating: " ", count: spaces)
                        col += spaces
                    } else {
                        result.append(char)
                        col += 1
                    }
                }
                print(result)
            }
        }

        return 0
    }
}
