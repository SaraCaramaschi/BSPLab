function check = stage1(signal, check, threshold)
%function called for each sample of PPG
    if signal<=0 
        check=1;
    elseif signal>=threshold
        check=1;
    else
        check=check;
    end
end

