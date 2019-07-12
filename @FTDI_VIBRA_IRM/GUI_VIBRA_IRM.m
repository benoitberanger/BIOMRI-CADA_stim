function varargout = GUI_VIBRA_IRM( container )
%GUI_VIBRA_IRM is the function that creates (or bring to focus) GUI_VIBRA_IRM
% You can call FTDI_VIBRA_IRM.GUI_VIBRA_IRM( figHandle / uipanelHandle ) to UI inside another container

% debug=1 closes previous figure and reopens it, and send the gui handles
% to base workspace.
debug = 0;


%% Open a singleton figure, or gring the actual into focus.

% Is the GUI already open ?
figPtr = findall(0,'Tag',mfilename);

if ~isempty(figPtr) % Figure exists so brings it to the focus
    
    figure(figPtr);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEBUG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if debug
        close(figPtr); %#ok<UNRCH>
        FTDI_VIBRA_IRM.GUI_VIBRA_IRM;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
else % Create the figure
    
    if ~exist( 'container' , 'var' )
        
        % Create a figure
        figHandle = figure( ...
            'HandleVisibility', 'off',... % close all does not close the figure
            'MenuBar'         , 'none'                   , ...
            'Toolbar'         , 'none'                   , ...
            'Name'            , mfilename                , ...
            'NumberTitle'     , 'off'                    , ...
            'Units'           , 'Pixels'                 , ...
            'Position'        , [20, 20, 500, 500] , ...
            'Tag'             , mfilename                );
        
        container = figHandle;
        new_fig = 1;
        
    else
        
        figHandle = container;
        new_fig = 0;
        
    end
    
    figureBGcolor = [0.9 0.9 0.9];
    buttonBGcolor = figureBGcolor - 0.1;
    editBGcolor   = [1.0 1.0 1.0];
    
    if new_fig
        set(figHandle,'Color',figureBGcolor);
    end
    
    % Create GUI handles : pointers to access the graphic objects
    handles               = guihandles(figHandle);
    handles.figureBGcolor = figureBGcolor;
    handles.buttonBGcolor = buttonBGcolor;
    handles.editBGcolor   = editBGcolor  ;
    
    
    %% Panel proportions
    
    panelProp.xposP = 0.01; % xposition of panel normalized : from 0 to 1
    panelProp.wP    = 1 - panelProp.xposP * 2;
    
    panelProp.interWidth = 0.01;
    panelProp.vect  = ...
        [2 1]; % relative proportions of each panel, from bottom to top
    panelProp.vectLength    = length(panelProp.vect);
    panelProp.vectTotal     = sum(panelProp.vect);
    panelProp.unitWidth     = ( 1 - (panelProp.interWidth*(panelProp.vectLength + 1)) ) / panelProp.vectTotal ;
    
    panelProp.countP = panelProp.vectLength + 1;
    panelProp.yposP  = @(countP) panelProp.unitWidth*sum(panelProp.vect(1:countP-1)) + panelProp.interWidth *(countP);
    
    
    %% Panel : Open / Close
    
    p_oc.x = panelProp.xposP;
    p_oc.w = panelProp.wP;
    
    panelProp.countP = panelProp.countP - 1;
    p_oc.y = panelProp.yposP(panelProp.countP);
    p_oc.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_VB_OpenClose = uipanel(container,...
        'Title','Open / Close',...
        'Units', 'Normalized',...
        'Position',[p_oc.x p_oc.y p_oc.w p_oc.h],...
        'BackgroundColor',figureBGcolor);
    
    % ---------------------------------------------------------------------
    % Pushbutton : Close
    
    b_close.x = 0.20;
    b_close.w = 0.60;
    b_close.y = 0.1;
    b_close.h = 0.40;
    b_close.tag = 'pushbutton_VB_Close';
    handles.(b_close.tag) = uicontrol(handles.uipanel_VB_OpenClose,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_close.x b_close.y b_close.w b_close.h],...
        'String','Close',...
        'BackgroundColor',[1 0 0],...
        'TooltipString','',...
        'Callback',@pushbutton_VB_Close_Callback);
    
    % ---------------------------------------------------------------------
    % Pushbutton : Open
    
    b_open.x = b_close.x;
    b_open.w = b_close.w;
    b_open.y = b_close.y + b_close.h;
    b_open.h = b_close.h;
    b_open.tag = 'pushbutton_VB_Open';
    handles.(b_open.tag) = uicontrol(handles.uipanel_VB_OpenClose,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_open.x b_open.y b_open.w b_open.h],...
        'String','Open',...
        'BackgroundColor',buttonBGcolor,...
        'TooltipString','',...
        'Callback',@pushbutton_VB_Open_Callback);
    
    
    %% Panel : Valve Control
    
    p_valve.x = panelProp.xposP;
    p_valve.w = panelProp.wP;
    
    panelProp.countP = panelProp.countP - 1;
    p_valve.y = panelProp.yposP(panelProp.countP);
    p_valve.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_Valve = uibuttongroup(container,...
        'Title','Valve control',...
        'Units', 'Normalized',...
        'Position',[p_valve.x p_valve.y p_valve.w p_valve.h],...
        'BackgroundColor',figureBGcolor);
    
    p_valve = Object_Xpos_Xwidth_dispatcher(p_valve, [ 1 1 1 1 ], 0.05 );
    
    button_y_OFF    = 0.05;
    button_h_OFF    = 0.30;
    button_y_ON     = button_y_OFF + button_h_OFF;
    button_h_ON     = button_h_OFF;
    button_y_VALVE  = button_y_ON + button_h_ON;
    button_h_VALVE  = button_h_OFF;
    
    b_OFF   = struct;
    b_ON    = struct;
    e_VALVE = struct;
    for channel = 1 : 4
        
        % ---------------------------------------------------------------------
        % Pushbutton : OFF
        
        p_valve.count     = p_valve.count + 1;
        
        b_OFF(channel).x   = p_valve.xpos(p_valve.count);
        b_OFF(channel).y   = button_y_OFF;
        b_OFF(channel).w   = p_valve.xwidth(p_valve.count);
        b_OFF(channel).h   = button_h_OFF;
        b_OFF(channel).tag = sprintf('pushbutton_OFF_%d',channel);
        handles.(b_OFF(channel).tag) = uicontrol(handles.uipanel_Valve,...
            'Style','pushbutton',...
            'Units', 'Normalized',...
            'Position',[b_OFF(channel).x b_OFF(channel).y b_OFF(channel).w b_OFF(channel).h],...
            'String','0',...
            'BackgroundColor',[1 0 0],...
            'Tag',b_OFF(channel).tag,...
            'Callback',@pushbutton_OFF_Callback,...
            'Tooltip','');
        
        % ---------------------------------------------------------------------
        % Pushbutton : ON
        
        b_ON(channel).x   = p_valve.xpos(p_valve.count);
        b_ON(channel).y   = button_y_ON;
        b_ON(channel).w   = p_valve.xwidth(p_valve.count);
        b_ON(channel).h   = button_h_ON;
        b_ON(channel).tag = sprintf('pushbutton_ON_%d',channel);
        handles.(b_ON(channel).tag) = uicontrol(handles.uipanel_Valve,...
            'Style','pushbutton',...
            'Units', 'Normalized',...
            'Position',[b_ON(channel).x b_ON(channel).y b_ON(channel).w b_ON(channel).h],...
            'String','1',...
            'BackgroundColor',buttonBGcolor,...
            'Tag',b_ON(channel).tag,...
            'Callback',@pushbutton_ON_Callback,...
            'Tooltip','');
        
        
        % ---------------------------------------------------------------------
        % Edit : Valve aperture
        
        e_VALVE(channel).x   = p_valve.xpos(p_valve.count);
        e_VALVE(channel).y   = button_y_VALVE;
        e_VALVE(channel).w   = p_valve.xwidth(p_valve.count);
        e_VALVE(channel).h   = button_h_VALVE;
        e_VALVE(channel).tag = sprintf('edit_VALVE_%d',channel);
        handles.(e_VALVE(channel).tag) = uicontrol(handles.uipanel_Valve,...
            'Style','edit',...
            'Units', 'Normalized',...
            'Position',[e_VALVE(channel).x e_VALVE(channel).y e_VALVE(channel).w e_VALVE(channel).h],...
            'String','100',...
            'BackgroundColor',editBGcolor,...
            'Visible','On');
        
    end
    
    
    %% End of opening
    
    % IMPORTANT
    guidata(figHandle,handles)
    % After creating the figure, dont forget the line
    % guidata(figHandle,handles) . It allows smart retrive like
    % handles=guidata(hObject)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEBUG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if debug
        assignin('base','handles',handles) %#ok<UNRCH>
        disp(handles)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    figPtr = figHandle;
    
    
end

if nargout > 0
    
    varargout{1} = guidata(figPtr);
    
end


end % function


%% GUI Functions

% -------------------------------------------------------------------------
function obj = Object_Xpos_Xwidth_dispatcher( obj , vect , interWidth )

obj.vect  = vect; % relative proportions of each panel, from left to right

obj.interWidth = interWidth;
obj.vectLength = length(obj.vect);
obj.vectTotal  = sum(obj.vect);
obj.unitWidth  = ( 1 - (obj.interWidth*(obj.vectLength + 1)) ) / obj.vectTotal ;

obj.count  = 0;
obj.xpos   = @(count) obj.unitWidth*sum(obj.vect(1:count-1)) + obj.interWidth *(count);
obj.xwidth = @(count) obj.vect(count)*obj.unitWidth;

end % function


% -------------------------------------------------------------------------
function pushbutton_VB_Open_Callback(hObject, ~)
handles = guidata(hObject); % load gui data

if isfield(handles, 'FTDI')
    warning('FTDI_VIBRA_IRM is already opened')
    return
end

handles.FTDI = FTDI_VIBRA_IRM(); % create instance
handles.FTDI.Open();
handles.FTDI.Setup();

set(handles.pushbutton_VB_Open ,'BackgroundColor',[0 1 0]              );
set(handles.pushbutton_VB_Close,'BackgroundColor',handles.buttonBGcolor);

guidata(hObject,handles); % store gui data
end % function


% -------------------------------------------------------------------------
function pushbutton_VB_Close_Callback(hObject, ~)
handles = guidata(hObject); % load gui data

if ~isfield(handles, 'FTDI')
    warning('FTDI_VIBRA_IRM not opened')
    return
end

handles.FTDI.StopAll();
handles.FTDI.Close();
handles.FTDI.delete();
handles = rmfield(handles, 'FTDI');

set(handles.pushbutton_VB_Close ,'BackgroundColor',[1 0 0]              );
set(handles.pushbutton_VB_Open  ,'BackgroundColor',handles.buttonBGcolor);

guidata(hObject,handles); % store gui data
end % function


% -------------------------------------------------------------------------
function pushbutton_OFF_Callback(hObject, ~)
handles = guidata(hObject); % load gui data

if ~isfield(handles, 'FTDI')
    warning('FTDI_VIBRA_IRM not opened')
    return
end

tag = get(hObject,'tag');
channel = str2double(tag(end));
handles.FTDI.Stop(channel);

set(handles.(sprintf('pushbutton_OFF_%d',channel)),'BackgroundColor',[1 0 0]              );
set(handles.(sprintf('pushbutton_ON_%d' ,channel)),'BackgroundColor',handles.buttonBGcolor);

guidata(hObject,handles); % store gui data
end % function


% -------------------------------------------------------------------------
function pushbutton_ON_Callback(hObject, ~)
handles = guidata(hObject); % load gui data

if ~isfield(handles, 'FTDI')
    warning('FTDI_VIBRA_IRM not opened')
    return
end

tag = get(hObject,'tag');
channel = str2double(tag(end));
handles.FTDI.Value(channel) = str2double(get(handles.(sprintf('edit_VALVE_%d',channel)),'String'));
handles.FTDI.Start(channel);

set(handles.(sprintf('pushbutton_ON_%d'  ,channel)),'BackgroundColor',[0 1 0]              );
set(handles.(sprintf('pushbutton_OFF_%d' ,channel)),'BackgroundColor',handles.buttonBGcolor);

guidata(hObject,handles); % store gui data
end % function
