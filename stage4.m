function [th,annotation4] = stage4 (signal, annotation1, fs)   
    %calculate the moving average threshold
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
            annotation4(pos_min(i))= -1;
         end
       end
       
    end
    for i=1:size(pos_max,1)
       if ~ isnan (th(pos_max(i)))
          if (signal(pos_max(i)) > th(pos_max(i))) %peak
             annotation4(pos_max(i))= 1;
          end
       end
    end
 
    pos_valleys = find (annotation4 == -1);
    
    %creation of reference value as maximum between the first 3 pwa
    for j=1:length(pos_valleys)-1
        if j<=3 %reference constructed by the first 3 valley-peak couples
            ref_peaks = find(annotation4(pos_valleys(j):pos_valleys(j+1))==1); %peaks in the interval between two consecutive valleys
            ref_peaks=pos_valleys(j)+ref_peaks-1;
            
            if size(ref_peaks,1)>0
                annotation4(ref_peaks(2:end))=0; % take in consideration only the first peak between two valleys (not considere a peak without a valley)
                ref_peak=ref_peaks(1);
                ref_pwa(j)= signal(ref_peak) - signal(pos_valleys(j));
            else 
                ref_pwa(j)=0;
            end
            if j==3
                reference_pwa = max(ref_pwa);   
            end
            
        else
            position_peaks = find(annotation4(pos_valleys(j):pos_valleys(j+1))==1); % find all peaks between two valleys
            
            position_peaks = position_peaks + pos_valleys(j)-1;
            if size(position_peaks,1)>0
                annotation4(position_peaks(2:end))=0;
                position_peak=position_peaks(1);
                pwa = signal(position_peak) - signal(pos_valleys(j));
                if pwa*3 < reference_pwa %diastolic valley-peak couple
                    annotation4(position_peak) = 2;
                    annotation4(pos_valleys(j)) = -2;
                else
                    reference_pwa = pwa; %update of reference pwa with last systolic pwa
                end  
            end 
        end
    end
    %non teniamo conto di picchi senza valle e valli senza picchi
    %corrispondenti
end