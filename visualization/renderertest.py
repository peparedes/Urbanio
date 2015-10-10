#!/usr/bin/env python3
import socket
import struct
# import tkinter

MBED_IP = '192.168.1.11'
MBED_PORT = '54322'
MBED_CLOCK_PORT = '49000'
MBED_CLOCK_IP = '192.168.1.11'


def set_clock(ip, port, value):
    sck = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sck.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sck.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    sck.sendto(struct.pack('q', 0), (MBED_CLOCK_IP, MBED_CLOCK_PORT))
    sck.close()


def send_cmd(ip, port, cmd):
    sck = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sck.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sck.sendto(cmd, (MBED_IP, MBED_PORT))
    sck.close()


def mk_cmd(light, r, g, b, ts):
    return 'L,{0},{1},{2},{3},{4},'.format(light, r, b, g, ts)


# Probably need to chunk packets
def send_program(ip, port, lines):
    set_clock(ip, port, 0)
    for line in lines:
        send_cmd(ip, port, line)


def blink_all(ip, port, dur=1000, times=3):
    prog = []
    latency = 10
    for x in (1, 2, 3, 4):
        cmd = mk_cmd(x, 0, 0, 0, latency)
        prog.append(cmd)
    for x in range(1, times):
        for x in (1, 2, 3, 4):
            cmd = mk_cmd(x, 255, 255, 255, dur*x + latency)
            prog.append(cmd)
        for x in (1, 2, 3, 4):
            cmd = mk_cmd(x, 0, 0, 0, dur*x + dur/2 + latency)
            prog.append(cmd)
    send_program(ip, port, prog)


def main():
    for x in range(0, 10):
        blink_all('192.168.1.11', 54322, 1000, 6)


if __name__ == "__main__":
    main()
