function result = stage2_3(signal, fs)

    fn=fs/2; %Nyquist frequency
    fc_low=0.01/fn; %normalized inferior cut off frequency
    fc_high=15/fn; %normalized superior cut off frequency
    N=2048; %arbitrary  
    order = 4; % specificato nel paper
    
%scompongo high (fc=0.01) e low pass (fc=15)
    [b1,a1] = butter(order,fc_low ,'high');
    %figure()
    %freqz(b1,a1,N,fs);
    [b2,a2] = butter(order,fc_high,'low');
    %figure()
    %freqz(b2,a2,N,fs);
    
    res = filter(b1,a1,signal);
    result = filter(b2,a2,res);
  
end