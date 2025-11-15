import Foundation

/// Tac command - Concatenate and print files in reverse
/// Usage: tac [FILE...]
struct TacCommand {
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
                    FileHandle.standardError.write("tac: \(file): No such file or directory\n".data(using: .utf8)!)
                    return 1
                }
                content = data
            }

            let lines = content.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
            for line in lines.reversed() {
                print(line)
            }
        }

        return 0
    }
}
