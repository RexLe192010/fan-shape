


function [det, info] = detect_app(gray, edgemap, dirmap, para, model)

resol     = para.resol;
Ss        = para.Ss;
nms       = para.nms;
t1        = para.t1;
t2        = para.t2;
t3        = para.t3;
miss_rate = para.miss_rate;
maxs      = para.maxs;

sz         = size(edgemap);
row_sample = 1:resol:sz(1);
col_sample = 1:resol:sz(2);
score_map  = zeros( length(row_sample), length(col_sample) );
cnt_map    = cell( length(row_sample), length(col_sample) );
score2_map = cell( length(row_sample), length(col_sample) );

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


if para.sift
    ttpros = nn_classifier(gray, edgemap, model, para.knn, para.tt_sigma);
end
if para.sc
    scpros = nn_classifier_sc( edgemap, model, para.knn, para.sc_sigma);
end

p_local = cell(1, length(cnt_dir));
for k = 1:length(cnt_dir)
    ori_pro = circ_vmpdf( dirs*2, cnt_dir(k), cnt_con(k) );     
    
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
        
        off = [ r_in-rc, c_in-cc ];
        dis = sqrt( off(:,1).^2 + off(:,2).^2 );
        theta = atan2( off(:,1), ( off(:,2)+eps ) );        % angle of ray
        itheta = round(theta*180/pi);
        itheta( itheta<=0 ) = itheta( itheta<=0 ) + 360;
               
        hists = zeros( length(cnt_d), maxs );
        cnts  = zeros( length(cnt_d), maxs );
        
        % miss_on_scale = zeros(1, length(Ss) );
        for k = 1:length(cnt_d)
            p1 = lutab( k,  itheta);        
            
            % d1 = circ_dist_( ray_dir(k), theta );
            % p1 = d1 < (ray_std(k)*1.5);
            
            p2 = p_local{k}( inind );
            p12 = p1 .* p2;
            
            can_ind = find( p12 > t1 );     % can_ind is the relative index of inind
            if isempty(can_ind)
                continue;
            end
            p12 = p12(can_ind);
            can_dis = dis(can_ind);
            
            for m = 1:length(can_dis)
                cur_d = can_dis(m);
                min_s = round( cur_d / (cnt_d(k)+2*cnt_sd(k)) );
                max_s = round( cur_d / (cnt_d(k)-2*cnt_sd(k)) );
                ind_s = max(1,min_s):1:min(maxs,max_s);
                
                if ~isempty(ind_s)
                    d3    = cur_d ./ ind_s;
                    p3    = normpdf_( d3, cnt_d(k), cnt_sd(k));   
                    p123  = p12(m) .* p3;

                    rp_ind = find( (p123 - hists(k,ind_s)) > 0 );
                    hists(k,ind_s(rp_ind)) = p123(rp_ind);
                    cnts(k, ind_s(rp_ind)) = can_ind(m);
                end
            end
        end
        
        scale_pro = zeros(1, length(Ss));
        for i_s = 1:size(hists,2)
            help_hist = hists(:,i_s);
            help_hist2 = help_hist( help_hist>0 );
            if ~isempty(help_hist2)
                scale_pro(i_s) = sum( log(help_hist2) );
            else
                scale_pro(i_s) = -inf;
            end
        end
        
        % estimate the scale factor
        [maxv, maxi] = max(scale_pro);     
        
        score_map(i,j) = nthroot( exp(maxv), 100);
        score2_map{i,j} = hists(:, maxi);
        

        cnt_ind = cnts(:, maxi);
        cnt_ind = cnt_ind( cnt_ind>0 );
        cnt_map{i,j} = [r_in(cnt_ind), c_in(cnt_ind)];

        
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
info.score2_map = score2_map;


