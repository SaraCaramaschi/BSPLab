function [th,annotation4] = stage4 (check,fs)
%identification of peaks and valleys and their classification in systolic
%or diastolic:
%1) computation of moving average threshold
%2) identification of local maxima and minima
%3) comparison of local maxima and minima with threshold to establish if
%they are real peaks and valleys correspondingly
%4) computation of reference PWA and mean consecutive valleys distance
%excluding samples classified as disturbed by stage1
%5) systolic peak criterion verification: a peak is classified as systolic
%if its amplitude multiplied by a scaling factor (3) is greater than
%reference PWA
%6)???


%calculate the moving average threshold
    p=0;
    signal=check(:,1);
    annotation1=check(:,2);
    annotation4=check(:,3);
    flag1=0;
    pwdLength = 2.4; % seconds
    pwdSamples = pwdLength*fs; %samples
    ma_span = 0.75*pwdSamples; %moving average span
    sig = signal;
    sig (annotation1==1) = NaN; %create a variable equal to the signal but with NaN where the signal is disturbed (reffering to the check of stage1)
    th = ones(size(signal,1),1)*NaN;
    for i= ma_span+1:size(sig,1) %first ma_span of the signal is discarded because cannot be associated to a threshold
        th(i) = nanmean(sig(i-ma_span:i));
    end
    
    %find peaks and valleys with matlab function findpeaks
    [~,pos_max] = findpeaks(signal);
    [~,pos_min] = findpeaks(-signal); %consider the signal upsidedown to turn valleys into peaks and be identificable by findpeaks function
   
    %identification of true peaks and valleys of the signal considering
    %their position with respect to the threshold just computed
    %initialize check as a vector of zeros
    annotation4=zeros(size(signal,1),1);
    for i=1:size(pos_min,1)
       if ~ isnan (th(pos_min(i)))
         if (signal(pos_min(i)) < th(pos_min(i))) %valley
            annotation4(pos_min(i))= -10;
         end
       end
       
    end
    for i=1:size(pos_max,1)
       if ~ isnan (th(pos_max(i)))
          if (signal(pos_max(i)) > th(pos_max(i))) %peak
             annotation4(pos_max(i))= 10;
          end
       end
    end
 
    pos_valleys = find (annotation4 == -10);
    pos=find(annotation4 == 10);
    %creation of reference value as maximum between the first 3 pwa
    % eliminare segnale che fallisce allo stage1 
    for j=1:length(pos_valleys)-1
         %reference constructed by the all valley-peak couples
            ref_peaks = find(annotation4(pos_valleys(j):pos_valleys(j+1))==10); %peaks in the interval between two consecutive valleys
            ref_peaks=pos_valleys(j)+ref_peaks-1;
            
            if size(ref_peaks,1)>0
                annotation4(ref_peaks(2:end))=0; % take in consideration only the first peak between two valleys (not considere a peak without a valley)
                ref_peak=ref_peaks(1);
                ref_pwa(j)= signal(ref_peak) - signal(pos_valleys(j));
                ref_valleydistance(j)=pos_valleys(j+1)-pos_valleys(j);
            else 
                
                ref_pwa(j)=NaN;
                ref_valleydistance(j)=NaN;
            end
            
    end
    reference_valleydistance=nanmean(ref_valleydistance);
    reference_pwa = nanmean(ref_pwa);
    for j=1:length(pos_valleys)-1       
            flag1=0;
            position_peaks=[];
            position_peaks = find(annotation4(pos_valleys(j):pos_valleys(j+1))==10); % find all peaks between two valleys
            % if in the interval between two valleys there are a failed
            % check1 all the interval is considered not valid.( essenziale
            % per poter aggiornare la reference pwa al 'last correct
            % pulsewave')
            for i=pos_valleys(j):pos_valleys(j+1)
                if annotation1(i)==1
                    annotation4(pos_valleys(j):pos_valleys(j+1))=1;
                    flag1=1;
                    
                end
            end
            if flag1==0
              if length(position_peaks)>0 % if there is a peak
                
                  
                position_peaks = position_peaks + pos_valleys(j)-1;
                annotation4(position_peaks(2:end))=0; % eliminate all the double peaks
                position_peak=position_peaks(1);
                pwa = signal(position_peak) - signal(pos_valleys(j));
                if pwa*3 < reference_pwa %diastolic valley-peak couple
                    annotation4(position_peak) = 2;
                    annotation4(pos_valleys(j)) = -2;
                    
                else 
                    reference_pwa = pwa; %update of reference pwa with last systolic pwa
                    reference_valleydistance=pos_valleys(j+1)-pos_valleys(j);
                   %reference_valleydistance=pos_valleys(j+1)-pos_valleys(j);
                   %( si può anche non aggiornare sempre, funziona lo
                   %stesso)
                end  
              else % if there is no a peak,I check the distance between two valley and I choose to unify them or to eliminate the signal
                  
                  if pos_valleys(j+1)-pos_valleys(j)<1.5*reference_valleydistance
                    
                    annotation4(pos_valleys(j))=0; % eliminate the followinf valley
                    j=j+1;
                    
                % in questo modo riesco a trattare il caso in cui ho più di
                % due valley consecutive, infatti continuo a fare check con
                % la prima di esse.
                 else % eliminate the interval, because there is not peak
                    
                    annotation4(pos_valleys(j):pos_valleys(j+1))=1;
                 end
                    
              
              end
              
            end
    end   
end

%Quando ci sono più picchi tra due valli consideriamo solo il primo picco, 
% ipotizzando che il secondo sia un picco dicrotico, quindi da eliminare. 
% se abbiamo due valley e nessun picco in mezzo, allora controllo che la
% distanza tra le sue valley sia minore di quella media,se lo è prendo la
% prima valley, avevamo pensato che sarebbe meglio prendere la minore, ma
% non sono riuscita a farlo perchè quando ne ho più di 2 consecutive ho
% problemi. Ma visto che sono così vicine non penso sia un problema.
% Se sono maggiori della reference allora elimino il segnale in mezzo.
% 