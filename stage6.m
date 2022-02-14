
function annotation6 = stage6(pulsewave_1, pulsewave_2)

%verification of checks on couples of consecutive pulsewaves

% INPUT:
%     pulsewave_1: portion of signal_check matrix of the right (successive) pulsewave of the couple
%     pulsewave_2: portion of signal_check matrix of the left (previous) pulsewave of the couple
% OUTPUT:
%     annotation6: updated versio of annotation vector 

signal_1 = pulsewave_1(:,1);
signal_2 = pulsewave_2(:,1);
annotation5_1 = pulsewave_1(:,4);
annotation5_2 = pulsewave_2(:,4);
annotation6 = pulsewave_1(:,5); %relative to second pulsewave of the couple

flag = 0; %initialization of boolean variable considering the pulswave as not disturbed

    %% Check 11
    %Rize Time variation     
    risetime1 = find(annotation5_1 == 11);
    risetime2 = find(annotation5_2 == 11) ;
    PWRT = risetime1/risetime2;
    if PWRT > 3 | PWRT < 0.33
        flag = 1; %failed check
    end

    %% Check 12
    %PulseWave Duration variation
    if flag == 0
        PWD1 = length(signal_1);
        PWD2 = length(signal_2);
        if PWD1/PWD2 > 3 | PWD1/PWD2 < 0.33
            flag = 1; %failed check           
        end
    end

    %% Check 13
    %PulseWave Amplitude variation
    if flag == 0
        PWA_1 = signal_1(annotation5_1 == 11) - signal_1(1);
        PWA_2 = signal_2(annotation5_2 == 11) - signal_2(1);
        if PWA_1/PWA_2 < 0.25 | PWA_1/PWA_2 > 4
            flag = 1; %failed check          
        end
    end

    %% Final annotation
    if flag == 1
        annotation6(:) = 1;
    end

end
