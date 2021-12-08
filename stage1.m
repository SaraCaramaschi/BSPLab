function check = stage1(signal, check, threshold_low, threshold_high)
%function called for each sample of PPG

    if signal<=threshold_low 
        check=1;
    elseif signal>=threshold_high
        check=1;
    else
        check=check;
    end
    
end

