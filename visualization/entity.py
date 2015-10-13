#!/usr/bin/env python3
# -*- coding: ascii -*-
import math


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
        self.camera_pos = 0

    def get_point(self, p):
        return self.rgb

    def update_time(self, t2):
        while self.t1 < t2:
            self.increment_time()

    def update_velocity(self, v):
        self.v0 = self.v1
        self.v1 = v

    def update_position(self, pos):
        self.pos0 = self.pos1
        self.pos1 = pos

    def increment_time(self):
        self.t0 = self.t1
        self.t1 += self.increment
        self.update()

    def update(self):
        pass


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


def walker(channel=0):

    def wk(le):
        rgb = [0, 0, 0]
        diff = math.floor((1-abs(le.pos1 - le.t1/1000.0))*1024)
        diff = max(diff, 0)
        diff = min(diff, 255)
        rgb[channel] = diff
        return rgb

    return wk


def sine(channels=[0]):
    def fun(le):
        rgb = [0, 0, 0]
        diff = math.floor(math.sin(le.t1/1000.0 + (le.pos1/le.length))*255)
        diff = max(diff, 0)
        diff = min(diff, 255)
        for channel in channels:
            rgb[channel] = diff
        return rgb

    return fun
