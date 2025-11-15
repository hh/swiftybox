import Foundation

/// Whoami command - Print effective user name
/// Usage: whoami
/// Prints the user name associated with the current effective user ID
struct WhoamiCommand {
    static func main(_ args: [String]) -> Int32 {
        // Get effective user ID
        let uid = geteuid()

        // Get password entry for this UID
        guard let passwd = getpwuid(uid) else {
            FileHandle.standardError.write("whoami: cannot find name for user ID \(uid)\n".data(using: .utf8)!)
            return 1
        }

        // Convert C string to Swift String
        guard let username = String(validatingCString: passwd.pointee.pw_name) else {
            FileHandle.standardError.write("whoami: cannot read username\n".data(using: .utf8)!)
            return 1
        }

        print(username)
        return 0
    }
}
