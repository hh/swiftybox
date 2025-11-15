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
                let data = (try? FileHandle.standardInput.readToEnd()) ?? Data()
                content = String(data: data, encoding: .utf8) ?? ""
            } else {
                guard let data = try? String(contentsOfFile: file, encoding: .utf8) else {
                    FileHandle.standardError.write("rev: \(file): No such file or directory\n".data(using: .utf8)!)
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
                print(String(line.reversed()))
            }
        }

        return 0
    }
}
