function lutab = create_lutab( model )

lutab = zeros( length( model.cnt_d ), 360 );

for k = 1:length( model.ray_dir )
    for a = 1:360
        lutab( k, a ) = circ_vmpdf( a*2*pi/360, model.ray_dir(k), model.ray_con(k) ); 
    end
end