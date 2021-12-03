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
fs=400;
pwdLength = 4.8; % secondi
pwdSamples = 4.8*400;

signal = signal_check(:,1);
annotation = signal_check(:,2); 
% Inizializzazione treshold: 
tresh = zeros(1, length(signal_check(:,1)) - 2*pwdSamples);
valore=signal(0.75*pwdSamples);
valore_precedente=signal(0.75*pwdSamples-1);
segno_incremento=0;
segno_incremento_precedente=0;
indice=0;
j=0;
picco=[];
for i = 0.75*pwdSamples:1:(length(signal_check(:,1)-2*pwdSamples)) % si sposta di uno per uno 
    %aggiorno le variabili
    valore_precedente=valore;
    segno_incremento_precedente=segno_incremento;
    if i+pwdSamples*2<length(signal)
       % Buffer array 4.8s*2 filtered PPG
       %filteredPPGbuff = signal(i:i + pwdSamples*2);
       filteredPPGbuff = signal(i:i + pwdSamples*2);
       %aggiorno la threshold
    % Adaptive treshold: ultimi 4.8*fs VALIDI (SENZA UNI) 
    % Il primo 75% dei primi 4.8*2 secondi non è bello   
    % Adaptive treshold calculated thanks to a moving average
    % filter with span size 75% 
       tresh(i)= mean(filteredPPGbuff(1:0.75*pwdSamples));
       valore=signal(i);
    
       if(valore_precedente-valore>0) % il segnale decresce
           segno_incremento=-1;
       else
           segno_incremento=1;
       end
       if(segno_incremento==-1) 
           if(segno_incremento_precedente==1)
            % è un picco verso l'alto.
               if (signal(i-1)>tresh(i))
                   indice=indice+1;
                   picco(indice)= i-1;
                   
               end
           end 
       else 
           if (segno_incremento_precedente==-1)
            % è un picco verso il basso
               if (signal(i-1)<tresh(i))
                   indice=indice+1;
                   picco(indice)=i-1;
                   
               end
           end
       end
    
     % Buffer array 4.8s raw signal annotation of PPG
       PPGbuff = signal_check(:,2);
       % plotto il segnale ogni 100 samples.
       if i==0.75*pwdSamples+j*100
          j=j+1;
          plot(signal(1:i))
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




