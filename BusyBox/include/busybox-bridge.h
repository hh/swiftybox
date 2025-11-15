#ifndef BUSYBOX_BRIDGE_H
#define BUSYBOX_BRIDGE_H

// Forward declare command main functions we want to use from BusyBox
// Using default visibility - the symbols are exported from libbusybox.so
#ifdef __cplusplus
extern "C" {
#endif

int echo_main(int argc, char **argv) __attribute__((visibility("default")));
int pwd_main(int argc, char **argv) __attribute__((visibility("default")));
int true_main(int argc, char **argv) __attribute__((visibility("default")));
int false_main(int argc, char **argv) __attribute__((visibility("default")));
int ash_main(int argc, char **argv) __attribute__((visibility("default")));

// BusyBox library initialization
void lbb_prepare(const char *applet, char **argv) __attribute__((visibility("default")));
int lbb_main(char **argv) __attribute__((visibility("default")));

#ifdef __cplusplus
}
#endif

#endif /* BUSYBOX_BRIDGE_H */
