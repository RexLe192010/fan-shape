function rays = extr_ray_local_feats(im, n_contsamp, dir_patchsize)

ed = zeros( size(im) );
[cntr, cntr_unsample] = extract_longest_cont(im, n_contsamp);

cntr = round(cntr);
cntr_unsample = round(cntr_unsample);
ed(sub2ind(size(ed), cntr_unsample(:,2), cntr_unsample(:,1) )) = 1;
[nc, labelmap] = bwdist(ed);

help_list{1} = [cntr_unsample(:, 2), cntr_unsample(:, 1)];
dirmap = im_dir(ed, help_list, dir_patchsize);

rays.im = im;
rays.cntr = cntr;
rays.alpha = dirmap( labelmap( sub2ind( size(im), cntr(:,2), cntr(:,1) ) ) );