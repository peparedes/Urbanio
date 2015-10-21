#!/usr/bin/env python3
import socket
import struct
from copy import deepcopy
import time
from entity import *
import sys

MAXBUFSIZE = 5
MAXINCREMENT = 100


class FLNode:
    def __init__(self, ID, ip, port):
        self.ID = ID
        self.ip = ip
        self.port = port
        self.cmd_q = []
        self.wait = 0
        self.next_send = time.time()

    def push(self, cmd):
        self.cmd_q.append(cmd)

    def load_queue(self, lines):
        self.cmd_q = deepcopy(lines)

    def send_chunk(self, size=MAXBUFSIZE):
        lines = self.cmd_q
        t = time.time()
        wait = 1000
        line = b''
        min_ts = 0
        max_ts = 0
        for y in range(0, MAXBUFSIZE):
            if len(lines):
                cmd = lines.pop(0)
                print(cmd)
                ts = int(str(cmd).split(',')[-2])
                min_ts = min(min_ts, ts)
                max_ts = max(max_ts, ts)
                line += cmd
            else:
                break
        wait = max_ts - min_ts - MAXBUFSIZE
        self.send_cmd(line)
        self.wait = wait
        self.next_send = t + wait/1000.0

    def send_cmd(self, cmd):
        sck = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sck.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        sck.sendto(cmd, (self.ip, self.port))
        sck.close()


MANIFEST = {
    1: FLNode(1, '192.168.1.13', 50004),
    2: FLNode(2, '192.168.1.12', 50003),
    3: FLNode(3, '192.168.1.11', 50002),
    4: FLNode(4, '192.168.1.10', 50001)
}

FL1 = MANIFEST[1]
FL2 = MANIFEST[2]
FL3 = MANIFEST[3]
FL4 = MANIFEST[4]

LIGHTMAP = {
    0: [FL1, 1, None],
    1: [FL1, 2, None],
    2: [FL1, 3, None],
    3: [FL1, 4, None],

    4: [FL2, 1, None],
    5: [FL2, 2, None],
    6: [FL2, 3, None],
    7: [FL2, 4, None],

    8: [FL3, 1, None],
    9: [FL3, 2, None],
    10: [FL3, 3, None],
    11: [FL3, 4, None],

    12: [FL4, 1, None],
    13: [FL4, 2, None],
    14: [FL4, 3, None],
    15: [FL4, 4, None]
}


MBED_CLOCK_IP = '192.168.1.10'
MBED_CLOCK_PORT = 49000
MBED_BROADCAST = '192.168.1.255'


# TODO Endianness may be wrong
def set_clocks(ip, port, value):
    sck = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sck.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sck.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    sck.sendto(struct.pack('bq', 1, value), (ip, port))
    sck.close()


def mk_cmd(light, r, g, b, ts):
    return bytes(u'L,{0},{1},{2},{3},{4},'.format(light, r, b, g, ts), 'ascii')


def blink_all(flnode, dur=1000, times=3):
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
    flnode.send_chunk(prog)


def main():
    print(sys.argv)
    select = int(sys.argv[1])
    funcs = [(sine([1, 2]), 8),
             (ran([1, 2]), 10),
             (on, 5),
             (walker([1, 2], speed=1000), 15)
             ]
    func = funcs[select][0]
    run_length = funcs[select][1]

    for k, v in LIGHTMAP.items():
        LIGHTMAP[k][2] = LightFunction(func)
        LIGHTMAP[k][2].update_position(k)
        LIGHTMAP[k][2].update_time(0)
        LIGHTMAP[k][2].increment = MAXINCREMENT

    # add change function
    # need clearq on  nodes
    # add reset lights
    #   clear q and reset parameters
    for t in range(0, 0 + int(run_length*1000/MAXINCREMENT)):
        for k, v in LIGHTMAP.items():
            rgb = v[2].rgb1
            cmd = mk_cmd(v[1], rgb[0], rgb[1], rgb[2], v[2].t1)
            v[0].push(cmd)
            v[2].increment_time()
    set_clocks(MBED_BROADCAST, MBED_CLOCK_PORT, 100000)
    time.sleep(1)
    set_clocks(MBED_BROADCAST, MBED_CLOCK_PORT, 0)
    for x in range(1, 5):
        MANIFEST[x].send_chunk()
    while len(MANIFEST[x].cmd_q):
        for x in range(1, 5):
            MANIFEST[x].send_chunk()
            print(len(MANIFEST[x].cmd_q))
        print('Sleeping: ' + str(MAXINCREMENT*MAXBUFSIZE/1000.0/4))
        time.sleep(MAXINCREMENT*MAXBUFSIZE/1000.0/4)

    # TODO
    # Every 5 ms update light list and push to nodes as commands
    # Every 15 ms send the list to the nodes
    # for x in range(1, 5):
    #    flnode = MANIFEST[x]
    #    flnode.load_queue(lines)
    #    flnode.send_chunk()


if __name__ == "__main__":
    main()
