import Foundation
import Crypto

/// Sha256sum command - Compute SHA256 checksums
/// Usage: sha256sum [-c] [FILE...]
struct Sha256sumCommand {
    static func main(_ args: [String]) -> Int32 {
        var checkMode = false
        var files: [String] = []

        var i = 1
        while i < args.count {
            let arg = args[i]
            if arg == "-c" || arg == "--check" {
                checkMode = true
            } else if arg.hasPrefix("-") && arg != "-" {
                FileHandle.standardError.write("sha256sum: invalid option -- '\(arg)'\n".data(using: .utf8)!)
                return 1
            } else {
                files.append(arg)
            }
            i += 1
        }

        if files.isEmpty {
            files = ["-"]
        }

        if checkMode {
            return verifyChecksums(files)
        } else {
            return computeChecksums(files)
        }
    }

    static func computeChecksums(_ files: [String]) -> Int32 {
        var exitCode: Int32 = 0
        for file in files {
            let data: Data
            if file == "-" {
                var input = Data()
                while let line = readLine(strippingNewline: false) {
                    if let lineData = line.data(using: .utf8) { input.append(lineData) }
                }
                data = input
            } else {
                guard let fileData = try? Data(contentsOf: URL(fileURLWithPath: file)) else {
                    FileHandle.standardError.write("sha256sum: \(file): No such file or directory\n".data(using: .utf8)!)
                    exitCode = 1
                    continue
                }
                data = fileData
            }

            let hash = computeSHA256(data)
            let output = "\(hash)  \(file)\n"
            FileHandle.standardOutput.write(output.data(using: .utf8)!)
        }

        return exitCode
    }

    static func verifyChecksums(_ files: [String]) -> Int32 {
        var exitCode: Int32 = 0

        for checksumFile in files {
            guard let content = try? String(contentsOfFile: checksumFile, encoding: .utf8) else {
                FileHandle.standardError.write("sha256sum: \(checksumFile): No such file or directory\n".data(using: .utf8)!)
                return 1
            }

            for line in content.components(separatedBy: "\n") {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.isEmpty { continue }

                // Parse format: "hash  filename" or "hash *filename"
                let parts = trimmed.split(separator: " ", maxSplits: 1)
                guard parts.count == 2 else { continue }

                let expectedHash = String(parts[0])
                var filename = String(parts[1])

                // Remove leading * or whitespace
                filename = filename.trimmingCharacters(in: .whitespaces)
                if filename.hasPrefix("*") {
                    filename = String(filename.dropFirst())
                }

                // Compute actual hash
                guard let fileData = try? Data(contentsOf: URL(fileURLWithPath: filename)) else {
                    print("\(filename): FAILED open or read")
                    exitCode = 1
                    continue
                }

                let actualHash = computeSHA256(fileData)
                if actualHash == expectedHash {
                    print("\(filename): OK")
                } else {
                    print("\(filename): FAILED")
                    exitCode = 1
                }
            }
        }

        return exitCode
    }

    static func computeSHA256(_ data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
