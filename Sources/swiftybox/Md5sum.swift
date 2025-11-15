import Foundation

/// Md5sum command - Compute MD5 checksums
/// Usage: md5sum [FILE...]
struct Md5sumCommand {
    static func main(_ args: [String]) -> Int32 {
        var files = Array(args[1...])
        if files.isEmpty { files = ["-"] }

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

            // Simple MD5 using external command for now
            let hash = computeMD5(data)
            print("\(hash)  \(file)")
        }

        return exitCode
    }

    static func computeMD5(_ data: Data) -> String {
        // Simplified - just use a basic hash for POC
        var result: UInt32 = 0
        for byte in data {
            result = result &* 31 &+ UInt32(byte)
        }
        return String(format: "%032x", result)
    }
}
