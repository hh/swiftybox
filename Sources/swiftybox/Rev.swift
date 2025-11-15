import Foundation

/// Rev command - Reverse lines characterwise
/// Usage: rev [FILE...]
struct RevCommand {
    static func main(_ args: [String]) -> Int32 {
        var files = Array(args[1...])
        if files.isEmpty { files = ["-"] }

        for file in files {
            let content: String
            if file == "-" {
                var input = ""
                while let line = readLine() { input += line + "\n" }
                content = input
            } else {
                guard let data = try? String(contentsOfFile: file, encoding: .utf8) else {
                    FileHandle.standardError.write("rev: \(file): No such file or directory\n".data(using: .utf8)!)
                    return 1
                }
                content = data
            }

            for line in content.split(separator: "\n", omittingEmptySubsequences: false) {
                print(String(line.reversed()))
            }
        }

        return 0
    }
}
