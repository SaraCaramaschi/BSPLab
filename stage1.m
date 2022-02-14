
function annotation1 = stage1(signal, annotation1, threshold_low, threshold_high)

%updating of annotation vector: change to "1" in correspondence to samples 
%over upper clipping threshold or under lower clipping threshold, otherwise maintain "0"

% INPUT:
%     signal: filtered signal
%     check: annotation vector initialization
%     threshold_low: lower clipping threshold
%     threshold_high: upper clipping threshold
% OUTPUT:
%     annotation1: updated version of annotation vector

    if signal <= threshold_low 
        annotation1=1;
    elseif signal >= threshold_high
        annotation1=1;
    end
    
end

