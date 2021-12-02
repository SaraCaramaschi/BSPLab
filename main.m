clear
close
clc
PPG = load('PPGm.mat');
PPG=PPG.PPG;
PPG=PPG';
signal_check=cat(2,PPG,zeros(size(PPG,1),1));

figure()
plot(signal_check(:,1),'b')

%% stage 1: top and bottom clipping
th=0.6; %depends on the tye of recording system
for i=1:size(signal_check,1)
    signal_check(i,2)=stage1(signal_check(i,1),signal_check(i,2),th);
end

% figure()
% plot(signal_check(1,signal_check(2)==0),'g')signal_check(1,signal_check(2)==1),'k')

%% stage2-3: low and hig pass filter
fs=100;%??????????
signal_check(:,1) = stage2_3(signal_check(:,1), fs);
figure()
plot(signal_check(:,1))
