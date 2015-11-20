#!/usr/bin/env python3
import time
from entity import *
import sys
from nodeprotocol import *

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

for node in MANIFEST.values():
    node.start_listening()

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


def main():
    print(sys.argv)
    select = int(sys.argv[1])
    funcs = [(sine([1, 2]), 8),
             (ran([1, 2]), 10),
             (on, 5),
             (walker([1, 2], speed=300), 15)
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

if __name__ == "__main__":
    main()
