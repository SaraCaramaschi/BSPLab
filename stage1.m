function check = stage1(signal, check, threshold_low, threshold_high)
%updating of annotation vector: change to "1" in correspondence to samples 
%over upper clipping threshold or under lower clipping threshold, otherwise maintain "0"

% INPUT:
%     signal: filtered signal
%     check: annotation vector initialization
%     threshold_low: lower clipping threshold
%     threshold_high: upper clipping threshold
% OUTPUT:
%     check: updated version of annotation vector

    if signal <= threshold_low 
        check=1;
    elseif signal >= threshold_high
        check=1;
    end
    
end

