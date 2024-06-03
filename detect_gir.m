
clear; clc; close all;

addpath('include\edge_linking\');
addpath('include\CircStat2010e\');
addpath('include\dsift\');
addpath('include\utils\');
addpath('src\');

nick = 'gir';
cls = 'Giraffes';
load data/model_gir;


para.resol = 8;
para.Ss  = logspace( log10(30), log10(180), 12 );
para.nms = 8;
para.t1 = 1e-1;
para.t2 = 1e-2;
para.t3 = 1e-3;
para.knn = 5;
para.miss_rate = 0.15;
para.tt_sigma = 1;
para.sift = 1;
para.sc = 0;
para.ori = 1;


im = imread('testing_images\three.jpg');
ed = imread('testing_images\three_edges.tif');
ed = im2bw(ed, 0.02);

edgelist = edgelink(ed, 10);
ed = zeros( size(ed) );
for i = 1:length(edgelist)
    help_ind = sub2ind( size(ed), edgelist{i}(:,1), edgelist{i}(:,2) );
    ed(help_ind) = 1;
end
dirmap = im_dir(ed, edgelist, model.dir_patchsize);

tic
fprintf('%s detecting.\n', cls);
[det, info] = inference(im, ed, dirmap, para, model);     
toc

pic = im;
[y x c] = size(pic); 
figure('Units','Pixels','Resize','on',...
    'Position',[100 100 x y],'PaperUnit','points',...
    'PaperPosition',[0 0 x y]);
axes('position',[0 0 1 1]);
imshow(pic, []);
hold on
axis off

for i = 1:length(det)
    clr = rand(3,1);
    plot( det(i).contour(:,2), det(i).contour(:,1), '*', 'color', clr );
    % plot( det(i).contour([1:end,1],2), det(i).contour([1:end,1],1), '-', 'color', clr );
    text( det(i).center(2), det(i).center(1), num2str(det(i).score,2), 'BackgroundColor',[.7 .9 .7] );
end