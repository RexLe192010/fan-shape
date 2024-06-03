function r = circ_dist_( x, y )

r = abs(x - y);
r = min( 2*pi-r, r );