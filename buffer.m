load('PPG_train.mat')
signal=train_ppg(1,:);
x=struct2cell(signal);
x_1=x(1,:);
l=length(x_1);
conc=x_1{1};
for i=2:200
    conc=cat(2,conc,x_1{i});
end
plot(conc)
%faccio un array di 4,8s per 2, i dati che ho hanno frequenza 400 Hz. 3.840
%samples.
