#!/usr/bin/env python3
import socket
import struct
import numpy as np
from scipy import stats
import time
from entity import *
import threading
import itertools


MAXBUFSIZE = 5
MAXINCREMENT = 80
MBED_CLOCK_PORT = 49000
MBED_BROADCAST = '192.168.1.255'

SET_PROGRAM_CLOCK = 0x01
SET_GLOBAL_CLOCK = 0x02
FLUSH_BUFFER = 0x03
ECHO_MSG = 0x10
LOG_FILE = "log.txt"


def set_clocks(ip, port, value):
    flush_buffer(ip, port)
    time.sleep(.005)
    broadcast_config(ip, port, SET_PROGRAM_CLOCK, value)
    broadcast_config(ip, port, SET_GLOBAL_CLOCK, int(time.time()*1000))


def flush_buffer(ip, port):
    broadcast_config(ip, port, FLUSH_BUFFER)


def echo_message(ip, port, msg):
    msg = msg + '\n'
    broadcast_struct(ip, port, struct.pack('<bs', ECHO_MSG, msg))


# TODO Endianness may be wrong
def broadcast_config(ip, port, cmd, value=0):
    broadcast_struct(ip, port, struct.pack('<bq', cmd, value))


def broadcast_struct(ip, port, payload):
    sck = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sck.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sck.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    sck.sendto(payload, (ip, port))
    sck.close()


def mk_cmd(light, r, g, b, ts):
    return bytes(u'L,{0},{1},{2},{3},{4},'.format(light, r, b, g, ts), 'ascii')


class FLNode:
    def __init__(self, ID, ip, port):
        self.ID = ID
        self.ip = ip
        self.port = port
        self.cmd_q = []
        self.wait = 0
        self.next_send = time.time()
        self.rec_fmt = struct.Struct('15s 64f f 4H q')
        self.pos_values = []
        self.temp_receiver = None
        self.sck = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.sck.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.sck.bind(('', self.port))

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
                # print(cmd)
                parts = str(cmd).split(',')
                ts = int(parts[-2])
                min_ts = min(min_ts, ts)
                max_ts = max(max_ts, ts)
                line += cmd
            else:
                break
        wait = max_ts - min_ts - MAXBUFSIZE
        self.send_cmd(line)
        # print(line)
        self.wait = wait
        self.next_send = t + wait/1000.0

    def send_cmd(self, cmd):
        with open(LOG_FILE, 'a') as f:
            f.write(",".join([str(self.ID), self.ip, str(cmd) + '\n']))
        sck = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sck.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        sck.sendto(cmd, (self.ip, self.port))
        sck.close()

    def recv_cmd(self):
        data, address = self.sck.recvfrom(296)
        uData = self.rec_fmt.unpack(data)
        tempImage = np.asarray(uData[1:65])
        tSamp = uData[70]
        tempImageMat = np.reshape(tempImage, (16, 4))
        tempRow = tempImageMat.sum(axis=1)/4

        tempRowSq = tempRow**2
        # Select a threshold as a percentace above the RMS value
        tempRms = np.sqrt(tempRowSq.sum()/tempRow.size)
        threshold = tempRms*1.06

        # Binarizing the signal (0=no reading, 1=person detected)
        defaultVals = stats.threshold(tempRow, threshmin=threshold, newval=0)
        defaultVals = stats.threshold(defaultVals, threshmax=threshold,
                                    newval=1)
        # print(defaultVals)
        span = 3.2  # Width of sensed floor
        # print(defaultVals)
        values = np.dot([i for i, x in enumerate(defaultVals) if x == 1],
                        span/15)
        self.pos_values.append((tSamp, defaultVals))
        if len(self.pos_values) > 100:
            self.pos_values.pop(0)

    def start_listening(self):
        def rec():
            while True:
                # print(self.pos_values)
                self.recv_cmd()
        self.temp_receiver = threading.Thread(target=rec)
        self.temp_receiver.start()

