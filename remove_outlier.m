function thresh = Removeoutlier( x )
thresh=median(x)+2*std(x);
end

