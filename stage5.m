%% Stage 5

% Secondo buffer con info su picchi e valli. Consideriamo come input: 
% altezza buffer e lunghezza 1 (picchi sys = 3, picchi dys = 2, valley = 1, nulla=0 ) 


function matrix = stage5(matrix, fs)
    pw = matrix(:,1);
    tempo= [1:length(pw)];
    annStage1 = matrix(:,2);
    annStage4 = matrix(:,3);
    annStage5 = zeros(1,length(pw));
    
    
% C'è ritardo: 2.4s. I parametri li calcoliamo sulla:
% Each time a complete pulse wave (called N-1 pulse wave) is recorded, 
% the fifth stage with the second decision list checks absolute and 
% relative pulse wave characteristics.
% noi conosciamo gia 2.4 sec di segnale+annotazioni (pulswave precedente) 

    flag = 0;
    % single raw sample disturbed or not 
    
    % TODO: ricompatta questo for
    for sample=1:1:length(pw) 
        %% Check prima del 3
        if (annStage1(sample) == 1)
            flag = 1;
            break;
            % Tutta la pulsewave e' 1, artifact
        end 
    end
        
    %% Check 3
    % Calcolo PWA della pulse wave: 
    % individuo picco e valley e sottraggo
    if flag==0
        picMax = max(pw); 
        pic = pw(annStage4 == 3);
        if picMax == pic
            combaciano = 1; 
        end

        valley = pw(1); 
        PWA = pic - valley;

        if PWA <= 2*mean(abs(diff(pw)))
            flag=1;
        end
    end
    
    %% Check 4
    if flag == 0
        % Rise time 
        tValley = 1;
        % prendiamo gli indici di sample del vettore che ha dentro 
        % i valori == 3
        tPicSys = tempo(annStage4 == 3);
        if length(tPicSys) ~= 1
            tPicSys = tPicSys(1);
        end
        PWRT = tPicSys - tValley; 
        PWRT = PWRT/fs;
        if PWRT<0.08 || PWRT>0.49
            flag = 1; 
        end
    end
    
    %% Check 5
    if flag==0 
        tValley = length(pw); 
        DT = (tValley - tPicSys)/fs; 
        PWSDRatio = PWRT/DT; 
        if PWSDRatio>1.1 
            flag = 1;
        end
    end
    
    %% Check 6 
    if flag==0 
        PWD = length(pw)/fs; 
        if PWD < 0.27 || PWD > 2.4 
            flag = 1;
        end
    end
    
    %% Check 7
    if flag==0
        NPDys = annStage4(annStage4 == 2); 
        % prendiamo la lunghezza del vettore che ha dentro i valori 
        if length(NPDys) > 2
            flag=1;
        end
    end
    
    %% Check 8: Monotonia
    if flag==0 
        sys = pw(1:tPicSys); 
        difSys = diff(sys); 
        if ~isempty(difSys(difSys<0)) 
            flag = 1; 
        end
    end
    
    %% Check 9: 
    if flag==0
        dys = pw(tPicSys:end); 
        minDys = min(dys); 
        if minDys < pw(1) || minDys < pw(end)
            flag = 1;
        end
    end
    
    %% Check 10: 
    % nostra interpretazione di PWALeft e PWARight 
    if flag==0
        PWALeft = PWA; 
        valley = pw(end); 
        PWARight = pic - valley;
        
        if (PWALeft/PWARight > 0.4 || PWARight/PWALeft > 0.4) 
            flag=1;
        end
    end
    
    %%
    if flag==1 
        annStage5(1:length(pw)-1) = 1;
    end
    
    if flag==0
        %% Definiamo tre sample specifici
        % first potential valleys PWB (pw(1)),     10
        % potential sys peak PWSP (annStage4==3)   11
        % before second potential valley PWE (pw(end-1))   12
        annStage5 = zeros(1,length(pw)); 
        annStage5(1) = 10; 
        annStage5(tempo(pw==pic)) = 11; 
        annStage5(end-1) = 12;
    end
    
    matrix(:,4) = annStage5;
    
end