clear
close
clc

%% Loading 
PPG = load('PPGm.mat'); % file di martina
PPG=PPG.PPG;
PPG=PPG';

% vettore colonna + vettore zeri. 
% All'inizio tutto zero, poi uno dove artifacts
signal_check=cat(2,PPG,zeros(size(PPG,1),1)); 

figure()
plot(signal_check(:,1),'b')

%% stage 1: top and bottom clipping

th=0.6; %depends on the tye of recording system
for i=1:size(signal_check,1)
    % 1 per ogni sample sopra treshold e sotto tresh bassa 
    signal_check(i,2)=stage1(signal_check(i,1),signal_check(i,2),th);
end

% figure()
% plot(signal_check(1,signal_check(2)==0),'g')signal_check(1,signal_check(2)==1),'k')

%% stage2-3: low and hig pass filter

fs=400;%??????????
% fs = 125;

signal_check(:,1) = stage2_3(signal_check(:,1), fs);

figure()
plot(signal_check(:,1))

%% Stage 4: Entrata nel buffer 

% da una parte: filtered PPG, dall'altra raw signal annotation of PPG 

pwdLength = 4.8; % secondi
pwdSamples = pwdLength*fs;

signal = signal_check(:,1);
annotation = signal_check(:,2); 

% Inizializzazione treshold: 
tresh = zeros(1, length(signal_check(:,1)) - 2*pwdSamples);
count = 1;
for i = 0.75*pwdSample:1:(length(signal_check(:,1)) - 2*pwdSamples) % si sposta di uno per uno 

    % Buffer array 4.8s*2 filtered PPG 
    filteredPPGbuff = signal(i:i + pwdSamples*2);
    
    % Buffer array 4.8s raw signal annotation of PPG
    PPGbuff = signal_check(:,2);
    
    % Adaptive treshold: ultimi 4.8*fs VALIDI (SENZA UNI) 
    % Il primo 75% dei primi 4.8*2 secondi non � bello   
        
    % Adaptive treshold calculated thanks to a moving average
    % filter with span size 75% 
        
    tresh(count) = mean(filteredPPGbuff(i - 0.75*pwdSample : i)) ; % treshold che sta in i 
    count = count+1;
        
end




