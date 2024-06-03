
function cs = contour_curvature( cont, n )

    cs = zeros( size(cont,1), 1 );
    
    for i = 1 : size(cont, 1)
        cs(i) = curvature( cont, i, n );
    end