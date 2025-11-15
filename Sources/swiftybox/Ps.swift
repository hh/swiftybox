import Foundation

/// Ps command - Report process status
/// Usage: ps [OPTIONS]
struct PsCommand {
    static func main(_ args: [String]) -> Int32 {
        var bsdStyle = false
        var unixShowAll = false
        var unixFullFormat = false
        var showAllProcesses = false
        var customColumns: [String] = []
        var filterPIDs: [Int32] = []
        var filterCommand: String? = nil
        var filterUser: String? = nil
        var noHeaders = false
        var sortColumn: String? = nil

        // Parse arguments
        var i = 1
        while i < args.count {
            let arg = args[i]

            if arg == "aux" {
                // BSD style: a=all users, u=user-oriented, x=no tty
                bsdStyle = true
                showAllProcesses = true
            } else if arg == "-e" || arg == "-A" {
                unixShowAll = true
                showAllProcesses = true
            } else if arg == "-f" {
                unixFullFormat = true
            } else if arg == "-ef" {
                unixShowAll = true
                unixFullFormat = true
                showAllProcesses = true
            } else if arg == "-o" {
                i += 1
                if i < args.count {
                    customColumns = args[i].split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
                }
            } else if arg == "-p" {
                i += 1
                if i < args.count {
                    let pidStr = args[i]
                    for pid in pidStr.split(separator: ",") {
                        if let pidNum = Int32(pid) {
                            filterPIDs.append(pidNum)
                        }
                    }
                }
            } else if arg == "-C" {
                i += 1
                if i < args.count {
                    filterCommand = args[i]
                }
            } else if arg == "-u" {
                i += 1
                if i < args.count {
                    filterUser = args[i]
                }
            } else if arg == "--no-headers" {
                noHeaders = true
            } else if arg.hasPrefix("--sort=") {
                sortColumn = String(arg.dropFirst("--sort=".count))
            }

            i += 1
        }

        // Get all processes
        let processes = getProcesses()

        // Filter processes
        var filtered = processes
        if !showAllProcesses {
            // By default, show only current user's processes
            let currentUID = getuid()
            filtered = filtered.filter { $0.uid == currentUID }
        }
        if !filterPIDs.isEmpty {
            filtered = filtered.filter { filterPIDs.contains($0.pid) }
        }
        if let cmd = filterCommand {
            filtered = filtered.filter { $0.command.contains(cmd) }
        }
        if let user = filterUser {
            let username = user
            filtered = filtered.filter { getUserName($0.uid) == username }
        }

        // Sort if requested
        if let sort = sortColumn {
            filtered = sortProcesses(filtered, by: sort)
        }

        // Output
        if !customColumns.isEmpty {
            printCustomFormat(processes: filtered, columns: customColumns, noHeaders: noHeaders)
        } else if bsdStyle {
            printBSDFormat(processes: filtered, noHeaders: noHeaders)
        } else if unixFullFormat {
            printUnixFullFormat(processes: filtered, noHeaders: noHeaders)
        } else {
            printDefaultFormat(processes: filtered, noHeaders: noHeaders)
        }

        return 0
    }

    // MARK: - Process Structure

    struct ProcessInfo {
        let pid: Int32
        let ppid: Int32
        let uid: UInt32
        let gid: UInt32
        let command: String
        let state: String
        let vsz: UInt64  // Virtual memory size in KB
        let rss: UInt64  // Resident set size in KB
        let pcpu: Double  // CPU usage percentage
        let pmem: Double  // Memory usage percentage
        let tty: String
        let startTime: String
        let cpuTime: String
        let fullCommand: String
    }

    // MARK: - Get Processes

    static func getProcesses() -> [ProcessInfo] {
        var processes: [ProcessInfo] = []

        #if os(Linux)
        let fm = FileManager.default
        guard let procDirs = try? fm.contentsOfDirectory(atPath: "/proc") else {
            return []
        }

        for dir in procDirs {
            guard let pid = Int32(dir) else { continue }

            let procPath = "/proc/\(pid)"
            guard let process = readProcessInfo(pid: pid, procPath: procPath) else { continue }

            processes.append(process)
        }
        #else
        // macOS fallback - minimal implementation
        processes.append(ProcessInfo(
            pid: getpid(),
            ppid: getppid(),
            uid: getuid(),
            gid: getgid(),
            command: "ps",
            state: "R",
            vsz: 0,
            rss: 0,
            pcpu: 0.0,
            pmem: 0.0,
            tty: "?",
            startTime: "00:00",
            cpuTime: "00:00:00",
            fullCommand: "ps"
        ))
        #endif

        return processes
    }

    #if os(Linux)
    static func readProcessInfo(pid: Int32, procPath: String) -> ProcessInfo? {
        // Read /proc/[pid]/stat
        guard let stat = try? String(contentsOfFile: "\(procPath)/stat", encoding: .utf8) else {
            return nil
        }

        // Parse stat file
        // Format: pid (comm) state ppid pgrp session tty_nr tpgid flags ...
        guard let statFields = parseStatFile(stat) else { return nil }

        // Read /proc/[pid]/status
        var uid: UInt32 = 0
        var gid: UInt32 = 0
        var vmSize: UInt64 = 0
        var vmRSS: UInt64 = 0

        if let status = try? String(contentsOfFile: "\(procPath)/status", encoding: .utf8) {
            for line in status.split(separator: "\n") {
                let parts = line.split(separator: ":", maxSplits: 1)
                guard parts.count == 2 else { continue }

                let key = parts[0].trimmingCharacters(in: .whitespaces)
                let value = parts[1].trimmingCharacters(in: .whitespaces)

                switch key {
                case "Uid":
                    let uids = value.split(separator: "\t")
                    uid = UInt32(uids.first ?? "0") ?? 0
                case "Gid":
                    let gids = value.split(separator: "\t")
                    gid = UInt32(gids.first ?? "0") ?? 0
                case "VmSize":
                    // Value is in kB
                    let sizeStr = value.replacingOccurrences(of: " kB", with: "").trimmingCharacters(in: .whitespaces)
                    vmSize = UInt64(sizeStr) ?? 0
                case "VmRSS":
                    let sizeStr = value.replacingOccurrences(of: " kB", with: "").trimmingCharacters(in: .whitespaces)
                    vmRSS = UInt64(sizeStr) ?? 0
                default:
                    break
                }
            }
        }

        // Read /proc/[pid]/cmdline
        var fullCommand = statFields.command
        if let cmdline = try? String(contentsOfFile: "\(procPath)/cmdline", encoding: .utf8) {
            let cmd = cmdline.replacingOccurrences(of: "\0", with: " ").trimmingCharacters(in: .whitespaces)
            if !cmd.isEmpty {
                fullCommand = cmd
            }
        }

        // Calculate CPU and memory percentages
        let pcpu = 0.0  // TODO: Calculate based on utime + stime
        let pmem = calculateMemoryPercent(rss: vmRSS)

        // Format TTY
        let tty = formatTTY(statFields.ttyNr)

        // Format times
        let startTime = "00:00"  // TODO: Calculate from boot time
        let cpuTime = formatCPUTime(utime: statFields.utime, stime: statFields.stime)

        return ProcessInfo(
            pid: statFields.pid,
            ppid: statFields.ppid,
            uid: uid,
            gid: gid,
            command: statFields.command,
            state: statFields.state,
            vsz: vmSize,
            rss: vmRSS,
            pcpu: pcpu,
            pmem: pmem,
            tty: tty,
            startTime: startTime,
            cpuTime: cpuTime,
            fullCommand: fullCommand
        )
    }

    struct StatFields {
        let pid: Int32
        let command: String
        let state: String
        let ppid: Int32
        let ttyNr: Int32
        let utime: UInt64
        let stime: UInt64
    }

    static func parseStatFile(_ stat: String) -> StatFields? {
        // Find command in parentheses
        guard let startParen = stat.firstIndex(of: "("),
              let endParen = stat.lastIndex(of: ")") else {
            return nil
        }

        let pidStr = stat[..<startParen].trimmingCharacters(in: .whitespaces)
        guard let pid = Int32(pidStr) else { return nil }

        let command = String(stat[stat.index(after: startParen)..<endParen])

        let afterParen = stat.index(after: endParen)
        let fields = stat[afterParen...].split(separator: " ").map { String($0) }

        guard fields.count >= 13 else { return nil }

        let state = fields[0]
        let ppid = Int32(fields[1]) ?? 0
        let ttyNr = Int32(fields[4]) ?? 0
        let utime = UInt64(fields[11]) ?? 0
        let stime = UInt64(fields[12]) ?? 0

        return StatFields(
            pid: pid,
            command: command,
            state: state,
            ppid: ppid,
            ttyNr: ttyNr,
            utime: utime,
            stime: stime
        )
    }

    static func formatTTY(_ ttyNr: Int32) -> String {
        if ttyNr == 0 {
            return "?"
        }
        // Major device number is bits 31-8, minor is bits 7-0
        let major = (ttyNr >> 8) & 0xFF
        let minor = ttyNr & 0xFF

        switch major {
        case 4:  // /dev/tty*
            return "tty\(minor)"
        case 136:  // /dev/pts/*
            return "pts/\(minor)"
        default:
            return "?"
        }
    }

    static func formatCPUTime(utime: UInt64, stime: UInt64) -> String {
        // Convert from clock ticks to seconds (assuming 100 Hz)
        let totalTicks = utime + stime
        let totalSeconds = totalTicks / 100

        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    static func calculateMemoryPercent(rss: UInt64) -> Double {
        // Read total memory from /proc/meminfo
        guard let meminfo = try? String(contentsOfFile: "/proc/meminfo", encoding: .utf8) else {
            return 0.0
        }

        for line in meminfo.split(separator: "\n") {
            if line.hasPrefix("MemTotal:") {
                let parts = line.split(separator: " ").filter { !$0.isEmpty }
                if parts.count >= 2, let totalKB = UInt64(parts[1]) {
                    return (Double(rss) / Double(totalKB)) * 100.0
                }
                break
            }
        }

        return 0.0
    }
    #endif

    static func getUserName(_ uid: UInt32) -> String {
        #if os(Linux)
        if let passwd = try? String(contentsOfFile: "/etc/passwd", encoding: .utf8) {
            for line in passwd.split(separator: "\n") {
                let parts = line.split(separator: ":")
                if parts.count >= 3, let lineUid = UInt32(parts[2]), lineUid == uid {
                    return String(parts[0])
                }
            }
        }
        #endif
        return "\(uid)"
    }

    // MARK: - Sorting

    static func sortProcesses(_ processes: [ProcessInfo], by column: String) -> [ProcessInfo] {
        let col = column.hasPrefix("-") ? String(column.dropFirst()) : column
        let reverse = column.hasPrefix("-")

        var sorted = processes
        switch col {
        case "cpu", "%cpu":
            sorted = sorted.sorted { $0.pcpu > $1.pcpu }
        case "mem", "%mem":
            sorted = sorted.sorted { $0.pmem > $1.pmem }
        case "vsz":
            sorted = sorted.sorted { $0.vsz > $1.vsz }
        case "rss":
            sorted = sorted.sorted { $0.rss > $1.rss }
        case "pid":
            sorted = sorted.sorted { $0.pid < $1.pid }
        default:
            break
        }

        return reverse ? sorted : sorted.reversed()
    }

    // MARK: - Output Formats

    static func printDefaultFormat(processes: [ProcessInfo], noHeaders: Bool) {
        if !noHeaders {
            print("  PID TTY          TIME CMD")
        }

        for p in processes {
            print(String(format: "%5d %-12s %8s %s",
                        p.pid, p.tty, p.cpuTime, p.command))
        }
    }

    static func printBSDFormat(processes: [ProcessInfo], noHeaders: Bool) {
        if !noHeaders {
            print("USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND")
        }

        for p in processes {
            let user = getUserName(p.uid)
            print(String(format: "%-8s %5d %4.1f %4.1f %6llu %5llu %-8s %-4s %5s %6s %s",
                        String(user.prefix(8)), p.pid, p.pcpu, p.pmem,
                        p.vsz, p.rss, String(p.tty.prefix(8)), p.state,
                        p.startTime, String(p.cpuTime.prefix(6)), p.fullCommand))
        }
    }

    static func printUnixFullFormat(processes: [ProcessInfo], noHeaders: Bool) {
        if !noHeaders {
            print("UID        PID  PPID  C STIME TTY          TIME CMD")
        }

        for p in processes {
            let user = getUserName(p.uid)
            print(String(format: "%-8s %5d %5d %2d %5s %-12s %8s %s",
                        String(user.prefix(8)), p.pid, p.ppid, 0,
                        p.startTime, p.tty, p.cpuTime, p.fullCommand))
        }
    }

    static func printCustomFormat(processes: [ProcessInfo], columns: [String], noHeaders: Bool) {
        // Print header
        if !noHeaders {
            var headers: [String] = []
            for col in columns {
                headers.append(getColumnHeader(col))
            }
            print(headers.joined(separator: " "))
        }

        // Print rows
        for p in processes {
            var values: [String] = []
            for col in columns {
                values.append(getColumnValue(p, column: col))
            }
            print(values.joined(separator: " "))
        }
    }

    static func getColumnHeader(_ col: String) -> String {
        switch col.lowercased() {
        case "pid": return "PID"
        case "ppid": return "PPID"
        case "user", "uid": return "USER"
        case "group", "gid": return "GROUP"
        case "%cpu", "cpu": return "%CPU"
        case "%mem", "mem": return "%MEM"
        case "vsz": return "VSZ"
        case "rss": return "RSS"
        case "tty": return "TTY"
        case "stat", "state", "s": return "STAT"
        case "start", "stime": return "START"
        case "time": return "TIME"
        case "cmd", "command", "comm": return "COMMAND"
        default: return col.uppercased()
        }
    }

    static func getColumnValue(_ p: ProcessInfo, column: String) -> String {
        switch column.lowercased() {
        case "pid": return String(format: "%5d", p.pid)
        case "ppid": return String(format: "%5d", p.ppid)
        case "user", "uid": return String(format: "%-8s", String(getUserName(p.uid).prefix(8)))
        case "group", "gid": return String(format: "%d", p.gid)
        case "%cpu", "cpu": return String(format: "%4.1f", p.pcpu)
        case "%mem", "mem": return String(format: "%4.1f", p.pmem)
        case "vsz": return String(format: "%6llu", p.vsz)
        case "rss": return String(format: "%5llu", p.rss)
        case "tty": return String(format: "%-8s", String(p.tty.prefix(8)))
        case "stat", "state", "s": return String(format: "%-4s", p.state)
        case "start", "stime": return String(format: "%5s", p.startTime)
        case "time": return String(format: "%8s", p.cpuTime)
        case "cmd", "command": return p.fullCommand
        case "comm": return p.command
        default: return "?"
        }
    }
}
