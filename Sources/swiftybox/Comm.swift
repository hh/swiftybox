import Foundation

/// Comm command - Compare two sorted files line by line
/// Usage: comm [OPTIONS] FILE1 FILE2
struct CommCommand {
    static func main(_ args: [String]) -> Int32 {
        var suppress1 = false
        var suppress2 = false
        var suppress3 = false
        var files: [String] = []

        for i in 1..<args.count {
            let arg = args[i]
            if arg == "-1" { suppress1 = true }
            else if arg == "-2" { suppress2 = true }
            else if arg == "-3" { suppress3 = true }
            else if arg.hasPrefix("-") && arg != "-" {
                for c in arg.dropFirst() {
                    if c == "1" { suppress1 = true }
                    else if c == "2" { suppress2 = true }
                    else if c == "3" { suppress3 = true }
                }
            } else { files.append(arg) }
        }

        guard files.count == 2 else {
            FileHandle.standardError.write("comm: missing operand\n".data(using: .utf8)!)
            return 1
        }

        guard let content1 = try? String(contentsOfFile: files[0], encoding: .utf8),
              let content2 = try? String(contentsOfFile: files[1], encoding: .utf8) else {
            FileHandle.standardError.write("comm: error reading files\n".data(using: .utf8)!)
            return 1
        }

        let lines1 = content1.split(separator: "\n").map(String.init)
        let lines2 = content2.split(separator: "\n").map(String.init)

        var i = 0, j = 0
        while i < lines1.count || j < lines2.count {
            if i >= lines1.count {
                if !suppress2 { print("\t\(lines2[j])") }
                j += 1
            } else if j >= lines2.count {
                if !suppress1 { print(lines1[i]) }
                i += 1
            } else if lines1[i] < lines2[j] {
                if !suppress1 { print(lines1[i]) }
                i += 1
            } else if lines1[i] > lines2[j] {
                if !suppress2 { print("\t\(lines2[j])") }
                j += 1
            } else {
                if !suppress3 { print("\t\t\(lines1[i])") }
                i += 1
                j += 1
            }
        }

        return 0
    }
}
