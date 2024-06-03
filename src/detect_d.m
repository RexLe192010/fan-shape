


function [det, info] = detect_d(gray, edgemap, dirmap, para, model)

resol     = para.resol;
Ss        = para.Ss;
nms       = para.nms;
t1        = para.t1;
t2        = para.t2;
t3        = para.t3;
miss_rate = para.miss_rate;
w         = para.w;

sz         = size(edgemap);
row_sample = 1:resol:sz(1);
col_sample = 1:resol:sz(2);
score_map  = zeros( length(row_sample), length(col_sample) );
cnt_map    = cell( length(row_sample), length(col_sample) );

% for speed
cnt_d   = model.cnt_d;
cnt_sd  = model.cnt_sd;

cnt_dir = model.cnt_dir;
cnt_con = model.cnt_con;
cnt_std = model.cnt_std;

ray_dir = model.ray_dir;
ray_con = model.ray_con;
ray_std = model.ray_std;
lutab   = model.lutab;


R = max(Ss);
edind = find(edgemap(:) > 0);
[edr, edc] = ind2sub( sz, edind );
dirs = dirmap( edind );

cnts0  = cell(1, length(Ss));
for i = 1:length(Ss)
    cnts0{i} = zeros( length(cnt_d), 2 );
end

[d_tt, d_sc] = nn_classifier_d(gray, edgemap, model, para.knn, para.t_sigma, para.s_sigma);

% p2_map: von Mises probabilty estimation for edge orientation
d_local = cell(1, length(cnt_dir));
for k = 1:length(cnt_dir)
    d_or = circ_dist_( dirs*2, cnt_dir(k) );     
    d_or = d_or / cnt_std(k);
    
    d_local{k} = d_tt{k}'*w(1) + d_sc{k}'*w(2) + d_or*w(3);
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
        
        off = [ r_in-rc, c_in-cc ];
        dis = sqrt( off(:,1).^2 + off(:,2).^2 );
        theta = atan2( off(:,1), ( off(:,2)+eps ) );        % angle of ray
               
        hists = ones( length(cnt_d), length(Ss) );
        cnts  = cnts0;
        
        miss_on_scale = zeros(1, length(Ss) );
        for k = 1:length(cnt_d)
            d1 = d_local{k}( inind );
            
            d2 = circ_dist_( ray_dir(k), theta );
            d2 = d2 / ray_std(k);
            
            d12 = d1 + d2*w(4);
            
            can_ind = find( d12 < t1 );
            if isempty(can_ind)
                continue;
            end
            
            for m = 1:length(Ss)   % for differents scales
                if miss_on_scale(m) < miss_rate
                    d3 = abs( dis(can_ind)/Ss(m) - cnt_d(k) );
                    d3 = d3 / cnt_sd(k);

                    d123 = d12(can_ind) + d3*w(5);
                    [mind, mini] = min(d123);
                    if mind < t2
                        hists( k, m ) = mind;
                        cnts{m}(k, :) = [ r_in(can_ind(mini)), c_in(can_ind(mini)) ];
                    else
                        miss_on_scale(m) = miss_on_scale(m) + 1/length(cnt_d);
                    end
                end
            end
        end
        
        d_scale = mean( hists, 1 );
        
        % estimate the scale factor
        [minv, mini] = min(d_scale);     
        
        score_map(i,j) = exp(-minv);
        cnt_map{i,j} = cnts{mini};
        
    end
end

if max(score_map(:)) == 0
    det = [];
    info = [];
    return;
end

[lmr, lmc] = nonmaxsuppts(score_map, nms, min(t3*max(score_map(:))) );  
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


