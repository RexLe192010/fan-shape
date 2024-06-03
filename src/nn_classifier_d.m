% addpath('include\dsift\');
% addpath('src\');
% 
% load model_gir;
% 
% knn = 10;
% 
% im = imread( 'D:\images\ETHZShapeClasses-V1.2\Giraffes\amsterdam.jpg' );
% ed = imread( 'D:\images\ETHZShapeClasses-V1.2\Giraffes\amsterdam_edges.tif' );
% ed = im2bw(ed, 0.01);
function [d_tt, d_sc] = nn_classifier_d( im, ed, model, knn, sigma_tt, sigma_sc )

ss = im_sift(im, ed, model.sift_patchsize);
sc = im_sc(ed);

for i = 1:length( model.texture )
    
    %% sift part
    fv = model.texture{i};
    dm = dist2( fv, ss.fea );
    dm = sort(dm, 1);
    d  = dm(1:knn, :);   
    d  = mean(d, 1);
    d  = d / sigma_tt;
    d_tt{i} = d;
    
    %% shape context part
    fv = model.localsc{i};
    dm = dist2( fv, sc.fea );
    dm = sort(dm, 1);
    d  = dm(1:knn, :);
    d  = mean(d, 1);
    d  = d / sigma_sc;
    d_sc{i} = d;
    
    % figure, imagesc(smap);
    % axis off; axis equal;
    
end
