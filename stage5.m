%% Stage 5
%input pulsewave contains just one systolic peak

function annStage5 = stage5(matrix, fs)
    signal = matrix(:,1); %pulsewave signal
    annStage1 = matrix(:,2); %annotation of first stage
    annStage4 = matrix(:,3); %annotation of fourth stage (systolic peak = 1, diastolic peak = 2, systolic valley = -1)
    annStage5 = matrix(:,4); %annotation of fifth (current) stage 
   

    flag = 0;%initialization of boolean variable considering the pulswave as not disturbed

    for sample=1:1:length(signal) 
        %% preliminar Check
        if (annStage1(sample) == 1)
            flag = 1;
            break;
            % at least one sample of the pulswave is disturbed -> the whole
            % pulswave is annotated
        end 
    end
        
    %% Check 3
    % PWA calculation: 
    % individuation of systolic valley and corresponding systolic peak
    if flag==0
        peak = signal(annStage4 == 1);
        signal_end = signal(1); 
        PWA = peak - signal_end;
        if PWA <= 2*mean(abs(diff(signal)))
            flag=1; %failed check
        end
    end
    
    %% Check 4
    if flag == 0
        % Rise time 
        tValley = 1; %valley = first sample of the pulswave
        tPeakSys = find(annStage4 == 1);
        PWRT = tPeakSys - tValley; 
        PWRT = PWRT/fs; %conversion to seconds
        if PWRT < 0.08 || PWRT > 0.49
            flag = 1; %failed check
        end
    end
    
    %% Check 5
    if flag==0 
        tValley = length(signal); %last sample of pulsewave is the potential pulsewave end 
        DiastolicPhase = (tValley - tPeakSys); 
        DiastolicPhase = DiastolicPhase/fs; %conversion to seconds 
        PWSDRatio = PWRT/DiastolicPhase; 
        if PWSDRatio > 1.1 
            flag = 1; %failed check
        end
    end
    
    %% Check 6 
    if flag==0 
        PWD = (length(signal)-1)/fs; 
        if PWD < 0.27 || PWD > 2.4 
            flag = 1; %failed check
        end
    end
    
    %% Check 7
    if flag==0
        NumberOfDiastolicPeaks = length(find(annStage4 == 2)); 
        if NumberOfDiastolicPeaks > 2
            flag=1; %failed check
        end
    end
    
    %% Check 8
    if flag==0 
        systolicPhase = signal(1:tPeakSys); 
        if ~isempty(find(diff(systolicPhase)<0)) 
            flag = 1; %failed check
        end
    end
    
    %% Check 9: 
    if flag==0
        diastolicPhase = signal(tPeakSys:end); 
        minDiastolic = min(diastolicPhase); 
        if minDiastolic < signal(1) || minDiastolic < signal(end)
            flag = 1; %failed check
        end
    end
    
    %% Check 10: 
    % nostra interpretazione di PWALeft e PWARight 
    if flag==0
        PWALeft = PWA; 
        signal_end = signal(end); 
        PWARight = peak - signal_end;  
        if (PWALeft/PWARight > 0.4 || PWARight/PWALeft > 0.4) 
            flag=1; %failed check
        end
    end
    
    %%
    if flag==1 %if failed check
        annStage5(1:length(signal)-1) = 1; %annotation on the whole pulsewave as disturbed excepts the last sample
    end
    
    if flag==0
        %% Definiamo tre sample specifici
        % first potential valleys PWB (pw(1)),     10
        % potential sys peak PWSP (annStage4==3)   11
        % before second potential valley PWE (pw(end-1))   12
        annStage5(1) = 10; 
        annStage5(tempo(signal==pic)) = 11; 
        annStage5(end-1) = 12;
    end
        
end