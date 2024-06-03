


function [det, info] = inference(gray, edgemap, dirmap, para, model)

resol     = para.resol;
Ss        = para.Ss;
nms       = para.nms;
t1        = para.t1;
t2        = para.t2;
t3        = para.t3;
miss_rate = para.miss_rate;

sz         = size(edgemap);
row_sample = 1:resol:sz(1);     % row_sample = 430:8:600;
col_sample = 1:resol:sz(2);     % col_sample = 420:8:600; % for debug
score_map  = zeros( length(row_sample), length(col_sample) );
cnt_map    = cell( length(row_sample), length(col_sample) );
score2_map = cell( length(row_sample), length(col_sample) );

% for speed
cnt_d   = single(model.cnt_d);
cnt_sd  = single(model.cnt_sd);

cnt_dir = single(model.cnt_dir);
cnt_con = model.cnt_con;
cnt_std = model.cnt_std;

ray_dir = model.ray_dir;
ray_con = model.ray_con;
ray_std = model.ray_std;
lutab   = single(model.lutab);

neib_dm = model.neib_dm;
neib_am = model.neib_am;


R = max(Ss);
% n_exist = round( length(cnt_d)*(1-miss_rate) );
n_ray  = length(ray_dir);

edind = find(edgemap(:) > 0);
[edr, edc] = ind2sub( sz, edind );
dirs = dirmap( edind );

cnts0  = cell(1, length(Ss));
for i = 1:length(Ss)
    cnts0{i} = zeros( length(cnt_d), 2 );
end

if para.sift
    ttpros = nn_classifier(gray, edgemap, model, para.knn, para.tt_sigma);
end
if para.sc
    scpros = nn_classifier_sc( edgemap, model, para.knn, para.sc_sigma);
end

p_local = cell(1, length(cnt_dir));
for k = 1:length(cnt_dir)
    ori_pro = circ_vmpdf( dirs*2, cnt_dir(k), cnt_con(k) );     
    % ori_d = circ_dist_( dirs*2, cnt_dir(k) )/2;
    % ori_pro = normpdf_( ori_d, 0, pi/10 );
    
    help_pro = 1;
    if para.ori == 1
        help_pro = help_pro .* ori_pro';
    end
    if para.sc == 1
        help_pro = help_pro .* scpros{k};
    end
    if para.sift == 1
        help_pro = help_pro .* ttpros{k};
    end
    p_local{k} = help_pro;
end
    

for i = 1:length(row_sample)
    for j = 1:length(col_sample)
        
        rc = row_sample(i);
        cc = col_sample(j);
        
        inind = find( edr>(rc-R) & edr<(rc+R) & edc>(cc-R) & edc<(cc+R) );
        if sum(inind) == 0
            continue;
        end
        
        r_in = edr(inind);
        c_in = edc(inind);
        
        off = single([ r_in-rc, c_in-cc ]);
        dis = sqrt( off(:,1).^2 + off(:,2).^2 );
        theta = atan2( off(:,1), ( off(:,2)+eps ) );        % angle of ray
        itheta = round(theta*180/pi);
        itheta( itheta<=0 ) = itheta( itheta<=0 ) + 360;
               
        hists = zeros( length(cnt_d), length(Ss) );
        pool  = cell( length(cnt_d), length(Ss) );
        
        miss_on_scale = zeros(1, length(Ss) );
        for k = 1:length(cnt_d)
            p1 = lutab( k,  itheta);        
            
            p2 = p_local{k}( inind );
            p12 = p1 .* p2;
            
            can_ind = find( p12 > t1 );
            if isempty(can_ind)
                continue;
            end
            p12 = p12(can_ind);
            can_dis = dis(can_ind);
            
            for m = 1:length(Ss)   % for differents scales
                if miss_on_scale(m) < miss_rate
                    p3 = normpdf_( can_dis, cnt_d(k)*Ss(m), cnt_sd(k)*Ss(m) );   
                    
                    p123 =  p12.* p3';
                    bigi = find( p123 > t2 );
                    if ~isempty(bigi)
                        bigp = p123( bigi );
                        hists(k, m) = max( bigp );                        
                        pool{k, m}  = [ r_in(can_ind(bigi)), c_in(can_ind(bigi)), bigp' ];
                    else
                        miss_on_scale(m) = miss_on_scale(m) + 1/length(cnt_d);
                    end
                end
            end
        end
        
        scale_pro = zeros(1, length(Ss));
        hists( hists(:)==0 ) = t2 * 0.1;
        
        for i_s = 1:size(hists,2)
            help_hist = hists(:,i_s);
            scale_pro(i_s) = nthroot( exp(sum(log(help_hist))), n_ray );
        end
        
        % estimate the scale factor
        [maxp, maxi] = max(scale_pro);     
        
        if maxp > t3
            help_hist = hists(:, maxi);
            detect_ind = find( help_hist > t2 );
            
            final_p = zeros( 1, n_ray );
            final_c = zeros( 3*n_ray, 2 );
            
            for m = 1:length(detect_ind)
                cur_ind = detect_ind(m);
                if m == 1
                    pre_ind = detect_ind(end);
                else
                    pre_ind = detect_ind(m-1);
                end
                if m == length(detect_ind)
                    post_ind = detect_ind(1);
                else
                    post_ind = detect_ind(m+1);
                end
                
                [p12, p1, p2, v1, v2] = part_relation(pool, cur_ind, pre_ind,  maxi, neib_dm, neib_am, Ss(maxi) );
                [p13, p1, p3, v1, v3] = part_relation(pool, cur_ind, post_ind, maxi, neib_dm, neib_am, Ss(maxi) );
                
                p122 = p12 .* repmat(p2', [size(p1), 1] );
                p133 = p13 .* repmat(p3', [size(p1), 1] );
               
                [max_p122, max_pre_ind ] = max( p122, [], 2 );
                [max_p133, max_post_ind] = max( p133, [], 2 );
                
                all_p = max_p122 .* p1 .* max_p133;
                [final_max_p, final_max_i] = max(all_p);
               
                
                final_p(detect_ind(m)) = final_max_p * 1e5;     % 
                final_c(detect_ind(m),:) = v1(final_max_i, 1:2);
                final_c(detect_ind(m)+n_ray,:) = v2(max_pre_ind(final_max_i), 1:2);
                final_c(detect_ind(m)+n_ray*2,:) = v3(max_post_ind(final_max_i), 1:2);
            end
            
            final_p( final_p==0 ) = eps;
            score_map(i,j) = nthroot( exp( sum(log(final_p)) ), n_ray );
            cnt_map{i,j} = final_c;
            score2_map{i,j} = hists(:, maxi);
        end
        
        
    end
end

[lmr, lmc] = nonmaxsuppts(score_map, nms, max(score_map(:))*0.1 );  
if isempty(lmr)
    det = [];
    info = [];
    return;
end

det(length(lmr)) = struct('contour', [], 'score', [], 'center', []);

for i = 1:length(lmr)
    det(i).contour = cnt_map{ lmr(i), lmc(i) };
    det(i).score = score_map( lmr(i), lmc(i) );
    det(i).center = [ row_sample(lmr(i)), col_sample(lmc(i)) ];
end

info.score_map  = score_map;
info.cnt_map    = cnt_map;
info.row_sample = row_sample;
info.col_sample = col_sample;
info.score2_map = score2_map;


function [p12, p1, p2, v1, v2] = part_relation(pool, cur_ind, other_ind, maxi, neib_dm, neib_am, scale)

v1 = pool{cur_ind, maxi};
v2 = pool{other_ind, maxi};
dr = repmat(v1(:,1), [1, size(v2,1)]) - repmat( v2(:,1)', [size(v1, 1), 1] );
dc = repmat(v1(:,2), [1, size(v2,1)]) - repmat( v2(:,2)', [size(v1, 1), 1] );
p1 = v1(:,3);
p2 = v2(:,3);

d12 = sqrt( dr.^2 + dc.^2 );
a12 = atan2( dr, (dc+eps) );

model_d12 = neib_dm( cur_ind, other_ind ) * scale;
model_a12 = neib_am( cur_ind, other_ind );
             
p_d12 = exp( -abs(d12-model_d12)/(model_d12) );

help_da = abs(a12 - model_a12);
help_da = min( help_da, 2*pi-help_da ) / pi;
p_a12 = exp( -help_da  );

p12 = sqrt( p_d12 .* p_a12 );

