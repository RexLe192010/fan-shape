function [dir_map] = im_dir2(bw, els, s)

    if nargin == 2
        s = 4;
    end
	
	dir_map = zeros(size(bw));
	dir_map(:) = NaN;
	
	for m = 1 : length(els)
		pnts = els{m};
		len  = size(pnts, 1);
		pnts = [pnts; pnts];
		
		dif = pnts( 1+s:len+s, : ) - pnts(1:len, :);
		k   = dif(:,1) ./ (dif(:,2)+eps);
		dir_map( sub2ind(size(bw), pnts(1:len,1), pnts(1:len,2)) ) = atan(k);
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
    
    
    