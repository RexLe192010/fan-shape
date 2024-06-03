function rays = extr_ray_local_feats_mpeg7(im, n_contsamp, dir_patchsize)

ed = zeros( size(im) );
[cntr, cntr_unsample] = extract_longest_cont(im, n_contsamp);

cntr = round(cntr);
cntr_unsample = round(cntr_unsample);

help_ind = sub2ind(size(ed), cntr_unsample(:,2), cntr_unsample(:,1));
ed(help_ind) = 1;
[nc, labelmap] = bwdist(ed);

% help_list{1} = [cntr_unsample(:, 2), cntr_unsample(:, 1)];
% dirmap = im_dir(ed, help_list, dir_patchsize);

curvs = contour_curvature( cntr_unsample, dir_patchsize );
curv_map = zeros( size(im) );
curv_map(help_ind) = curvs;

rays.im = im;
rays.cntr = cntr;
rays.curv = curv_map( labelmap( sub2ind( size(im), cntr(:,2), cntr(:,1) ) ) );