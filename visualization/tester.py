#!/usr/bin/env python3
import socket
import struct
import time
# import tkinter

MBED_IP = '192.168.1.10'
MBED_PORT = 50001
MBED_CLOCK_IP = '192.168.1.10'
MBED_CLOCK_PORT = 49000
MBED_BROADCAST = '192.168.1.255'


def set_clocks(ip, port, value):
    sck = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sck.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sck.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    sck.sendto(struct.pack('q', 0), (ip, port))
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
    set_clocks(MBED_BROADCAST, MBED_CLOCK_PORT, 0)
    while len(lines):
        line = b''
        wait = 1000
        min_ts = 0
        max_ts = 1000
        for y in range(0, 10):
            if len(lines):
                cmd = lines.pop(0)
                min_ts = min(min_ts, int(cmd.split(',')[-2]))
                max_ts = max(max_ts, int(cmd.split(',')[-2]))
                line += bytes(cmd, 'ascii')
        wait = max_ts - min_ts - 10
        send_cmd(ip, port, line)
        # TODO wait as long as the commands take
        if len(lines):
            time.sleep(wait/1000.0)


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
