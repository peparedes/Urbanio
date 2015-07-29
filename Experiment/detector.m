close all
MEAN_SIGNAL=2.5;
MAX_SIGNAL=5;
POS_TRESHOLD=MEAN_SIGNAL+0.1*MAX_SIGNAL;
NEG_TRESHOLD=MEAN_SIGNAL-0.1*MAX_SIGNAL;
flag_n=0;
flag_p=0;
pos_max=0;
pos_min=0;
min_value=0;
max_value=0;
a=datos;
%umbralSup=ones(length(a))*POS_TRESHOLD;
%umbralNeg=ones(length(a))*NEG_TRESHOLD;
plot(a,'c')
%plot(umbralSup);
%plot(umbralNeg);
hold on
grid on

muestra=6330;

for i=2:length(a)
%     if(i>muestra)
%         plot(i,a(i),'bo');
%     end
    if((a(i)>POS_TRESHOLD))
        flag_p=1;
        if(a(i)>a(i-1))
            max_value=a(i);
            pos_max=i;
            flag_p=0;
        end  
    end
    
    if((a(i)<NEG_TRESHOLD))
        flag_n=1;
        if(a(i)<a(i-1))
            min_value=a(i);
            pos_min=i;
            flag_n=0;
        end
    end
    
    
     if((flag_p==1)&&(flag_n==1))
         
         flag_p=0;
         flag_n=0;   
         plot(pos_max,max_value,'b*');
         plot(pos_min,min_value,'r^');
     end
end






