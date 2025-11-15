import Foundation

/// Mktemp command - Create a temporary file or directory
/// Usage: mktemp [OPTIONS] [TEMPLATE]
struct MktempCommand {
    static func main(_ args: [String]) -> Int32 {
        var directory = false
        var dryRun = false
        var tmpdir: String? = nil
        var useTmpdir = false
        var quiet = false
        var template: String? = nil

        var i = 1
        while i < args.count {
            let arg = args[i]

            if arg == "-d" || arg == "--directory" {
                directory = true
            } else if arg == "-u" || arg == "--dry-run" {
                dryRun = true
            } else if arg == "-q" || arg == "--quiet" {
                quiet = true
            } else if arg == "-p" {
                // -p DIR: set tmpdir
                i += 1
                if i < args.count {
                    tmpdir = args[i]
                } else {
                    FileHandle.standardError.write("mktemp: option requires an argument -- 'p'\n".data(using: .utf8)!)
                    return 1
                }
            } else if arg == "--tmpdir" {
                // --tmpdir or --tmpdir=DIR
                if arg.contains("=") {
                    let parts = arg.split(separator: "=", maxSplits: 1)
                    if parts.count == 2 {
                        tmpdir = String(parts[1])
                    }
                } else {
                    // Next arg is tmpdir (optional)
                    if i + 1 < args.count && !args[i + 1].hasPrefix("-") {
                        i += 1
                        tmpdir = args[i]
                    } else {
                        // Use default tmpdir
                        useTmpdir = true
                    }
                }
            } else if arg == "-t" {
                // -t: Interpret TEMPLATE relative to tmpdir
                useTmpdir = true
            } else if arg.hasPrefix("-") {
                FileHandle.standardError.write("mktemp: invalid option -- '\(arg)'\n".data(using: .utf8)!)
                return 1
            } else {
                // This is the template
                template = arg
            }
            i += 1
        }

        // Determine the tmpdir to use
        let finalTmpdir: String
        if let dir = tmpdir {
            finalTmpdir = dir
        } else if useTmpdir {
            finalTmpdir = NSTemporaryDirectory()
        } else {
            finalTmpdir = ""  // Use current directory or template's directory
        }

        // Default template
        var finalTemplate = template ?? "tmp.XXXXXX"

        // Validate template has enough X's (GNU requires at least 3, many implementations require 6)
        let xCount = finalTemplate.filter { $0 == "X" }.count
        if xCount < 3 {
            if !quiet {
                FileHandle.standardError.write("mktemp: too few X's in template '\(finalTemplate)'\n".data(using: .utf8)!)
            }
            return 1
        }

        // Build full path
        let fullPath: String
        if !finalTmpdir.isEmpty {
            // Template is relative to tmpdir
            fullPath = (finalTmpdir as NSString).appendingPathComponent(finalTemplate)
        } else if finalTemplate.hasPrefix("/") {
            // Absolute path template
            fullPath = finalTemplate
        } else {
            // Relative to current directory
            fullPath = finalTemplate
        }

        // Generate unique name with retries
        let maxRetries = 10
        for attempt in 0..<maxRetries {
            let uniquePath = generateUniquePath(fullPath)

            if dryRun {
                // Dry run: just print the path without creating
                print(uniquePath)
                return 0
            }

            let fm = FileManager.default

            // Check if path already exists
            if fm.fileExists(atPath: uniquePath) {
                if attempt == maxRetries - 1 {
                    if !quiet {
                        FileHandle.standardError.write("mktemp: failed to create unique name after \(maxRetries) attempts\n".data(using: .utf8)!)
                    }
                    return 1
                }
                continue  // Try again with new random suffix
            }

            do {
                if directory {
                    // Create directory with 700 permissions
                    try fm.createDirectory(atPath: uniquePath, withIntermediateDirectories: false, attributes: [.posixPermissions: 0o700])
                } else {
                    // Create file with 600 permissions (secure default)
                    let created = fm.createFile(atPath: uniquePath, contents: nil, attributes: [.posixPermissions: 0o600])
                    if !created {
                        throw NSError(domain: "mktemp", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create file"])
                    }
                }
                print(uniquePath)
                return 0
            } catch {
                if attempt == maxRetries - 1 {
                    if !quiet {
                        FileHandle.standardError.write("mktemp: failed to create \(directory ? "directory" : "file"): \(error.localizedDescription)\n".data(using: .utf8)!)
                    }
                    return 1
                }
            }
        }

        return 1
    }

    static func generateUniquePath(_ template: String) -> String {
        // Find the last contiguous sequence of X's and replace them
        var result = ""
        var xCount = 0
        var xStart = -1

        // Scan from the end to find the last sequence of X's
        let chars = Array(template)
        var i = chars.count - 1
        while i >= 0 {
            if chars[i] == "X" {
                if xStart == -1 {
                    xStart = i
                }
                xCount += 1
            } else if xStart != -1 {
                break  // Found the end of X sequence from the right
            }
            i -= 1
        }

        // If no X's found, just append random suffix
        if xCount == 0 {
            let randomSuffix = String((0..<6).map { _ in
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()!
            })
            return template + randomSuffix
        }

        // Generate random replacement for X's
        let randomChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomSuffix = String((0..<xCount).map { _ in randomChars.randomElement()! })

        // Replace the X's
        let beforeX = String(chars[0..<(xStart - xCount + 1)])
        let afterX = xStart + 1 < chars.count ? String(chars[(xStart + 1)...]) : ""

        return beforeX + randomSuffix + afterX
    }
}
