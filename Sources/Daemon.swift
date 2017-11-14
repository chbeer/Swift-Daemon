// inspired by
// https://github.com/ruby/ruby/blob/trunk/process.c
// https://github.com/kylef/Curassow/blob/master/Sources/Curassow/Arbiter.swift#L54
#if os(Linux)
    import Glibc
    private let system_fork = Glibc.fork
#else
    import Darwin.C
    @_silgen_name("fork") private func system_fork() -> Int32
#endif

// chbeer: extended after: http://www.netzmafia.de/skripten/unix/linux-daemon-howto.html#ss6.1

public struct Daemon {
    public static func daemonize() {
        let devnull = open("/dev/null", O_RDWR)
        if devnull == -1 {
            fatalError("can't open /dev/null")
        }
        
        /* Fork off the parent process */
        let pid = system_fork()
        if pid < 0 {
            fatalError("can't fork")
        } else if pid != 0 {
            exit(0)
        }
        
        /* Change the file mode mask */
        umask(0)

        /* Create a new SID for the child process */
        if setsid() < 0 {
            fatalError("can't create session")
        }
        
        /* Change the current working directory */
        if ((chdir("/")) < 0) {
            /* Log the failure */
            fatalError("can't change directory")
        }

        for descriptor in Int32(0)..<Int32(3) {
            dup2(devnull, descriptor)
        }
    }
}
