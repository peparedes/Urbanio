#!/usr/bin/env python
import sys, pygame
import time
pygame.init()

size = width, height = 1200, 150
black = 0, 0, 0

screen = pygame.display.set_mode(size)

FPS = 60
PERS = int(1000*1.0/FPS)

class bball(object):

    def __init__(self):
        self.vel = [60/FPS, 0]
        self.dev = [0, 0]
        self.ball = pygame.image.load('ball.gif')
        self.ballrect = self.ball.get_rect()
        self.ballrect = self.ballrect.move([0,height/4])
        self.ball.set_alpha(127)

    def next(self):
        self.dev = [self.dev[0] + self.vel[0], self.dev[1] + self.vel[1]]
        if (self.ballrect.left < 0 and self.vel[0] < 0) or (self.ballrect.right > width and self.vel[0] > 0):
            self.vel = [-self.vel[0],self.vel[1]]
        if (self.ballrect.top < 0 and self.vel[1] < 0) or (self.ballrect.bottom > height and self.vel[1] > 0) :
            self.vel = [self.vel[0],-self.vel[1]]
        incr = [int(self.dev[0]), int(self.dev[1])]
        self.dev[0] -= int(self.dev[0])
        self.dev[1] -= int(self.dev[1])
        self.ballrect = self.ballrect.move(incr)


balls = [bball() for x in range(1,10) ]


while 1:
    s1 = time.time()
    for event in pygame.event.get():
        if event.type == pygame.QUIT: sys.exit()

    screen.fill(black)
    for b in balls:
        screen.blit(b.ball, b.ballrect)
        b.next()
    pygame.display.flip()
    s2 = time.time()
    s3 = s2 - s1
    if s3 > 0 and s3 < PERS/1000.0:
        time.sleep(PERS/1000.0-s3)

