import Foundation

/// Id command - Print user and group information
/// Usage: id [OPTIONS] [USER]
struct IdCommand {
    static func main(_ args: [String]) -> Int32 {
        var user: String? = nil
        var showUser = false
        var showGroup = false
        var showGroups = false
        var showName = false
        var showReal = false

        for i in 1..<args.count {
            let arg = args[i]
            if arg == "-u" || arg == "--user" { showUser = true }
            else if arg == "-g" || arg == "--group" { showGroup = true }
            else if arg == "-G" || arg == "--groups" { showGroups = true }
            else if arg == "-n" || arg == "--name" { showName = true }
            else if arg == "-r" || arg == "--real" { showReal = true }
            else if arg.hasPrefix("-") {
                // Handle combined flags like -un, -ur
                for char in arg.dropFirst() {
                    switch char {
                    case "u": showUser = true
                    case "g": showGroup = true
                    case "G": showGroups = true
                    case "n": showName = true
                    case "r": showReal = true
                    default: break
                    }
                }
            }
            else if !arg.hasPrefix("-") { user = arg }
        }

        let uid: uid_t
        let gid: gid_t
        let username: String

        if let u = user {
            guard let passwd = getpwnam(u) else {
                FileHandle.standardError.write("id: '\(u)': no such user\n".data(using: .utf8)!)
                return 1
            }
            uid = passwd.pointee.pw_uid
            gid = passwd.pointee.pw_gid
            username = u
        } else {
            uid = getuid()
            gid = getgid()
            if let passwd = getpwuid(uid),
               let name = String(validatingCString: passwd.pointee.pw_name) {
                username = name
            } else {
                username = String(uid)
            }
        }

        if showUser {
            if showName {
                print(username)
            } else {
                print(uid)
            }
        } else if showGroup {
            if showName {
                guard let group = getgrgid(gid),
                      let gname = String(validatingCString: group.pointee.gr_name) else {
                    print(gid)
                    return 0
                }
                print(gname)
            } else {
                print(gid)
            }
        } else if showGroups {
            // Just print primary group for simplicity
            if showName {
                guard let group = getgrgid(gid),
                      let gname = String(validatingCString: group.pointee.gr_name) else {
                    print(gid)
                    return 0
                }
                print(gname)
            } else {
                print(gid)
            }
        } else {
            // Full output
            guard let passwd = getpwuid(uid),
                  let uname = String(validatingCString: passwd.pointee.pw_name),
                  let group = getgrgid(gid),
                  let gname = String(validatingCString: group.pointee.gr_name) else {
                print("uid=\(uid) gid=\(gid)")
                return 0
            }
            print("uid=\(uid)(\(uname)) gid=\(gid)(\(gname))")
        }

        return 0
    }
}
