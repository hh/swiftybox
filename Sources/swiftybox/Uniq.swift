import Foundation

/// Uniq command - Report or filter out repeated lines
/// Usage: uniq [OPTIONS] [INPUT [OUTPUT]]
struct UniqCommand {
    static func main(_ args: [String]) -> Int32 {
        var count = false
        var repeated = false
        var unique = false
        var ignoreCase = false
        var files: [String] = []

        for i in 1..<args.count {
            let arg = args[i]
            if arg == "-c" || arg == "--count" { count = true }
            else if arg == "-d" || arg == "--repeated" { repeated = true }
            else if arg == "-u" || arg == "--unique" { unique = true }
            else if arg == "-i" || arg == "--ignore-case" { ignoreCase = true }
            else if arg.hasPrefix("-") && arg != "-" {
                for c in arg.dropFirst() {
                    if c == "c" { count = true }
                    else if c == "d" { repeated = true }
                    else if c == "u" { unique = true }
                    else if c == "i" { ignoreCase = true }
                }
            } else { files.append(arg) }
        }

        let input = files.first ?? "-"
        let content: String
        if input == "-" {
            var result = ""
            while let line = readLine() { result += line + "\n" }
            content = result
        } else {
            guard let data = try? String(contentsOfFile: input, encoding: .utf8) else {
                FileHandle.standardError.write("uniq: \(input): No such file or directory\n".data(using: .utf8)!)
                return 1
            }
            content = data
        }

        let lines = content.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        var result: [(String, Int)] = []
        var prev: String? = nil
        var prevCount = 0

        for line in lines {
            let comparable = ignoreCase ? line.lowercased() : line
            if let p = prev, (ignoreCase ? p.lowercased() : p) == comparable {
                prevCount += 1
            } else {
                if let p = prev {
                    result.append((p, prevCount))
                }
                prev = line
                prevCount = 1
            }
        }
        if let p = prev { result.append((p, prevCount)) }

        for (line, cnt) in result {
            if repeated && cnt < 2 { continue }
            if unique && cnt > 1 { continue }
            if count {
                print(String(format: "%7d %@", cnt, line))
            } else {
                print(line)
            }
        }

        return 0
    }
}
