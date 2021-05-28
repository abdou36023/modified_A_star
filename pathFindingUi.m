function varargout = pathFindingUi(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pathFindingUi_OpeningFcn, ...
                   'gui_OutputFcn',  @pathFindingUi_OutputFcn, ...
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

% --- Executes just before pathFindingUi is made visible.
function pathFindingUi_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
ax = handles.axes1;
setGlobalax(ax);
set(ax,'ButtonDownFcn', @mouse_down_call);
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes pathFindingUi wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pathFindingUi_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
setHandle(handles);

function mouse_down_call(hObject,~)
    axesHandle  = get(hObject,'Parent');
    mousePos=get(axesHandle,'CurrentPoint');
    x = round(mousePos(1,1));
    y = round(mousePos(1,2));
    disp(['You clicked X:',num2str(x),',  Y:',num2str(y)]);
    mainView = guidata(hObject);
    if get(mainView.start,'value')==1
        setStartPoint([x,y]);
        set(mainView.startEdit,'string',['X:',num2str(x),',Y:',num2str(y)]);
    else
        setEndPoint([x,y]);
        set(mainView.distEdit,'string',['X:',num2str(x),',Y:',num2str(y)]);
    end
    sz = size(getMap);
    sz = sz(1:2);
    st = uint8(ones(sz));
    dt = uint8(ones(sz));
    img = getMap;
    xy = getStartPoint;
    if max(size(xy)) > 0
        st(xy(2)-2:xy(2)+2,xy(1)-2:xy(1)+2)=0;
    end
    xy = getEndPoint;
    if max(size(xy)) > 0
        dt(xy(2)-2:xy(2)+2,xy(1)-2:xy(1)+2)=0;
    end
    
    size(img(:,:,1))
    size(st)
    img(:,:,1) = img(:,:,1).*st;
    img(:,:,3) = img(:,:,3).*st;
    
    img(:,:,1) = img(:,:,1).*dt;
    img(:,:,2) = img(:,:,2).*dt;
    showImgInAxes(img)
    
%     disp(mousePos);
%     mouse_pos  = get(0, 'pointerlocation');
%     mousex = mouse_pos(1);
%     mousey = mouse_pos(2);
%     disp(['You clicked X:',num2str(mouse_pos(1)),',Y:',num2str(mouse_pos(2))]);

function imagePath_Callback(hObject, eventdata, handles)


function imagePath_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browse.
function browse_Callback(hObject, eventdata, handles)
[fileName,path] = uigetfile({'*.png'});
fi = str2num(erase(erase(fileName,'.PNG'),'image'));
db = xlsread('db.xlsx');
set(handles.startLat,'string',num2str(db(fi,1)))
set(handles.startLong,'string',num2str(db(fi,2)))
set(handles.desLat,'string',num2str(db(fi,5)))
set(handles.destLong,'string',num2str(db(fi,6)))
setStartPoint([db(fi,3),db(fi,4)])
setEndPoint([db(fi,7),db(fi,8)])
calcMScale(handles)

fileName = [path,'/',fileName];
img = imread(fileName);
showImgInAxes(img);
setMap(img)
set(handles.imagePath,'string', fileName);

function showImgInAxes(img)
imgHandle = imshow(img,'Parent',getGlobalax);
set(imgHandle,'ButtonDownFcn', @mouse_down_call);


% --- Executes on button press in showSteps.
function showSteps_Callback(hObject, eventdata, handles)


% Hint: get(hObject,'Value') returns toggle state of showSteps


% --- Executes on button press in useSpeed.
function useSpeed_Callback(hObject, eventdata, handles)


% Hint: get(hObject,'Value') returns toggle state of useSpeed


% --- Executes on button press in withDistance.
function withDistance_Callback(hObject, eventdata, handles)
% hObject    handle to withDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of withDistance


% --- Executes on button press in startButton.
function startButton_Callback(hObject, eventdata, handles)
showStep = get(handles.showSteps,'value');
useSpeed = get(handles.useSpeed,'value');
factor = 1.0;
if get(handles.withDistance,'value')==1
    factor = str2double(get(handles.edit2,'string'));
else
    factor = 1.0;
end
resizeFactor = 1.0;
if get(handles.resizeFactor,'value')==1
    resizeFactor = str2double(get(handles.resizeEdit,'string'));
else
    resizeFactor = 1.0;
end
[img,disImg,dis]=aStar(round(getStartPoint*resizeFactor),round(getEndPoint*resizeFactor),getMap,showStep,useSpeed,factor,resizeFactor);
showVisitedPoint(disImg);
setDis(dis/resizeFactor);
setImg(disImg);

function [count] = showVisitedPoint(img)
count = nnz(img)
f = msgbox(['Number of visited point : ',num2str(count)]);



% --- Executes on button press in showPath.
function showPath_Callback(hObject, eventdata, handles)
resizeFactor = 1.0;
if get(handles.resizeFactor,'value')==1
    resizeFactor = str2double(get(handles.resizeEdit,'string'));
else
    resizeFactor = 1.0;
end
path = getPath(getImg,round(getStartPoint*resizeFactor),round(getEndPoint*resizeFactor));
img = imresize(imread(get(handles.imagePath,'string')),resizeFactor);
img(:,:,1) = img(:,:,1).*uint8((double(path(:,:,1)>0.5)-1)*-1);
imshow(img)



function edit2_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function setGlobalax(val)
global ax
ax = val;

function r = getGlobalax
global ax
r = ax;

function setStartPoint(val)
global startPoint
startPoint = val;

function r = getStartPoint
global startPoint
r = startPoint;

function setEndPoint(val)
global endPoint
endPoint = val;

function r = getEndPoint
global endPoint
r = endPoint;

function setHandle(val)
global handle
handle = val;

function r = getHandle
global handle
r = handle;

function setImg(val)
global img
img = val;

function r = getImg
global img
r = img;

function setMap(val)
global mapImg
mapImg = val;

function r = getMap
global mapImg
r = mapImg;

function setMapScaleValue(val)
global mapScale
mapScale = val;

function r = getMapScaleValue
global mapScale
r = mapScale;

function setDis(val)
global dis
dis = val;

function r = getDis
global dis
r = dis;

function startEdit_Callback(hObject, eventdata, handles)
% hObject    handle to startEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startEdit as text
%        str2double(get(hObject,'String')) returns contents of startEdit as a double


% --- Executes during object creation, after setting all properties.
function startEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function distEdit_Callback(hObject, eventdata, handles)
% hObject    handle to distEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of distEdit as text
%        str2double(get(hObject,'String')) returns contents of distEdit as a double


% --- Executes during object creation, after setting all properties.
function distEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to distEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in resizeFactor.
function resizeFactor_Callback(hObject, eventdata, handles)
% hObject    handle to resizeFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of resizeFactor



function resizeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to resizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of resizeEdit as text
%        str2double(get(hObject,'String')) returns contents of resizeEdit as a double


% --- Executes during object creation, after setting all properties.
function resizeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startLat_Callback(hObject, eventdata, handles)
% hObject    handle to startLat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startLat as text
%        str2double(get(hObject,'String')) returns contents of startLat as a double


% --- Executes during object creation, after setting all properties.
function startLat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startLat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startLong_Callback(hObject, eventdata, handles)
% hObject    handle to startLong (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startLong as text
%        str2double(get(hObject,'String')) returns contents of startLong as a double


% --- Executes during object creation, after setting all properties.
function startLong_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startLong (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function desLat_Callback(hObject, eventdata, handles)
% hObject    handle to desLat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of desLat as text
%        str2double(get(hObject,'String')) returns contents of desLat as a double


% --- Executes during object creation, after setting all properties.
function desLat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to desLat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function destLong_Callback(hObject, eventdata, handles)
% hObject    handle to destLong (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of destLong as text
%        str2double(get(hObject,'String')) returns contents of destLong as a double


% --- Executes during object creation, after setting all properties.
function destLong_CreateFcn(hObject, eventdata, handles)
% hObject    handle to destLong (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in calcMapScale.
function calcMapScale_Callback(hObject, eventdata, handles)
calcMScale(handles);

function calcMScale(handles)
startLatLong = [str2double(get(handles.startLat,'string')),str2double(get(handles.startLong,'string'))];
endLatLong = [str2double(get(handles.desLat,'string')),str2double(get(handles.destLong,'string'))];
startXY = getStartPoint;
endXY = getEndPoint;

mapScale = getMapScale(startLatLong,endLatLong,startXY,endXY);
set(handles.mapScaleEdit,'string',num2str(mapScale));
setMapScaleValue(mapScale);



function mapScaleEdit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function mapScaleEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in getDist.
function getDist_Callback(hObject, eventdata, handles)
%imgDis = getImg;
%endPoint = getEndPoint;
disPix = getDis;
distance = disPix/getMapScaleValue;
f = msgbox(['distance by pixels : ',num2str(disPix),'     real distance by m : ',num2str(distance)]);


% --- Executes on button press in dijkstraStart.
function dijkstraStart_Callback(hObject, eventdata, handles)
showStep = get(handles.showSteps,'value');
useSpeed = get(handles.useSpeed,'value');
resizeFactor = 1.0;
if get(handles.resizeFactor,'value')==1
    resizeFactor = str2double(get(handles.resizeEdit,'string'));
else
    resizeFactor = 1.0;
end
[img,disImg,dis]=dijkstra(round(getStartPoint*resizeFactor),round(getEndPoint*resizeFactor),getMap,showStep,useSpeed,resizeFactor);
showVisitedPoint(disImg);
setDis(dis/resizeFactor);
setImg(disImg);
