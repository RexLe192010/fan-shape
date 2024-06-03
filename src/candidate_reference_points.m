
function refp = candidate_reference_points(cntr, n_search, r)

r1 = max(r, 1-r);
r2 = min(r, 1-r);

min_c = min( cntr(:,1) );
max_c = max( cntr(:,1) );
min_r = min( cntr(:,2) );
max_r = max( cntr(:,2) );

if n_search == 1
    % refp = [mean(cntr(:,1)), mean(cntr(:,2))];
    refp = [max_c+min_c, max_r+min_r]/2;
    return;
end

% searching step
dr = (max_r - min_r)*(r1 - r2)/(n_search-1);
dc = (max_c - min_c)*(r1 - r2)/(n_search-1);

[sr, sc] = meshgrid( (r1*min_r+r2*max_r):dr:(r2*min_r+r1*max_r), (r1*min_c+r2*max_c):dc:(r2*min_c+r1*max_c) );
sr = round( sr(:) );
sc = round( sc(:) );
refp = [sc, sr];