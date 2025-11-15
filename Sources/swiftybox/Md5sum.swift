import Foundation
import Crypto

/// Md5sum command - Compute MD5 checksums
/// Usage: md5sum [-c] [FILE...]
struct Md5sumCommand {
    static func main(_ args: [String]) -> Int32 {
        var checkMode = false
        var files: [String] = []

        var i = 1
        while i < args.count {
            let arg = args[i]
            if arg == "-c" || arg == "--check" {
                checkMode = true
            } else if arg.hasPrefix("-") && arg != "-" {
                FileHandle.standardError.write("md5sum: invalid option -- '\(arg)'\n".data(using: .utf8)!)
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
                    FileHandle.standardError.write("md5sum: \(file): No such file or directory\n".data(using: .utf8)!)
                    exitCode = 1
                    continue
                }
                data = fileData
            }

            let hash = computeMD5(data)
            print("\(hash)  \(file)")
        }

        return exitCode
    }

    static func verifyChecksums(_ files: [String]) -> Int32 {
        var exitCode: Int32 = 0

        for checksumFile in files {
            guard let content = try? String(contentsOfFile: checksumFile, encoding: .utf8) else {
                FileHandle.standardError.write("md5sum: \(checksumFile): No such file or directory\n".data(using: .utf8)!)
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

                let actualHash = computeMD5(fileData)
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

    static func computeMD5(_ data: Data) -> String {
        let digest = Insecure.MD5.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
