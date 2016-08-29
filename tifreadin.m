function I = tifreadin(s)
info = imfinfo(s);
num = numel(info);
temp=imread(s,1,'Info', info);
I=zeros(size(temp,1),size(temp,2),num,'uint8');
for i=1:num
    I(:,:,i)=imread(s,i,'Info', info);
end
end
