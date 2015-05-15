function ptrInfoTrn (train, cm)
    handles = design (cm);
    putInfo (handles.txtInfo, train);
    imshow (train.trn.img_x, 'Parent',handles.ej(1));
    imshow (train.trn.img_y, 'Parent',handles.ej(2));
    imshow (train.trn.img_z, 'Parent',handles.ej(3));

    ptrCenterWindow(handles.dlg);
    guidata (handles.dlg, handles);
    colormap (cm);
    set(handles.dlg, 'Visible','on');
    set(handles.txtInfo,'Value',[]);
end

function putInfo (h, train)
    prefix = '<HTML><b>';
    sufix = '</b>';
    info = train.trn.info;
    t = {[prefix ptrLgGetString('infoTrn_Name')   ': ' sufix info.descrip], ...
        [prefix ptrLgGetString('infoTrn_Method') ': ' sufix info.met_name], ...
        [prefix ptrLgGetString('infoTrn_Date')   ': ' sufix info.date], ...
        [prefix ptrLgGetString('infoTrn_Dir')    ': ' sufix train.fileName], '', ...
        [prefix '<u>' ptrLgGetString('infoTrn_Images') sufix], ...
        [prefix ptrLgGetString('infoTrn_Mod')    ': ' sufix info.tipoImgs], ...
        [prefix ptrLgGetString('infoTrn_Number') ': ' sufix num2str(info.nImgs)], ...
        [prefix ptrLgGetString('infoTrn_OSize')  ': ' sufix num2str(info.tamaImgsOri)], ...
        [prefix ptrLgGetString('infoTrn_RSize')  ': ' sufix num2str(info.tamaImgsRed)], ...
        [prefix ptrLgGetString('infoTrn_IntTh')  ': ' sufix num2str(round(info.umbral)), ...
         ptrLgGetString('infoTrn_IntThSuf')]};

    set (h,'String',t);
end

function handles = design (cm)
    handles.dlg = figure(...
        'Name', ptrLgGetString('infoTrn_Title'), ...
        'NumberTitle', 'off',...
        'Menubar', 'none', ...
        'Resize', 'off', ...
        'Visible','off', ...
        'Units','pixels', ...
        'Position', [0 0 357 360], ...
        'WindowStyle','modal');
    
    handles.pn = uipanel(...
        'Parent', handles.dlg, ...
        'Units', 'normalized', ...
        'Position', [0 0 1 1]);

    handles.txtInfo = uicontrol(...
        'Parent', handles.pn,...
        'Units','pixels',...
        'Position',[13 150 329 198],...
        'Max',10,...
        'Enable','inactive',...
        'FontUnits', 'pixels', ...
        'FontName', 'Helvetica', ...
        'FontSize', 12, ...
        'FontWeight', 'normal',...
        'HorizontalAlignment','left',...
        'Style','listbox',...
        'BackgroundColor', [1 1 1], ...
        'Value',[]);

    handles.txtOri = uicontrol(...
        'Parent',handles.pn,...
        'Style','text',...
        'Units','pixels',...
        'FontUnits', 'pixels', ...
        'FontName', 'Helvetica', ...
        'FontSize', 12, ...
        'FontWeight', 'normal',...
        'HorizontalAlignment','left',...
        'Position',[12 121 328 19],...
        'String', ptrLgGetString('infoTrn_Orient'));

    posLeft = [17 127 241];
    for i=1:3
        handles.ejPn(i) = uipanel(...
            'Parent', handles.pn, ...
            'Units','pixels', ...
            'Position', [posLeft(i) 19 100 100], ...
            'BorderType', 'none', ...
            'BackgroundColor', cm(1,:));
        handles.ej(i) = axes(...
            'Parent', handles.pn,...
            'Units','pixels',...
            'Position',[posLeft(i) 19 100 100],...
            'NextPlot','replace',...
            'XTick',[],...
            'XTickLabel',{},...
            'YTick',[],...
            'YTickLabel',{},...
            'Box','on');
    end

end