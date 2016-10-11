function ptrDsList (hMainWin)
    ptrData = guidata (hMainWin);

    pnPos = [0, ptrData.params.statusBarHeight, ...
             ptrData.params.mainWinSize(1), ...
             ptrData.params.mainWinSize(2) - ptrData.params.statusBarHeight];

    % Deletes the panel if already exists
    if isfield(ptrData.handles,'mainPanel') && ...
            isfield(ptrData.handles.mainPanel,'hPanel') && ...
            ishandle(ptrData.handles.mainPanel.hPanel)
        delete(ptrData.handles.mainPanel.hPanel);
    end
    
    % Creates main panel
    h.hPanel = uipanel('Parent', hMainWin, ...
            'Units','pixels', ...
            'Position', pnPos, ...
            'BorderType','none');
    bgColor = max(get(h.hPanel,'BackgroundColor') - [0.1 0.1 0.1], 0);
    set (h.hPanel,'BackgroundColor', bgColor);

    % If there are images loaded, creates the panel for images and slider
    nVols = 0;
    if isfield(ptrData,'images'), 
        nVols = numel(ptrData.images);
        pList = ptrData.params.listView;
        
        % Determines the panel size
        volPanelSpaceW = pList.volPanelW + pList.volPanelMarginW;
        volPanelSpaceH = pList.volPanelH + pList.volPanelMarginH;
        
        % Determines the number of rows and columns and store it
        volsColumns = max(floor((pnPos(3)-20-pList.volPanelMarginW) / ...
            volPanelSpaceW),1);
        volsRows = max(ceil(nVols / volsColumns),1);
        ptrData.params.listView.volsColumns = volsColumns;
        ptrData.params.listView.volsRows = volsRows;
        
        
        % Creates panel for all the volumes
        volsPanelW = pList.volPanelMarginW + volsColumns * volPanelSpaceW;
        volsPanelH = pList.volPanelMarginH + volsRows * volPanelSpaceH;
        h.volsPanel = uipanel('Parent', h.hPanel, ...
            'Units','pixels', ...
            'Position',[(pnPos(3)-volsPanelW-20)/2 pnPos(4)-volsPanelH, ...
                        volsPanelW, volsPanelH], ...
            'HighlightColor',[0, 0, 0], ...
            'BackgroundColor', bgColor, ...
            'BorderType','none');
        
        % Creates slider
        h.volsPanelSlider = uicontrol(...
            'Parent', h.hPanel,...
            'Style', 'slider', ...
            'Units','pixels', ...
            'Position', [pnPos(3)-20, 0, 20, pnPos(4)], ...
            'Callback', {'ptrCbList','mainSlider'}, ...
            'Enable','off', ...
            'Min', 0, ...
            'Max', 1, ...
            'SliderStep', [0.1 0.1], ...
            'Value', 1);
    end

    % For each image loaded
    for i=1:nVols
        iRow = ceil(i/volsColumns);
        iCol = mod(i-1,volsColumns)+1;
        posH = pList.volPanelMarginH + volPanelSpaceH * (volsRows-iRow);
        posW = pList.volPanelMarginW + volPanelSpaceW * (iCol-1);
                
        % Panel for an image
        h.volPanel(i).hPanel = uipanel (...
            'Parent', h.volsPanel, ...
            'Units','pixels', ...
            'Position', [posW, posH, ...
                         pList.volPanelW, pList.volPanelH], ...
            'BorderType','line');
        
        % Panel for an image info (name, class, etc)
        h.volPanel(i).infoPanel = uipanel (...
            'Parent', h.volPanel(i).hPanel, ...
            'Units','pixels', ...
            'Position', [0 pList.volPanelH-55 pList.volPanelW 55], ...
            'BorderType','line');
        
        % Txt for image number
        h.volPanel(i).nameTitTxt = uicontrol( ...
                'Parent', h.volPanel(i).infoPanel, ...
                'String', num2str(i), ...
                'Style','text', ...
                'Units','pixels', ...
                'Position',[5 30 20 18], ...
                'FontUnits','pixels', ...
                'FontName', 'Helvetica', ...
                'FontSize',12, ...
                'HorizontalAlignment','center');
            
        % Selection check box
        h.volPanel(i).selCheck = uicontrol( ...
                'Parent', h.volPanel(i).infoPanel, ...
                'Style', 'checkbox',...
                'Units', 'Pixels', ...
                'Position', [5 10 20 20], ...
                'Value', ptrData.images(i).selected, ...
                'Callback', {'ptrCbMainWindow','selectImg', i}, ...
                'String', '');
            
        % Txt for name title
        h.volPanel(i).nameTitTxt = uicontrol( ...
                'Parent', h.volPanel(i).infoPanel, ...
                'String',ptrLgGetString('listUI_NameTxt'), ...
                'Style','text', ...
                'Units','pixels', ...
                'Position',[30 30 200 18], ...
                'FontUnits','pixels', ...
                'FontName', 'Helvetica', ...
                'FontSize',12, ...
                'HorizontalAlignment','left');
                
        % Txt for name
        h.volPanel(i).nameTxt = uicontrol( ...
                'Parent', h.volPanel(i).infoPanel, ...
                'String', ptrData.images(i).fileName, ...
                'BackgroundColor',[1 1 1], ...
                'Style','text', ...
                'Units','pixels', ...
                'Position',[30 10 200 18], ...
                'FontUnits','pixels', ...
                'FontName', 'Helvetica', ...
                'FontSize',12, ...
                'HorizontalAlignment','left');
        
        % Txt for type title
        h.volPanel(i).typeTitTxt = uicontrol( ...
                'Parent', h.volPanel(i).infoPanel, ...
                'String',ptrLgGetString('listUI_TypeTxt'), ...
                'Style','text', ...
                'Units','pixels', ...
                'Position',[235 30 110 18], ...
                'FontUnits','pixels', ...
                'FontName', 'Helvetica', ...
                'FontSize',12, ...
                'HorizontalAlignment','left');
                
        % Txt for type
        idxType = [ptrData.params.imgTypes{:,1}]==ptrData.images(i).type;
        h.volPanel(i).typeTxt = uicontrol( ...
                'Parent', h.volPanel(i).infoPanel, ...
                'String', ptrData.params.imgTypes{idxType,2}, ...
                'BackgroundColor',[1 1 1], ...
                'Style','text', ...
                'Units','pixels', ...
                'Position',[235 10 110 18], ...
                'FontUnits','pixels', ...
                'FontName', 'Helvetica', ...
                'FontSize',12, ...
                'HorizontalAlignment','left');
        
        % Txt for class title
        h.volPanel(i).classTitTxt = uicontrol( ...
                'Parent', h.volPanel(i).infoPanel, ...
                'String',ptrLgGetString('listUI_ClassTxt'), ...
                'Style','text', ...
                'Units','pixels', ...
                'Position',[350 30 80 18], ...
                'FontUnits','pixels', ...
                'FontName', 'Helvetica', ...
                'FontSize',12, ...
                'HorizontalAlignment','left');
            
        % Txt for class
        h.volPanel(i).classTxt = uicontrol( ...
                'Parent', h.volPanel(i).infoPanel, ...
                'String', ptrData.images(i).class, ...
                'Style','text', ...
                'BackgroundColor',[1 1 1], ...
                'Units','pixels', ...
                'Position',[350 10 80 18], ...
                'FontUnits','pixels', ...
                'FontName', 'Helvetica', ...
                'FontSize',12, ...
                'HorizontalAlignment','left');

        % Classify button
        bgColor = get(h.volPanel(i).infoPanel,'BackgroundColor');
        h.volPanel(i).btnClassify = uicontrol( ...
                'Parent', h.volPanel(i).infoPanel, ...
                'Style', 'pushbutton',...
                'Units', 'Pixels', ...
                'Position', [435 9 47 20], ...
                'Callback', {'ptrCbMainWindow','imgClassify', i}, ...
                'TooltipString', ptrLgGetString('secuUI_ClassifyTip'), ...
                'String', ptrLgGetString('listUI_EstimateBtnTxt'));

        % Close button
        bgColor = get(h.volPanel(i).infoPanel,'BackgroundColor');
        h.volPanel(i).btnClassify = uicontrol( ...
                'Parent', h.volPanel(i).infoPanel, ...
                'Style', 'pushbutton',...
                'Units', 'Pixels', ...
                'Position', [473 38 12 12], ...
                'Callback', {'ptrCbMainWindow','imgClose', i}, ...
                'CData', ptrLoadIcon(ptrData.params,'close',bgColor), ...
                'String', '');
            
        % For each image ...
        volume = ptrData.images(i).volume;
        h.volPanel(i).sliceIdx = round(size(volume)/2);
        for j=1:3
            
            c = uicontextmenu;
            m1 = uimenu(c,'Label',ptrLgGetString('listUI_RotateCW'),'Callback',{'ptrCbList', 'rotateAndFlip', i, j, 'cw'});
            m2 = uimenu(c,'Label',ptrLgGetString('listUI_RotateACW'),'Callback',{'ptrCbList', 'rotateAndFlip', i, j, 'anticw'});
            m3 = uimenu(c,'Label',ptrLgGetString('listUI_Flip'),'Callback',{'ptrCbList', 'rotateAndFlip', i, j, 'flip'});
            
            h.volPanel(i).slPanel(j) = uipanel (...
                'Parent', h.volPanel(i).hPanel, ...
                'Units','pixels', ...
                'Position', [10+(pList.sliceAxesW+10)*(j-1), 10, ...
                             pList.sliceAxesW, pList.sliceAxesH], ...
                'BackgroundColor', ptrData.params.colormap(1,:), ...
                'HighlightColor',[0, 0, 0], ...
                'UIContextMenu', c,...
                'BorderType','none');
            
            h.volPanel(i).slAxes(j) = axes (...
                'Parent', h.volPanel(i).slPanel(j), ...
                'Units','pixels', ...
                'Visible','off',...
                'Position',[0 0 pList.sliceAxesW pList.sliceAxesH], ...
                'Box','on',...
                'NextPlot','add',...
                'CLim',[0 1],...
                'CLimMode','manual',...
                'DataAspectRatio',[1 1 1],...
                'DataAspectRatioMode','manual',...
                'Layer','top',...
                'YDir','reverse',...
                'TickDir','out',...
                'TickDirMode','manual');
            
            h.volPanel(i).slImage(j) = image(...
                'Parent',h.volPanel(i).slAxes(j),...
                'CData',[],...
                'CDataMapping','scaled',...
                'UIContextMenu', c,...
                'ButtonDownFcn',{'ptrCbList','setSlices',i,j},...
                'Interruptible','off');
            
            h.volPanel(i).slLineH(j) = line(...
                'Parent',h.volPanel(i).slAxes(j),...
                'Color',[1 1 1],...
                'XData',[0 0],...
                'YData',[0 0]);
            
            h.volPanel(i).slLineV(j) = line(...
                'Parent',h.volPanel(i).slAxes(j),...
                'Color',[1 1 1],...
                'XData',[0 0],...
                'YData',[0 0]);
            
%             posLeft = (volsPanelWidth-volPanelWidth)/2 + 10 + ...
%                 (slAxesWidth+10)*(j-1);
%             h.volPanel(i).slAxes(j) = axes (...
%                 'Parent', h.volsPanel, ...
%                 'Units','pixels', ...
%                 'Visible','off',...
%                 'Position',[posLeft posHeight+10 slAxesWidth slAxesHeight], ...
%                 'Box','off');            
        end
    end

    % Scroll function
    set (ptrData.handles.win, 'WindowScrollWheelFcn', ...
        {'ptrCbList','scroll'});    
    
    ptrData.handles.mainPanel = h;
    guidata (hMainWin, ptrData);

    %Display slices
    for i=1:nVols, 
        ptrStatusBar(hMainWin,'updateProgress', i/nVols, '$main_CreatingUI');
        ptrCbList(hMainWin, [], 'drawSlices', i); 
    end
    colormap (ptrData.params.colormap);
    ptrCbList(hMainWin, [], 'adjustSlider');

    % Disable image tools (tool bar)
    ptrPlotTools (ptrData.handles.toolbar.toolbar, [], 'enable', 'off');
    
    % Regenerate status bar
    delete (ptrData.handles.statusBar.statusBar)
    ptrStatusBar(ptrData.handles.win, 'create')    
end
