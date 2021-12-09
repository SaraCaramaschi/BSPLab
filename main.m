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

fs=400;
% fs = 125;

signal_check(:,1) = stage2_3(signal_check(:,1), fs);

figure()
plot(signal_check(:,1))

%% Stage 4: Entrata nel buffer 

pwdLength = 2.4; % seconds
pwdSamples = pwdLength*fs; %samples


signal_check(:,3)= zeros(length(signal_check),1);%initialization third column for peaks and valley detection
%add nan at beginning and end of signal (and annotation of signal) to make 
%it more realistic as a live acquisition
signal = cat(1,NaN*ones(pwdSamples+1,1), signal_check(:,1), NaN*ones(pwdSamples+1,1));
annotation = cat(1,NaN*ones(pwdSamples+1,1), signal_check(:,2), NaN*ones(pwdSamples+1,1));

%initialization variables
valore=signal(0.75*pwdSamples);
valore_precedente=signal(0.75*pwdSamples-1);
segno_incremento=0;
segno_incremento_precedente=0;

for k=1:size(signal,1) %signal sampling simulation, k is the first element of the buffer (the oldest value of the vector entering)
        i= pwdSamples+k+1; %element in the middle of the buffer       
        if ~isnan(signal(i))
            valore=signal(i);
            valore_precedente=signal(i-1);            
            segno_incremento_precedente=segno_incremento;
            incremento(k)= valore_precedente - valore;
            %creation of buffer vectors, change at every iteration (1 in 1
            %out)
            buff = signal(k : i+pwdSamples-1);
            buff_ann = annotation(k : i+pwdSamples-1);
            %insert NaN in the buffer in correspondance to annotation =1 (disturbed signal)
            buff(buff_ann==1)= NaN; 
            %moving average threshold            
            thresh(k)= nanmean(buff(0.25*pwdSamples:pwdSamples)); 
            if(incremento(k)>0) % signal is decreasing
               segno_incremento = -1;
               if(segno_incremento_precedente == 1)% max                
                   if (signal(i-1) > thresh(k-1)) % peak
                       signal_check(k-1,3)= 1;                  
                   end
               end 
           elseif (incremento(k) <0) %signal is increasing
               segno_incremento = 1;
               if (segno_incremento_precedente==-1)% min                
                   if (signal(i-1) < thresh(k-1)) %valley
                        signal_check(k-1,3)= -1;                    
                   end
               end
            end
        end
    end


figure()
plot(signal_check(:,1))
hold on
plot(find(signal_check(:,3)==1),signal_check(find(signal_check(:,3)==1),1),'*')
hold on
plot(find(signal_check(:,3)==-1),signal_check(find(signal_check(:,3)==-1),1),'o')
hold on 
plot(thresh)




