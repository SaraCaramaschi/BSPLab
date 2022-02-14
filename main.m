clear all
close all
clc

%%
for dataset = 1:10
   %% Loading 
   %training set
%     load('training_dataset.mat');
%     PPG = training_dataset{dataset}.signal.pleth.y;
%     LABELS = training_dataset{dataset}.labels.pleth.artif.x;
   
   %test set
    load('test_dataset.mat');
    PPG = test_dataset{dataset}.signal.pleth.y;
    LABELS = test_dataset{dataset}.labels.pleth.artif.x;


    %%
    %create a matrix having as first column the signal and as second column
    %the initialization of stage1 check
    signal_check=cat(2,PPG,zeros(size(PPG,1),1)); 

    %plot of the original signal
%     figure()
%     plot(signal_check(:,1))
%     title('SIGNAL');

    %% stage 1: top and bottom clipping

    th_high = 10.3; %depends on the type of recording system
    th_low = -10.3;
    for sample=1:size(signal_check,1)
        signal_check(sample,2)=stage1(signal_check(sample,1),signal_check(sample,2),th_low,th_high);
    end

    %plot highlighting samples failing stage1 check
%     figure()
%     plot(signal_check(:,1))
%     title('STAGE 1')
%     hold on
%     plot(find(signal_check(:,2)==1), signal_check(signal_check(:,2)==1,1),'g*')
%     legend('signal','anotation stage1');

    
    %% stage2-3: low-pass and high-pass filters
    
    fs=300; %sampling frequency 
    %filtered signal overwrited to the original one in the first column of
    %the matrix
    signal_check(:,1) = stage2_3(signal_check(:,1), fs);

    %plot of filtered signal
%     figure()
%     plot(signal_check(:,1))
%     title('STAGE 2+3 - POST FILTER');

    %% Stage 4: peaks and valleys identification and classification (systolic or diastolic)
    
    %initialization column of stage 4 annotations
    signal_check(:,3) = zeros(1, size(signal_check,1));
    [moving_average_threshold, signal_check(:,3)] = stage4 (signal_check, fs);  

    %plot of filtered signal highlighting the moving-average threshold,
    %systolic and diastolic peaks and valleys identified
%     figure()
%     plot(signal_check(:,1));
%     title('STAGE 4');
%     hold on
%     plot(moving_average_threshold,'k')
%     hold on
%     plot(find(signal_check(:,3)==10), signal_check(signal_check(:,3)==10,1),'g*')
%     hold on
%     plot(find(signal_check(:,3)==2), signal_check(signal_check(:,3)==2,1),'r*')
%     hold on
%     plot(find(signal_check(:,3)==-10), signal_check(signal_check(:,3)==-10,1),'go')
%     hold on
%     plot(find(signal_check(:,3)==-2), signal_check(signal_check(:,3)==-2,1),'ro')
%     legend ('filtered signal','moving average threshold','systolic peak','systolic valley','diastolic peak','diastolic valley');


    %% STAGE 5: checks on single pulsewaves
    
    %initialization column of stage 5 annotations
    signal_check(:,4) = zeros(size(signal_check(:,1),1),1);

    pos_systolic_valleys = find (signal_check(:,3) == -10);
    for i = 1:size(pos_systolic_valleys,1)-1
        pulsewave = signal_check(pos_systolic_valleys(i):pos_systolic_valleys(i+1),:);
        %give in input to stage5 function the single pulsewaves identified
        signal_check(pos_systolic_valleys(i):pos_systolic_valleys(i+1),4) = stage5(pulsewave, fs);
    end
    
    %plot of filtered signal highlighting PWB, PWSP and PWE
%     figure()
%     plot(signal_check(:,1));
%     hold on
%     title('stage 5');
%     plot(find(signal_check(:,4)==10), signal_check(signal_check(:,4)==10,1),'g*')
%     hold on
%     plot(find(signal_check(:,4)==11), signal_check(signal_check(:,4)==11,1),'bl*')
%     hold on
%     plot(find(signal_check(:,4)==12), signal_check(signal_check(:,4)==12,1),'ro')
%     legend('filtered signal','PWB','PWSP','PWE');

    %% STAGE 6: checks on couples of consecutive pulsewaves
    
    %initialization column of stage 6 annotations
    signal_check(:,5) = zeros(size(signal_check(:,1),1),1);

    pos_pwb = find (signal_check(:,4) == 10);
    pos_pwe = find (signal_check(:,4) == 12);
    for i = 1:size(pos_pwb,1)-1
        if pos_pwe(i)+1 == pos_pwb(i+1) %consecutive pulsewaves
            pulsewave_2 = signal_check(pos_pwb(i):pos_pwe(i),:);
            pulsewave_1 = signal_check(pos_pwb(i+1):pos_pwe(i+1), :);
            signal_check(pos_pwb(i+1):pos_pwe(i+1),5) = stage6(pulsewave_1, pulsewave_2);
        end
    end

    %plot of filtered signal highlighting were stage6 check failed
%     figure()
%     plot(signal_check(:,1));
%     title('STAGE 6');
%     hold on
%     plot(find(signal_check(:,5)==1), signal_check(signal_check(:,5)==1,1),'r*')
%     legend('filtered signal','check failed');
    
    %% final visualization highlighting were the filtered signal has failed checks in stage 1,4,5,6
%?????
    y=-3000:1:3000;
    x=find(signal_check(:,4)==10);
    %??????????
%     LABELS = training_dataset{dataset}.labels.pleth.artif.x;
    
    if length(LABELS)>0 & LABELS(1)==0
        LABELS = LABELS(3:end);
    end
    
%     figure()
%     plot(signal_check(:,1));
%     hold on
%     title(FINAL PLOT');
%     plot(find(signal_check(:,4)==10), signal_check(signal_check(:,4)==10,1),'g*')
%     hold on
%     plot(find(signal_check(:,4)==11), signal_check(signal_check(:,4)==11,1),'bl*')
%     hold on
%     plot(find(signal_check(:,4)==12), signal_check(signal_check(:,4)==12,1),'ro')
%     hold on
%     plot(find(signal_check(:,3)==1), signal_check(signal_check(:,2)==1,1),'r*')
%     hold on
%     plot(find(signal_check(:,3)==1), signal_check(signal_check(:,3)==1,1),'r*')
%     hold on 
%     plot(find(signal_check(:,4)==1), signal_check(signal_check(:,4)==1,1),'r*')
%     hold on
%     plot(find(signal_check(:,5)==1), signal_check(signal_check(:,5)==1,1),'r*')
%     hold on
%     plot(LABELS,signal_check(LABELS,1),'ko')
%     legend('filtered signal','PWB','PWSP','PWE','failed check stage 1','failed check stage 4','failed check stage 5','failed check stage 6','reference annotations' extremes');

    %% algorithm evaluation
    %initialization complexive computed annotations' vector
    annotation_computed = zeros(size(signal_check(:,1),1),1);
    % complexive computed annotations' vector updating
    annotation_computed(find(signal_check(:,2)==1)) =1;
    annotation_computed(find(signal_check(:,3)==1)) =1;
    annotation_computed(find(signal_check(:,4)==1)) =1;
    annotation_computed(find(signal_check(:,5)==1)) =1;
    %reference annotations positions (vector containing positions of the start and end of the artifact portion) 
    pos_annotation_reference = LABELS'; 
    %initialization reference annotation vector (made by zeros and ones)
    annotation_reference = zeros(size(signal_check(:,1),1),1);
    
    performance(dataset) = evaluation(pos_annotation_reference, annotation_reference, annotation_computed);

end

%% average performance on train/test set
mean_performance = mean (performance)


