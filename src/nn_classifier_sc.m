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
function [scpros] = nn_classifier_sc(  ed, model, knn, sigma )

sc = im_sc(ed);

for i = 1:length( model.texture )

    
    fv = model.localsc{i};
    dm = dist2( fv, sc.fea );
    dm = sort(dm, 1);
    d  = dm(1:knn, :);
    d  = mean(d, 1);
    
    scpros{i} = exp(-d/sigma);
    
%     figure, imagesc(smap);
%     axis off; axis equal;
    
end
