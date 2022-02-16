
function annotaion5 = stage5(matrix, fs)

%verification of checks on single pulsewaves

% INPUT:
%     matrix: single pulsewave's portion of the signal_check matrix
%     fs: sampling frequency
% OUTPUT:
%     annotation5: updated version of annotation vector   
       
    signal = matrix(:,1); %pulsewave signal
    annotation1 = matrix(:,2); %stage1 annotation
    annotation4 = matrix(:,3); %stage4 annotation (systolic peak = 10, diastolic peak = 2,
    %systolic valley = -10)
    annotaion5 = matrix(:,4); %stage5 annotation (initialization)
      
    flag =0; %initialization of boolean variable considering the pulswave as not disturbed
 
    %% Preliminar Check 
    % if at least one sample of the pulswave is classified as disturbed by stage1 
    % -> the whole pulswave is annotated
    for sample = 1:length(signal) 
        if (annotation1(sample) ==1)
            flag = 1; %failed check          
            break;          
        end 
    end
        
    %% Check 3
    % PWA calculation: 
    % individuation of systolic valley and corresponding systolic peak
    if flag==0
        peak = signal(annotation4 == 10);
        signal_beginning = signal(1); 
        PWA = peak - signal_beginning;
        if PWA <= 2*mean(abs(diff(signal)))           
            flag=1; %failed check
        end
    end
    
    %% Check 4 
    % Rise time
    if flag == 0
        tValley = 1; %valley = first sample of the pulswave
        tPeakSys = find(annotation4 == 10);
        PWRT = tPeakSys - tValley; 
        PWRT = PWRT/fs; %conversion to seconds
        if ((PWRT < 0.08) | (PWRT > 0.56))          
            flag = 1; %failed check            
        end
    end
    
    %% Check 5
    % Systolic-Diastolic Ratio
    if flag==0 
        tValley = length(signal); %last sample of pulsewave is the potential pulsewave end 
        DiastolicPhase = (tValley - tPeakSys); 
        DiastolicPhase = DiastolicPhase/fs; %conversion to seconds 
        PWSDRatio = PWRT/DiastolicPhase;
        if PWSDRatio > 1.6          
            flag = 1; %failed check            
        end
    end
    
    %% Check 6 
    %PulseWave Duration
    if flag==0 
        PWD = (length(signal)-1)/fs; 
       if PWD < 0.27 | PWD > 2.4  
            flag = 1; %failed check                    
       end
    end
   
    %% Check 7
    %diastolic peaks number
    if flag==0
        NumberOfDiastolicPeaks = length(find(annotation4 == 2)); 
        if NumberOfDiastolicPeaks > 2
            flag=1; %failed check                     
        end
    end
    
    %% Check 8
    %monotonic systolic phase
    if flag==0 
        systolicPhase = signal(1:tPeakSys);    
        if ~isempty(find(diff(systolicPhase)<0, 1)) 
            flag = 1; %failed check          
        end
    end
    
    %% Check 9: 
    %excessive low-amplitude valley in DiastolicPhase:
    %check fails when amplitude difference between PWE or PWB from DiastolicPhase
    %minimum overcomes established threshold
    if flag==0
        diastolicPhase = signal(tPeakSys:end); 
        minDiastolic = min(diastolicPhase); 
        if (signal(tPeakSys) - minDiastolic) > 2*(signal(tPeakSys) - signal(1))|...
                (signal(tPeakSys) - minDiastolic) > 1.7*(signal(tPeakSys) - signal(end))
            flag = 1; %failed check         
        end
    end
    
    %% Check 10: 
    % PWALeft and PWARight 
    if flag==0
        PWALeft = PWA ;
        signal_end = signal(end); 
        PWARight = peak - signal_end;
        if (PWALeft/PWARight > 2 | PWARight/PWALeft > 2) 
            flag=1; %failed check                 
        end
    end
    
    %% Final annotation
    if flag==1 % failed check
        %annotation on the whole pulsewave as disturbed excepts the last sample
        %(that corresponds to beginning of following pulsewave)
        annotaion5(1:length(signal)-1) = 1; 
    else %flag == 0
        % characteristic pulsewave's elements annotation
            % first potential valleys PWB (pw(1)) -> 10
            % potential sys peak PWSP (annStage4==1) -> 11
            % sample before second potential valley PWE (pw(end-1)) -> 12
        if isempty(tPeakSys)
            annotaion5(1:length(signal)-1) =1;
        else
          annotaion5(1) =10; 
          annotaion5(tPeakSys) =11; 
          annotaion5(end-1) =12;
        end      
    end       
end
