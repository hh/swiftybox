import Foundation

/// Cksum command - Compute CRC checksums and byte counts
/// Usage: cksum [FILE...]
struct CksumCommand {
    static func main(_ args: [String]) -> Int32 {
        var files = Array(args[1...])
        if files.isEmpty { files = ["-"] }

        var exitCode: Int32 = 0
        for file in files {
            let data: Data
            let displayName: String

            if file == "-" {
                var input = Data()
                while let line = readLine(strippingNewline: false) {
                    if let lineData = line.data(using: .utf8) { input.append(lineData) }
                }
                data = input
                displayName = "-"
            } else {
                guard let fileData = try? Data(contentsOf: URL(fileURLWithPath: file)) else {
                    FileHandle.standardError.write("cksum: \(file): No such file or directory\n".data(using: .utf8)!)
                    exitCode = 1
                    continue
                }
                data = fileData
                displayName = file
            }

            let crc = crc32(data)
            print("\(crc) \(data.count) \(displayName)")
        }

        return exitCode
    }

    static func crc32(_ data: Data) -> UInt32 {
        var crc: UInt32 = 0
        let polynomial: UInt32 = 0x04C11DB7

        for byte in data {
            var temp = UInt32(byte) << 24
            for _ in 0..<8 {
                if (crc ^ temp) & 0x80000000 != 0 {
                    crc = (crc << 1) ^ polynomial
                } else {
                    crc <<= 1
                }
                temp <<= 1
            }
        }

        // Process length
        var length = data.count
        while length > 0 {
            var temp = UInt32(length & 0xFF) << 24
            for _ in 0..<8 {
                if (crc ^ temp) & 0x80000000 != 0 {
                    crc = (crc << 1) ^ polynomial
                } else {
                    crc <<= 1
                }
                temp <<= 1
            }
            length >>= 8
        }

        return ~crc
    }
}
