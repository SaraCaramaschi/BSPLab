
function result = evaluation(pos_annotation_reference,annotation_reference,annotation_computed)

%algorithm performance evaluation: considering that the portions of signal 
%annotated as distured by the algorithm go from one valley to another
%(considering the whole pulsewave) and that the identification of the
%valleys is per se something evaluated by algorithm -> the decision was to
%give different weights to the two types of inaccuracy (simple annotation
%error and annotation error due to incorrect valley identification)

% INPUT:
%     pos_annotation_reference: vector containing initial and final position 
%     of each disturbed interval of the signal
%     annotation_reference: vector of zeros and ones reflecting reference
%     annotations of signal disturbance 
%     annotation_computed: vector of zeros and ones reflecting computed
%     annotations of signal disturbance
% OUTPUT:
%     result: algorithm performance

    
    %creation reference annotations' vector made by zeros and ones
    for i = 1 : 2 : length(pos_annotation_reference)-1
        annotation_reference(pos_annotation_reference(i):pos_annotation_reference(i+1)) =1;
    end
    
    %vector of comparison sample by sample: 1 when equal, 0 when different
    match = (annotation_reference == annotation_computed);
    %count how many times there is no match between computed and reference
    %annotations
    n1 = length(find(match==0));
    
    %initialization count not matched samples in a more permissive range
    %(extended by 150 samples on the left and on the right of the
    % reference annotations' interval)
    count=0; 
    for i = 1:length(pos_annotation_reference)-1
        for j = pos_annotation_reference(i)-150 : pos_annotation_reference(i)+150
            if match(j)==0 %no match 
               count = count+1;
            end
        end
    end
    %count how many time there is no match between computed and reference
    %annotations but in a more permissive range???
    n2 = length(count);
    
    %performance is computed as the maximum (100) to which is subtracted
    %the simple non-match with weight 1 and the non-match in permissive
    %range with weigth 0.5, then normalized by the total number of
    %annotated samples by the reference classification
    result = 100 -((n1*100)+(n2*100*0.5)) / length(annotation_reference);
end