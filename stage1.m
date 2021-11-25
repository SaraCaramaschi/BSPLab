function check = stage1(signal, threshold)
%function called for each sample of PPG

% commento inutile 


    if signal<=0 
        check=1;
    elseif signal>=threshold
        check=1;
    end
end

