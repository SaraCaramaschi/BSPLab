load('PPG_train.mat')
s=train_ppg(1,:);
x=struct2cell(s);
x_1=x(1,:);
l=length(x_1);
conc=x_1{1};
for i=2:100
    conc=cat(2,conc,x_1{i});
end

%faccio un array di 4,8s per 2, i dati che ho hanno frequenza 400 Hz. 3.840
%samples.

signal=conc;
plot(signal)
%%
fs=400;
pwdLength = 4.8; % secondi
pwdSamples = 4.8*400;


%signal=signal(1:120000);
%annotation = signal_check(:,2); 

% Inizializzazione treshold: 
tresh = zeros(1, length(signal) - 2*pwdSamples);

c= 1;
valore=signal(0.75*pwdSamples)
valore_precedente=signal(0.75*pwdSamples-1)
segno_incremento=0;
segno_incremento_precedente=0;


j=0;

for i = 0.75*pwdSamples:1:(length(signal-2*pwdSamples)) % si sposta di uno per uno 
    valore_precedente=valore;
    segno_incremento_precedente=segno_incremento;
    % Buffer array 4.8s*2 filtered PPG 
    %if i+pwdSamples*2<12000
    valore=signal(i);
    filteredPPGbuff = signal(i:i + pwdSamples*2);
    tresh(i)= mean(filteredPPGbuff(1:0.75*pwdSamples));
    if i<length(signal)
       
       
       if(valore_precedente-valore>0) % decresco
           segno_incremento=-1;
       else
           segno_incremento=1;
       end
       if(segno_incremento==-1) 
           
           if(segno_incremento_precedente==1)
            % è un picco verso l'alto.
               if (signal(i-1)>tresh(i))
                   m= signal (i-1);
                   c=c+1;
                   
               end
           end 
       else %segnale aumenta
           if (segno_incremento_precedente==-1)
            % è un picco verso il basso
               if (signal(i-1)<tresh(i))
                   mi(c)=i-1;
                   c=c+1;
               end
           end
       end
    
            
            
    
    
    % Buffer array 4.8s raw signal annotation of PPG
       %PPGbuff = signal_check(:,2);
    
    % Adaptive treshold: ultimi 4.8*fs VALIDI (SENZA UNI) 
    % Il primo 75% dei primi 4.8*2 secondi non è bello   
        
    % Adaptive treshold calculated thanks to a moving average
    % filter with span size 75% 
    
       %tresh= mean(filteredPPGbuff(i - 0.75*pwdSamples+1 : i)) ; % treshold che sta in i 
       
       %plotto ogni 100 samples.
       if i==0.75*pwdSamples+j*100
          j=j+1;
      
          plot(signal(1:i),'r')
          hold on
          plot(tresh(1:i),'b')
          hold on
          plot(mi(1:c),signal(mi(1:c)),'o')
          hold on
          
          
          
       end
       pause(0.001)
       
    end
   
end
%%
figure(2)
plot(signal)
hold on
plot(mi,signal(mi),'o')

