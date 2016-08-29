function thresh = remove_outlier( x )
thresh=median(x)+2*std(x);
end

