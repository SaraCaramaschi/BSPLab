
function result = stage2_3(signal, fs)

%filtering of the signal

% INPUT:
%     signal: original signal
%     fs: sampling frequency
% OUTPUT:
%     result: filtered signal

    fn = fs/2; %Nyquist frequency
    fc_low = 0.01/fn; %normalized inferior cut off frequency
    fc_high = 15/fn; %normalized superior cut off frequency 
    order = 4;    
    %subdivision in high-pass and low-pass filter
    [b1,a1] = butter(order,fc_low,'high');
    [b2,a2] = butter(order,fc_high,'low');
    res = filter(b1,a1,signal);
    result = filter(b2,a2,res);
  
end