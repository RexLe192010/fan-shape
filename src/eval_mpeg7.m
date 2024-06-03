
function macc = eval_mpeg7(cm)

N = size(cm,1);

acc = zeros(1, N);

cm = (cm+cm')/2;

for i = 1:N
    c = ceil(i / 20);
    
    [~, I] = sort(cm(i,:));
    c2 =  I(1:40);
    c2 = ceil(c2 / 20);
    
    acc(i) = length(find(c2==c))/20;
    
end

macc = mean(acc);

fprintf('Accuracy on Mpeg7 dataset is %f.\n', macc );