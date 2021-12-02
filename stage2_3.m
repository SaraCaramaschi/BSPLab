function result = stage2_3(signal, fs)
    fn=fs/2; %Nyquist frequenc
    fc_low=15/fn; %normalized inferior cut off frequency
    fc_high=0.01/fn; %normalized superior cut off frequency
    N=2048; %arbitrary
    
    pad=20;
    signal_to_filter = [ones(pad,1)*signal(1); signal(:); ones(pad,1)*signal(end)];
    
    order = 5; 
    [b,a] = butter(order,[fc_low fc_high],'bandpass');
    freqz(b,a,N)%,fs)
    res = filtfilt(b,a,signal_to_filter);%zero phase filtering
    result=res(pad+1:size(res,1)-pad);
end