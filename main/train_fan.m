function train_fan

addpath('include\CircStat2010e\');
addpath('include\common_innerdist\');
addpath('include\dsift\');
addpath('include\libsvm-mat-3.0-1\');
addpath('include\utils\');
addpath('include\edge_linking\');
addpath('src\');

nick = 'fan';
show_figure = 0;

n_contsamp	= 100;
sift_patchsize = 20;
dir_patchsize = 4;

num_start	= round(n_contsamp);
search_step	= 1;
thre		= .75;
lamda = 1.2;

img_fld = ['training_images\fan\', nick, '\'];
model_name = ['data\model_', nick];
imgs = dir([img_fld, '*.bmp']);

theta = zeros( length(imgs), n_contsamp );
d     = zeros( length(imgs), n_contsamp );
alpha = zeros( length(imgs), n_contsamp );
texture = cell( 1, n_contsamp );
localsc = cell( 1, n_contsamp );
cntrdes( length(imgs) ) = struct( 'd', [], 'a', [] );

%  get the first model
center1 = load(['training_images/fan/', nick, '/center1.txt']);

for n = 1:length(imgs)
    fprintf('Matching %d of %d\n', n, length(imgs));
    
    im = imread([img_fld, imgs(n).name]);
    im = imbinarize(im);
    ed = zeros( size(im) );
    [cntr, cntr_unsample] = extract_longest_cont(im, n_contsamp);
    
    cntr = round(cntr);
    cntr_unsample = round(cntr_unsample);
    ed(sub2ind(size(ed), cntr_unsample(:,2), cntr_unsample(:,1) )) = 1;
    [nc, labelmap] = bwdist(ed);
    
    clear help_el;
    help_el(:, 1) = cntr_unsample(:, 2);
    help_el(:, 2) = cntr_unsample(:, 1);
    help_list{1} = help_el;
    dirmap = im_dir(ed, help_list, dir_patchsize);
    scmap  = im_sc(ed);
    
    if n == 1
        d0 = zeros( 1, size(cntr,1) );
        alpha0 = zeros( 1, size(cntr,1) );
        theta0 = zeros( 1, size(cntr,1) );
        cntr0 = cntr;
        
        gray_im_name = [img_fld, imgs(n).name(1:end-4), '.jpg'];
        if exist(gray_im_name, 'file')
            jpg = imread([img_fld, imgs(n).name(1:end-4), '.jpg']);
            siftmap = im_sift(jpg, ed, sift_patchsize);
        end
        
        for i = 1:n_contsamp
            d0(i) = sqrt( (cntr(i,1)-center1(1))^2 + (cntr(i,2)-center1(2))^2 );
            help_ind = sub2ind( size(ed), cntr(i,2), cntr(i,1) );
            alpha0(i) = dirmap( labelmap(help_ind) );
            theta0(i) = atan2( cntr(i,2)-center1(2), cntr(i,1)-center1(1)+eps );
            localsc{i} = scmap.fea( scmap.ref( labelmap(help_ind) ), : );           % local shape context feature
            
            if exist(gray_im_name, 'file')
                texture{i} = siftmap.fea( siftmap.ref( labelmap(help_ind) ), : );
            else
                texture{i} = [];
            end
        end
        d0 = d0 / mean(d0);        % normalize
        
        d(n, :)     = d0;
        alpha(n, :) = alpha0;
        theta(n, :) = theta0;
        cntrdes(n).d = d0;
        cntrdes(n).a = alpha0;
    else
        % search for the best match position
        alpha_now = zeros( 1, size(cntr,1) );
        tt_now    = zeros( size(cntr,1), 128 );
        sc_now    = zeros( size(cntr,1), 50 );
        
        jpg = imread([img_fld, imgs(n).name(1:end-4), '.jpg']);
        siftmap = im_sift(jpg, ed, sift_patchsize);
        
        for i = 1:n_contsamp
            help_ind = sub2ind( size(ed), cntr(i,2), cntr(i,1) );
            alpha_now(i) = dirmap( labelmap(help_ind) );
            tt_now(i, :) = siftmap.fea( siftmap.ref( labelmap(help_ind) ), : );
            sc_now(i, :) =   scmap.fea( scmap.ref(   labelmap(help_ind) ), : );
        end
        
        costmat2 = repmat(alpha_now, [n_contsamp, 1]) - repmat(alpha0', [1, n_contsamp]);
        costmat2 = abs(costmat2);
        costmat2 = min( costmat2, pi-costmat2 );
        costmat2 = costmat2 / (pi/2);
        
        min_c = min( cntr(:,1) );
        max_c = max( cntr(:,1) );
        min_r = min( cntr(:,2) );
        max_r = max( cntr(:,2) );
        delta_d = ( max_c-min_c+max_r-min_r )/100;       % searching step
        [sr, sc] = meshgrid( (0.5*min_r+0.5*max_r)/2:delta_d:(0.25*min_r+0.75*max_r), (0.75*min_c+0.25*max_c):delta_d:(0.25*min_c+0.75*max_c) );
        sr = round( sr(:) );
        sc = round( sc(:) );
        match_costs = zeros(1, length(sr) );
        
        for i = 1:length( sr )
            help_cen = [ sc(i), sr(i) ];        % !
            help_d = zeros(1, n_contsamp);
            for j = 1:n_contsamp
                help_d(j) = sqrt( (cntr(j,1)-help_cen(1))^2 + (cntr(j,2)-help_cen(2))^2 );
            end
            help_d = help_d / mean(help_d);        % normalize
            costmat1 = repmat(help_d, [n_contsamp, 1]) - repmat(d0', [1, n_contsamp]);
            costmat1 = abs(costmat1);
            costmat  = costmat1 + lamda*costmat2;
            [cvec, match_cost]	= DPMatching_C(costmat, thre, num_start, search_step);
            
            match_costs(i) = match_cost;
        end
        [min_cost, min_ind] = min( match_costs );
        
        cen_now   = [ sc(min_ind), sr(min_ind) ];
        d_now     = zeros(1, n_contsamp);
        theta_now = zeros(1, n_contsamp);
        for i = 1:n_contsamp
            d_now(i) = sqrt( (cntr(i,1)-cen_now(1))^2 + (cntr(i,2)-cen_now(2))^2 );
            theta_now(i) = atan2( cntr(i,2)-cen_now(2), cntr(i,1)-cen_now(1)+eps );
        end
        d_now = d_now / mean(d_now);
        costmat1 = repmat(d_now, [n_contsamp, 1]) - repmat(d0', [1, n_contsamp]);
        costmat1 = abs(costmat1);
        costmat  = costmat1 + lamda*costmat2;
        [cvec, cost_now] = DPMatching_C(costmat, thre, num_start, search_step);
        
        %
        id_gd1		= find(cvec<=n_contsamp);
        id_gd2		= cvec(id_gd1);
        pt_from		= cntr0(id_gd1,:);
        pt_to		= cntr(id_gd2,:);
        n_match		= length(pt_from);
        
        no_match_id = setdiff( [1:n_contsamp], id_gd1 );
        
        d(n, id_gd1) = d_now(id_gd2);
        d(n, no_match_id) = nan;
        alpha(n, id_gd1) = alpha_now(id_gd2);
        alpha(n, no_match_id) = nan;
        theta(n, id_gd1) = theta_now(id_gd2);
        theta(n, no_match_id) = nan;
        
        for j = 1:length(id_gd1)
            texture{id_gd1(j)} = [ texture{id_gd1(j)}; tt_now(id_gd2(j), :) ];
            localsc{id_gd1(j)} = [ localsc{id_gd1(j)}; sc_now(id_gd2(j), :) ];
        end
        
        cntrdes(n).d = d_now;
        cntrdes(n).a = alpha_now;
        
        if show_figure
            %-- display correspondence
            figure(101); clf;	hold on; set(101,'color','w');
            step	= 3;
            roff = 200;
            
            plot([pt_from(1:step:end,1) pt_to(1:step:end,1)+roff]', ...
                [pt_from(1:step:end,2) pt_to(1:step:end,2)]', '+--',...
                'linewidth',.5);
            
            plot(cntr0(:,1),    cntr0(:,2),'k-', ...
                cntr(:,1)+roff, cntr(:,2),'k-',...
                'linewidth',.5);
            
            plot( center1(1), center1(2), '*r' );
            plot( cen_now(1)+roff, cen_now(2), '*r' );
            
            % sTitle	= ['#match=' i2s(n_match) ' cost=' num2str(match_cost)];
            % title(sTitle);
            axis equal;	axis ij; axis off;
            
            saveas(gcf, ['fig/', num2str(n), '.bmp']);
            % print(gcf, '-depsc', [nick, num2str(n), '.eps'])
        end
        
    end
    
end

% stat
id = 0;
for i = 1:n_contsamp
    help_d = d(:, i);
    help_d( isnan(help_d) ) = [];
    
    if length(help_d) <= 5
        continue;
    end
    id = id + 1;
    
    cnt_d(id) = mean(help_d);
    cnt_sd(id) = std(help_d);
    
    help_alpha = alpha(:, i);
    help_alpha( isnan(help_alpha) ) = [];
    [dir_, con] = circ_vmpar( help_alpha * 2 );
    cnt_dir(id) = dir_;
    cnt_con(id) = con;
    cnt_std(id) = circ_std( help_alpha*2 );
    
    help_theta = theta(:, i);
    help_theta( isnan(help_theta) ) = [];
    [dir_, con] = circ_vmpar( help_theta );
    ray_dir(id) = dir_;
    ray_con(id) = con;
    ray_std(id) = circ_std( help_theta );
    
    model.texture{id} = texture{i};
    model.localsc{id} = localsc{i};
end

% ignore the variance
%     cnt_con(:) = mean(cnt_con);
%     ray_con(:) = mean(ray_con);
%     cnt_sd(:)  = mean(cnt_sd);
%


model.cnt_d = cnt_d;
model.cnt_sd = cnt_sd;

model.cnt_dir = cnt_dir;
model.cnt_con = cnt_con;
model.cnt_std = cnt_std;

model.ray_dir = ray_dir;
model.ray_con = ray_con;
model.ray_std = ray_std;

model.lutab = create_lutab( model );

model.sift_patchsize = sift_patchsize;
model.dir_patchsize  = dir_patchsize;

model.cntrdes = cntrdes;

% model.svms = train_texture_classifier( texture, img_fld, sift_patchsize );


pos = zeros( length(model.cnt_d), 2 );
for j = 1:length(model.cnt_d)
    pos(j,1) = model.cnt_d(j) * sin(model.ray_dir(j));
    pos(j,2) = model.cnt_d(j) * cos(model.ray_dir(j));
end
neib_dm = zeros( length(model.cnt_d), length(model.cnt_d) );
neib_am = zeros( length(model.cnt_d), length(model.cnt_d) );
for i = 1:length(model.cnt_d)
    for j = 1:length(model.cnt_d)
        neib_dm(i, j) = sqrt( (pos(i,1)-pos(j,1))^2 + (pos(i,2)-pos(j,2))^2 );
        neib_am(i, j) = atan2( pos(i,2)-pos(j,2), pos(i,1)-pos(j,1)+eps );
    end
end
model.neib_dm = neib_dm;
model.neib_am = neib_am;


save(model_name, 'model');




R0 = 50;
figure(103); clf;	hold on; set(103,'color','w');

r = cnt_d .* cos(ray_dir) * R0;
c = cnt_d .* sin(ray_dir) * R0;

for i = 1:length(r)
    plot( [r(i), r(i)+5*cos(cnt_dir(i)/2)], [c(i), c(i)+5*sin(cnt_dir(i)/2)], '-r', 'linewidth', 3 );
end

plot(  r([1:end]), c([1:end]), '.g' );

% [~, IND] = sort(ray_std);
for ii = 1:10:length(r)
    % i = IND(ii);
    i = ii;
    clear r;
    clear c;
    
    clr = rand(1, 3);
    
    a = [ray_dir(i), ray_dir(i)+ray_std(i), ray_dir(i)-ray_std(i)];
    R = [R0, (1+cnt_sd(i))*R0, (1-cnt_sd(i))*R0];
    for k = 1:3
        for j = 1:3
            r(j) = R(k) * cnt_d(i) * cos(a(j));
            c(j) = R(k) * cnt_d(i) * sin(a(j));
            plot( [0, r(j)], [0, c(j)], 'color', clr );
        end
        plot( r([1,2]), c([1,2]), 'color', clr );
        plot( r([1,3]), c([1,3]), 'color', clr );
    end
    
end
axis equal;	axis ij; axis off;


saveas(103, [model_name, '_103.bmp']);
% print(gcf, '-depsc', [model_name, '_103.eps'])
waitfor(gcf);

























