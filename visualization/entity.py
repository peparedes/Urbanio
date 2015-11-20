#!/usr/bin/env python3
# -*- coding: ascii -*-
import math
from random import Random

RANDOM_SRC = Random()


class LightEntity:
    def __init__(self):
        self.t0 = 0
        self.t1 = 0
        self.v0 = 0
        self.v1 = 0
        self.detected = False
        self.rgb0 = [0, 0, 0]
        self.rgb1 = [0, 0, 0]
        self.length = 16
        self.increment = 5
        self.pos0 = 0
        self.pos1 = 0
        self.viewer_pos = 0

    def get_point(self, p):
        return self.rgb

    def update_time(self, t2):
        self.t0 = self.t1
        self.t1 = t2

    def update_velocity(self, v):
        self.v0 = self.v1
        self.v1 = v

    def update_position(self, pos):
        self.pos0 = self.pos1
        self.pos1 = pos

    def set_viewer(self, pos):
        self.viewer_pos = pos

    def increment_time(self):
        self.t0 = self.t1
        self.t1 += self.increment
        self.update()

    def update(self):
        pass

    def reset_time(self):
        self.t1 = 0
        self.t0 = 0


class LightFunction(LightEntity):
    def __init__(self, formula):
        self.formula = formula
        super(LightFunction, self).__init__()

    def update(self):
        super(LightFunction, self).update()
        self.rgb0 = self.rgb1
        self.rgb1 = self.formula(self)


def on(channel=0):
    return [255, 255, 255]


def tracker(channels=None, shape=.5):
    if channels is None:
        channels = [0]

    def tk(le):
        rgb = [0, 0, 0]
        diff = round((1-abs((le.viewer_pos - le.pos1)/self.length*shape)**2)*255)
        diff = max(diff, 0)
        diff = min(diff, 255)
        for channel in channels:
            rgb[channel] = diff
        return rgb

    return tk


def walker(channels=None, shape=.5, speed=1200.0, reverse=False):
    if channels is None:
        channels = [0]

    def wk(le):
        rgb = [0, 0, 0]
        fade = True
        if fade:
            diff = round((1-shape*abs(le.pos1 - le.t1/float(speed)))*255)
            if reverse:
                diff = round((1-abs(le.pos1 - le.t1/float(speed)))*255)
        else:
            if (1-abs(le.pos1 - le.t1/speed)) >= shape:
                diff = 255
            else:
                diff = 0
        diff = max(diff, 0)
        diff = min(diff, 255)
        for channel in channels:
            rgb[channel] = diff
        return rgb

    return wk


def sine(channels=None, shape=.5):
    if channels is None:
        channels = [0]

    def fun(le):
        rgb = [0, 0, 0]
        diff = math.floor(math.sin((le.t1/(1000.0*shape)) +
                                   (le.pos1/le.length))*255)
        diff = max(diff, 0)
        diff = min(diff, 255)
        for channel in channels:
            rgb[channel] = diff
        return rgb

    return fun


def ran(channels=None, minn=0, maxx=255, per_channel=True, delay=1000):
    if channels is None:
        channels = [0]

    def fun(le):

        rgb = [0, 0, 0]
        intensity = RANDOM_SRC.randint(minn, maxx)
        for channel in channels:
            rgb[channel] = intensity
            if per_channel:
                intensity = RANDOM_SRC.randint(minn, maxx)
        if (le.t1 % delay) < 20:
            rgb_out = []
            for pt1, pt2 in zip(rgb, le.rgb1):
                rgb_out.append(math.floor(((pt1+pt2)/2)))

            return rgb_out
        else:
            return le.rgb1

    return fun
