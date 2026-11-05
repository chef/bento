/**
 * @file HELLO16.C
 * @brief Sample 16-bit Real-Mode DOS program for OpenWatcom v2 (`wcl -bcl=dos HELLO16.C`)
 * @description
 *   Demonstrates compiling a 16-bit DOS `.EXE` with OpenWatcom, syncing it into
 *   the standalone FreeDOS Vagrant VM (`D:`), running it via `vagrant ssh -c`,
 *   verifying the DOS `%ERRORLEVEL%` exit status, and syncing the generated
 *   output artifact back to the host workspace.
 */

#include <stdio.h>

/**
 * @brief Main entry point for 16-bit DOS test target.
 * @param argc Argument count.
 * @param argv Argument vector.
 * @return 0 on success.
 */
int main(int argc, char *argv[]) {
    (void)argc;
    (void)argv;
    puts("Hello from 16-bit OpenWatcom DOS Real-Mode!");
    return 0;
}
