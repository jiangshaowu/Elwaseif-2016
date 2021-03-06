function [doi, model1,model2]=FEMIC_DOII(Ma,S,el,pobs,sigma,f,r,muv,err_tol,max_iter,q,vall,perc,sx,sz,wta,d,pmin,pmax,coords)
fprintf('******  STARTING MAXIMUM DOI ESTIMATION  ******\n');
pobs=reshape(pobs,length(S.freq),length(pobs(:))/length(S.freq));
sigma=reshape(sigma,length(S.freq),length(pobs(:))/length(S.freq));
[m, n]=size(pobs);%sigma=sigma(:,1);
parfor i=1:n-1
po(i)=abs(sum(pobs(:,i))-sum(pobs(:,i+1)))\min(min([sum(pobs(:,i)) sum(pobs(:,i+1))]));
end
po(po==inf)=0;po=100.*po;
ee=find(po>perc);dff=n-length(ee);
if dff>1 && min(ee)~=1 && max(ee)~=n
    ff=[1 min(ee)-1 ee max(ee)+1 n];%ff(length(ff)+1:length(ee)+dff)=[ee max(ee)+1 n];
else
    ff=[ee];
end
ff=unique(ff);
if isempty(ff) || length(ff)<=3
    redpobs=pobs(:,[1 floor(n/3) floor(n/2) floor(2*n/3) n]);
    ff =[1  floor(n/3) floor(n/2) floor(2*n/3) n];
    rsigma=sigma(:,[1 floor(n/3) floor(n/2) floor(2*n/3) n]);
else
    redpobs=pobs(:,ff);
    rsigma=sigma(:,ff);
end
[m2, n2]=size(redpobs);
Ma.thk=4*ones(5,1);Ma.k=5;Ma.chie=zeros(5,1);Ma.chim=zeros(5,1);
Ma.con=log10(1/400)*ones(length(Ma.thk),n2);wta=ones(length(Ma.thk),n2);%round((min(min(redpobs)) + max(max(redpobs)))/2)*ones(length(f),1);

  muv=1;
   [model1, muh_final, rms_error2, G]=FEMIC_tost21(Ma,S,el,redpobs,rsigma,muv,err_tol,max_iter,q,sx,sz,wta,pmin,pmax,coords)
  Ma.con=log10(1/200)*ones(Ma.k,n2);%abs(params(1)-round(max(max(redpobs))/2))*ones(length(f),1); %model2=zeros(sa,ta);
  [model2, muh_final, rms_error2, G]=FEMIC_tost21(Ma,S,el,redpobs,rsigma,muv,err_tol,max_iter,q,sx,sz,wta,pmin,pmax,coords)

R=abs(model1-model2)./abs(log10(1/400)-log10(1/200));dlmwrite('R.dat',R);dlmwrite('m1.dat',model1);dlmwrite('m2.dat',model2);
[u y]=size(R);dd=cumsum(Ma.thk);
for i=1:y
b=find(R(:,i)<0.2);
if isempty(b) 
to(i)=dd(1);
else
ba=find(diff(b)>1);if isempty(ba);to(i)=dd(2);else to(i)=dd(ba(1));end

end

end
ap=1:n;%rq=length(ff);ff(rq+1)=n;to(rq+1)=to(1);
doi=interp1(ff,to,ap);dlmwrite('doi.dat',doi);dlmwrite('ff.dat',ff);

fprintf('******  END OF DOI ESTIMATION  ******\n');
fprintf('******  STARTING THE INVERSION  ******\n');