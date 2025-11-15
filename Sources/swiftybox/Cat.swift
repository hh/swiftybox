import Foundation

/// Cat command - Concatenate files and print on the standard output
/// Usage: cat [FILE...]
/// Concatenate FILE(s) to standard output
/// With no FILE, or when FILE is -, read standard input
struct CatCommand {
    static func main(_ args: [String]) -> Int32 {
        var files: [String] = []

        // Parse arguments (skip program name)
        for i in 1..<args.count {
            files.append(args[i])
        }

        // If no files specified, read from stdin
        if files.isEmpty {
            files.append("-")
        }

        // Process each file
        for file in files {
            if file == "-" {
                // Read from stdin
                if let data = try? FileHandle.standardInput.readToEnd(),
                   let content = String(data: data, encoding: .utf8) {
                    print(content, terminator: "")
                }
            } else {
                // Read from file
                do {
                    let content = try String(contentsOfFile: file, encoding: .utf8)
                    print(content, terminator: "")
                } catch {
                    FileHandle.standardError.write("cat: \(file): No such file or directory\n".data(using: .utf8)!)
                    return 1
                }
            }
        }

        return 0
    }
}
