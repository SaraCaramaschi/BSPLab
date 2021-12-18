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
    [~,pos_peaks] = findpeaks(signal);
    [~,pos_valleys] = findpeaks(-signal); %consider the signal upsidedown to turn valleys into peaks and be identificable by findpeaks function
   
    %identification of true peaks and valleys of the signal considering
    %their position with respect to the threshold just computed
    %initialize check as a vector of zeros
    annotation4=zeros(size(signal,1),1);
    for i=1:size(pos_valleys,1)
       if (signal(pos_valleys(i)) < th(pos_valleys(i))) %valley
            annotation4(pos_valleys(i))= -1;
       end
    end
    for i=1:size(pos_peaks,1)               
       if (signal(pos_peaks(i)) > th(pos_peaks(i))) %peak
            annotation4(pos_peaks(i))= 1;
       end
    end
 

    %creation of reference value as maximum between the first 3 pwa
    for j=1:length(pos_valleys)-1
        if j<=3 %reference constructed by the first 3 valley-peak couples
            ref_peaks(j,:) = find(annotation4(pos_valleys(j):pos_valleys(j+1))==1);%first peak in the interval between two consecutive valleys
            if size(ref_peaks(j,:),2)>0
                ref_pwa(j)= signal(ref_peaks(j,1)) - signal(pos_valley(j));
            else 
                ref_pwa(j)=0;
            end
            if j==3
                reference_pwa = max(ref_pwa);   
            end
        else
            position_peak = find(annotation4(pos_valleys(j):pos_valleys(j+1))==1,1);
            position_peak = position_peak + pos_valleys(j)-1;
            pwa = signal(position_peak) - signal(pos_valleys(j));
            if pwa*3 < reference_pwa %diastolic valley-peak couple
                annotation4(position_peak) = 2;
                annotation4(pos_valleys(j)) = -2;
            else
                reference_pwa = pwa; %update of reference pwa with last systolic pwa
            end  
        end
    end
    %non teniamo conto di picchi senza valle e valli senza picchi
    %corrispondenti
end