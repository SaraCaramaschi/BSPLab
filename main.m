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

th_low = -0.8;%should be 0
th_high=0.6; %depends on the tye of recording system
for i=1:size(signal_check,1)
    % 1 per ogni sample sopra treshold e sotto tresh bassa 
    signal_check(i,2)=stage1(signal_check(i,1),signal_check(i,2),th_low,th_high);
end

figure()
plot(signal_check(:,1),'*-g')
hold on
plot(find(signal_check(:,2)==1),signal_check(find(signal_check(:,2)==1),1),'ro')

%% stage2-3: low and hig pass filter

fs=400;%??????????
% fs = 125;

signal_check(:,1) = stage2_3(signal_check(:,1), fs);

figure()
plot(signal_check(:,1))

%% Stage 4: Entrata nel buffer 

% da una parte: filtered PPG, dall'altra raw signal annotation of PPG 
fs=400;
pwdLength = 4.8; % secondi
pwdSamples = 4.8*fs;

signal = signal_check(:,1);
annotation = signal_check(:,2); 
% Inizializzazione treshold: 
tresh = zeros(1, length(signal_check(:,1)) - 0.75*pwdSamples);
valore=signal(0.75*pwdSamples);
valore_precedente=signal(0.75*pwdSamples-1);
segno_incremento=0;
segno_incremento_precedente=0;
indice=0;
j=0;
peaks=[];
p=0;
valleys=[];
v=0;
for i = 0.75*pwdSamples:1:(length(signal_check(:,1))-2*pwdSamples)) % si sposta di uno per uno 
    %aggiorno le variabili
    valore_precedente=valore;
    segno_incremento_precedente=segno_incremento;
    if i+pwdSamples*2<length(signal)%questo controllo penso non serva se la i la facessimo andare fino a quello a cui va ora -1
       filteredPPGbuff = signal(i:i + pwdSamples*2);
       tresh(i)= mean(filteredPPGbuff(1:0.75*pwdSamples));%whole non-disturbed span of signal or just avoid disturbed samples??
       valore=signal(i);
       if(valore_precedente - valore >0) % il segnale decresce
           segno_incremento = -1;
           if(segno_incremento_precedente == 1)
            % è un picco verso l'alto.
               if (signal(i-1) > tresh(i-1))%non bisgna comparare segnale e threshold nello stesso punto?
                   p = p + 1;
                   peaks(p) = i-1;                   
               end
           end 
       else
           segno_incremento = 1;
           if (segno_incremento_precedente==-1)
            % è un picco verso il basso
               if (signal(i-1) < tresh(i-1))
                   v = v + 1;
                   valleys(v) = i-1;                   
               end
           end
       end
       
     % Buffer array 4.8s raw signal annotation of PPG
       PPGbuff = signal_check(:,2);
       % plotto il segnale ogni 100 samples.
       if i==0.75*pwdSamples+j*100
          j=j+1;
          plot(signal(1:i))%il segnale non è in colonna
          hold on
          plot(tresh(1:i),'b')
          hold on
          if length(picco)>0
             plot(picco(1:indice),signal(picco(1:indice)),'o')
             hold on
          end
          
       end
       pause(0.00001)
       
    end
   
end




