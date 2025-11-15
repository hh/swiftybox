import Foundation

/// Grep command - Print lines matching a pattern
/// Usage: grep [-i] [-v] [-n] [-c] [-l] [-r] PATTERN [FILE...]
/// Search for PATTERN in each FILE or standard input
struct GrepCommand {
    /// egrep wrapper - grep with -E enabled by default
    static func egrepMain(_ args: [String]) -> Int32 {
        // Inject -E flag if not present
        var modifiedArgs = args
        if !modifiedArgs.dropFirst().contains(where: { $0.contains("E") }) {
            modifiedArgs.insert("-E", at: 1)
        }
        return main(modifiedArgs)
    }

    static func main(_ args: [String]) -> Int32 {
        var ignoreCase = false
        var invertMatch = false
        var showLineNumbers = false
        var countOnly = false
        var filesWithMatches = false
        var treatAsText = false  // -a flag
        var useRegex = false  // -E flag
        // var recursive = false  // TODO: implement -r recursive flag
        var pattern: String?
        var files: [String] = []

        // Parse arguments
        var i = 1
        while i < args.count {
            let arg = args[i]

            if arg.hasPrefix("-") && arg != "-" && pattern == nil {
                // Parse flags
                for char in arg.dropFirst() {
                    switch char {
                    case "i": ignoreCase = true
                    case "v": invertMatch = true
                    case "n": showLineNumbers = true
                    case "c": countOnly = true
                    case "l": filesWithMatches = true
                    case "a": treatAsText = true  // Treat binary as text
                    case "E": useRegex = true  // Extended regex
                    case "r":
                        FileHandle.standardError.write("grep: -r recursive search not yet implemented\n".data(using: .utf8)!)
                        return 1
                    default:
                        FileHandle.standardError.write("grep: invalid option: -\(char)\n".data(using: .utf8)!)
                        return 1
                    }
                }
            } else if pattern == nil {
                pattern = arg
            } else {
                files.append(arg)
            }
            i += 1
        }

        // Validate pattern
        guard let searchPattern = pattern else {
            FileHandle.standardError.write("grep: no pattern specified\n".data(using: .utf8)!)
            return 1
        }

        // If no files specified, read from stdin
        if files.isEmpty {
            files.append("-")
        }

        var foundMatch = false
        let showFilenames = files.count > 1 && !filesWithMatches

        // Process each file
        for file in files {
            let result = processFile(
                file,
                pattern: searchPattern,
                ignoreCase: ignoreCase,
                invertMatch: invertMatch,
                showLineNumbers: showLineNumbers,
                countOnly: countOnly,
                filesWithMatches: filesWithMatches,
                showFilename: showFilenames,
                treatAsText: treatAsText,
                useRegex: useRegex
            )

            if result.matched {
                foundMatch = true
            }

            if result.error {
                return 1
            }
        }

        // Exit code 0 if match found, 1 if no match
        return foundMatch ? 0 : 1
    }

    private static func processFile(
        _ file: String,
        pattern: String,
        ignoreCase: Bool,
        invertMatch: Bool,
        showLineNumbers: Bool,
        countOnly: Bool,
        filesWithMatches: Bool,
        showFilename: Bool,
        treatAsText: Bool,
        useRegex: Bool
    ) -> (matched: Bool, error: Bool) {
        let content: String

        // Read file or stdin
        if file == "-" {
            guard let data = try? FileHandle.standardInput.readToEnd(),
                  let str = String(data: data, encoding: .utf8) else {
                FileHandle.standardError.write("grep: error reading standard input\n".data(using: .utf8)!)
                return (false, true)
            }
            content = str
        } else {
            do {
                content = try String(contentsOfFile: file, encoding: .utf8)
            } catch {
                FileHandle.standardError.write("grep: \(file): No such file or directory\n".data(using: .utf8)!)
                return (false, true)
            }
        }

        // Prepare pattern for matching
        let regex: NSRegularExpression?
        if useRegex {
            do {
                var options: NSRegularExpression.Options = []
                if ignoreCase {
                    options.insert(.caseInsensitive)
                }
                regex = try NSRegularExpression(pattern: pattern, options: options)
            } catch {
                FileHandle.standardError.write("grep: invalid regex pattern\n".data(using: .utf8)!)
                return (false, true)
            }
        } else {
            regex = nil
        }

        // Split into lines
        let lines = content.components(separatedBy: "\n")
        var matchCount = 0
        var foundMatch = false

        // Process each line
        for (index, line) in lines.enumerated() {
            // Skip empty last line if content ends with newline
            if index == lines.count - 1 && line.isEmpty && content.hasSuffix("\n") {
                continue
            }

            let matches: Bool
            if let regex = regex {
                // Regex matching
                let range = NSRange(line.startIndex..., in: line)
                matches = regex.firstMatch(in: line, options: [], range: range) != nil
            } else {
                // Literal string matching
                let searchOptions: String.CompareOptions = ignoreCase ? [.caseInsensitive] : []
                matches = line.range(of: pattern, options: searchOptions) != nil
            }

            let shouldPrint = invertMatch ? !matches : matches

            if shouldPrint {
                matchCount += 1
                foundMatch = true

                // If files-with-matches mode, print filename and return
                if filesWithMatches {
                    print(file == "-" ? "(standard input)" : file)
                    return (true, false)
                }

                // If count-only mode, just increment
                if countOnly {
                    continue
                }

                // Print the line
                var output = ""

                if showFilename {
                    output += "\(file == "-" ? "(standard input)" : file):"
                }

                if showLineNumbers {
                    output += "\(index + 1):"
                }

                output += line
                print(output)
            }
        }

        // Print count if requested
        if countOnly {
            var output = ""
            if showFilename {
                output += "\(file == "-" ? "(standard input)" : file):"
            }
            output += "\(matchCount)"
            print(output)
        }

        return (foundMatch, false)
    }
}
