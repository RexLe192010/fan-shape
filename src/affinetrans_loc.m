function  [Mpoints_trans,Ipoints_trans] = affinetrans_loc(Mpoints,Ipoints,Model_point,w_size)

[~,index] = setdiff(Model_point, Mpoints,'rows');
[~,ia,ib] = intersect(Model_point, Mpoints,'rows');

Mindex = 1:length(Model_point);
Mindex(index) = [];


Mpoints_Num = length(Model_point);

Mid_Num = floor(Mpoints_Num/2);

% index = 1:length(Model_point);

% index = index';

Mpoints_trans = Mpoints;
Ipoints_trans = Ipoints;


for i = 1: size(index,1)
    
    Mpoints_temp = [];
    Ipoints_temp = [];
    
    temp = index(i);
    
    Model_temp = Model_point;
    
    [~,ia,ib] = intersect(Model_temp, Model_point(temp,:),'rows');
  
    Model_temp(1:end-ia+1,:)   = Model_point(ia:end,:);
    Model_temp(end-ia+2:end,:) = Model_point(1:ia-1,:);
    
    Model_temp_2 = Model_temp;
    Model_temp_2(Mid_Num:end,:) = Model_temp(1:end-Mid_Num+1,:);
    Model_temp_2(1:Mid_Num-1,:) = Model_temp(end-Mid_Num+2:end,:);
    Model_temp = Model_temp_2;
    
    [~,ia,ib] = intersect(Model_temp, Model_point(temp,:),'rows');
    [~,iaindex,ibindex] = intersect(Model_temp, Mpoints,'rows');
    dis = iaindex-ia;
    temp_dis = dis;
    temp_dis(temp_dis>0) = inf;
    temp_dis = abs(temp_dis);
    [~,ind] = sort(temp_dis,'ascend');
    
    Mpoints_temp = [];
    Ipoints_temp =[];
    
    
    for j = 1 : w_size 
        temp_index = ibindex(ind(j));
        Mpoints_temp = [Mpoints_temp;Mpoints(temp_index,:)];
        Ipoints_temp = [Ipoints_temp;Ipoints(temp_index,:)];
    end
    
    
    temp_dis = dis;
    temp_dis(temp_dis<0) = inf;
    temp_dis = abs(temp_dis);
    [~,ind] = sort(temp_dis,'ascend');
    
    
    for j = 1 : w_size
        temp_index = ibindex(ind(j));
        Mpoints_temp = [Mpoints_temp;Mpoints(temp_index,:)];        
        Ipoints_temp = [Ipoints_temp;Ipoints(temp_index,:)];
    end

    trans = Ipoints_temp'/Mpoints_temp';
    point_trans = Model_point(temp,:);
    Ipoints_new =  (trans*point_trans')';
    Mpoints_trans = [Mpoints_trans;Model_point(temp,:)];
    Ipoints_trans = [Ipoints_trans;Ipoints_new];

end
