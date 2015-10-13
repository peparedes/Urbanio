#!/usr/bin/env python3
import socket
import struct
import time
# import tkinter

MBED_IP = '192.168.1.11'
MBED_PORT = 50001
MBED_CLOCK_IP = '192.168.1.11'
MBED_CLOCK_PORT = 49000


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
    return bytes(u'L,{0},{1},{2},{3},{4},'.format(light, r, b, g, ts), 'ascii')


# Probably need to chunk packets
def send_program(ip, port, lines):
    set_clock(ip, port, 0)
    while len(lines):
        line = b''
        for y in range(0, 20):
            while len(lines) and y < 20:
                line += bytes(lines.pop(0), 'ascii')
        send_cmd(ip, port, line)
        # TODO wait as long as the commands take
        time.sleep(1)


def blink_all(ip, port, dur=1000, times=3):
    prog = []
    latency = 10
    for l in (4, 2, 1, 3):
        cmd = mk_cmd(l, 0, 0, 0, latency)
        prog.append(cmd)
    for t in range(1, times):
        for l in (4, 2, 1, 3):
            cmd = mk_cmd(l, 255, 255, 255, dur*t + latency)
            prog.append(cmd)
        for l in (4, 2, 1, 3):
            cmd = mk_cmd(l, 0, 0, 0, dur*t + dur/2 + latency)
            prog.append(cmd)
    send_program(ip, port, prog)


def main():
    f = open('test2.txt', 'r')
    lines = f.readlines()
    send_program(MBED_IP, MBED_PORT, lines)
    f.close()


if __name__ == "__main__":
    main()
