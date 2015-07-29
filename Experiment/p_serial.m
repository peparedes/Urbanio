clear all 
close all
s = serial('COM8');
set(s,'BaudRate',9600);
fopen(s);
i=1
tamano=1500;

a=zeros(tamano,1);
while(i<tamano)
    valor = fscanf(s);
    texto=sprintf('Muestra nro %d = %f\n\r',i,valor);
    disp(texto);
    a(i)=str2double(valor);
    i=i+1;
end

fclose(s)
delete(s)
clear s


plot(a)
axis([-inf inf 0 5]);
grid on