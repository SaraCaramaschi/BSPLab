clear all
close all
clc

%% Loading 
%PPG = load('PPGm.mat'); % file di martina
%PPG = load('n10151m.mat');
%PPG=PPG.val;
%PPG = PPG(800:5000);

for k=1:10
   file_train=["0115_8min.mat","0123_8min.mat","0030_8min.mat","0031_8min.mat","0032_8min.mat","0105_8min.mat","0035_8min.mat","0028_8min.mat","0018_8min.mat","0029_8min.mat"];
   %file_test=["0103_8min.mat","0134_8min.mat","0133_8min.mat","0127_8min.mat","0125_8min.mat","0123_8min.mat","0122_8min.mat","0121_8min.mat","0104_8min.mat","0103_8min.mat","0023_8min.mat","0016_8min.mat","0015_8min.mat","0009_8min.mat"];
   load(file_train(k))
   PPG=signal.pleth.y;

%PPG=PPG';
%load('443m.mat')
%PPG=val;
%PPG=PPG';
% vettore colonna + vettore zeri. 
% All'inizio tutto zero, poi uno dove artifacts
%%
signal_check=cat(2,PPG,zeros(size(PPG,1),1)); 

% figure()
% plot(signal_check(:,1))
% title('SEGNALE');

signal_check(:,3) = zeros(1, size(signal_check,1));
signal_check(:,4) = zeros(1, size(signal_check,1));

%% stage 1: top and bottom clipping

th_high = 15; %depends on the tye of recording system
th_low = -15;
signal_check(:,2)=zeros (size(signal_check,1),1);
for i=1:size(signal_check,1)
    % 1 per ogni sample sopra treshold e sotto tresh bassa 
    signal_check(i,2)=stage1(signal_check(i,1),signal_check(i,2),th_low,th_high);
end

% figure()
% plot(signal_check(:,1))
% title('STAGE 1')
% hold on
% plot(find(signal_check(:,2)==1), signal_check(signal_check(:,2)==1,1),'g*')
%fs=125;
fs=300;
%% stage2-3: low and hig pass filter

% fs=400;%?


signal_check(:,1) = stage2_3(signal_check(:,1), fs);

%figure()
%plot(signal_check(:,1))
%title('STAGE 2+3 - POST FILTRO');

%% Stage 4 

[moving_average_threshold, signal_check(:,3)] = stage4 (signal_check, fs);  

% figure()
% plot(signal_check(:,1));
% title('stage 4');
% hold on
% plot(moving_average_threshold,'k')
% hold on
% plot(find(signal_check(:,3)==10), signal_check(signal_check(:,3)==10,1),'g*')
% hold on
% plot(find(signal_check(:,3)==2), signal_check(signal_check(:,3)==2,1),'r*')
% hold on
% plot(find(signal_check(:,3)==-10), signal_check(signal_check(:,3)==-10,1),'go')
% hold on
% plot(find(signal_check(:,3)==-2), signal_check(signal_check(:,3)==-2,1),'ro')

    
%% STAGE 5:    
%initialization column of stage 5 annotations



signal_check(:,4) = zeros(size(signal_check(:,1),1),1);

pos_systolic_valleys = find (signal_check(:,3) == -10);

for i = 1:size(pos_systolic_valleys,1)-1
    
    pulsewave = signal_check(pos_systolic_valleys(i):pos_systolic_valleys(i+1),:);
    signal_check(pos_systolic_valleys(i):pos_systolic_valleys(i+1),4) = stage5(pulsewave, fs);
    %PWRTLow(j));
    
end

% 
% figure()
% plot(signal_check(:,1));
% hold on
% title('stage 5');
% plot(find(signal_check(:,4)==10), signal_check(signal_check(:,4)==10,1),'g*')
% hold on
% plot(find(signal_check(:,4)==11), signal_check(signal_check(:,4)==11,1),'bl*')
% hold on
% plot(find(signal_check(:,4)==12), signal_check(signal_check(:,4)==12,1),'ro')
    
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


% figure()
% plot(signal_check(:,1));
% title('stage 6');
% hold on
% plot(find(signal_check(:,5)==1), signal_check(signal_check(:,5)==1,1),'r*')
% hold on
%% Visualizzazione del segnale con delle x rosse dove è disturbato
% cioè dove sono falliti i check dello stage 1,4,5,6
% il fallimento del check 1 viene inserito nello stage 4 e anche 5, quindi
% non deve essere visualizzato qui. Devo invece visualizzare il fallimento
% nello stage 4 (condizione di due valley senza picco in mezzo con una
% distanza tra esse maggiore di quella media). E dello stage 5 e 6.
y=-3000:1:3000;
x=find(signal_check(:,4)==10);
if length(labels.pleth.artif.x)>0 & labels.pleth.artif.x(1)==0
    labels.pleth.artif.x=labels.pleth.artif.x(3:end)
end
% figure()
% plot(signal_check(:,1));
% hold on
% title('Final plot');
% plot(find(signal_check(:,4)==10), signal_check(signal_check(:,4)==10,1),'g*')
% hold on
% plot(find(signal_check(:,4)==11), signal_check(signal_check(:,4)==11,1),'bl*')
% hold on
% plot(find(signal_check(:,4)==12), signal_check(signal_check(:,4)==12,1),'ro')
% hold on
% plot(find(signal_check(:,3)==1), signal_check(signal_check(:,3)==1,1),'r*')
% hold on 
% plot(find(signal_check(:,4)==1), signal_check(signal_check(:,4)==1,1),'r*')
% hold on
% plot(find(signal_check(:,5)==1), signal_check(signal_check(:,5)==1,1),'r*')
% hold on
% plot(labels.pleth.artif.x,signal_check(labels.pleth.artif.x,1),'ko')

%%
errore=zeros(size(signal_check(:,1),1),1);
art=zeros(size(signal_check(:,1),1),1);
errore(find(signal_check(:,3)==1))=1;
errore(find(signal_check(:,4)==1))=1;
errore(find(signal_check(:,5)==1))=1;
lable=labels.pleth.artif.x'; %%vector with the indices of the start and end of the artifact 
performance(k)=valutazione(lable,art,errore);

end

