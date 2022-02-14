
function [th,annotation4] = stage4 (check,fs)

%identification of peaks and valleys and their classification in systolic
%or diastolic:
%1) computation of moving average threshold
%2) identification of local maxima and minima
%3) comparison of local maxima and minima with threshold to establish if
    %they are real peaks and valleys correspondingly
%4) computation of initial reference PWA and reference consecutive-valleys-distance
    %as mean of PWAs and valleys' distances respectively, excluding samples 
    %classified as disturbed by stage1
%5a) systolic peak criterion verification: a peak is classified as systolic
    %if its amplitude multiplied by a scaling factor (3) is greater than
    %reference PWA
%5b) update reference values if the valley-peak couple results systolic
%6) in case there is no peak between two valleys:
    %6a) if the distance between them multiplied by a scaling factor (1.5)
        %is lower then the reference valley distance -> then the first
        %valley is discarded
    %6b) otherwise -> the signal portion between the two valleys is
    %annotated as disturbed
    
% INPUT:
%     check: check: annotation vector initialization
%     fs: sampling frequency
% OUTPUT:
%     th: moving average threshold
%     annotation4: updated version of annotation vector


%1) calculate the moving average threshold
    signal = check(:,1);
    annotation1 = check(:,2);
    annotation4 = check(:,3);
    
    pwdLength = 2.4; % seconds
    pwdSamples = pwdLength*fs; %samples
    ma_span = 0.75*pwdSamples; %moving average span
    
    %create a variable equal to the signal but with NaN where the signal is 
    %disturbed (reffering to the check of stage1)
    sig = signal;
    sig (annotation1==1) =NaN;
    %threshold vector initialization
    th = ones(size(signal,1),1)*NaN;
    
    %first ma_span of the signal is discarded because cannot be associated 
    %to a threshold
    for i = ma_span+1 : size(sig,1) 
        th(i) = nanmean(sig(i-ma_span : i));
    end
    
%2) find peaks and valleys with matlab function findpeaks
    [~,pos_max] = findpeaks(signal);
    %consider the signal upsidedown to turn valleys into peaks and be 
    %identifiable by findpeaks function
    [~,pos_min] = findpeaks(-signal); 
   
%3) identification of true peaks and valleys of the signal considering
    %their position with respect to the threshold just computed
    for i = 1:size(pos_min,1)
       if ~isnan(th(pos_min(i)))
         if signal(pos_min(i)) < th(pos_min(i)) %valley
            annotation4(pos_min(i)) =-10;
         end
       end 
    end
    for i = 1:size(pos_max,1)
       if ~isnan(th(pos_max(i)))
          if (signal(pos_max(i)) > th(pos_max(i))) %peak
             annotation4(pos_max(i)) =10;
          end
       end
    end

%4) reference PWA and valleys' distances calculation
    pos_valleys = find (annotation4 ==-10);
    for j = 1:length(pos_valleys)-1
        % exclusion of signal classified as disturbed by stage1
        for i = pos_valleys(j):pos_valleys(j+1)
            if annotation1(i) ==1
                annotation4(pos_valleys(j):pos_valleys(j+1)) =1;
            end
        end         
        %peaks in the interval between two consecutive valleys
        ref_peaks = find(annotation4(pos_valleys(j):pos_valleys(j+1))==10); 
        ref_peaks = pos_valleys(j) + ref_peaks-1;  
        %take in consideration only the first peak between two valleys 
        if size(ref_peaks,1) >0
            annotation4(ref_peaks(2:end)) =0; 
            ref_peak = ref_peaks(1);
            ref_pwa(j) = signal(ref_peak) - signal(pos_valleys(j));
            ref_valleydistance(j) = pos_valleys(j+1) - pos_valleys(j);
        else %if there is no peak between two consecutive valleys both PWA 
             %and valleys' distance are not taken into consideration for
             %the mean values
            ref_pwa(j) =NaN;
            ref_valleydistance(j) =NaN;
        end         
    end
    reference_pwa = nanmean(ref_pwa);
    reference_valleydistance = nanmean(ref_valleydistance);
    
%5) systolic-diastolic peaks-valleys classification + reference update
    for j = 1:length(pos_valleys)-1 
        % find all peaks between two valleys       
        position_peaks=[];
        position_peaks = find(annotation4(pos_valleys(j):pos_valleys(j+1)) ==10);
        %signal is not disturbed
        if annotation4(pos_valleys(j):pos_valleys(j+1)) ~=1 
            %there is at least one peak
            if ~isempty(position_peaks) 
                position_peaks = position_peaks + pos_valleys(j)-1;
                % eliminate excess peaks
                annotation4(position_peaks(2:end)) =0; 
                position_peak = position_peaks(1);
                %pulsewave PWA calculation
                pwa = signal(position_peak) - signal(pos_valleys(j));
                
                %verification of criterion
                if pwa*3 < reference_pwa %diastolic valley-peak couple
                    annotation4(position_peak) =2;
                    annotation4(pos_valleys(j)) =-2;
                else %systolic valley-peak couple
                    %update reference pwa and valleys' distance with last
                    %valid one
                    reference_pwa = pwa; 
                    reference_valleydistance = pos_valleys(j+1) - pos_valleys(j);
                end 
                
%6) no peak between two valleys -> check the distance between the valleys 
            else
                if pos_valleys(j+1)-pos_valleys(j) < 1.5*reference_valleydistance
                    %discard the first valley
                    annotation4(pos_valleys(j)) =0; 
                else
                    %annotate signal between the valleys as disturbed
                    annotation4(pos_valleys(j):pos_valleys(j+1)) =1;
                end
            end            
        end
    end   

