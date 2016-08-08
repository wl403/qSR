function varargout = TemporalClustering(varargin)
% TEMPORALCLUSTERING MATLAB code for TemporalClustering.fig
%      TEMPORALCLUSTERING, by itself, creates a new TEMPORALCLUSTERING or raises the existing
%      singleton*.
%
%      H = TEMPORALCLUSTERING returns the handle to a new TEMPORALCLUSTERING or the handle to
%      the existing singleton*.
%
%      TEMPORALCLUSTERING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEMPORALCLUSTERING.M with the given input arguments.
%
%      TEMPORALCLUSTERING('Property','Value',...) creates a new TEMPORALCLUSTERING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TemporalClustering_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TemporalClustering_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TemporalClustering

% Last Modified by GUIDE v2.5 08-Aug-2016 16:50:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TemporalClustering_OpeningFcn, ...
                   'gui_OutputFcn',  @TemporalClustering_OutputFcn, ...
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


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

delete(hObject);

% --- Executes just before TemporalClustering is made visible.
function TemporalClustering_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TemporalClustering (see VARARGIN)

% Choose default command line output for TemporalClustering
handles.mainObject=varargin{1};
mainHandles=guidata(handles.mainObject);


if ~isempty(mainHandles.ROIs)
    
    handles.current_ROI = 1;
    
    mainHandles=PlotPointillist(handles.mainObject,mainHandles);
    guidata(handles.mainObject,mainHandles)
    
    PlotCurrentROI(handles.mainObject,mainHandles,handles.current_ROI)
    
    DisplayText = [num2str(handles.current_ROI),'/',num2str(length(mainHandles.ROIs))];
    set(handles.CurrentROIID,'string',DisplayText)
    
    handles.in_ROI = ((mainHandles.fXpos>mainHandles.ROIs{handles.current_ROI}(1))&(mainHandles.fXpos<(mainHandles.ROIs{handles.current_ROI}(1)+mainHandles.ROIs{handles.current_ROI}(3))))&((mainHandles.fYpos>mainHandles.ROIs{handles.current_ROI}(2))&(mainHandles.fYpos<(mainHandles.ROIs{handles.current_ROI}(2)+mainHandles.ROIs{handles.current_ROI}(4))));

    handles.WinArea=mainHandles.ROIs{1}(3)*mainHandles.ROIs{1}(4);

    axes(handles.Spatial_Axes);

    plot(mainHandles.fXpos(handles.in_ROI),mainHandles.fYpos(handles.in_ROI),'ok','MarkerSize',2)

    X = 1:max(mainHandles.fFrames);
    Y = zeros(1,length(X));
    for i = 1:length(X)
        NumberOfDetections = sum(mainHandles.fFrames(handles.in_ROI)==i);
        Y(i) = NumberOfDetections;
    end

    axes(handles.Detection_Axes);
    plot(X,Y,'k')
    axes(handles.Cumulative_Axes);
    plot(X,cumsum(Y),'k')

    handles.X = X;
    handles.Y = Y;
    
    if isfield(mainHandles,'time_cluster_parameters')
        handles.parameters.min_size=mainHandles.time_cluster_parameters.min_size;
        handles.parameters.tolerance=mainHandles.time_cluster_parameters.tolerance;
        
        if isnan(handles.parameters.tolerance(handles.current_ROI))
            Number_Slider_Value = get(handles.Cluster_Number_Selector,'Value');   
            
            Dark_Tolerance=log(1-Number_Slider_Value)/log(0.99);
            handles.parameters.tolerance(handles.current_ROI)=Dark_Tolerance;

            min_pts = str2num(get(handles.Cluster_Cutoff_Input,'String'));
            handles.parameters.min_size(handles.current_ROI)=min_pts;
        else
            set(handles.Cluster_Number_Display,'string',num2str(handles.parameters.tolerance(handles.current_ROI)))
            
            Slider_Value=ToleranceToSlider(handles.parameters.tolerance(handles.current_ROI));
            set(handles.Cluster_Number_Selector,'Value',Slider_Value)
            set(handles.Cluster_Cutoff_Input,'String',num2str(handles.parameters.min_size(handles.current_ROI)))
        end
        
        GraphUpdateCode(hObject,eventdata,handles)
    else
        handles.parameters.min_size=nan(1,length(mainHandles.ROIs));
        handles.parameters.tolerance=nan(1,length(mainHandles.ROIs));
    end
    
else
    msgbox('You must first select ROIs!')
end



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TemporalClustering wait for user response (see UIRESUME)
%uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TemporalClustering_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1}=handles.output;





%%% ROI manipulations %%%


% --- Executes on button press in LoadPrevious.
function LoadPrevious_Callback(hObject, eventdata, handles)
% hObject    handle to LoadPrevious (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mainHandles=guidata(handles.mainObject);

handles.current_ROI = mod(handles.current_ROI-2,length(mainHandles.ROIs))+1;
handles.in_ROI = ((mainHandles.fXpos>mainHandles.ROIs{handles.current_ROI}(1))&(mainHandles.fXpos<(mainHandles.ROIs{handles.current_ROI}(1)+mainHandles.ROIs{handles.current_ROI}(3))))&((mainHandles.fYpos>mainHandles.ROIs{handles.current_ROI}(2))&(mainHandles.fYpos<(mainHandles.ROIs{handles.current_ROI}(2)+mainHandles.ROIs{handles.current_ROI}(4))));

DisplayText = [num2str(handles.current_ROI),'/',num2str(length(mainHandles.ROIs))];
set(handles.CurrentROIID,'string',DisplayText)

if isnan(handles.parameters.tolerance(handles.current_ROI))
    Number_Slider_Value = get(handles.Cluster_Number_Selector,'Value');   
    
    Dark_Tolerance=SliderToTolerance(Number_Slider_Value);
    handles.parameters.tolerance(handles.current_ROI)=Dark_Tolerance;
    
    min_pts = str2num(get(handles.Cluster_Cutoff_Input,'String'));
    handles.parameters.min_size(handles.current_ROI)=min_pts;
else
    set(handles.Cluster_Number_Display,'string',num2str(handles.parameters.tolerance(handles.current_ROI)))
    
    Slider_Value=ToleranceToSlider(handles.parameters.tolerance(handles.current_ROI));
    
    set(handles.Cluster_Number_Selector,'Value',Slider_Value)
    set(handles.Cluster_Cutoff_Input,'String',num2str(handles.parameters.min_size(handles.current_ROI)))
end

handles.WinArea=mainHandles.ROIs{handles.current_ROI}(3)*mainHandles.ROIs{handles.current_ROI}(4);
guidata(hObject,handles)

mainHandles=PlotPointillist(handles.mainObject,mainHandles);
guidata(handles.mainObject,mainHandles)
    
PlotCurrentROI(handles.mainObject,mainHandles,handles.current_ROI)

GraphUpdateCode(hObject,eventdata,handles)

% --- Executes on button press in LoadNext.
function LoadNext_Callback(hObject, eventdata, handles)
% hObject    handle to LoadNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
mainHandles=guidata(handles.mainObject);

handles.current_ROI = mod(handles.current_ROI,length(mainHandles.ROIs))+1;
handles.in_ROI = ((mainHandles.fXpos>mainHandles.ROIs{handles.current_ROI}(1))&(mainHandles.fXpos<(mainHandles.ROIs{handles.current_ROI}(1)+mainHandles.ROIs{handles.current_ROI}(3))))&((mainHandles.fYpos>mainHandles.ROIs{handles.current_ROI}(2))&(mainHandles.fYpos<(mainHandles.ROIs{handles.current_ROI}(2)+mainHandles.ROIs{handles.current_ROI}(4))));

DisplayText = [num2str(handles.current_ROI),'/',num2str(length(mainHandles.ROIs))];
set(handles.CurrentROIID,'string',DisplayText)

if isnan(handles.parameters.tolerance(handles.current_ROI))
    Number_Slider_Value = get(handles.Cluster_Number_Selector,'Value');   
    
    Dark_Tolerance=SliderToTolerance(Number_Slider_Value);
    handles.parameters.tolerance(handles.current_ROI)=Dark_Tolerance;
    
    min_pts = str2num(get(handles.Cluster_Cutoff_Input,'String'));
    handles.parameters.min_size(handles.current_ROI)=min_pts;
else
    set(handles.Cluster_Number_Display,'string',num2str(handles.parameters.tolerance(handles.current_ROI)))
    
    Slider_Value=ToleranceToSlider(handles.parameters.tolerance(handles.current_ROI));
    set(handles.Cluster_Number_Selector,'Value',Slider_Value)
    set(handles.Cluster_Cutoff_Input,'String',num2str(handles.parameters.min_size(handles.current_ROI)))
end

handles.WinArea=mainHandles.ROIs{handles.current_ROI}(3)*mainHandles.ROIs{handles.current_ROI}(4);
guidata(hObject,handles)

mainHandles=PlotPointillist(handles.mainObject,mainHandles);
guidata(handles.mainObject,mainHandles)
    
PlotCurrentROI(handles.mainObject,mainHandles,handles.current_ROI)

GraphUpdateCode(hObject,eventdata,handles)

% --- Executes on button press in SelectROI.
function SelectROI_Callback(hObject, eventdata, handles)
% hObject    handle to SelectROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mainHandles=guidata(handles.mainObject);

if isfield(mainHandles,'XposRaw')
    set(mainHandles.PlotROIS,'Value',1)
    guidata(handles.mainObject,mainHandles)
    
    mainHandles = PlotPointillist(handles.mainObject,mainHandles);
    guidata(handles.mainObject,mainHandles)
    
    try
        rectangle = imrect;
        rectangleCorners = getPosition(rectangle);
    end
    
    if exist('rectangleCorners','var')
        mainHandles.ROIs{end+1}=rectangleCorners;
        if isfield(mainHandles,'time_cluster_parameters')
            mainHandles.time_cluster_parameters.tolerance(end+1)=nan;
            mainHandles.time_cluster_parameters.min_size(end+1)=nan;
            guidata(handles.mainObject,mainHandles)
        end
        
        handles.parameters.tolerance(end+1)=nan;
        handles.parameters.min_size(end+1)=nan;
        guidata(hObject,handles) 
        
        handles.current_ROI = length(mainHandles.ROIs);
        handles.in_ROI = ((mainHandles.fXpos>mainHandles.ROIs{handles.current_ROI}(1))&(mainHandles.fXpos<(mainHandles.ROIs{handles.current_ROI}(1)+mainHandles.ROIs{handles.current_ROI}(3))))&((mainHandles.fYpos>mainHandles.ROIs{handles.current_ROI}(2))&(mainHandles.fYpos<(mainHandles.ROIs{handles.current_ROI}(2)+mainHandles.ROIs{handles.current_ROI}(4))));

        DisplayText = [num2str(handles.current_ROI),'/',num2str(length(mainHandles.ROIs))];
        set(handles.CurrentROIID,'string',DisplayText)

        if isnan(handles.parameters.tolerance(handles.current_ROI))
            Number_Slider_Value = get(handles.Cluster_Number_Selector,'Value');   

            Dark_Tolerance=SliderToTolerance(Number_Slider_Value);
            handles.parameters.tolerance(handles.current_ROI)=Dark_Tolerance;

            min_pts = str2num(get(handles.Cluster_Cutoff_Input,'String'));
            handles.parameters.min_size(handles.current_ROI)=min_pts;
        else
            set(handles.Cluster_Number_Display,'string',num2str(handles.parameters.tolerance(handles.current_ROI)))

            Slider_Value=ToleranceToSlider(handles.parameters.tolerance(handles.current_ROI));

            set(handles.Cluster_Number_Selector,'Value',Slider_Value)
            set(handles.Cluster_Cutoff_Input,'String',num2str(handles.parameters.min_size(handles.current_ROI)))
        end

        handles.WinArea=mainHandles.ROIs{handles.current_ROI}(3)*mainHandles.ROIs{handles.current_ROI}(4);
        guidata(hObject,handles)

        mainHandles=PlotPointillist(handles.mainObject,mainHandles);
        guidata(handles.mainObject,mainHandles)

        PlotCurrentROI(handles.mainObject,mainHandles,handles.current_ROI)

        GraphUpdateCode(hObject,eventdata,handles)
    end    
    
    
    
else
    msgbox('You must first load data!')
end

% --- Executes on button press in DeleteCurrentROI.
function DeleteCurrentROI_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteCurrentROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mainHandles=guidata(handles.mainObject);

old_ROI=handles.current_ROI;
mainHandles.ROIs(old_ROI)=[];
handles.current_ROI = mod(handles.current_ROI-2,length(mainHandles.ROIs))+1;
handles.in_ROI = ((mainHandles.fXpos>mainHandles.ROIs{handles.current_ROI}(1))&(mainHandles.fXpos<(mainHandles.ROIs{handles.current_ROI}(1)+mainHandles.ROIs{handles.current_ROI}(3))))&((mainHandles.fYpos>mainHandles.ROIs{handles.current_ROI}(2))&(mainHandles.fYpos<(mainHandles.ROIs{handles.current_ROI}(2)+mainHandles.ROIs{handles.current_ROI}(4))));

handles.parameters.min_size(old_ROI)=[];
handles.parameters.tolerance(old_ROI)=[];
mainHandles.time_cluster_parameters.min_size(old_ROI)=[];
mainHandles.time_cluster_parameters.tolerance(old_ROI)=[];
guidata(hObject,handles)
guidata(handles.mainObject,mainHandles)

DisplayText = [num2str(handles.current_ROI),'/',num2str(length(mainHandles.ROIs))];
set(handles.CurrentROIID,'string',DisplayText)

if isnan(handles.parameters.tolerance(handles.current_ROI))
    Number_Slider_Value = get(handles.Cluster_Number_Selector,'Value');   
    
    Dark_Tolerance=SliderToTolerance(Number_Slider_Value);
    handles.parameters.tolerance(handles.current_ROI)=Dark_Tolerance;
    
    min_pts = str2num(get(handles.Cluster_Cutoff_Input,'String'));
    handles.parameters.min_size(handles.current_ROI)=min_pts;
else
    set(handles.Cluster_Number_Display,'string',num2str(handles.parameters.tolerance(handles.current_ROI)))
    
    Slider_Value=ToleranceToSlider(handles.parameters.tolerance(handles.current_ROI));
    
    set(handles.Cluster_Number_Selector,'Value',Slider_Value)
    set(handles.Cluster_Cutoff_Input,'String',num2str(handles.parameters.min_size(handles.current_ROI)))
end

handles.WinArea=mainHandles.ROIs{handles.current_ROI}(3)*mainHandles.ROIs{handles.current_ROI}(4);
guidata(hObject,handles)

mainHandles=PlotPointillist(handles.mainObject,mainHandles);
guidata(handles.mainObject,mainHandles)
    
PlotCurrentROI(handles.mainObject,mainHandles,handles.current_ROI)

GraphUpdateCode(hObject,eventdata,handles)

% --- Executes on button press in DeleteROIs.
function DeleteROIs_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteROIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mainHandles=guidata(handles.mainObject);

if isfield(mainHandles,'XposRaw')
    if isfield(mainHandles,'ROIs')
        if isempty(mainHandles.ROIs)
            msgbox('No ROIs Selected!')
        else
            set(mainHandles.PlotROIS,'Value',1)
            guidata(handles.mainObject,mainHandles)
            mainHandles = PlotPointillist(handles.mainObject,mainHandles);
            guidata(handles.mainObject,mainHandles)
            
            try
                rectangle = imrect;
                rectangleCorners = getPosition(rectangle);
            end
            
            if exist('rectangleCorners','var')
                delete_indices = ROIsInBox(mainHandles.ROIs,rectangleCorners);
                mainHandles.ROIs(delete_indices)=[];
                if isfield(mainHandles,'time_cluster_parameters')
                    mainHandles.time_cluster_parameters.tolerance(delete_indices)=[];
                    mainHandles.time_cluster_parameters.min_size(delete_indices)=[];
                    guidata(handles.mainObject,mainHandles)
                end
                handles.parameters.tolerance(delete_indices)=[];
                handles.parameters.min_size(delete_indices)=[];
                guidata(hObject,handles)
                
                handles.current_ROI=1;
                handles.in_ROI = ((mainHandles.fXpos>mainHandles.ROIs{handles.current_ROI}(1))&(mainHandles.fXpos<(mainHandles.ROIs{handles.current_ROI}(1)+mainHandles.ROIs{handles.current_ROI}(3))))&((mainHandles.fYpos>mainHandles.ROIs{handles.current_ROI}(2))&(mainHandles.fYpos<(mainHandles.ROIs{handles.current_ROI}(2)+mainHandles.ROIs{handles.current_ROI}(4))));

                DisplayText = [num2str(handles.current_ROI),'/',num2str(length(mainHandles.ROIs))];
                set(handles.CurrentROIID,'string',DisplayText)

                if isnan(handles.parameters.tolerance(handles.current_ROI))
                    Number_Slider_Value = get(handles.Cluster_Number_Selector,'Value');   

                    Dark_Tolerance=SliderToTolerance(Number_Slider_Value);
                    handles.parameters.tolerance(handles.current_ROI)=Dark_Tolerance;

                    min_pts = str2num(get(handles.Cluster_Cutoff_Input,'String'));
                    handles.parameters.min_size(handles.current_ROI)=min_pts;
                else
                    set(handles.Cluster_Number_Display,'string',num2str(handles.parameters.tolerance(handles.current_ROI)))

                    Slider_Value=ToleranceToSlider(handles.parameters.tolerance(handles.current_ROI));

                    set(handles.Cluster_Number_Selector,'Value',Slider_Value)
                    set(handles.Cluster_Cutoff_Input,'String',num2str(handles.parameters.min_size(handles.current_ROI)))
                end

                handles.WinArea=mainHandles.ROIs{handles.current_ROI}(3)*mainHandles.ROIs{handles.current_ROI}(4);
                guidata(hObject,handles)

                mainHandles=PlotPointillist(handles.mainObject,mainHandles);
                guidata(handles.mainObject,mainHandles)

                PlotCurrentROI(handles.mainObject,mainHandles,handles.current_ROI)

                GraphUpdateCode(hObject,eventdata,handles)
                
            else
                msgbox('Window closed before user selected ROIs for deletion!')
            end
            
        end
    else
        msgbox('No ROIs Selected!')
    end
else
    msgbox('You must first load data!')
end


% --- Executes on button press in Subsection_Selector.
function Subsection_Selector_Callback(hObject, eventdata, handles)
% hObject    handle to Subsection_Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% axes(handles.Spatial_Axes);
% rectangle = imrect;
% rectangleCorners = getPosition(rectangle);
% 
% ROIindices = and(handles.ROIindices,((handles.Xpos>rectangleCorners(1))&(handles.Xpos<(rectangleCorners(1)+rectangleCorners(3))))&((handles.Ypos>rectangleCorners(2))&(handles.Ypos<(rectangleCorners(2)+rectangleCorners(4)))));
% 
% handles.ROIindices = ROIindices;
% 
% handles.WinArea=(max(handles.Xpos(ROIindices))-min(handles.Xpos(ROIindices)))*(max(handles.Ypos(ROIindices))-min(handles.Ypos(ROIindices)));
% 
% guidata(hObject, handles);
% 
% GraphUpdateCode(hObject,eventdata,handles)
% 
% uiwait(handles.figure1);

msgbox('Add this functionality')







%%% Visualization Tools %%% 

% --- Executes on button press in DisplayCumDetTrace.
function DisplayCumDetTrace_Callback(hObject, eventdata, handles)
% hObject    handle to DisplayCumDetTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DisplayCumDetTrace

GraphUpdateCode(hObject,eventdata,handles)

% --- Executes on button press in FitTrace.
function FitTrace_Callback(hObject, eventdata, handles)
% hObject    handle to FitTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FitTrace

GraphUpdateCode(hObject,eventdata,handles)




%%% Data Output %%%

% --- Executes on button press in Save_Data.
function Save_Data_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mainHandles=guidata(handles.mainObject);
mainHandles.st_clusters=RenumberClusters(handles.st_clusters);
mainHandles.valid_st_clusters=true;

mainHandles.time_cluster_parameters.tolerance=handles.parameters.tolerance;
mainHandles.time_cluster_parameters.min_size=handles.parameters.min_size;

guidata(handles.mainObject, mainHandles);





%%% Clustering Parameter Adjustments %%%

function Cluster_Cutoff_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Cluster_Cutoff_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cluster_Cutoff_Input as text
%        str2double(get(hObject,'String')) returns contents of Cluster_Cutoff_Input as a double

min_pts = str2num(get(handles.Cluster_Cutoff_Input,'String'));

if isempty(min_pts)
    set(handles.Cluster_Cutoff_Input,'String',2)
    handles.parameters.min_size(handles.current_ROI)=min_pts;
    guidata(hObject,handles)
    GraphUpdateCode(hObject,eventdata,handles)
    
    msgbox('Minimum Cluster Size should be a positive integer!')
else
    handles.parameters.min_size(handles.current_ROI)=min_pts;
    GraphUpdateCode(hObject,eventdata,handles)
end

% --- Executes on slider movement.
function Cluster_Number_Selector_Callback(hObject, eventdata, handles)
% hObject    handle to Cluster_Number_Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

Number_Slider_Value = get(handles.Cluster_Number_Selector,'Value'); %Reads the value of Number slider, which was just adjusted.

Dark_Tolerance=SliderToTolerance(Number_Slider_Value); 
set(handles.Cluster_Number_Display,'string',num2str(Dark_Tolerance))
handles.parameters.tolerance(handles.current_ROI)=Dark_Tolerance;
guidata(hObject,handles)

GraphUpdateCode(hObject,eventdata,handles)

function Cluster_Number_Display_Callback(hObject, eventdata, handles)
% hObject    handle to Cluster_Number_Display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cluster_Number_Display as text
%        str2double(get(hObject,'String')) returns contents of Cluster_Number_Display as a double

Dark_Tolerance = str2num(get(handles.Cluster_Number_Display,'String'));

if isempty(Dark_Tolerance)
    msgbox('Tolerance must be a non-negative number!')
    
    Number_Slider_Value = get(handles.Cluster_Number_Selector,'Value');  
    Dark_Tolerance=SliderToTolerance(Number_Slider_Value);
    set(handles.Cluster_Number_Display,'string',num2str(Dark_Tolerance))
    
    guidata(hObject,handles)
    
elseif Dark_Tolerance <0
    msgbox('Tolerance must be a non-negative number!')
    
    Number_Slider_Value = get(handles.Cluster_Number_Selector,'Value');  
    Dark_Tolerance=SliderToTolerance(Number_Slider_Value);
    set(handles.Cluster_Number_Display,'string',num2str(Dark_Tolerance))
    
    guidata(hObject,handles)
    
else
    Number_Slider_Value=ToleranceToSlider(Dark_Tolerance);
    set(handles.Cluster_Number_Selector,'Value',Number_Slider_Value)
     
    handles.parameters.tolerance(handles.current_ROI)=Dark_Tolerance;
    guidata(hObject,handles)

    GraphUpdateCode(hObject,eventdata,handles)
end

% --- Executes on button press in ApplyToAll.
function ApplyToAll_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyToAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mainHandles=guidata(handles.mainObject);

ClusterSizeCutoff = str2num(get(handles.Cluster_Cutoff_Input,'String'));
Number_Slider_Value = get(handles.Cluster_Number_Selector,'Value');   

Dark_Tolerance=SliderToTolerance(Number_Slider_Value);

ROI_ids=ClustersFromROIS(mainHandles.fXpos,mainHandles.fYpos,mainHandles.ROIs);

handles.st_clusters=DarkTimeClustering(mainHandles.fFrames,ROI_ids,Dark_Tolerance,ClusterSizeCutoff);
handles.parameters.tolerance(:)=Dark_Tolerance;
handles.parameters.min_size(:)=ClusterSizeCutoff;

guidata(hObject,handles)





%%% Auxiliary Functions %%%

function GraphUpdateCode(hObject,eventdata,handles)

mainHandles=guidata(handles.mainObject);
displayFit = get(handles.FitTrace,'Value');
displayBackground = get(handles.DisplayCumDetTrace,'Value');

ClusterSizeCutoff = str2num(get(handles.Cluster_Cutoff_Input,'String'));
Number_Slider_Value = get(handles.Cluster_Number_Selector,'Value'); %Reads the value of Number slider, which was just adjusted.  

Dark_Tolerance=SliderToTolerance(Number_Slider_Value);

%[Start_Times,End_Times] = HierarchicalClusterIdentification(mainHandles.fFrames,handles.in_ROI,Number_Slider_Value,ClusterSizeCutoff);
st_clusters=DarkTimeClustering(mainHandles.fFrames,handles.in_ROI,Dark_Tolerance,ClusterSizeCutoff);
unique_ids=unique(st_clusters);

%%% Graph Update Code %%%
%NumberOfClusters = length(Start_Times);
NumberOfClusters=sum(unique_ids~=0);
if NumberOfClusters>0
    Clusters = false(NumberOfClusters,length(mainHandles.fFrames));
    if unique_ids(1)==0
        start_index=2;
    else
        start_index=1;
    end
    for i = 1:NumberOfClusters
        Clusters(i,:)=(st_clusters==unique_ids(i+start_index-1));
    end
else
    Clusters = false(1,length(mainHandles.fFrames));
end

guidata(hObject, handles);

axes(handles.Spatial_Axes);
hold off
plot(mainHandles.fXpos(handles.in_ROI),mainHandles.fYpos(handles.in_ROI),'ok','MarkerSize',2)

X = 1:max(mainHandles.fFrames);
Y = zeros(1,length(X));
for i = 1:length(X)
    NumberOfDetections = sum(mainHandles.fFrames(handles.in_ROI)==i);
    Y(i) = NumberOfDetections;
end
Z = cumsum(Y);

axes(handles.Detection_Axes);
hold off
plot(X,Y,'k')
axes(handles.Cumulative_Axes);
hold off
plot(X,Z,'k')

% Color Code Graphs %

ColorScheme = [213,94,0;... Vermillion
    86,180,233;... Sky Blue
    240,228,66;... Yellow
    204,121,167;... Reddish Purple
    0,158,115;... Bluish Green
    230,159,0;... Orange
    0,114,178;... Blue
    0,0,0]; %Black

Markers = '^osd';

% Spatial
axes(handles.Spatial_Axes)
if NumberOfClusters <= 1000
    hold on
    for i = 1:NumberOfClusters
        plot(mainHandles.fXpos(Clusters(i,:)),mainHandles.fYpos(Clusters(i,:)),Markers(mod(ceil(i/4),4)+1),'MarkerFaceColor',ColorScheme(mod(i,7)+1,:)/255,'Color',ColorScheme(mod(i,7)+1,:)/255,'MarkerSize',4)
    end
else
    display('Need a Larger Color Scheme!!!!!!')
end 

axes(handles.Cumulative_Axes)
if NumberOfClusters <= 1000
    hold on
    for i = 1:NumberOfClusters
        start_time=min(mainHandles.fFrames(Clusters(i,:)));
        end_time = max(mainHandles.fFrames(Clusters(i,:)));
        plotIndices = and(X>=start_time,X<=end_time);
        plot(X(plotIndices),Z(plotIndices),'LineWidth',3,'Color',ColorScheme(mod(i,7)+1,:)/255)
    end
end 

[a,~] = size(Clusters);
if ~isfield(handles,'st_clusters')
    handles.st_clusters=zeros(1,length(mainHandles.fFrames));
end
for i = 1:a
    LargestClusterID = max(handles.st_clusters);
    handles.st_clusters = (LargestClusterID+1)*double(Clusters(i,:))+handles.st_clusters; %Each ROI will be indexed by a unique integer
end

% if displayFit
%     functionHandle = @(params,x)(params*(1-exp(-x{1}/x{2}))+x{1}*x{3});
%     handles.A=nlinfit({X,handles.TimeConstant,handles.WinArea/handles.NucArea*handles.FalseDetRate},Z,functionHandle,10);
%     AreaFraction = handles.WinArea/handles.NucArea;
%     ExponentialTerm = (1-exp(-X/handles.TimeConstant));
%     Zfit = handles.A*ExponentialTerm+AreaFraction*(handles.FalseDetRate*X);
%     %Zfit = A*ExponentialTerm;
%     hold on
%     plot(X,Zfit,'g')
% else
%     handles.A=0;
% end

% if displayBackground
%     AreaFraction = handles.WinArea/handles.NucArea;
%     ExponentialTerm = (1-exp(-X/handles.TimeConstant));
%     AverageCumTrace = AreaFraction*(handles.LimitValue*ExponentialTerm+handles.FalseDetRate*X);
%     plot(X,AverageCumTrace,'r')
% end

guidata(hObject,handles)

function clusters_out=RenumberClusters(clusters_in)

clusters_out=zeros(size(clusters_in));
unique_ids=unique(clusters_in(clusters_in~=0));
for i = 1:length(unique_ids)
    clusters_out(clusters_in==unique_ids(i))=i;
end

function PlotCurrentROI(mainObject,mainHandles,current_ROI)

    maintain_axes=false;
    if isfield(mainHandles,'pointillist_handle')
        if ishandle(mainHandles.pointillist_handle)
            figure(mainHandles.pointillist_handle)
            maintain_axes=true;
            current_axis=axis;
        else
            mainHandles.pointillist_handle = figure;
            guidata(mainObject, mainHandles);
        end

    else
        mainHandles.pointillist_handle = figure;
        guidata(mainObject, mainHandles);
    end

    hold_status = ishold;
    hold on
    
    x=[mainHandles.ROIs{current_ROI}(1),mainHandles.ROIs{current_ROI}(1)+mainHandles.ROIs{current_ROI}(3),mainHandles.ROIs{current_ROI}(1)+mainHandles.ROIs{current_ROI}(3),mainHandles.ROIs{current_ROI}(1),mainHandles.ROIs{current_ROI}(1)];
    y=[mainHandles.ROIs{current_ROI}(2),mainHandles.ROIs{current_ROI}(2),mainHandles.ROIs{current_ROI}(2)+mainHandles.ROIs{current_ROI}(4),mainHandles.ROIs{current_ROI}(2)+mainHandles.ROIs{current_ROI}(4),mainHandles.ROIs{current_ROI}(2)];
    plot(x,y,'-c')
    
    if hold_status
        hold on
    else
        hold off
    end
    
function Tolerance=SliderToTolerance(Slider)
    Tolerance=log(1-Slider)/log(0.99); %Dividing by log(0.99) adjusts to useful range of the slider to belong to a tolerance of 1 - ~450 frames.

function Slider=ToleranceToSlider(Tolerance)
    Slider=1-exp(Tolerance*log(0.99));

function ids=ClustersFromROIS(Xpos,Ypos,ROIs)
    ids = zeros(size(Xpos));
    for i = 1:length(ROIs)
        in_ROI = ((Xpos>ROIs{i}(1))&(Xpos<(ROIs{i}(1)+ROIs{i}(3))))&((Ypos>ROIs{i}(2))&(Ypos<(ROIs{i}(2)+ROIs{i}(4))));
        ids(in_ROI)=i;
    end
        

%%% Create Functions %%%

% --- Executes during object creation, after setting all properties.
function Cluster_Number_Selector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cluster_Number_Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function Cluster_Cutoff_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cluster_Cutoff_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function Cluster_Number_Display_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cluster_Number_Display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
