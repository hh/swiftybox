import Foundation

/// Cut command - Remove sections from each line of files
/// Usage: cut -f LIST [-d DELIM] [FILE...]
///        cut -c LIST [FILE...]
/// Print selected parts of lines from each FILE to standard output
struct CutCommand {
    static func main(_ args: [String]) -> Int32 {
        var fields: [Int] = []
        var characters: [Int] = []
        var delimiter = "\t"
        var files: [String] = []
        var useFields = false
        var useCharacters = false

        // Parse arguments
        var i = 1
        while i < args.count {
            let arg = args[i]

            if arg == "-f" {
                // Field mode
                guard i + 1 < args.count else {
                    FileHandle.standardError.write("cut: option requires an argument -- 'f'\n".data(using: .utf8)!)
                    return 1
                }
                i += 1
                useFields = true
                fields = parseFieldList(args[i])
                if fields.isEmpty {
                    FileHandle.standardError.write("cut: invalid field list: '\(args[i])'\n".data(using: .utf8)!)
                    return 1
                }
            } else if arg == "-c" {
                // Character mode
                guard i + 1 < args.count else {
                    FileHandle.standardError.write("cut: option requires an argument -- 'c'\n".data(using: .utf8)!)
                    return 1
                }
                i += 1
                useCharacters = true
                characters = parseFieldList(args[i])
                if characters.isEmpty {
                    FileHandle.standardError.write("cut: invalid character list: '\(args[i])'\n".data(using: .utf8)!)
                    return 1
                }
            } else if arg == "-d" {
                // Delimiter
                guard i + 1 < args.count else {
                    FileHandle.standardError.write("cut: option requires an argument -- 'd'\n".data(using: .utf8)!)
                    return 1
                }
                i += 1
                delimiter = args[i]
                if delimiter.count != 1 {
                    FileHandle.standardError.write("cut: the delimiter must be a single character\n".data(using: .utf8)!)
                    return 1
                }
            } else if !arg.hasPrefix("-") {
                files.append(arg)
            } else {
                FileHandle.standardError.write("cut: invalid option: '\(arg)'\n".data(using: .utf8)!)
                return 1
            }
            i += 1
        }

        // Validate mode
        if !useFields && !useCharacters {
            FileHandle.standardError.write("cut: you must specify a list of fields or characters\n".data(using: .utf8)!)
            return 1
        }

        if useFields && useCharacters {
            FileHandle.standardError.write("cut: only one type of list may be specified\n".data(using: .utf8)!)
            return 1
        }

        // If no files specified, read from stdin
        if files.isEmpty {
            files.append("-")
        }

        // Process each file
        for file in files {
            let result: Int32
            if useFields {
                result = processFileFields(file, fields: fields, delimiter: delimiter)
            } else {
                result = processFileCharacters(file, characters: characters)
            }

            if result != 0 {
                return result
            }
        }

        return 0
    }

    private static func parseFieldList(_ list: String) -> [Int] {
        var result: [Int] = []

        let parts = list.split(separator: ",")
        for part in parts {
            if part.contains("-") {
                // Range (e.g., "1-3")
                let rangeParts = part.split(separator: "-")
                if rangeParts.count == 2,
                   let start = Int(rangeParts[0]),
                   let end = Int(rangeParts[1]),
                   start > 0, end > 0, start <= end {
                    result.append(contentsOf: start...end)
                } else {
                    return []
                }
            } else {
                // Single field
                if let field = Int(part), field > 0 {
                    result.append(field)
                } else {
                    return []
                }
            }
        }

        return result.sorted()
    }

    private static func processFileFields(_ file: String, fields: [Int], delimiter: String) -> Int32 {
        let content: String

        // Read file or stdin
        if file == "-" {
            guard let data = try? FileHandle.standardInput.readToEnd(),
                  let str = String(data: data, encoding: .utf8) else {
                FileHandle.standardError.write("cut: error reading standard input\n".data(using: .utf8)!)
                return 1
            }
            content = str
        } else {
            do {
                content = try String(contentsOfFile: file, encoding: .utf8)
            } catch {
                FileHandle.standardError.write("cut: \(file): No such file or directory\n".data(using: .utf8)!)
                return 1
            }
        }

        // Process each line
        let lines = content.components(separatedBy: "\n")
        for (index, line) in lines.enumerated() {
            // Skip empty last line if content ends with newline
            if index == lines.count - 1 && line.isEmpty && content.hasSuffix("\n") {
                continue
            }

            let lineFields = line.components(separatedBy: delimiter)
            var output: [String] = []

            for field in fields {
                if field <= lineFields.count {
                    output.append(lineFields[field - 1])
                }
            }

            print(output.joined(separator: delimiter))
        }

        return 0
    }

    private static func processFileCharacters(_ file: String, characters: [Int]) -> Int32 {
        let content: String

        // Read file or stdin
        if file == "-" {
            guard let data = try? FileHandle.standardInput.readToEnd(),
                  let str = String(data: data, encoding: .utf8) else {
                FileHandle.standardError.write("cut: error reading standard input\n".data(using: .utf8)!)
                return 1
            }
            content = str
        } else {
            do {
                content = try String(contentsOfFile: file, encoding: .utf8)
            } catch {
                FileHandle.standardError.write("cut: \(file): No such file or directory\n".data(using: .utf8)!)
                return 1
            }
        }

        // Process each line
        let lines = content.components(separatedBy: "\n")
        for (index, line) in lines.enumerated() {
            // Skip empty last line if content ends with newline
            if index == lines.count - 1 && line.isEmpty && content.hasSuffix("\n") {
                continue
            }

            let lineChars = Array(line)
            var output = ""

            for pos in characters {
                if pos <= lineChars.count {
                    output.append(lineChars[pos - 1])
                }
            }

            print(output)
        }

        return 0
    }
}
