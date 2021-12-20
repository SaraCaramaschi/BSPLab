clear all
close all
clc

%% Loading 
% PPG = load('PPGm.mat'); % file di martina
PPG = load('n10151m.mat');
PPG=PPG.val;
PPG = PPG(500:5000);
PPG=PPG';

% vettore colonna + vettore zeri. 
% All'inizio tutto zero, poi uno dove artifacts
signal_check=cat(2,PPG,zeros(size(PPG,1),1)); 

figure()
plot(signal_check(:,1))
title('SEGNALE');

signal_check(:,3) = zeros(1, size(signal_check,1));
signal_check(:,4) = zeros(1, size(signal_check,1));

%% stage 1: top and bottom clipping

th_high = 400; %depends on the tye of recording system
th_low = -400;
signal_check(:,2)=zeros (size(signal_check,1),1);
for i=1:size(signal_check,1)
    % 1 per ogni sample sopra treshold e sotto tresh bassa 
    signal_check(i,2)=stage1(signal_check(i,1),signal_check(i,2),th_low,th_high);
end

figure()
plot(signal_check(:,1))
title('STAGE 1')
hold on
plot(find(signal_check(:,2)==1), signal_check(signal_check(:,2)==1,1),'g*')


%% stage2-3: low and hig pass filter

% fs=400;%??????????
fs = 125;

signal_check(:,1) = stage2_3(signal_check(:,1), fs);

figure()
plot(signal_check(:,1))
title('STAGE 2+3 - POST FILTRO');

%% Stage 4 

[moving_average_threshold, signal_check(:,3)] = stage4 (signal_check(:,1), signal_check(:,2), fs);  

figure()
plot(signal_check(:,1));
title('stage 4');
hold on
plot(moving_average_threshold,'k')
hold on
plot(find(signal_check(:,3)==1), signal_check(signal_check(:,3)==1,1),'g*')
hold on
plot(find(signal_check(:,3)==2), signal_check(signal_check(:,3)==2,1),'r*')
hold on
plot(find(signal_check(:,3)==-1), signal_check(signal_check(:,3)==-1,1),'go')
hold on
plot(find(signal_check(:,3)==-2), signal_check(signal_check(:,3)==-2,1),'ro')

    
%% STAGE 5:    
%initialization column of stage 5 annotations
signal_check(:,4) = zeros(size(signal_check(:,1),1),1);

pos_systolic_valleys = find (signal_check(:,3) == -1);
for i = 1:size(pos_systolic_valleys,1)-1
    pulsewave = signal_check(pos_systolic_valleys(i):pos_systolic_valleys(i+1),:);
    signal_check(pos_systolic_valleys(i):pos_systolic_valleys(i+1),4) = stage5(pulsewave, fs);
end

figure()
plot(signal_check(:,1));
title('stage 5');
hold on
plot(find(signal_check(:,4)==10), signal_check(signal_check(:,4)==10,1),'g*')
hold on
plot(find(signal_check(:,4)==11), signal_check(signal_check(:,4)==11,1),'r*')
hold on
plot(find(signal_check(:,4)==12), signal_check(signal_check(:,4)==12,1),'go')
    
 %% STAGE 6
 %initialization column of stage 6 annotations
 signal_check(:,5) = zeros(size(signal_check(:,1),1),1);


pos_pwb = find (signal_check(:,4) == 10);
pos_pwe = find (signal_check(:,4) == 12);
for i = 1:size(pos_pwb,1)-1
    if pos_pwe(i)+1 == pos_pwb(i+1)
        pulsewave_2 = signal_check(pos_pwb(i):pos_pwe(i),:);
        pulsewave_1 = signal_check(pos_pwb(i+1):pos_pwe(i+1), :);
        signal_check(pos_pwb(i+1):pos_pwe(i+1),5) = stage6(pulsewave_1, pulsewave_2);
    end
end


figure()
plot(signal_check(:,1));
title('stage 6');
hold on
plot(find(signal_check(:,5)==1), signal_check(signal_check(:,5)==1,1),'r*')
hold on
    
    






