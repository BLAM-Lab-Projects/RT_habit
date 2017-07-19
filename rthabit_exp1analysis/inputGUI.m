function varargout = inputGUI(varargin)
% INPUTGUI M-file for inputGUI.fig
%      INPUTGUI, by itself, creates a new INPUTGUI or raises the existing
%      singleton*.
%
%      H = INPUTGUI returns the handle to a new INPUTGUI or the handle to
%      the existing singleton*.
%
%      INPUTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INPUTGUI.M with the given input arguments.
%
%      INPUTGUI('Property','Value',...) creates a new INPUTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before inputGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to inputGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
%commands to run:
%    inputGUI;
%    uiwait(guih.figure1);


% Edit the above text to modify the response to help inputGUI

% Last Modified by GUIDE v2.5 01-Feb-2008 00:23:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @inputGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @inputGUI_OutputFcn, ...
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


%% --- Executes just before inputGUI is made visible.
function inputGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to inputGUI (see VARARGIN)

% Choose default command line output for inputGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%global guih;
assignin('base','guih',handles);
%guih = handles;

% UIWAIT makes inputGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


%% --- Outputs from this function are returned to the command line.
function varargout = inputGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% add file to list
function addFile_pushbutton_Callback(hObject, eventdata, handles)
global pathname curpath exten
if isempty(curpath) && isempty(exten)
    [input_file,pathname] = uigetfile('*.*','Select All Files to Analyze','Multiselect','on');
elseif isempty(curpath)
    [input_file,pathname] = uigetfile(exten,'Select All Files to Analyze','Multiselect','on');
else
    [input_file,pathname] = uigetfile(sprintf('%s\\%s',curpath,exten),'Select All Files to Analyze','Multiselect','on');
end
    
if pathname == 0
    return;
else
    assignin('base','pathname',pathname);
end

%gets the current data file names inside the listbox
inputFileNames = get(handles.inputFiles_listbox,'String');


%if they only select one file, then the data will not be a cell
%if more than one file selected at once,
%then the data is stored inside a cell
if iscell(input_file) == 0
 
    %add the most recent data file selected to the cell containing
    %all the data file names
    inputFileNames{end+1} = input_file;
 
%else, data will be in cell format
else
    %stores full file path into inputFileNames
    for n = 1:length(input_file)
        %notice the use of {}, because we are dealing with a cell here!
        inputFileNames{end+1} = input_file{n};
    end
end
 
%updates the gui to display all filenames in the listbox
set(handles.inputFiles_listbox,'String',inputFileNames);
 
%make sure first file is always selected so it doesn't go out of range
%the GUI will break if this value is out of range
set(handles.inputFiles_listbox,'Value',1);
 
% Update handles structure
guidata(hObject, handles);


%% delete file from list
function deleteFile_pushbutton_Callback(hObject, eventdata, handles)
%get the current list of file names from the listbox
inputFileNames = get(handles.inputFiles_listbox,'String');
 
%get the values for the selected file names
option = get(handles.inputFiles_listbox,'Value');
 
%is there is nothing to delete, nothing happens
if (isempty(option) == 1 || option(1) == 0 || isempty(inputFileNames))
    return
end
 
%erases the contents of highlighted item in data array
inputFileNames(option) = [];
 
%updates the gui, erasing the selected item from the listbox
set(handles.inputFiles_listbox,'String',inputFileNames);
 
%moves the highlighted item to an appropiate value or else will get error
if option(end) > length(inputFileNames)
    set(handles.inputFiles_listbox,'Value',length(inputFileNames));
end
 
% Update handles structure
guidata(hObject, handles);

%% list callback
function inputFiles_listbox_Callback(hObject, eventdata, handles)
%nothing needed here.  we are just using the listbox to display data!


%% done push button
function done_pushbutton_Callback(hObject, eventdata, handles)
%global pathname cpath cnames;

%global filename

%get the current list of file names from the listbox
inputFileNames = get(handles.inputFiles_listbox,'String');

%close(hObject);
delete(gcf)

%filename = inputFileNames;

if ~isempty(inputFileNames)
    %assignin('base','cpath',cpath);
    assignin('base','filename',inputFileNames);
else
    assignin('base','filename',{});
end



%% listbox
function inputFiles_listbox_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%% promote file in list
function promoteFile_pushbutton_Callback(hObject, eventdata, handles)

%get the current list of file names from the listbox
inputFileNames = get(handles.inputFiles_listbox,'String');
 
%get the values for the selected file names
option = get(handles.inputFiles_listbox,'Value');
 
%do nothing if...
if (isempty(option) == 1 || option(1) == 0 || isempty(inputFileNames))
    %there is nothing to move
    return
elseif length(option)>1
    %multiple files are selected
    return;
elseif option(1) == 1
    %the first file is selected
    return;
end
 
%promote the file in data array
tmp = inputFileNames{option-1};
inputFileNames{option-1} = inputFileNames{option};
inputFileNames{option} = tmp;

 
%updates the gui, refreshing the listbox
set(handles.inputFiles_listbox,'String',inputFileNames);
 
%moves the highlighted item to an appropiate value or else will get error
if option > length(inputFileNames)
    set(handles.inputFiles_listbox,'Value',length(inputFileNames));
elseif option-1 < 1
    set(handles.inputFiles_listbox,'Value',1);
else    
    set(handles.inputFiles_listbox,'Value',option-1);
end

% Update handles structure
guidata(hObject, handles);



%% demote file in list
function demoteFile_pushbutton_Callback(hObject, eventdata, handles)

%get the current list of file names from the listbox
inputFileNames = get(handles.inputFiles_listbox,'String');
 
%get the values for the selected file names
option = get(handles.inputFiles_listbox,'Value');
 
%do nothing if...
if (isempty(option) == 1 || option(1) == 0 || isempty(inputFileNames))
    %there is nothing to move
    return
elseif length(option)>1
    %multiple files are selected
    return;
elseif option(1) == length(inputFileNames)
    %the last file is selected
    return;
end
 
%demote the file in data array
tmp = inputFileNames{option+1};
inputFileNames{option+1} = inputFileNames{option};
inputFileNames{option} = tmp;

 
%updates the gui, refreshing the listbox
set(handles.inputFiles_listbox,'String',inputFileNames);

%moves the highlighted item to an appropiate value or else will get error
if option+1 > length(inputFileNames)
    set(handles.inputFiles_listbox,'Value',length(inputFileNames));
else
    set(handles.inputFiles_listbox,'Value',option+1);
end
 
% Update handles structure
guidata(hObject, handles);

