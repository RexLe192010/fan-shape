
function [sc_map, bw2] = im_sc(bw, is_norm)
    if nargin == 1
        is_norm = 1;
    end
	
	edgelist = imlink(bw);
	sc_map0 = cell(size(bw,1), size(bw,2) );
    bw2 = zeros( size(bw) );
	
	for n = 1:length(edgelist)
		pnts = edgelist{n};
		for k = 1:size(pnts, 1)
           
                pnt = pnts(k, :);
                hist = sc_hist(pnt, pnts);
                sc_map0{pnt(1), pnt(2)} = [hist(:)+0]';
   
		end
    end
    
    ind = find( bw(:) > 0 );
    ref = zeros( size(bw) );
    ref(ind) = 1:length(ind);		% map edge index to it's feature index in the feature array
    sc_map.ref = ref;
    
    
    sc_map.fea = zeros( length(ind), 0, 'single' );
    for i = 1:length(ind)
        help_v = sc_map0{ind(i)};
        if is_norm
            % help_v = help_v / (sqrt(sum(help_v.^2))+eps);
            help_v = help_v / (sum(help_v)+eps);
            sc_map.fea(i, 1:length(help_v) ) = help_v;
        end
    end