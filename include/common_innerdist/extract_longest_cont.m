function [cont, all_cont] = extract_longest_cont(im, n_contsamp, id)
	%- Extract contour, count only the longest contours
    [Cs]	= boundary_extract_binary(im);
    
    % n_max	= 0;
    % i_max	= 0;
    % for cc=1:length(Cs)
    %     if size(Cs{cc},2)>n_max
    %         n_max = size(Cs{cc},2);
    %         i_max = cc;
    %     end
    % end
    % cont	= Cs{i_max}';
    
    if nargin == 2
        id = 1;
    end
    
    lens = [];
    for i = 1:length(Cs)
        lens(i) = size( Cs{i}, 2 );
    end
    [lens, IND] = sort( lens, 'descend' );
    cont	= Cs{IND(id)}';
            
    % remove redundant point in contours
    cont		= [cont; cont(1,:)];
    dif_cont	= abs(diff(cont,1,1));
    id_gd		= find(sum(dif_cont,2)>0.001);
    cont		= cont(id_gd,:);
            
    % force the contour to be anti-clockwisecomputed above is at the different orientation
    bClock		= is_clockwise(cont,im);
    if bClock	cont	= flipud(cont);		end
            
    % start from bottom
    [min_v,id]	= min(cont(:,2));
    cont		= circshift(cont,[length(cont)-id+1]);
    
    all_cont = cont;
            
	[XIs,YIs]	= uniform_interp(cont(:,1),cont(:,2),n_contsamp-1);
	cont		= [cont(1,:); [XIs YIs]];
