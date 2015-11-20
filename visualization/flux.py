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
             (walker([1, 2], speed=300), 30),
             (tracker([1, 2], .5), 30),
             (onwper(), 60),
             (ranwper([1, 2]), 60),
             ]
    func = funcs[select][0]
    run_length = funcs[select][1]

    for k, v in LIGHTMAP.items():
        LIGHTMAP[k][2] = LightFunction(func)
        LIGHTMAP[k][2].update_position(k)
        LIGHTMAP[k][2].set_viewer(k)
        LIGHTMAP[k][2].update_time(0)
        LIGHTMAP[k][2].increment = MAXINCREMENT

    set_clocks(MBED_BROADCAST, MBED_CLOCK_PORT, 0)
    start_t = time.time()*1000
    while (time.time()*1000 - start_t) < 1000*run_length:
        increment = 128
        ahead = 2
        future_t = time.time() + increment*ahead/1000.0
        velocity, position = motion_calculator(MANIFEST)
        for x in range(0, ahead):
            for k, v in LIGHTMAP.items():
                # position = (time.time()*1000 - start_t)/1000
                v[2].update_position(position)
                v[2].update_time(int(time.time()*1000 - start_t + x*increment))
                v[2].update()
                rgb = v[2].rgb1
                cmd = mk_cmd(v[1], rgb[0], rgb[1], rgb[2], v[2].t1)
                v[0].push(cmd)
        while len(MANIFEST[x].cmd_q):
            for x in range(1, 5):
                MANIFEST[x].send_chunk()
        sleep_time = future_t - time.time()  # + increment/1000*ahead
        if sleep_time > 0:
            time.sleep(sleep_time)
        else:
            print("falling behind by:{}".format((sleep_time,)))

def motion_calculator(manifest):
    # return #(time.time()*1000-0)/1000
    velocity = 0
    position = 0
    positionPrior = 0
    prior = []
    present = []
    globalList = []
    for k, v in manifest.items():
        print(k)
        if len(v.pos_values):
            globalList.append(list(zip(*v.pos_values))[1])
    # print(globalList)
    newList = list(zip(*globalList))
    # print(newList)
    if len(newList) > 1:
        for x in newList[-1]:
            present.extend(x)
        for x in newList[-2]:
            prior.extend(x)
        prior = np.asarray(prior)
        present = np.asarray(present)
        # print(prior)
        if present.sum() > 1 or prior.sum() > 1:
            indexes = [i for i, x in enumerate(list(present)) if x == 1]
            indexesPrior = [i for i, x in enumerate(list(prior)) if x == 1]
            # print(indexes)
            pairs = list(np.asarray(indexes[1:]) -
                         np.asarray(indexes[0:len(indexes)-1]))
            pairsPrior = list(np.asarray(indexesPrior[1:]) -
                              np.asarray(indexesPrior[0:len(indexesPrior)-1]))
            print(pairs)
            if 1 in pairs or 1 in pairsPrior:
                if 1 in pairs:
                    position = indexes[pairs.index(1)]/4
                elif 1 in pairsPrior:
                    positionPrior = indexesPrior[pairsPrior.index(1)]/4
                    position = positionPrior
                print(position)
                print(positionPrior)
            print(present)
            print(prior)

    return velocity, position

if __name__ == "__main__":
    main()
