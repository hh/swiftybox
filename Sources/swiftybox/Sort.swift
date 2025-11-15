import Foundation

/// Sort command - Sort lines of text files
/// Usage: sort [OPTIONS] [FILE...]
struct SortCommand {
    static func main(_ args: [String]) -> Int32 {
        var reverse = false
        var numeric = false
        var unique = false
        var ignoreCase = false
        var files: [String] = []

        for i in 1..<args.count {
            let arg = args[i]
            if arg == "-r" || arg == "--reverse" { reverse = true }
            else if arg == "-n" || arg == "--numeric-sort" { numeric = true }
            else if arg == "-u" || arg == "--unique" { unique = true }
            else if arg == "-f" || arg == "--ignore-case" { ignoreCase = true }
            else if arg.hasPrefix("-") && arg != "-" {
                for c in arg.dropFirst() {
                    if c == "r" { reverse = true }
                    else if c == "n" { numeric = true }
                    else if c == "u" { unique = true }
                    else if c == "f" { ignoreCase = true }
                }
            } else { files.append(arg) }
        }

        if files.isEmpty { files.append("-") }

        var allLines: [String] = []
        for file in files {
            let content: String
            if file == "-" {
                content = readStdin()
            } else {
                guard let data = try? String(contentsOfFile: file, encoding: .utf8) else {
                    FileHandle.standardError.write("sort: \(file): No such file or directory\n".data(using: .utf8)!)
                    return 1
                }
                content = data
            }
            allLines.append(contentsOf: content.split(separator: "\n", omittingEmptySubsequences: false).map(String.init))
        }

        // Sort lines
        let sorted: [String]
        if numeric {
            sorted = allLines.sorted { (a, b) -> Bool in
                let aNum = Double(a.trimmingCharacters(in: .whitespaces)) ?? 0
                let bNum = Double(b.trimmingCharacters(in: .whitespaces)) ?? 0
                return reverse ? aNum > bNum : aNum < bNum
            }
        } else if ignoreCase {
            sorted = allLines.sorted { reverse ? $0.lowercased() > $1.lowercased() : $0.lowercased() < $1.lowercased() }
        } else {
            sorted = allLines.sorted { reverse ? $0 > $1 : $0 < $1 }
        }

        // Filter unique if needed
        let output = unique ? Array(Set(sorted)).sorted { reverse ? $0 > $1 : $0 < $1 } : sorted

        for line in output {
            print(line)
        }

        return 0
    }

    static func readStdin() -> String {
        var result = ""
        while let line = readLine(strippingNewline: false) {
            result += line
        }
        return result
    }
}
