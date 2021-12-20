%% Stage 6

function AnnStage6 = stage6(pulsewave_1, pulsewave_2)

%nella colonna 3 di matrix ci sono picchi e valli
 % first potential valleys PWB 10
 % potential sys peak PWSP 11
 % before second potential valley PWE (pw(end-1))   12
%p1 è la N-1, p2 è la N-2 waveform
%signal 2 è la parte di segnale che viene prima di signal 1

signal_1 = pulsewave_1(:, 1);
signal_2 = pulsewave_2(:, 1);
AnnStage5_1 = pulsewave_1(:, 4);
AnnStage5_2 = pulsewave_2(:, 4);
AnnStage6 = pulsewave_1(:, 5); %relativo a N-1

% %Check direct neighbors
%     if (signal_2(end-1) == 12 AND signal_1(1) == 10)
%         %%yey sono direct neighbors puoi andare avanti
%         flag = 0;
%     else
%         flag = 1; %non sono direct neighbors, passa ai successivi
%     end

%check direct neighbors inutile, lo faccio nel main

flag = 0;
    
% Check 11
    if (flag == 0)
        risetime1 = find(signal_1(AnnStage5_1 == 11)) - 1;
        risetime2 = find(signal_2(AnnStage5_2 == 11)) - 1;
        PWRT = risetime1/risetime2;
        if (PWRT > 3 | PWRT < 0.33)
            flag = 1; %failed check
        end
    end

 % Check 12
    if (flag == 0)
        PWD1 = length(signal_1);
        PWD2 = length(signal_2);
        if (PWD1/PWD2 > 3 | PWD1/PWD2 < 0.33)
            flag = 1; %failed check
        end
    end

 % Check 13
    if (flag == 0)
        PWA_1 = signal_1(AnnStage5_1 == 11) - signal_1(1);
        PWA_2 = signal_2(AnnStage5_2 == 11) - signal_2(1);
        if PWA_1/PWA_2 < 0.25 | PWA_1/PWA_2 > 4
            flag = 1; %failed check
        end

    end

  if flag == 1
      AnnStage6(:) = 1;
  end

  end