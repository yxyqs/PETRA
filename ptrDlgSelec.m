%
% Show dialog to choose an option from a list
%
% PARAMS IN:
%  - ls      -> List (cell)
%  - dft     -> Default selection (integer with the position in 'ls')
%  - title   -> Window title (string)
%  - sizeWin -> Window size [Width, Height] (optional).
%
% PARAMS OUT:
%  - sel     -> Selected item (integer). Zero (0) if canceled.
%
function sel = ptrDlgSelec(ls, dft, title, sizeWin)
    sel = 0;
    if nargin<4, sizeWin = [350,200]; end
    winWidth = sizeWin(1);      % Window width
    winHeight = sizeWin(2);     % Window height

    f = figure('Name', title, ...
        'NumberTitle', 'off', ...
        'visible','off',...
        'WindowStyle','modal', ...
        'Position', [1 1 winWidth winHeight], ...
        'MenuBar', 'none', ...
        'Resize', 'off', ...
        'UserData', 0, ...
        'KeyPressFcn', @(h,event) keyPress(h));

    ptrCenterWindow(f);

    pan = uipanel('Parent',f, 'BorderType', 'none',...
                  'Units','pixels','Position',[1 1 winWidth winHeight]);


    lsBox = uicontrol('Parent', pan, ...
                  'String', ls, ...
                  'Value', dft, ...
                  'Style', 'listbox', ...
                  'Units', 'pixels', ...
                  'Position', [15 45 winWidth-30 winHeight-60], ...
                  'FontUnits','pixels', ...
                  'FontName', 'Helvetica', ...
                  'FontSize',12, ...
                  'HorizontalAlignment','left',...
                  'Callback', @(h,event) selecItem(f));

    btnOk = uicontrol('Parent',pan, ...
                  'String', ptrLgGetString('all_OkBtn'),...
                  'Units','pixels', ...
                  'Position', [15 10 (winWidth-40)/2 30], ...
                  'FontUnits', 'pixels', ...
                  'FontName', 'Helvetica', ...
                  'FontSize', 11, ...
                  'FontWeight', 'bold',...
                  'Callback', 'set(gcbf,''UserData'',1); uiresume(gcbf)');
              
    btnCancel = uicontrol('Parent',pan, ...
                  'String', ptrLgGetString('all_CancelBtn'),...
                  'Units','pixels', ...
                  'Position', [5+winWidth/2 10 (winWidth-40)/2 30], ...
                  'FontUnits', 'pixels', ...
                  'FontName', 'Helvetica', ...
                  'FontSize', 11, ...
                  'FontWeight', 'bold',...
                  'Callback', 'uiresume(gcbf)');

    set(f,'Visible','on');
    drawnow;
    uicontrol(lsBox);
    uiwait(f);
    if ~ishandle(f), return; end
    if get(f,'UserData') == 1
        sel = get(lsBox,'Value');
    end
    close(f); 
end


function selecItem (figure)
    action = get (figure, 'SelectionType');
    if strcmp(action,'open'), 
        set(figure,'UserData',1);
        uiresume(figure); 
    end
end


function keyPress (figure)
    key = get(figure,'CurrentKey');
    switch key
        case 'escape'
            set(figure,'UserData',0);
            uiresume(figure); 
        case 'return'
            set(figure,'UserData',1);
            uiresume(figure); 
    end
end

