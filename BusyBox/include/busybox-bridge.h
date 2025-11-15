#ifndef BUSYBOX_BRIDGE_H
#define BUSYBOX_BRIDGE_H

// Must include autoconf.h first - it defines all the ENABLE_* macros
#include "../../../../busybox/include/autoconf.h"

// Now we can include the main headers
#include "../../../../busybox/include/libbb.h"
#include "../../../../busybox/include/busybox.h"

// Forward declare command main functions we want to use
extern int echo_main(int argc, char **argv);
extern int pwd_main(int argc, char **argv);
extern int true_main(int argc, char **argv);
extern int false_main(int argc, char **argv);

// BusyBox library functions
extern int lbb_main(char **argv);
extern void lbb_prepare(const char *applet, char **argv);

// BusyBox applet dispatcher functions
// Note: find_applet_by_name, run_nofork_applet, and spawn_and_wait
// are available in busybox source but not exported from libbusybox.a
// For Phase 7, we'll need to either:
// 1. Build busybox with different config to export these symbols
// 2. Implement our own dispatcher using applet main functions directly
// 3. Use a different linking strategy
// extern int find_applet_by_name(const char *name);
// extern int run_nofork_applet(int applet_no, char **argv);
// extern int spawn_and_wait(char **argv);

#endif /* BUSYBOX_BRIDGE_H */
