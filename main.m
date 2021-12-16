clear all
close all
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

signal_check(:,3) = zeros(1, size(signal_check,1));
signal_check(:,4) = zeros(1, size(signal_check,1));

%% stage 1: top and bottom clipping

th_high = 0.6; %depends on the tye of recording system
th_low = 0;
for i=1:size(signal_check,1)
    % 1 per ogni sample sopra treshold e sotto tresh bassa 
    signal_check(i,2)=stage1(signal_check(i,1),signal_check(i,2),th_low,th_high);
end

% figure()
% plot(signal_check(1,signal_check(2)==0),'g')signal_check(1,signal_check(2)==1),'k')

%% stage2-3: low and hig pass filter

fs=400;%??????????
% fs = 125;

signal_check(:,1) = stage2_3(signal_check(:,1), fs);

figure()
plot(signal_check(:,1))

%% Stage 4 

[moving_average_threshold, signal_check(:,3)] = stage4 (signal_check(:,1), signal_check(:,2), fs);  

figure()
plot(signal_check(:,1));
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
    % ipotizziamo nella colonna 3 le annotazioni dei picchi/valley
    
    
    % !!! DA SELEZIONARE
    % Check dell'inizio e fine della pulse wave che consideriamo qui
    % (corrisponde a check second valley): consideriamo qualsiasi
    % intervallo tra DUE valli!! e poi valutiamo tutto su quello 
    
    % La pulsewave completa entra nel calcolo parametri vari: 
    
    % Matrice in cui di lunghezza LA PULSEWAVE e larghezza 4 colonne!! 
    % Nella prima colonna SEGNALE 
    % Seconda colonna ANNOTATIONS CHECK 1
    % Terza colonna ANNOTATIONS CHECK 4 
    % Quarta colonna ANNOTATIONS CHECK 5 
%     matrix = stage5(pulsewave, fs);
    
    % Aggiunta di matrix a signal_check 
    
    






