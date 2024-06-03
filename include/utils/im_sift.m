
function siftmap = im_sift(im, ed, sift_patchsize)

ss = dense_sift( im, sift_patchsize, 1 );

ind = find( ed(:) > 0 );
ref = zeros( size(ed) );
ref(ind) = 1:length(ind);		% map edge index to it's feature index in the feature array
siftmap.ref = ref;

[r, c] = ind2sub( size(ed), ind );

r = r - sift_patchsize/2 + 1;
c = c - sift_patchsize/2 + 1;

max_r = size(im, 1) - sift_patchsize + 2;
max_c = size(im, 2) - sift_patchsize + 2;

r(r<1) = 1;
c(c<1) = 1;

r(r>max_r) = max_r;
c(c>max_c) = max_c;

help_ind = sub2ind( [max_r, max_c], r, c );

siftmap.fea = ss(help_ind, : );
