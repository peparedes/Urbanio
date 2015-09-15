#!/usr/bin/env python3

# http://python-colormath.readthedocs.org/en/latest/index.html
# USES: scipy.interpolate.interp1d to do the interpolatio
# USES: python-colorpath to do the color conversions."""
# TODO: Use pymunk physics engine to get more complex behavior.
# TODO: Render ColorProfile to PNG
# http://jtauber.com/blog/2008/05/18/creating_gradients_programmatically_in_python/
# shows you how to make a PNG. Essentially don't use 'linear_gradient' and
# 'gradient' and instead make a 'rgb_fun' by creating a wrapper around
# 'interpolate_point'. The wrapper ignores the x axis argument to 'rgb_fun'.


class ColorProfile(object):
    """ Represents a curve of colors through RGB space.

    TODO Optimize by precomputing CIE-LCH points and then only
        interpolating and returning the RGB value in interpolate_points.
    """
    def __init__(self, rgb_list, interpolation_pts):
        """
        rgb_list is a list of RGB 3-tuples of values from 0 to 1 that will
        be interpolated. interpolation_pts is a list of interpolation points
        which must start at 0 and end at 1.
        Linear interpolation occurs in the CIE-LCh colorspace

        See:
        http://howaboutanorange.com/blog/2011/08/10/color_interpolation/
        http://www.stuartdenman.com/improved-color-blending/
        """
        self.rgb_list = rgb_list
        self.interpolation_pts = interpolation_pts

    def interpolate_point(self, pt):
        """Returns the RGB value at point pt."""
        # INCOMPLETE
        return (0.0, 0.0, 0.0)

    def interpolate_profiles(self, other_profile, other_scale=1.0,
                             other_offset=0.0):
        """Combine this profile and another profile.
        other_scale and other_offset are the relative scale and offset of
        the other color profile.
        If other is supposed to be twice the length of this profile and when
        scaled starts half-way before this profile then
        other_scale = 2 and other_offset =-.5
        """
        # INCOMPLETE
        return ColorProfile([(0.0, 0.0, 0.0), (1.0, 1.0, 1.0)], [0.0, 1.0])

    def add_point(self, rgb, pt, weight=1.0):
        """Add an rgb tuble and point into the profile.
        If weight=1.0 then the color is replaced.
        Otherwise, the new color is blended with the given weight
        out of total of 1.0.
        """
        # INCOMPLETE
        return None

    def render(self, file):
        """Renders profile to a PNG."""
        # INCOMPLETE
        pass


class Puck(object):
    def __init__(self, position, mass, velocity, acceleration, color_profile,
                 length=1, offset=0, solid=False):
        """Position in specified in m by the center of the puck.
        Mass is specified in kg.
        Velocity in m/s.
        Acceleration is in m/s^2.
        color_profile is a ColorProfile object
        length is the length in meters.
        offset is the relative location of the puck from position.
        If the offset is 2m then the center of the puck is 2m after the
        position.
        If solid=True the puck can collide with other solid pucks and objects.

        Collisions are completely elastic.
        """
        self.mass = mass
        self.velocity = velocity
        self.acceleration = acceleration
        self.color_profile = color_profile
        self.length = length
        self.offset = offset
        self.solid = False

    def apply_force(self, force):
        self.acceleration = self.force/self.mass
        return None

    def apply_acceleration(self, accleration):
        self.acceleration += accleration
        return None

    def new_velocity(u1, u2, m1, m2):
        return (u1*(m1-m2) + 2*m2*u2)/(m1+m2)

    def get_endpoints(self):
        return (self.position - self.length/2 + self.offset,
                self.position + self.length/2 + self.offset)

    def is_colliding(self, other):
        """returns True if the pucks actually collided.
        Assumes finite mass.
        """
        collided = False
        if self.solid and other.solid:
            ss, se = self.get_endpoints()
            os, oe = other.get_endpoints()
            collided = (os <= ss <= oe) or (os <= se <= oe)
            collided = collided or (ss <= os <= se) or (ss <= oe <= se)
        return collided

    def hit(self, other):
        """Applies elastic collision to both pucks.
        TODO change the puck positions to  make sure that the pucks are no
        longer on top of each other after acceleration is applied. Otherwise
        the pucks will keep on accelerating until they are past each other.
        The simulation resolution should be small enough to avoid seeing
        a big jump.
        """
        v1 = self.new_velocity(self.velocity, other.velocity,
                               self.mass, other.mass)
        v2 = self.new_velocity(other.velocity, self.velocity,
                               other.mass, self.mass)
        self.velocity = v1
        other.velocity = v2

    def intersection(self, other):
        """Returns the start and stop points that other interesects with self.
        In self's coordinate system.
        """
        # INCOMPLETE
        return (0.0, 1.0)

    def intersection_global(self, other):
        """Returns the start and stop points that other intersects with self.
        In the global coordinate system.
        """
        # INCOMPLETE
        return (0.0, 1.0)
