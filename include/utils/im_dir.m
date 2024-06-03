function [dir_map] = im_dir(bw, els, patch_size)

    if nargin == 2
        patch_size = 4;
    end
	
	dir_map = zeros(size(bw));
	dir_map(:) = NaN;
	
	for m = 1 : length(els)
		help_pnts = els{m};
		help_len  = size(help_pnts, 1);
		for n = 1 : help_len
%             cur_r = help_pnts( n, 1 );
%             cur_c = help_pnts( n, 2 );
%             dir_map( cur_r, cur_c ) = curvature( help_pnts, n,
%             patch_size);
            
            
			cur = help_pnts(n, :);
            cur_y = cur(:, 1);
            cur_x = cur(:, 2);
			neib = help_pnts( max(1, n-patch_size):min(help_len, n+patch_size), : );
			neib_y = neib(:, 1);
			neib_x = neib(:, 2);
			
            y = neib_y - cur_y;
            x = neib_x - cur_x;
			
			u = sum( x.*y );
			v = sum( x.^2 );
			if (u == 0 && v == 0)
			 	dir_map(cur_y, cur_x) = pi/2;
			else
				k = u / (v+eps);
				dir_map(cur_y, cur_x) = atan(k);
            end
            
            
            
		end
    end
	
    if 0
        figure, imshow(~bw);
        hold on;
        for m = 1:length(els)
            help_pnts = els{m};
            help_len  = size(help_pnts, 1);
            for n = 1:3:help_len
                y = help_pnts(n,1);
                x = help_pnts(n,2);
                a = dir_map(y, x);
                plot( [x, x+4*cos(a)], [y,y+4*sin(a)], '-r' );
            end
        end
    end
    
    
    