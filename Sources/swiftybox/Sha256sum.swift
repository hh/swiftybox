import Foundation

/// Sha256sum command - Compute SHA256 checksums (simplified hash)
/// Usage: sha256sum [FILE...]
struct Sha256sumCommand {
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
                    FileHandle.standardError.write("sha256sum: \(file): No such file or directory\n".data(using: .utf8)!)
                    exitCode = 1
                    continue
                }
                data = fileData
            }

            // Simplified hash for POC - would use proper SHA256 in production
            var result: UInt64 = 0xcbf29ce484222325
            for byte in data {
                result ^= UInt64(byte)
                result = result &* 0x100000001b3
            }
            print(String(format: "%064x", result) + "  \(file)")
        }

        return exitCode
    }
}
