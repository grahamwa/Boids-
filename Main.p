Author: GRAHAM

import pygame
import random
import math

pygame.init()
WIDTH, HEIGHT = 500, 500
screen = pygame.display.set_mode((WIDTH, HEIGHT))
clock = pygame.time.Clock()

WHITE = (255, 255, 255)
BLACK = (0, 0, 0)

NUM_BOIDS = 50
MAX_SPEED = 5
BOID_RADIUS = 5
BOID_VISION_RADIUS = 50
SEPARATION_DISTANCE = 20
ALIGNMENT_DISTANCE = 50
COHESION_DISTANCE = 50
MIN_DISTANCE = 10

class Boid:
    def __init__(self):
        self.x = random.randint(0, WIDTH)
        self.y = random.randint(0, HEIGHT)
        self.vx = random.uniform(-1, 1)
        self.vy = random.uniform(-1, 1)

    def update(self, boids):
        avg_velocity = [0, 0]
        separation = [0, 0]
        cohesion = [0, 0]
        num_neighbors = 0
        turnfactor = 0.2

        for boid in boids:
            if boid != self:
                distance = math.sqrt((self.x - boid.x) ** 2 + (self.y - boid.y) ** 2)

                if distance < BOID_VISION_RADIUS:
                    num_neighbors += 1
                    if distance < SEPARATION_DISTANCE:
                        separation[0] += (self.x - boid.x)
                        separation[1] += (self.y - boid.y)
                    if distance < ALIGNMENT_DISTANCE:
                        avg_velocity[0] += boid.vx
                        avg_velocity[1] += boid.vy
                    if distance < COHESION_DISTANCE:
                        cohesion[0] += boid.x
                        cohesion[1] += boid.y

        if num_neighbors > 0:
            avg_velocity[0] /= num_neighbors
            avg_velocity[1] /= num_neighbors
            cohesion[0] /= num_neighbors
            cohesion[1] /= num_neighbors

            self.vx += avg_velocity[0] * 0.01
            self.vy += avg_velocity[1] * 0.01
            self.vx += (cohesion[0] - self.x) * 0.01
            self.vy += (cohesion[1] - self.y) * 0.01
            self.vx -= separation[0] * 0.01
            self.vy -= separation[1] * 0.01

        speed = math.sqrt(self.vx ** 2 + self.vy ** 2)
        if speed > MAX_SPEED:
            scale_factor = MAX_SPEED / speed
            self.vx *= scale_factor
            self.vy *= scale_factor

        self.x += self.vx
        self.y += self.vy

        if self.x < 0 or self.x > WIDTH:
            self.vx *= -1
            self.vx += turnfactor if self.x < 0 else -turnfactor
        if self.y < 0 or self.y > HEIGHT:
            self.vy *= -1
            self.vy += turnfactor if self.y < 0 else -turnfactor

    def draw(self):
        pygame.draw.circle(screen, WHITE, (int(self.x), int(self.y)), BOID_RADIUS)

boids = [Boid() for _ in range(NUM_BOIDS)]

running = True
while running:
    screen.fill(BLACK)

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

    for boid in boids:
        boid.update(boids)
        boid.draw()

    for i in range(len(boids)):
        for j in range(i + 1, len(boids)):
            dx = boids[i].x - boids[j].x
            dy = boids[i].y - boids[j].y
            dist = math.sqrt(dx ** 2 + dy ** 2)
            if dist < MIN_DISTANCE:
                angle = math.atan2(dy, dx)
                overlap = MIN_DISTANCE - dist
                boids[i].x += overlap * math.cos(angle)
                boids[i].y += overlap * math.sin(angle)
                boids[j].x -= overlap * math.cos(angle)
                boids[j].y -= overlap * math.sin(angle)

    pygame.display.flip()
    clock.tick(60)

pygame.quit()
