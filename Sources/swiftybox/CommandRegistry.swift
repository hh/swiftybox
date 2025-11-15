import Foundation

/// Command implementation type
enum CommandImpl {
    case swift    // Pure Swift implementation
    case busybox  // BusyBox C implementation
}

/// Command registry - maps command names to their implementations
struct CommandRegistry {
    /// Type alias for command functions
    typealias CommandFunc = ([String]) -> Int32
    
    /// Current implementation preference
    var preferredImpl: CommandImpl = .swift
    
    /// Registry of Swift implementations
    private let swiftCommands: [String: CommandFunc]
    
    /// Registry of BusyBox implementations
    private let busyboxCommands: [String: CommandFunc]
    
    init(preferredImpl: CommandImpl = .swift) {
        self.preferredImpl = preferredImpl
        
        // Pure Swift implementations
        self.swiftCommands = [
            // Phase 1-3: Original commands
            "echo": EchoCommand.main,
            "pwd": PwdCommand.main,
            "true": TrueCommand.main,
            "false": FalseCommand.main,

            // Phase 4: Session 1 additions
            "yes": YesCommand.main,
            "sleep": SleepCommand.main,
            "basename": BasenameCommand.main,
            "dirname": DirnameCommand.main,
            "env": EnvCommand.main,

            // Phase 4: Session 2 additions
            "seq": SeqCommand.main,
            "wc": WcCommand.main,
            "cat": CatCommand.main,

            // Phase 5: Text processing additions
            "head": HeadCommand.main,
            "tail": TailCommand.main,
            "grep": GrepCommand.main,
            "tr": TrCommand.main,
            "cut": CutCommand.main,
            "tee": TeeCommand.main,

            // Phase 7: File operations additions
            "mkdir": MkdirCommand.main,
            "rmdir": RmdirCommand.main,
            "touch": TouchCommand.main,
            "link": LinkCommand.main,
            "unlink": UnlinkCommand.main,
            "sync": SyncCommand.main,

            // Batch 1: User/System Info (NOFORK)
            "whoami": WhoamiCommand.main,
            "logname": LognameCommand.main,
            "hostid": HostidCommand.main,
            "tty": TtyCommand.main,

            // Batch 2: Path Operations (NOFORK)
            "readlink": ReadlinkCommand.main,
            "realpath": RealpathCommand.main,
            "truncate": TruncateCommand.main,
            "which": WhichCommand.main,

            // Batch 3: Shell Conditionals (NOFORK)
            "printf": PrintfCommand.main,
            "test": TestCommand.main,
            "[": TestCommand.main,
            "printenv": PrintenvCommand.main,

            // Batch 4: System Info & Control (NOFORK)
            "uname": UnameCommand.main,
            "arch": ArchCommand.main,
            "nproc": NprocCommand.main,
            "clear": ClearCommand.main,

            // Batch 5: Final NOFORK commands (44/44 complete!)
            "usleep": UsleepCommand.main,
            "free": FreeCommand.main,
            "pwdx": PwdxCommand.main,
            "fsync": FsyncCommand.main,

            // Phase 6: File Operations (NOEXEC)
            "ln": LnCommand.main,
            "chmod": ChmodCommand.main,
            "chown": ChownCommand.main,
            "chgrp": ChgrpCommand.main,
            "rm": RmCommand.main,
            "mv": MvCommand.main,
            "cp": CpCommand.main,
            "ls": LsCommand.main,

            // Phase 7: Text Processing (NOEXEC)
            "sort": SortCommand.main,
            "uniq": UniqCommand.main,
            "comm": CommCommand.main,
            "fold": FoldCommand.main,
            "paste": PasteCommand.main,
            "nl": NlCommand.main,

            // Phase 8: Checksums & Utilities (NOEXEC)
            "md5sum": Md5sumCommand.main,
            "sha256sum": Sha256sumCommand.main,
            "sha512sum": Sha512sumCommand.main,
            "cksum": CksumCommand.main,
            "date": DateCommand.main,
            "id": IdCommand.main,
            "expr": ExprCommand.main,
            "mktemp": MktempCommand.main,

            // Phase 9: Simple Utilities & File Info (NOEXEC)
            "tac": TacCommand.main,
            "rev": RevCommand.main,
            "expand": ExpandCommand.main,
            "hexdump": HexdumpCommand.main,
            "shuf": ShufCommand.main,
            "stat": StatCommand.main,
            "du": DuCommand.main,
            "df": DfCommand.main,
        ]
        
        // BusyBox C implementations
        self.busyboxCommands = [
            "echo": BusyBoxWrappers.echo,
            "pwd": BusyBoxWrappers.pwd,
            "true": BusyBoxWrappers.trueCommand,
            "false": BusyBoxWrappers.falseCommand,
        ]
    }
    
    /// Execute a command by name using preferred implementation
    func execute(command: String, args: [String]) -> Int32 {
        return execute(command: command, args: args, impl: preferredImpl)
    }
    
    /// Execute a command with specific implementation
    func execute(command: String, args: [String], impl: CommandImpl) -> Int32 {
        let registry = impl == .swift ? swiftCommands : busyboxCommands
        
        guard let commandFunc = registry[command] else {
            let msg = "swiftybox: \(command): command not found\n"
            if let data = msg.data(using: .utf8) {
                FileHandle.standardError.write(data)
            }
            return 127
        }
        
        return commandFunc(args)
    }
    
    /// List all available commands
    func listCommands() -> [String] {
        return Array(Set(swiftCommands.keys).union(busyboxCommands.keys)).sorted()
    }
    
    /// Check if a command exists
    func hasCommand(_ name: String) -> Bool {
        return swiftCommands[name] != nil || busyboxCommands[name] != nil
    }
    
    /// Get implementation description
    func implDescription() -> String {
        switch preferredImpl {
        case .swift:
            return "Pure Swift (Phase 1)"
        case .busybox:
            return "BusyBox C (Phase 2)"
        }
    }
}
