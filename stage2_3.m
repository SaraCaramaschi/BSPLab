function result = stage2_3(signal, fs)
    fn=fs/2; %Nyquist frequenc
    fc_low=15/fn; %normalized inferior cut off frequency
    fc_high=0.01/fn; %normalized superior cut off frequency
    N=2048; %arbitrary
    
    order = 4; 
    [b,a] = butter(order,[fc_low fc_high],'bandpass');
    freqz(b,a,N)%,fs)
    result = filter(b,a,signal);
    
end