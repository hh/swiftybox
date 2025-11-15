import Foundation

/// Arch command - Print machine architecture
/// Usage: arch
/// Print the machine hardware architecture name (same as uname -m)
struct ArchCommand {
    static func main(_ args: [String]) -> Int32 {
        var systemInfo = utsname()
        uname(&systemInfo)

        let machine = String(cString: withUnsafePointer(to: &systemInfo.machine.0) { $0 })
        print(machine)
        return 0
    }
}
