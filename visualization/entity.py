#!/usr/bin/env python3
# -*- coding: ascii -*-


class LightEntity:
    def __init__(self):
        self.t0 = 0
        self.t1 = 0
        self.v0 = 0
        self.v1 = 0
        self.detected = False
        self.rgb0 = [0, 0, 0]
        self.rgb1 = [0, 0, 0]
        self.length = 0
        self.increment = 5

    def get_point(self, p):
        return self.rgb

    def update_time(self, t2):
        while self.t1 < t2:
            self.increment_time()

    def update_velocity(self, v):
        self.v0 = self.v1
        self.v1 = v

    def increment_time(self):
        self.t0 = self.t1
        self.t1 += self.increment
        self.update()

    def update(self, pos):
        self.pos = pos


class LightFunction(LightEntity):
    def __init__(self, formula):
        self.formula = formula
        super(LightFunction, self).__init__()

    def update(self, pos):
        super(LightFunction, self).update(pos)
        self.rgb0 = self.rgb1
        self.rgb1 = self.formula(self)
