import Foundation

/// Hostid command - Print numeric host identifier
/// Usage: hostid
/// Prints the numeric identifier for the current host in hexadecimal
struct HostidCommand {
    static func main(_ args: [String]) -> Int32 {
        // gethostid() returns a unique 32-bit identifier for the current host
        let hostid = gethostid()

        // Print as 8-digit hexadecimal (with leading zeros)
        print(String(format: "%08x", hostid))
        return 0
    }
}
