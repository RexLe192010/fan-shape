function show_res(results, img, filename, gt)

splnum = [40 20 20 20 20 30];

figure('Resize','off','Position',[100 100 size(img,2) size(img,1)],...
       'PaperUnit','points','PaperPosition',[1 1 size(img,2) size(img,1)]);
axes('position',[0 0 1 1]);

imshow(img); hold on;

gt_lt = [ gt(2), gt(1) ];
gt_rb = [ gt(4), gt(3) ];
plot( [gt_lt(2), gt_lt(2)], [gt_lt(1), gt_rb(1)], 'c', 'linewidth', 2 );
plot( [gt_lt(2), gt_rb(2)], [gt_rb(1), gt_rb(1)], 'c', 'linewidth', 2 );
plot( [gt_rb(2), gt_rb(2)], [gt_lt(1), gt_rb(1)], 'c', 'linewidth', 2 );
plot( [gt_lt(2), gt_rb(2)], [gt_lt(1), gt_lt(1)], 'c', 'linewidth', 2 );

for n = 1:length(results)
    
   res = results(n);
    
   all_cntr = [];
   all_skel = [];
   for m =  1 : length(res.tplt)
       all_cntr = [all_cntr; res.tplt{m} ];
       
       help_skel = res.skel{m}( round(1:size(res.skel{m},1)/splnum(m):end), : );
       all_skel = [all_skel; help_skel ];
   end
   
   lt = min(all_cntr);   
   rb = max(all_cntr);     
   lt = lt(1:2);
   rb = rb(1:2);
   
   plot( [lt(2), lt(2)], [lt(1), rb(1)], 'b', 'linewidth', 2 );
   plot( [lt(2), rb(2)], [rb(1), rb(1)], 'b', 'linewidth', 2 );
   plot( [rb(2), rb(2)], [lt(1), rb(1)], 'b', 'linewidth', 2 );
   plot( [lt(2), rb(2)], [lt(1), lt(1)], 'b', 'linewidth', 2 );
   
   plot( all_cntr(:, 2), all_cntr(:, 1), '.g', 'MarkerSize', 15 );
   plot( all_skel(:, 2), all_skel(:, 1), '.r', 'MarkerSize', 15 );
   
   saveas(gcf, filename);
   close all;
   
end
