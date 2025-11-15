import Foundation

/// Nl command - Number lines of files
/// Usage: nl [OPTIONS] [FILE...]
struct NlCommand {
    static func main(_ args: [String]) -> Int32 {
        var startNumber = 1
        var increment = 1
        var files: [String] = []

        var i = 1
        while i < args.count {
            let arg = args[i]
            if arg == "-v" || arg == "--starting-line-number" {
                i += 1
                if i < args.count, let num = Int(args[i]) {
                    startNumber = num
                }
            } else if arg == "-i" || arg == "--line-increment" {
                i += 1
                if i < args.count, let num = Int(args[i]) {
                    increment = num
                }
            } else if !arg.hasPrefix("-") {
                files.append(arg)
            }
            i += 1
        }

        if files.isEmpty { files.append("-") }

        for file in files {
            let content: String
            if file == "-" {
                var result = ""
                while let line = readLine() { result += line + "\n" }
                content = result
            } else {
                guard let data = try? String(contentsOfFile: file, encoding: .utf8) else {
                    FileHandle.standardError.write("nl: \(file): No such file or directory\n".data(using: .utf8)!)
                    return 1
                }
                content = data
            }

            var lineNum = startNumber
            for line in content.split(separator: "\n", omittingEmptySubsequences: false) {
                if !line.trimmingCharacters(in: .whitespaces).isEmpty {
                    print(String(format: "%6d\t%@", lineNum, String(line)))
                    lineNum += increment
                } else {
                    print("\t\(line)")
                }
            }
        }

        return 0
    }
}
