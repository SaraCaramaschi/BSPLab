
function result = evaluation(label,art,error)
    v = zeros(size(art,1),1);
    for i=1:2:length(label)-1
        art(label(i):label(i+1))=1;
    end
    val = (art==error); %1 when equal, 0 when different
    for i = 1:length(label)-1
        for j = label(i)-150:label(i)+150
            if val(j)==0
               v(j) = 2;
            end
        end
    end
    n2 = length(find(v==2));
    n1 = length(find(val==0));
    result = 100-((n1*100)+(n2*100*0.5)) / length(art);
end