import Foundation

/// Hexdump command - Display file in hexadecimal
/// Usage: hexdump [OPTIONS] [FILE...]
struct HexdumpCommand {
    static func main(_ args: [String]) -> Int32 {
        var canonical = false
        var files: [String] = []

        for i in 1..<args.count {
            let arg = args[i]
            if arg == "-C" || arg == "--canonical" { canonical = true }
            else if !arg.hasPrefix("-") { files.append(arg) }
        }

        if files.isEmpty { files = ["-"] }

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
                    FileHandle.standardError.write("hexdump: \(file): No such file or directory\n".data(using: .utf8)!)
                    return 1
                }
                data = fileData
            }

            var offset = 0
            while offset < data.count {
                let chunk = data[offset..<min(offset + 16, data.count)]
                print(String(format: "%08x  ", offset), terminator: "")

                for (i, byte) in chunk.enumerated() {
                    print(String(format: "%02x", byte), terminator: i == 7 ? "  " : " ")
                }

                if canonical {
                    let padding = 16 - chunk.count
                    print(String(repeating: "   ", count: padding), terminator: padding > 8 ? " " : "")
                    print(" |", terminator: "")
                    for byte in chunk {
                        let char = (32...126).contains(byte) ? Character(UnicodeScalar(byte)) : "."
                        print(char, terminator: "")
                    }
                    print("|")
                } else {
                    print()
                }

                offset += 16
            }
            print(String(format: "%08x", data.count))
        }

        return 0
    }
}
