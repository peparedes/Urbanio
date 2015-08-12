function varargout = Experiment(varargin)
% EXPERIMENT MATLAB code for Experiment.fig
%      EXPERIMENT, by itself, creates a new EXPERIMENT or raises the existing
%      singleton*.
%
%      H = EXPERIMENT returns the handle to a new EXPERIMENT or the handle to
%      the existing singleton*.
%
%      EXPERIMENT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPERIMENT.M with the given input arguments.
%
%      EXPERIMENT('Property','Value',...) creates a new EXPERIMENT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Experiment_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Experiment_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Experiment

% Last Modified by GUIDE v2.5 11-Aug-2015 22:28:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Experiment_OpeningFcn, ...
                   'gui_OutputFcn',  @Experiment_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Experiment is made visible.
function Experiment_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Experiment (see VARARGIN)

% Choose default command line output for Experiment
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Experiment wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Experiment_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, ~)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userID=get(handles.edit1,'String');

%sPort=serial('/dev/tty.usbmodemfa142');%COM8');
delete(instrfindall);
sPort=serial('COM7');%COM8');
fclose(sPort);
set(sPort,'BaudRate',115200);


myDebug=0;
% ---- Abrimos el puerto serial -----------------------------------
try
    if(myDebug==0)
        if(strcmp(sPort.status,'closed'))
            fopen(sPort);  
            Port.ReadAsyncMode = 'manual';
        end
        readasync(sPort);
    end
    setappdata(handles.figure1,'serialPort',sPort);
catch
    if(strcmp(sPort.status,'closed'))
        set(handles.text11,'String','Invalid serial port!');
        set(handles.text11,'visible','on');
        pause(1);
        set(handles.text11,'visible','off');
        return;
    end
end

if(isempty(userID))     %Chequeamos si no esta en blanco el campo
    set(handles.text11,'String','Subject ID invalid!');
    set(handles.text11,'visible','on');
    pause(1);
    set(handles.text11,'visible','off');   
else   %
    set(handles.text1,'Enable','on');
    set(handles.text5,'Enable','on');
    set(handles.text5,'String',userID);
    set(handles.text4,'Enable','on');
    set(handles.text8,'Enable','on');
    set(handles.text8,'ForegroundColor',[1 0 0]);
    set(handles.text8,'String','IDLE');
    set(handles.pushbutton2,'Visible','on');
    set(handles.pushbutton3,'Visible','on');
    set(handles.pushbutton2,'Enable','on');
    set(handles.text11,'String','');
    set(handles.pushbutton1,'Visible','off');
    set(handles.text9,'Visible','off');
    set(handles.edit1,'Visible','off');
    set(handles.text4,'Value',1);
    set(handles.text8,'Value',0); %Este define la posicion en la que se quedo
    set(handles.uipanel5,'Visible','on');
    set(handles.pushbutton2,'String','GO');
    %Revisamos si existe un archivo de log con pruebas anteriores. Si no
    %existe creamos uno
    set(handles.text5,'UserData',({'0 (Test Run)','1 step before','3 steps before',...
        '6 steps before','1 light',' 2 lights','3 lights','0% base','5% base','20% base','waves',''}));
    name=strcat(get(handles.text5,'String'),'_log.txt');
    names=get(handles.text5,'UserData');
    
    if(strcmp(upper(userID),'TEST'))
        data=1:10;
        data1(1,:)=[0 data];
        data1(2,:)=[0 0 0 0 0 0 0 0 0 0 0];
    else 
        if(exist(name))
            data1=load(name)

            %Revisamos cual fue la ultima condicion
            for i=0:10
                if(data1(2,i+1)==0)
                    break;
                else
                    set(handles.text8,'Value',get(handles.text8,'Value')+1) 
                    set(handles.text13,'String',strcat(get(handles.text13,'String'),{'  -  '},{ '['}, num2str(i),'/10',{'] '},names{1,data1(1,i+1)+1}))
                end
            end

        else
            m=load('order.txt');
            [maxim,pos]=max(m(:,1));
            data=m(pos,2:11);
            m(pos,1)=0;
            pos=pos+1;
            if(pos>11)
                pos=1;
            end
            m(pos,1)=1;
            save('order.txt','m','-ascii');

            %data=1:9;
            data1(1,:)=[0 data];
            %data1(1,:)=[0 0 0 0 0 0 0 0 0 0];
            data1(2,:)=[0 0 0 0 0 0 0 0 0 0 0];
            save(name,'data1','-ascii');
        end
    end
    set(handles.text11,'ForegroundColor',[0 0 0]);
    set(handles.text11,'Visible','on');
    set(handles.text11,'String','Press button to start..');
    set(handles.text9,'UserData',data1);
    if(get(handles.text8,'Value')==0)
        set(handles.text7,'String','1/1');
    else
        set(handles.text7,'String','1/2');
    end
    if((get(handles.text8,'Value')+1)<11)
        data1(1,get(handles.text8,'Value')+1)
        set(handles.text6,'String',names{1,data1(1,get(handles.text8,'Value')+1)+1});
    else
        set(handles.text8,'Value',get(handles.text8,'Value')+1)
        set(handles.pushbutton2,'Enable','on');
         set(handles.text1,'Enable','off');
         set(handles.text2,'Enable','off');
         set(handles.text3,'Enable','off');
         set(handles.text4,'Enable','off');
         set(handles.text5,'Enable','off');
         set(handles.text6,'Enable','off');
         set(handles.text7,'Enable','off');
         set(handles.text8,'Enable','off');  
         set(handles.pushbutton2,'String','NEXT');
         set(handles.text11,'Visible','on');
         set(handles.text11,'String','The test has been completed for this user!');
    end
    get(handles.text8,'Value');
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userID=get(handles.edit1,'String');
sPort=getappdata(handles.figure1,'serialPort');
%Verificamos que si el usuario tiene mas tests pendientes
if((get(handles.text8,'Value')+1)>12)
         set(handles.text5,'String',' ');
         set(handles.text6,'String',' ');
         set(handles.text7,'String',' ');
         set(handles.text8,'String','OFF');
         set(handles.pushbutton1,'Visible','on');
         set(handles.text9,'Visible','on');
         set(handles.edit1,'String','');
         set(handles.edit1,'Visible','on');
         set(handles.text8,'Value',0); 
         set(handles.pushbutton2,'visible','off');
         set(handles.pushbutton3,'Visible','off');
         set(handles.uipanel5,'Visible','off');
         set(handles.text13,'String','');
         set(handles.text11,'String','');
         return
end

% Si el usuario tiene mas test pendientes, cargamos la secuencia -----
myDebug=0;
orden1=get(handles.text9,'UserData');
orden=orden1(1,:);
%get(handles.text9,'UserData')
names=get(handles.text5,'UserData');
status=orden(get(handles.text8,'Value')+1);

% % ---- Abrimos el puerto serial -----------------------------------
% if(myDebug==0)
%     sPort=getappdata(handles.figure1,'serialPort');
%     if(strcmp(sPort.status,'closed'))
%         fopen(sPort);  
%         Port.ReadAsyncMode = 'manual';
%     end
%     readasync(sPort);
% end

% ---- Abrimos el archivo de datos del usuario para escritura -------------
name=strcat(get(handles.text5,'String'),'_','Test',num2str(status),'_',num2str(get(handles.text4,'Value')),'.txt');
miArchivo=fopen(name,'wt');
data='';
    switch(status)
     case 0  % Test run 0
        set(handles.pushbutton2,'Enable','off'); 
        set(handles.text2,'Enable','on');
        set(handles.text3,'Enable','on');
        set(handles.text6,'Enable','on');
        set(handles.text7,'Enable','on');
        set(handles.text8,'ForegroundColor',[0 0.8 0]);
        set(handles.text8,'String','ACTIVE'); 
        set(handles.text11,'ForegroundColor',[0 0 0]);
        
        set(handles.text11,'String','Please wait. Checking for sensors....');
        set(handles.text11,'Visible','on');
        drawnow;
        
        if(myDebug==0)
        % --- Send command to begin ---
        try
            fprintf(sPort,'1');
        end
        
        miEvent='';
        data='';
        while(~strcmp(miEvent,'Timer timeStamp'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort); 
                     end
                end 
           miEvent=strtok(data,',');
        end
        %set(handles.text11,'String',data);
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
        % --- Send command to iCase[S/H] ---
        try
            fprintf(sPort,'3');
        end
        
        miEvent='';
        data='';
        while(~strcmp(miEvent,'iCase[S|H]'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
       % --- Send command to iTimeCase[B/D/A/R] ---
        try
            fprintf(sPort,':');     %Enviamos el 58
        end 
        miEvent='';
        data='';
        while(~strcmp(miEvent,'Sensors states:'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                         fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
                     end
                end 
           miEvent=strtok(data,',');
        end
        

        % --- Send command to begin ---
        try
            fprintf(sPort,'1');
        end 
        miEvent='';
        data='';
        while(~strcmp(miEvent,'iCommand'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        set(handles.text11,'String','Sensors are ok. GO!');
        drawnow;
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
        %Enviamos el threshold
        try
            fprintf(sPort,(get(handles.edit2,'String')));
        end
        
        % Wait for 'End' code    
        miEvent='';
        data='';
        while(~strcmp(miEvent,'End'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);
                         fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
                     end
                end 
           miEvent=strtok(data,',');
        end
        end
     
        
        set(handles.text8,'Value',get(handles.text8,'Value')+1);
        set(handles.text7,'String','1/2');
     
     case 1     % Case Before 1 steps - 1 light
        set(handles.pushbutton2,'Enable','off'); 
        set(handles.text2,'Enable','on');
        set(handles.text3,'Enable','on');
        set(handles.text6,'Enable','on');
        set(handles.text7,'Enable','on');
        set(handles.text8,'ForegroundColor',[0 0.8 0]);
        set(handles.text8,'String','ACTIVE'); 
        set(handles.text11,'ForegroundColor',[0 0 0]);
        set(handles.text11,'String','Ready...');
        set(handles.text11,'Visible','on');
        
         if(myDebug==0)
        % --- Send command to begin ---
        try
            fprintf(sPort,'2');
        end
        
        miEvent='';
        data='';
        while(~strcmp(miEvent,'Timer timeStamp'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        %set(handles.text11,'String',data);
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
        % --- Send command to iCase[S/H] ---
        try
            fprintf(sPort,'1');
        end
        
        miEvent='';
        data='';
        while(~strcmp(miEvent,'iCase[S|H]'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
       % --- Send command to iTimeCase[B/D/A/R] ---
        try
            fprintf(sPort,'1');
        end 
        miEvent='';
        data='';
        while(~strcmp(miEvent,'Sensors states:'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort); 
                         fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
                     end
                end 
           miEvent=strtok(data,',');
        end
        
        % --- Send command to begin ---
        try
            fprintf(sPort,'1');
        end 
        miEvent='';
        data='';
        while(~strcmp(miEvent,'iCommand'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        set(handles.text11,'String','Sensors are ok. GO!');
        drawnow;
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
        %Enviamos el threshold
        try
            fprintf(sPort,(get(handles.edit2,'String')));
        end
        
        % Wait for 'End' code    
        miEvent='';
        data='';
        while(~strcmp(miEvent,'End'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);
                         fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
                     end
                end 
           miEvent=strtok(data,',');
        end
         end
        
         if(get(handles.text4,'Value')==1)
            set(handles.text4,'Value',2);
            set(handles.text7,'String','2/2');
         else
            set(handles.text4,'Value',1);
            set(handles.text8,'Value',get(handles.text8,'Value')+1);
            set(handles.text7,'String','1/2');
         end
         
         
     case 2     % Case Before 3 steps - 1 light
        set(handles.pushbutton2,'Enable','off'); 
        set(handles.text2,'Enable','on');
        set(handles.text3,'Enable','on');
        set(handles.text6,'Enable','on');
        set(handles.text7,'Enable','on');
        set(handles.text8,'ForegroundColor',[0 0.8 0]);
        set(handles.text8,'String','ACTIVE'); 
        set(handles.text11,'ForegroundColor',[0 0 0]);
        set(handles.text11,'String','Ready...');
        set(handles.text11,'Visible','on');
        
        if(myDebug==0)
        % --- Send command to begin ---
        try
            fprintf(sPort,'2');
        end
        
        miEvent='';
        data='';
        while(~strcmp(miEvent,'Timer timeStamp'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        %set(handles.text11,'String',data);
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
        % --- Send command to iCase[S/H] ---
        try
            fprintf(sPort,'1');
        end
        
        miEvent='';
        data='';
        while(~strcmp(miEvent,'iCase[S|H]'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
       % --- Send command to iTimeCase[B/D/A/R] ---
        try
            fprintf(sPort,'2');
        end 
        miEvent='';
        data='';
        while(~strcmp(miEvent,'Sensors states:'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort); 
                         fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
                     end
                end 
           miEvent=strtok(data,',');
        end
       

        % --- Send command to begin ---
        try
            fprintf(sPort,'1');
        end 
        miEvent='';
        data='';
        while(~strcmp(miEvent,'iCommand'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        set(handles.text11,'String','Sensors are ok. GO!');
        drawnow;
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
        %Enviamos el threshold
        try
            fprintf(sPort,(get(handles.edit2,'String')));
        end
        
        % Wait for 'End' code    
        miEvent='';
        data='';
        while(~strcmp(miEvent,'End'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);
                         fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
                     end
                end 
           miEvent=strtok(data,',');
        end
         end
        
        
         if(get(handles.text4,'Value')==1)
            set(handles.text4,'Value',2);
            set(handles.text7,'String','2/2');
         else
            set(handles.text4,'Value',1);
            set(handles.text8,'Value',get(handles.text8,'Value')+1);
            set(handles.text7,'String','1/2');
         end
        
     case 3     %Case Before 6 steps - 1 light
        set(handles.pushbutton2,'Enable','off'); 
        set(handles.text2,'Enable','on');
        set(handles.text3,'Enable','on');
        set(handles.text6,'Enable','on');
        set(handles.text7,'Enable','on');
        set(handles.text8,'ForegroundColor',[0 0.8 0]);
        set(handles.text8,'String','ACTIVE'); 
        set(handles.text11,'ForegroundColor',[0 0 0]);
        set(handles.text11,'String','Ready...');
        set(handles.text11,'Visible','on');
        
         if(myDebug==0)
        % --- Send command to begin ---
        try
            fprintf(sPort,'2');
        end
        
        miEvent='';
        data='';
        while(~strcmp(miEvent,'Timer timeStamp'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        %set(handles.text11,'String',data);
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
        % --- Send command to iCase[S/H] ---
        try
            fprintf(sPort,'1');
        end
        
        miEvent='';
        data='';
        while(~strcmp(miEvent,'iCase[S|H]'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
       % --- Send command to iTimeCase[B/D/A/R] ---
        try
            fprintf(sPort,'3');
        end 
        miEvent='';
        data='';
        while(~strcmp(miEvent,'Sensors states:'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                         fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
                     end
                end 
           miEvent=strtok(data,',');
        end
        

        % --- Send command to begin ---
        try
            fprintf(sPort,'1');
        end 
        miEvent='';
        data='';
        while(~strcmp(miEvent,'iCommand'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        set(handles.text11,'String','Sensors are ok. GO!');
        drawnow;
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
        %Enviamos el threshold
        try
            fprintf(sPort,(get(handles.edit2,'String')));
        end
        
        % Wait for 'End' code    
        miEvent='';
        data='';
        while(~strcmp(miEvent,'End'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);
                         fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
                     end
                end 
           miEvent=strtok(data,',');
        end
         end
        
         if(get(handles.text4,'Value')==1)
            set(handles.text4,'Value',2);
            set(handles.text7,'String','2/2');
         else
            set(handles.text4,'Value',1);
            set(handles.text8,'Value',get(handles.text8,'Value')+1);
            set(handles.text7,'String','1/2');
         end
     case 4     %Case Before 3 steps - 1 Lights
        set(handles.pushbutton2,'Enable','off'); 
        set(handles.text2,'Enable','on');
        set(handles.text3,'Enable','on');
        set(handles.text6,'Enable','on');
        set(handles.text7,'Enable','on');
        set(handles.text8,'ForegroundColor',[0 0.8 0]);
        set(handles.text8,'String','ACTIVE'); 
        set(handles.text11,'ForegroundColor',[0 0 0]);
        set(handles.text11,'String','Ready...');
        set(handles.text11,'Visible','on');
        
         if(myDebug==0)
        % --- Send command to begin ---
        try
            fprintf(sPort,'2');
        end
        
        miEvent='';
        data='';
        while(~strcmp(miEvent,'Timer timeStamp'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        %set(handles.text11,'String',data);
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
        % --- Send command to iCase[S/H] ---
        try
            fprintf(sPort,'1');
        end
        
        miEvent='';
        data='';
        while(~strcmp(miEvent,'iCase[S|H]'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
       % --- Send command to iTimeCase[B/D/A/R] ---
        try
            fprintf(sPort,'4');
        end 
        miEvent='';
        data='';
        while(~strcmp(miEvent,'Sensors states:'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                         fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
                     end
                end 
           miEvent=strtok(data,',');
        end
        

        % --- Send command to begin ---
        try
            fprintf(sPort,'1');
        end 
        miEvent='';
        data='';
        while(~strcmp(miEvent,'iCommand'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        set(handles.text11,'String','Sensors are ok. GO!');
        drawnow;
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
        %Enviamos el threshold
        try
            fprintf(sPort,(get(handles.edit2,'String')));
        end
        
        % Wait for 'End' code    
        miEvent='';
        data='';
        while(~strcmp(miEvent,'End'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);
                         fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
                     end
                end 
           miEvent=strtok(data,',');
        end
         end
        
         if(get(handles.text4,'Value')==1)
            set(handles.text4,'Value',2);
            set(handles.text7,'String','2/2');
         else
            set(handles.text4,'Value',1);
            set(handles.text8,'Value',get(handles.text8,'Value')+1);
            set(handles.text7,'String','1/2');
         end
     case 5     %Case Before 3 steps -2 Lights
        set(handles.pushbutton2,'Enable','off'); 
        set(handles.text2,'Enable','on');
        set(handles.text3,'Enable','on');
        set(handles.text6,'Enable','on');
        set(handles.text7,'Enable','on');
        set(handles.text8,'ForegroundColor',[0 0.8 0]);
        set(handles.text8,'String','ACTIVE'); 
        set(handles.text11,'ForegroundColor',[0 0 0]);
        set(handles.text11,'String','Ready...');
        set(handles.text11,'Visible','on');
        
         if(myDebug==0)
        % --- Send command to begin ---
        try
            fprintf(sPort,'2');
        end
        
        miEvent='';
        data='';
        while(~strcmp(miEvent,'Timer timeStamp'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        %set(handles.text11,'String',data);
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
        % --- Send command to iCase[S/H] ---
        try
            fprintf(sPort,'1');
        end
        
        miEvent='';
        data='';
        while(~strcmp(miEvent,'iCase[S|H]'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
       % --- Send command to iTimeCase[B/D/A/R] ---
        try
            fprintf(sPort,'5');
        end 
        miEvent='';
        data='';
        while(~strcmp(miEvent,'Sensors states:'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);
                         fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
                     end
                end 
           miEvent=strtok(data,',');
        end
        

        % --- Send command to begin ---
        try
            fprintf(sPort,'1');
        end 
        miEvent='';
        data='';
        while(~strcmp(miEvent,'iCommand'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        set(handles.text11,'String','Sensors are ok. GO!');
        drawnow;
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
        %Enviamos el threshold
        try
            fprintf(sPort,(get(handles.edit2,'String')));
        end
        
        % Wait for 'End' code    
        miEvent='';
        data='';
        while(~strcmp(miEvent,'End'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);
                         fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
                     end
                end 
           miEvent=strtok(data,',');
        end
         end
        
        
          if(get(handles.text4,'Value')==1)
            set(handles.text4,'Value',2);
            set(handles.text7,'String','2/2');
         else
            set(handles.text4,'Value',1);
            set(handles.text8,'Value',get(handles.text8,'Value')+1);
            set(handles.text7,'String','1/2');
          end
          
     case 6     %Case Before 3 steps -3 Lights
          set(handles.pushbutton2,'Enable','off'); 
        set(handles.text2,'Enable','on');
        set(handles.text3,'Enable','on');
        set(handles.text6,'Enable','on');
        set(handles.text7,'Enable','on');
        set(handles.text8,'ForegroundColor',[0 0.8 0]);
        set(handles.text8,'String','ACTIVE'); 
        set(handles.text11,'ForegroundColor',[0 0 0]);
        set(handles.text11,'String','Ready...');
        set(handles.text11,'Visible','on');
        
        if(myDebug==0)
        % --- Send command to begin ---
        try
            fprintf(sPort,'2');
        end
        
        miEvent='';
        data='';
        while(~strcmp(miEvent,'Timer timeStamp'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        %set(handles.text11,'String',data);
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
        % --- Send command to iCase[S/H] ---
        try
            fprintf(sPort,'1');
        end
        
        miEvent='';
        data='';
        while(~strcmp(miEvent,'iCase[S|H]'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
       % --- Send command to iTimeCase[B/D/A/R] ---
        try
            fprintf(sPort,'7');
        end 
        miEvent='';
        data='';
        while(~strcmp(miEvent,'Sensors states:'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                         fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
                     end
                end 
           miEvent=strtok(data,',');
        end
       
        % --- Send command to begin ---
        try
            fprintf(sPort,'1');
        end 
        miEvent='';
        data='';
        while(~strcmp(miEvent,'iCommand'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        set(handles.text11,'String','Sensors are ok. GO!');
        drawnow;
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
        %Enviamos el threshold
        try
            fprintf(sPort,(get(handles.edit2,'String')));
        end
        
        % Wait for 'End' code    
        miEvent='';
        data='';
        while(~strcmp(miEvent,'End'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);
                         fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
                     end
                end 
           miEvent=strtok(data,',');
        end
         end
        
        
           if(get(handles.text4,'Value')==1)
            set(handles.text4,'Value',2);
            set(handles.text7,'String','2/2');
         else
            set(handles.text4,'Value',1);
            set(handles.text8,'Value',get(handles.text8,'Value')+1);
            set(handles.text7,'String','1/2');
         end
     case 7     %Case Before 3 steps - 1 Light - 0%
          set(handles.pushbutton2,'Enable','off'); 
        set(handles.text2,'Enable','on');
        set(handles.text3,'Enable','on');
        set(handles.text6,'Enable','on');
        set(handles.text7,'Enable','on');
        set(handles.text8,'ForegroundColor',[0 0.8 0]);
        set(handles.text8,'String','ACTIVE'); 
        set(handles.text11,'ForegroundColor',[0 0 0]);
        set(handles.text11,'String','Ready...');
        set(handles.text11,'Visible','on');
        
        if(myDebug==0)
        % --- Send command to begin ---
        try
            fprintf(sPort,'2');
        end
        
        miEvent='';
        data='';
        while(~strcmp(miEvent,'Timer timeStamp'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        %set(handles.text11,'String',data);
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
        % --- Send command to iCase[S/H] ---
        try
            fprintf(sPort,'1');
        end
        
        miEvent='';
        data='';
        while(~strcmp(miEvent,'iCase[S|H]'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
       % --- Send command to iTimeCase[B/D/A/R] ---
        try
            fprintf(sPort,'7');
        end 
        miEvent='';
        data='';
        while(~strcmp(miEvent,'Sensors states:'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort); 
                         fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
                     end
                end 
           miEvent=strtok(data,',');
        end
       

        % --- Send command to begin ---
        try
            fprintf(sPort,'1');
        end 
        miEvent='';
        data='';
        while(~strcmp(miEvent,'iCommand'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        set(handles.text11,'String','Sensors are ok. GO!');
        drawnow;
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
        %Enviamos el threshold
        try
            fprintf(sPort,(get(handles.edit2,'String')));
        end
        
        % Wait for 'End' code    
        miEvent='';
        data='';
        while(~strcmp(miEvent,'End'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);
                         fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
                     end
                end 
           miEvent=strtok(data,',');
        end
         end
        
        
         if(get(handles.text4,'Value')==1)
            set(handles.text4,'Value',2);
            set(handles.text7,'String','2/2');
         else
            set(handles.text4,'Value',1);
            set(handles.text8,'Value',get(handles.text8,'Value')+1);
            set(handles.text7,'String','1/2');
         end
         
     case 8     %Case Before 3 steps - 1 Light - 5%
          set(handles.pushbutton2,'Enable','off'); 
        set(handles.text2,'Enable','on');
        set(handles.text3,'Enable','on');
        set(handles.text6,'Enable','on');
        set(handles.text7,'Enable','on');
        set(handles.text8,'ForegroundColor',[0 0.8 0]);
        set(handles.text8,'String','ACTIVE'); 
        set(handles.text11,'ForegroundColor',[0 0 0]);
        set(handles.text11,'String','Ready...');
        set(handles.text11,'Visible','on');
        
        if(myDebug==0)
        % --- Send command to begin ---
        try
            fprintf(sPort,'2');
        end
        
        miEvent='';
        data='';
        while(~strcmp(miEvent,'Timer timeStamp'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        %set(handles.text11,'String',data);
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
        % --- Send command to iCase[S/H] ---
        try
            fprintf(sPort,'1');
        end
        
        miEvent='';
        data='';
        while(~strcmp(miEvent,'iCase[S|H]'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
       % --- Send command to iTimeCase[B/D/A/R] ---
        try
            fprintf(sPort,'8');
        end 
        miEvent='';
        data='';
        while(~strcmp(miEvent,'Sensors states:'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);
                         fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
                     end
                end 
           miEvent=strtok(data,',');
        end
        

        % --- Send command to begin ---
        try
            fprintf(sPort,'1');
        end 
        miEvent='';
        data='';
        while(~strcmp(miEvent,'iCommand'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        set(handles.text11,'String','Sensors are ok. GO!');
        drawnow;
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
        %Enviamos el threshold
        try
            fprintf(sPort,(get(handles.edit2,'String')));
        end
        
        % Wait for 'End' code    
        miEvent='';
        data='';
        while(~strcmp(miEvent,'End'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);
                         fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
                     end
                end 
           miEvent=strtok(data,',');
        end
         end
        
        
         if(get(handles.text4,'Value')==1)
            set(handles.text4,'Value',2);
            set(handles.text7,'String','2/2');
         else
            set(handles.text4,'Value',1);
            set(handles.text8,'Value',get(handles.text8,'Value')+1);
            set(handles.text7,'String','1/2');
         end
         
     case 9     %Case Before 3 steps - 1 Light - 20%
        set(handles.pushbutton2,'Enable','off'); 
        set(handles.text2,'Enable','on');
        set(handles.text3,'Enable','on');
        set(handles.text6,'Enable','on');
        set(handles.text7,'Enable','on');
        set(handles.text8,'ForegroundColor',[0 0.8 0]);
        set(handles.text8,'String','ACTIVE'); 
        set(handles.text11,'ForegroundColor',[0 0 0]);
        set(handles.text11,'String','Ready...');
        set(handles.text11,'Visible','on');
        
        if(myDebug==0)
        % --- Send command to begin ---
        try
            fprintf(sPort,'2');
        end
        
        miEvent='';
        data='';
        while(~strcmp(miEvent,'Timer timeStamp'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        %set(handles.text11,'String',data);
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
        % --- Send command to iCase[S/H] ---
        try
            fprintf(sPort,'1');
        end
        
        miEvent='';
        data='';
        while(~strcmp(miEvent,'iCase[S|H]'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        
        
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
       % --- Send command to iTimeCase[B/D/A/R] ---
        try
            fprintf(sPort,'9');
        end 
        miEvent='';
        data='';
        while(~strcmp(miEvent,'Sensors states:'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                         fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
                     end
                end 
           miEvent=strtok(data,',');
        end
        

        % --- Send command to begin ---
        try
            fprintf(sPort,'1');
        end 
        miEvent='';
        data='';
        while(~strcmp(miEvent,'iCommand'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);  
                     end
                end 
           miEvent=strtok(data,',');
        end
        set(handles.text11,'String','Sensors are ok. GO!');
        drawnow;
        fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
        
        %Enviamos el threshold
        try
            fprintf(sPort,(get(handles.edit2,'String')));
        end
        
        % Wait for 'End' code    
        miEvent='';
        data='';
        while(~strcmp(miEvent,'End'))  
           nroDatos=sPort.BytesAvailable;
                if(nroDatos>5)
                     try
                         data = fscanf(sPort);
                         fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
                     end
                end 
           miEvent=strtok(data,',');
        end
         end
        
        
         if(get(handles.text4,'Value')==1)
            set(handles.text4,'Value',2);
            set(handles.text7,'String','2/2');
         else
            set(handles.text4,'Value',1);
            set(handles.text8,'Value',get(handles.text8,'Value')+1);
            set(handles.text7,'String','1/2');
         end
         
      case 10
%         set(handles.pushbutton2,'Enable','off'); 
%         set(handles.text2,'Enable','on');
%         set(handles.text3,'Enable','on');
%         set(handles.text6,'Enable','on');
%         set(handles.text7,'Enable','on');
%         set(handles.text8,'ForegroundColor',[0 0.8 0]);
%         set(handles.text8,'String','ACTIVE'); 
%         set(handles.text11,'ForegroundColor',[0 0 0]);
%         
%         set(handles.text11,'String','Please wait. Checking for sensors....');
%         set(handles.text11,'Visible','on');
%         drawnow;
%         
%         if(myDebug==0)
%         % --- Send command to begin ---
%         try
%             fprintf(sPort,'2');
%         end
%         
%         miEvent='';
%         data='';
%         while(~strcmp(miEvent,'Timer timeStamp'))  
%            nroDatos=sPort.BytesAvailable;
%                 if(nroDatos>5)
%                      try
%                          data = fscanf(sPort); 
%                      end
%                 end 
%            miEvent=strtok(data,',');
%         end
%         %set(handles.text11,'String',data);
%         fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
%         
%         % --- Send command to iCase[S/H] ---
%         try
%             fprintf(sPort,'3');
%         end
%         
%         miEvent='';
%         data='';
%         while(~strcmp(miEvent,'iCase[S|H]'))  
%            nroDatos=sPort.BytesAvailable;
%                 if(nroDatos>5)
%                      try
%                          data = fscanf(sPort);  
%                      end
%                 end 
%            miEvent=strtok(data,',');
%         end
%         
%         fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
%         
%        % --- Send command to iTimeCase[B/D/A/R] ---
%         try
%             fprintf(sPort,'6');
%         end 
%         miEvent='';
%         data='';
%         while(~strcmp(miEvent,'Sensors states:'))  
%            nroDatos=sPort.BytesAvailable;
%                 if(nroDatos>5)
%                      try
%                          data = fscanf(sPort);  
%                          fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
%                      end
%                 end 
%            miEvent=strtok(data,',');
%         end
%         
% 
%         % --- Send command to begin ---
%         try
%             fprintf(sPort,'1');
%         end 
%         miEvent='';
%         data='';
%         while(~strcmp(miEvent,'iCommand'))  
%            nroDatos=sPort.BytesAvailable;
%                 if(nroDatos>5)
%                      try
%                          data = fscanf(sPort);  
%                      end
%                 end 
%            miEvent=strtok(data,',');
%         end
%         set(handles.text11,'String','Sensors are ok. GO!');
%         drawnow;
%         fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
%         
%         % Wait for 'End' code    
%         miEvent='';
%         data='';
%         while(~strcmp(miEvent,'End'))  
%            nroDatos=sPort.BytesAvailable;
%                 if(nroDatos>5)
%                      try
%                          data = fscanf(sPort);
%                          fprintf(miArchivo,'%s',strcat(datestr(now)),',',data);
%                      end
%                 end 
%            miEvent=strtok(data,',');
%         end
%         end
        
         if(get(handles.text4,'Value')==1)
            set(handles.text4,'Value',2);
            set(handles.text7,'String','2/2');
         else
            set(handles.text4,'Value',1);
            set(handles.text8,'Value',get(handles.text8,'Value')+1);
            set(handles.text7,'String','1/2');
         end
         
    end
    
    if(strcmp(upper(userID),'TEST'))
        set(handles.text4,'Value',1);
        set(handles.text8,'Value',get(handles.text8,'Value')+1);
        set(handles.text7,'String','1/2');
    end
    get(handles.text8,'Value');
    if((get(handles.text8,'Value')+1)<12)
        set(handles.pushbutton2,'Enable','on');
        set(handles.text2,'Enable','off');
        set(handles.text3,'Enable','off');
        status=orden(get(handles.text8,'Value')+1);
        set(handles.text6,'String',names{1,status+1});
        set(handles.text6,'Enable','off');
        set(handles.text7,'Enable','off');
        set(handles.text8,'ForegroundColor',[1 0 0]);
        set(handles.text8,'String','IDLE');
        set(handles.text11,'String','Press button to start..');
        
        if(get(handles.text4,'Value')==1)
            get(handles.text8,'Value');
            orden1(2,get(handles.text8,'Value'))=1;
            set(handles.text9,'UserData',orden1);
            name=strcat(get(handles.text5,'String'),'_log.txt');
            save(name,'orden1','-ascii');
            set(handles.text13,'String',strcat(get(handles.text13,'String')...
            ,{'  -  '},{ '['}, num2str(get(handles.text8,'Value')-1),'/10',{'] '},names{1,orden(get(handles.text8,'Value'))+1}))
        end
    elseif((get(handles.text8,'Value')+1)==12)     
         orden1(2,11)=1;
         if(get(handles.text4,'Value')==1)
            get(handles.text8,'Value');
            orden1(2,get(handles.text8,'Value'))=1;
            set(handles.text9,'UserData',orden1);
            name=strcat(get(handles.text5,'String'),'_log.txt');
            save(name,'orden1','-ascii');
            set(handles.text13,'String',strcat(get(handles.text13,'String')...
            ,{'  -  '},{ '['}, num2str(get(handles.text8,'Value')-1),'/10',{'] '},names{1,orden(get(handles.text8,'Value'))+1}))
          end
         set(handles.text13,'String',strcat(get(handles.text13,'String')...
            ,{'  -  '},{ '['}, num2str(get(handles.text8,'Value')-1),'/10',{'] '},names{1,orden(get(handles.text8,'Value'))+1}))
         set(handles.pushbutton2,'Enable','on');
         set(handles.text1,'Enable','off');
         set(handles.text2,'Enable','off');
         set(handles.text3,'Enable','off');
         set(handles.text4,'Enable','off');
         set(handles.text5,'Enable','off');
         set(handles.text6,'Enable','off');
         set(handles.text7,'Enable','off');
         set(handles.text8,'Enable','off'); 
         set(handles.text11,'String','Test was finished');
         set(handles.pushbutton2,'String','NEXT');
         set(handles.text8,'Value',get(handles.text8,'Value')+1);
         
         %Creamos la version final del archivo con los datos del usuario
         for i=1:19
             
         end
         %**************************************************************
             
    end
    
% if(myDebug==0)
%     fclose(sPort);
% end
fclose(miArchivo);
set(handles.pushbutton3,'Enable','on');


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
disp('llamando a create..')
delete(instrfindall);



% --- Executes during object creation, after setting all properties.
function pushbutton2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function uipanel2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes during object deletion, before destroying properties.
function uipanel2_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to uipanel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sPort=guidata(handles.figure1);


% --- Executes during object creation, after setting all properties.
function pushbutton1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(get(handles.text4,'Value')==2)
    set(handles.text4,'Value',1);
    set(handles.text7,'String','1/2');
elseif(get(handles.text4,'Value')==1)
    set(handles.text4,'Value',2);
    set(handles.text7,'String','2/2');
    set(handles.text8,'Value',get(handles.text8,'Value')-1);
    orden1=get(handles.text9,'UserData');
    orden=orden1(1,:);
    %get(handles.text9,'UserData')
    names=get(handles.text5,'UserData');
    status=orden(get(handles.text8,'Value')+1);
    set(handles.text6,'String',names{1,status+1}); 
end
set(handles.pushbutton3,'Enable','off');


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(instrfindall)
delete(hObject);



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
