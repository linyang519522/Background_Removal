function [pI,ebs]=background_removal(I1, ws, percentile)
[sx1,sy1,sz1]=size(I1);
dx=floor(sx1/ws);
dy=floor(sy1/ws);
dz=floor(sz1/ws);

sx=(dx+1)*ws;
sy=(dy+1)*ws;
sz=(dz+1)*ws;
I=zeros(sx,sy,sz,'uint8');
dx=dx+1;
dy=dy+1;
dz=dz+1;
I(1:sx1,1:sy1,1:sz1)=I1;
for i=sx1+1:sx
  I(i,:,:)=I(sx1,:,:);
end
for i=sy1+1:sy
  I(:,i,:)=I(:,sy1,:);
end
for i=sz1+1:sz
  I(:,:,i)=I(:,:,sz1);
end

disp 'Estimate Background'
ebs=pfilter(reshape(I,1,[]),dx,dy,dz,ws,size(I,1),size(I,2),percentile);
ebs=reshape(ebs,dx+2,dy+2,dz+2);
ebs=double(ebs);

rws=5;

disp 'Remove Outlier'
aebs=reshape(ebs,[],1);
id=find(aebs>0);
aebs=aebs(id);
if length(aebs)==0
  outlierv=255;
else
  outlierv=Removeoutlier(aebs);
end
id=ebs>outlierv;
ebs(id)=-1;

nebs=ebs;
for i=2:dx+1
  for j=2:dy+1
    for k=2:dz+1
      if nebs(i,j,k)==-1
        tarray=ebs(max(1,i-rws):min(dx+1,i+rws),max(1,j-rws):min(dy+1,j+rws),max(1,k-rws):min(dz+1,k+rws));
        id=find(tarray>0);
        it=1;
        while isempty(id)
          tarray=ebs(max(1,i-rws-it):min(dx+1,i+rws+it),max(1,j-rws-it):min(dy+1,j+rws+it),max(1,k-rws-it):min(dz+1,k+rws+it));
          id=find(tarray>0);
          it=it+1;
        end
        nebs(i,j,k)=median(tarray(id));
      end
    end
  end
end
ebs=nebs;

ebs(1,:,:)=ebs(2,:,:);
ebs(dx+2,:,:)=ebs(dx+1,:,:);
ebs(:,1,:)=ebs(:,2,:);
ebs(:,dy+2,:)=ebs(:,dy+1,:);
ebs(:,:,1)=ebs(:,:,2);
ebs(:,:,dz+2)=ebs(:,:,dz+1);
Xg=(ws+1)/2-ws:ws:sx+ws;
Yg=(ws+1)/2-ws:ws:sy+ws;
Zg=(ws+1)/2-ws:ws:sz+ws;
Xq=1:sx;
Yq=1:sy;
Zq=1:sz;
disp 'Interpolation'
pI=I-uint8(interp3(Yg,Xg',Zg,ebs,Yq,Xq',Zq));
pI=pI(1:sx1,1:sy1,1:sz1);
disp 'Adjust Contrast'
pI=double(pI)*255.0/double(quantile(pI(:),0.995));
pI=uint8(pI);
end
