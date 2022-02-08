%Algoritmo per la valutazione
function risultato=valutazione(lable,art,errore)
    v=zeros(size(art,1),1);
    for i=1:2:length(lable)-1
        art(lable(i):lable(i+1))=1;
    end
    val=(art==errore); %1 quando sono uguali, 0 quando sono diversi
    for i=1:length(lable)-1
        for j=lable(i)-150:lable(i)+150
            if val(j)==0
               v(j)=2;
            end
        end
    end
    n2=length(find(v==2));
    n1=length(find(val==0));
    risultato=100-((n1*100)+(n2*100*0.5))/length(art);
end