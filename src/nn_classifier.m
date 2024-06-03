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
function [ttpros] = nn_classifier( im, ed, model, knn, sigma )

ss = im_sift(im, ed, model.sift_patchsize);
% sc = im_sc(ed);

for i = 1:length( model.texture )
    fv = model.texture{i};
    dm = dist2( fv, ss.fea );
    dm = sort(dm, 1);
    d  = dm(1:knn, :);   
    d  = mean(d, 1);
    
    % smap = zeros(size(ed));
    % smap( ed(:)>0 ) = exp(-d/sigma);
    
    ttpros{i} = exp(-d/sigma);
    
%     fv = model.localsc{i};
%     dm = dist2( fv, sc.fea );
%     dm = sort(dm, 1);
%     d  = dm(1:knn, :);
%     d  = mean(d, 1);
%     
%     scpros{i} = exp(-d/sigma);
    
    % figure, imagesc(smap);
    % axis off; axis equal;
    
end
