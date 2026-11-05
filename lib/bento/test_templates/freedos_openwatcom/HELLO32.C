/**
 * @file HELLO32.C
 * @brief Sample 32-bit Protected-Mode DOS/4GW program for OpenWatcom v2 (`wcl386 -bcl=dos4g HELLO32.C`)
 * @description
 *   Demonstrates compiling a 32-bit protected-mode DOS `.EXE` (`DOS/4GW`,
 *   `DOS/32A`, or `CWSDPMI`) with OpenWatcom, syncing it to FreeDOS `D:`,
 *   executing it via `vagrant ssh -c`, and syncing results back to the host.
 */

#include <stdio.h>

/**
 * @brief Main entry point for 32-bit DOS/4GW protected-mode test target.
 * @param argc Argument count.
 * @param argv Argument vector.
 * @return 0 on success.
 */
int main(int argc, char *argv[]) {
    (void)argc;
    (void)argv;
    puts("Hello from 32-bit OpenWatcom DOS/4GW Protected-Mode!");
    return 0;
}
