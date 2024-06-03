
function minc = match_two_rays(rays1, rays2, para)

if nargin == 0
    im1 = imread('..\train_images\bot\1.bmp');
    im2 = imread('..\train_images\bot\3.bmp');
    n_contsamp = 100;
    dir_patchsize = 4;
    rays1 = extr_ray_local_feats(im1, n_contsamp, dir_patchsize);
    rays2 = extr_ray_local_feats(im2, n_contsamp, dir_patchsize);
end


n_contsamp = para.n_contsamp;
lambda     = para.wgt;
thre	   = para.dp_thre;
    
n_search = round(sqrt(1));
r_search = 0.45;
num_start	= round(n_contsamp);
search_step	= 1;
    
refp1 = candidate_reference_points(rays1.cntr, n_search, r_search);
refp2 = candidate_reference_points(rays2.cntr, n_search, r_search);

mcm = zeros( size(refp1,1), size(refp2,1) );
minc = inf;

cm_alpha = abs( repmat(rays1.alpha, [1, n_contsamp]) - repmat(rays2.alpha', [n_contsamp, 1]) );
cm_alpha = min( cm_alpha, pi-cm_alpha ) / (pi/2) ;

for i = 1:size(refp1,1)
    for j = 1:size(refp2,1)
        p1 = refp1(i, :);
        p2 = refp2(j, :);
        
        off1 = rays1.cntr - repmat( p1, [n_contsamp, 1] );
        off2 = rays2.cntr - repmat( p2, [n_contsamp, 1] );
        
        d1 = sqrt( sum(off1.^2,2) );
        d2 = sqrt( sum(off2.^2,2) );
        d1 = d1 / mean(d1);                 % normalize
        d2 = d2 / mean(d2);
        
        theta1 = atan2( off1(:,2), off1(:,1)+eps );
        theta2 = atan2( off2(:,2), off2(:,1)+eps );
        
        % cost mat for distance
        d1rep = repmat(d1, [1, n_contsamp]);
        d2rep = repmat(d2', [n_contsamp, 1]);
        cm_d     = abs( d1rep-d2rep );
        cm_theta = abs( circ_dist( repmat(theta1, [1, n_contsamp]), repmat(theta2', [n_contsamp, 1]) ) ) / pi ;
        
        cm = ( cm_alpha*lambda(1) + cm_d*lambda(2) + cm_theta*lambda(3) ) / sum(lambda);
        
        
        [cvec, match_cost]	= DPMatching_C(cm, thre, num_start, search_step);
        
        
        mcm(i,j) = match_cost;
        if match_cost  < minc
            minc = match_cost;
            matc  = cvec;
            
            rays1.d = d1;
            rays1.theta = theta1;
            rays1.refp = p1;
            
            rays2.d = d2;
            rays2.theta = theta2;
            rays2.refp = p2;
        end
    end
end

if nargout == 0
    %-- display correspondence
    id_gd1		= find(matc <= n_contsamp);
    id_gd2		= matc(id_gd1);
    pt_from		= rays1.cntr(id_gd1,:);
    pt_to		= rays2.cntr(id_gd2,:);
    n_match		= length(pt_from);
    
    figure(101); clf;	hold on; set(101,'color','w');
    step = 3;
    roff = 200;
    
    plot([pt_from(1:step:end,1) pt_to(1:step:end,1)+roff]', ...
         [pt_from(1:step:end,2) pt_to(1:step:end,2)]', '+--',...
         'linewidth',.5);
    
    plot(rays1.cntr(:,1), rays1.cntr(:,2),'k-', ...
         rays2.cntr(:,1)+roff, rays2.cntr(:,2),'k-',...
        'linewidth',.5);
    
    plot( rays1.refp(1), rays1.refp(2), '*r' );
    plot( rays2.refp(1)+roff, rays2.refp(2), '*r' );
    
    sTitle	= ['#match=' i2s(n_match) ' cost=' num2str(match_cost)];
    title(sTitle);
    axis equal;	axis ij; axis off;    
end






