import Foundation

/// Shuf command - Shuffle lines of text
/// Usage: shuf [FILE...]
struct ShufCommand {
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
                    FileHandle.standardError.write("shuf: \(file): No such file or directory\n".data(using: .utf8)!)
                    return 1
                }
                content = data
            }

            var lines = content.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
            lines.shuffle()

            for line in lines {
                print(line)
            }
        }

        return 0
    }
}
