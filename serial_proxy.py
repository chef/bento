#!/usr/bin/env python3
"""
Serial socket multiplexer & logger for Windows 11 Bento builds.
Connects to QEMU's serial socket (/tmp/windows-11-serial.sock),
logs all output in real-time to serial.log, and serves an interactive
client socket (/tmp/windows-11-serial-client.sock) for bidirectional debugging.
"""
import os
import sys
import time
import socket
import select
import signal

QEMU_SOCK = os.environ.get("SERIAL_SOCK", "/tmp/windows-11-serial.sock")
CLIENT_SOCK = os.environ.get("SERIAL_CLIENT_SOCK", "/tmp/windows-11-serial-client.sock")
LOG_FILE = os.environ.get("SERIAL_LOG", "serial.log")

running = True

def handle_sig(sig, frame):
    global running
    running = False

signal.signal(signal.SIGINT, handle_sig)
signal.signal(signal.SIGTERM, handle_sig)

def main():
    global running
    # Ensure client socket file is clean
    if os.path.exists(CLIENT_SOCK):
        try:
            os.unlink(CLIENT_SOCK)
        except OSError:
            pass

    # Server socket for interactive serial clients
    server_s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    server_s.bind(CLIENT_SOCK)
    server_s.listen(5)
    server_s.setblocking(False)

    clients = []
    qemu_conn = None
    log_f = open(LOG_FILE, "ab", buffering=0)

    print(f"[serial_proxy] Monitoring QEMU socket: {QEMU_SOCK}", file=sys.stderr)
    print(f"[serial_proxy] Client socket ready: {CLIENT_SOCK}", file=sys.stderr)
    print(f"[serial_proxy] Logging to: {LOG_FILE}", file=sys.stderr)

    while running:
        # Try to connect to QEMU serial socket if not connected
        if qemu_conn is None:
            active_sock = None
            candidates = [QEMU_SOCK, "/tmp/windows-11-serial.sock", "/tmp/bento-qemu-serial.sock"]
            for cand in candidates:
                if cand and os.path.exists(cand):
                    active_sock = cand
                    break
            if active_sock:
                try:
                    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
                    s.connect(active_sock)
                    s.setblocking(False)
                    qemu_conn = s
                    print(f"[serial_proxy] Connected to QEMU serial port: {active_sock}", file=sys.stderr)
                except Exception:
                    qemu_conn = None
            if qemu_conn is None:
                time.sleep(0.3)

        read_fds = [server_s]
        if qemu_conn is not None:
            read_fds.append(qemu_conn)
        read_fds.extend(clients)

        try:
            rlist, _, _ = select.select(read_fds, [], [], 0.5)
        except (select.error, InterruptedError):
            break

        for fd in rlist:
            if fd is server_s:
                try:
                    client_conn, _ = server_s.accept()
                    client_conn.setblocking(False)
                    clients.append(client_conn)
                    print(f"[serial_proxy] Interactive client connected ({len(clients)} total).", file=sys.stderr)
                except Exception:
                    pass
            elif fd is qemu_conn:
                try:
                    data = qemu_conn.recv(4096)
                    if not data:
                        print("[serial_proxy] QEMU disconnected (VM rebooting or shutting down).", file=sys.stderr)
                        qemu_conn.close()
                        qemu_conn = None
                    else:
                        log_f.write(data)
                        dead_clients = []
                        for c in clients:
                            try:
                                c.sendall(data)
                            except Exception:
                                dead_clients.append(c)
                        for dc in dead_clients:
                            if dc in clients:
                                clients.remove(dc)
                            try:
                                dc.close()
                            except Exception:
                                pass
                except Exception:
                    if qemu_conn:
                        qemu_conn.close()
                    qemu_conn = None
            elif fd in clients:
                try:
                    data = fd.recv(1024)
                    if not data:
                        clients.remove(fd)
                        fd.close()
                    else:
                        if qemu_conn:
                            try:
                                qemu_conn.sendall(data)
                            except Exception:
                                pass
                except Exception:
                    if fd in clients:
                        clients.remove(fd)
                    try:
                        fd.close()
                    except Exception:
                        pass

    # Cleanup
    if qemu_conn:
        qemu_conn.close()
    for c in clients:
        try:
            c.close()
        except Exception:
            pass
    server_s.close()
    log_f.close()
    if os.path.exists(CLIENT_SOCK):
        try:
            os.unlink(CLIENT_SOCK)
        except OSError:
            pass
    print("[serial_proxy] Terminated cleanly.", file=sys.stderr)

if __name__ == "__main__":
    main()
