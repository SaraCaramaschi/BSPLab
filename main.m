clear all
close all
clc

%%
for dataset = 1:10
   % Loading 
   %training set
%     load('training_dataset.mat');
%     PPG = training_dataset{dataset}.signal.pleth.y;
%     LABELS = training_dataset{dataset}.labels.pleth.artif.x;
%    
   %test set
    load('test_dataset.mat');
    PPG = test_dataset{dataset}.signal.pleth.y;
    LABELS = test_dataset{dataset}.labels.pleth.artif.x;
    
    %if first annotated portion starts at the beginning of the signal, can't be
    %detected by the algorithm because moving-average threshold can't be
    %computed for the first part of the signal (equivalent to the span necessary for
    %its own computation) -> first couple of annotations (initial and final
    %position of the perturbated portion) is discarded
    if ~isempty(LABELS) && LABELS(1)==0
        LABELS = LABELS(3:end);
    end


    %%
    %create a matrix having as first column the signal and as second column
    %the initialization of stage1 check
    signal_check=cat(2,PPG,zeros(size(PPG,1),1)); 

%     plot of the original signal
%     figure()
%     plot(signal_check(:,1))
%     title('SIGNAL');

    %% stage 1: top and bottom clipping

    th_high = 10.5; %depends on the type of recording system
    th_low = -10.5;
    for sample=1:size(signal_check,1)
        signal_check(sample,2)=stage1(signal_check(sample,1),signal_check(sample,2),th_low,th_high);
    end

    %plot highlighting samples failing stage1 check
%     figure()
%     s=signal_check(:,1);
%     plot(s(15800:17000))
%     title('STAGE 1')
%     %hold on
%     %plot(find(signal_check(:,2)==1), signal_check(signal_check(:,2)==1,1),'g*')
%     legend('signal','anotation stage1');

    
    %% stage2-3: low-pass and high-pass filters
    
    fs=300; %sampling frequency 
    %filtered signal overwrited to the original one in the first column of
    %the matrix
    signal_check(:,1) = stage2_3(signal_check(:,1), fs);


    %plot of filtered signal
%     figure()
%     s=signal_check(:,1);
%     plot(s(15800:17000))
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
    
    [cm{dataset},performance(dataset)] = evaluation(pos_annotation_reference, annotation_reference, annotation_computed);
    TN = cm{dataset}(1,1);
    if size(cm{dataset})~= [1,1] 
        FP = cm{dataset}(1,2);
        FN = cm{dataset}(2,1);
        TP = cm{dataset}(2,2);
        PRECISION = TP/(TP+FP);
        RECALL = TP/(TP+FN);
        F1(dataset) = (PRECISION*RECALL*2)/(PRECISION+RECALL);
        acc(dataset) = (TP+TN)/size(annotation_computed,1);
        classification_error(dataset) = (FP+FN)/size(annotation_computed,1);
    else 
        F1(dataset) =NaN; %no TP -> F1=NaN even if the computed annotations are correct
        FP = 0;
        FN = 0;
        TP = 0;
        acc(dataset) =(TP+TN)/size(annotation_computed,1);
        classification_error(dataset) = (FP+FN)/size(annotation_computed,1);

    end
    %% Metric Calculation
    %create a new matrix with the filtered PPG in the first column.
    %the second column have all the annotations and the error. 
    result=cat(2,signal_check(:,1),zeros(size(signal_check(:,1),1),1));
    result(find(signal_check(:,4)==10),2)=10; % begin of the pulsewave
    result(find(signal_check(:,4)==11),2)=11; % peak of the pulsewave
    result(find(signal_check(:,4)==12),2)=12; % end of the pulewave
    result(find(signal_check(:,2)==1),2)=1; 
    result(find(signal_check(:,3)==1),2)=1; 
    result(find(signal_check(:,4)==1),2)=1; 
    result(find(signal_check(:,5)==1),2)=1; 
    begin=find(result(:,2)==10);
    peak=find(result(:,2)==11);
    ended=find(result(:,2)==12);
    %calculation of the metric for all the pulsewave.
    for i=1:length(begin)
        PWA=result(peak(i),1)-result(begin(i),1); %Pulse wave amplitude
        PWD=ended(i)-begin(i);   %Pulse wave duration
        risetime=peak(i)-begin(i);
    end
    % calculation of the mean metric. 
    PWA_mean(dataset)=mean(PWA);
    PWD_mean(dataset)=mean(PWD);
    risetime_mean(dataset)=mean(risetime);
    pulserate(dataset)=length(peak)/8;
    %% Final plot
    figure()
    plot(result(:,1));
    hold on
    title('FINAL PLOT');
    plot(begin, result(begin,1),'g*')
    hold on
    plot(peak, result(peak,1),'bl*')
    hold on
    plot(ended, result(ended,1),'ro')
    hold on
    plot(find(result(:,2)==1), result(result(:,2)==1,1),'r*')
    hold on
    plot(LABELS,signal_check(LABELS,1),'ko')
    legend('filtered signal','PWB','PWSP','PWE','failed check stage 1-4-5-6','reference annotations extremes');
        
end

%% average performance on train/test set
mean_performance = mean (performance)
F1_mean = nanmean(F1)
mean_acc = nanmean(acc)
mean_ce = nanmean(classification_error)
%%

