function audio_eq_gui
% AUDIO_EQ_GUI - Final perfected version with original backend logic and perfect layout

% Main figure with perfect dimensions
hFig = figure('Name','Audio Equalizer','NumberTitle','off',...
    'MenuBar','none','ToolBar','none','Units','normalized',...
    'Position',[0.1 0.1 0.8 0.8], 'Color', [0.94 0.94 0.94]);

% Left panel (controls) - made slightly wider to prevent crowding
hLeft = uipanel(hFig,'Title','Controls','FontSize',12,...
    'Units','normalized','Position',[0.01 0.05 0.30 0.9],... % 30% width
    'BackgroundColor',[0.94 0.94 0.94], 'BorderType', 'etchedout');

% Right panel (visualization)
hRight = uipanel(hFig,'Title','Visualization','FontSize',12,...
    'Units','normalized','Position',[0.32 0.05 0.67 0.9],... % 67% width
    'BackgroundColor',[0.94 0.94 0.94], 'BorderType', 'etchedout');

%% Left panel layout - PERFECTLY SPACED ELEMENTS
% Calculate row positions (18 rows total)
rowHeight = 0.045; % Fixed height for all elements
spacing = 0.01; % Vertical spacing between elements
startY = 0.96; % Starting Y position (top of panel)

% Load Audio Button (TOP position - won't collide with anything)
uicontrol(hLeft,'Style','pushbutton','String','Load Audio File',...
    'FontSize',11,'FontWeight','bold','Units','normalized',...
    'Position',[0.1 startY-rowHeight 0.8 rowHeight],...
    'Callback',@onLoadAudio, 'BackgroundColor', [0.8 0.8 1]);

% Custom Mode Button (below Load button with proper spacing)
uicontrol(hLeft,'Style','pushbutton','String','Custom Mode',...
    'FontSize',11,'FontWeight','bold','Units','normalized',...
    'Position',[0.1 startY-2*rowHeight-spacing 0.8 rowHeight],...
    'Callback',@createCustomModeDialog, 'BackgroundColor', [0.8 1 0.8]);

% Sample Rates section
uicontrol(hLeft,'Style','text','String','Original SR:','FontSize',11,...
    'Units','normalized','Position',[0.05 startY-3*rowHeight-2*spacing 0.3 rowHeight],...
    'BackgroundColor',[0.94 0.94 0.94]);
hOrigSR = uicontrol(hLeft,'Style','text','String','N/A','FontSize',11,...
    'Units','normalized','Position',[0.4 startY-3*rowHeight-2*spacing 0.55 rowHeight],...
    'BackgroundColor','white', 'HorizontalAlignment', 'left');

uicontrol(hLeft,'Style','text','String','New SR (Hz):','FontSize',11,...
    'Units','normalized','Position',[0.05 startY-4*rowHeight-3*spacing 0.3 rowHeight],...
    'BackgroundColor',[0.94 0.94 0.94]);
hNewSR = uicontrol(hLeft,'Style','edit','String','','FontSize',10,...
    'Units','normalized','Position',[0.4 startY-4*rowHeight-3*spacing 0.55 rowHeight],...
    'BackgroundColor','white');

% Filter Type & Design
uicontrol(hLeft,'Style','text','String','Filter Type:','FontSize',11,...
    'Units','normalized','Position',[0.05 startY-5*rowHeight-4*spacing 0.25 rowHeight],...
    'BackgroundColor',[0.94 0.94 0.94]);
hFiltType = uicontrol(hLeft,'Style','popupmenu','String',{'FIR','IIR'},...
    'Units','normalized','Position',[0.3 startY-5*rowHeight-4*spacing 0.65 rowHeight],...
    'Callback',@onFilterType, 'BackgroundColor','white');

uicontrol(hLeft,'Style','text','String','Design:','FontSize',11,...
    'Units','normalized','Position',[0.05 startY-6*rowHeight-5*spacing 0.2 rowHeight],...
    'BackgroundColor',[0.94 0.94 0.94]);
hDesign = uicontrol(hLeft,'Style','popupmenu','String',{'Hamming','Hanning','Blackman'},...
    'Units','normalized','Position',[0.3 startY-6*rowHeight-5*spacing 0.65 rowHeight],...
    'Callback',@updateRecommendation, 'BackgroundColor','white');

% Order & Recommendation
uicontrol(hLeft,'Style','text','String','Order:','FontSize',11,...
    'Units','normalized','Position',[0.05 startY-7*rowHeight-6*spacing 0.2 rowHeight],...
    'BackgroundColor',[0.94 0.94 0.94]);
hOrder = uicontrol(hLeft,'Style','edit','String','100','FontSize',10,...
    'Units','normalized','Position',[0.3 startY-7*rowHeight-6*spacing 0.65 rowHeight],...
    'Callback',@updateRecommendation, 'BackgroundColor','white');
hRec = uicontrol(hLeft,'Style','text','String','Recommended: FIR Hamming 20–200',...
    'FontSize',9,'Units','normalized','Position',[0.05 startY-8*rowHeight-7*spacing 0.9 rowHeight],...
    'HorizontalAlignment','left', 'BackgroundColor',[0.9 0.95 1]);

%% Gain Sliders (0-100 dB) with SPECIFIED frequency bands
hSliders = gobjects(9,1);
hGainVals = gobjects(9,1);
bandNames = {'0-200Hz', '200-500Hz', '500-800Hz', '800-1200Hz',...
             '1.2-3kHz', '3-6kHz', '6-12kHz', '12-16kHz', '16-20kHz'};

% Calculate positions for all 9 sliders without collision
for i=1:9
    posY = startY-(9+i)*rowHeight-8*spacing;
    uicontrol(hLeft,'Style','text','String',bandNames{i},...
        'Units','normalized','Position',[0.05 posY 0.4 rowHeight],...
        'HorizontalAlignment','left', 'BackgroundColor',[0.94 0.94 0.94]);
    
    hSliders(i) = uicontrol(hLeft,'Style','slider',...
        'Min',0,'Max',100,'Value',0, 'SliderStep',[0.01 0.1],...
        'Units','normalized','Position',[0.45 posY 0.45 rowHeight],...
        'Callback',@updateGainLabel, 'BackgroundColor',[0.9 0.9 1]);
    
    hGainVals(i) = uicontrol(hLeft,'Style','text','String','0 dB',...
        'Units','normalized','Position',[0.92 posY 0.08 rowHeight],...
        'BackgroundColor','white');
end

% Process Audio Button (BOTTOM position - won't collide with last slider)
uicontrol(hLeft,'Style','pushbutton','String','Process Audio','FontSize',11,...
    'FontWeight','bold','Units','normalized','Position',[0.25 0.01 0.5 rowHeight],...
    'Callback',@onProcessAudio, 'BackgroundColor', [0.8 0.8 1]);

%% Right panel: 6 axes with reduced vertical height
% Calculate plot positions to use all available space
plotStartY = 0.78; % Higher starting position
plotHeight = 0.18; % Reduced height
for i=1:6
    row = ceil(i/2); col = mod(i-1,2)+1;
    axPos = [0.05+0.47*(col-1), plotStartY-0.26*(row-1), 0.45, plotHeight];
    hAxes(i) = axes('Parent',hRight,'Units','normalized','Position',axPos,...
        'Box','on', 'XGrid','on', 'YGrid','on');
    axis(hAxes(i),'on');
end

% Navigation & playback controls (BOTTOM - won't collide with plots)
controlY = 0.02;
controlHeight = 0.06;
uicontrol(hRight,'Style','pushbutton','String','< Previous','FontSize',11,...
    'Units','normalized','Position',[0.25 controlY 0.12 controlHeight],...
    'Callback',@onPrevPlot, 'BackgroundColor',[0.9 0.9 1]);
uicontrol(hRight,'Style','pushbutton','String','Next >','FontSize',11,...
    'Units','normalized','Position',[0.38 controlY 0.12 controlHeight],...
    'Callback',@onNextPlot, 'BackgroundColor',[0.9 0.9 1]);
uicontrol(hRight,'Style','pushbutton','String','Play','FontSize',11,...
    'FontWeight','bold','Units','normalized','Position',[0.52 controlY 0.12 controlHeight],...
    'Callback',@onPlay, 'BackgroundColor',[0.7 1 0.7]);
uicontrol(hRight,'Style','pushbutton','String','Stop','FontSize',11,...
    'FontWeight','bold','Units','normalized','Position',[0.65 controlY 0.12 controlHeight],...
    'Callback',@onStop, 'BackgroundColor',[1 0.7 0.7]);

%% Store data with original backend parameters
data = struct(...
    'hFiltType',hFiltType,'hDesign',hDesign,'hOrder',hOrder,'hRec',hRec,...
    'hOrigSR',hOrigSR,'hNewSR',hNewSR,'hSliders',{hSliders},'hGainVals',{hGainVals},...
    'hAxes',{hAxes},'Signal',[],'fs',[],'Filters',[],'BandNum',9,'Player',[],'OutputSignal',[],...
    'CurrentFig',1, 'Playing', false, 'Bands', [0, 200, 500, 800, 1200, 3000, 6000, 12000, 16000, 20000],...
    'CustomMode', false, 'CustomBands', [], 'CustomGains', [], 'StandardBands', [0, 200, 500, 800, 1200, 3000, 6000, 12000, 16000, 20000],...
    'CustomFig', [], 'CustomTable', [], 'CustomProcessing', false);
guidata(hFig,data);

%% Callback implementations with ORIGINAL BACKEND LOGIC
    function updateRecommendation(~,~)
        d = guidata(hFig);
        ft = get(d.hFiltType,'Value');
        des = get(d.hDesign,'String'); dv = get(d.hDesign,'Value');
        if ft==1
            rec = sprintf('FIR %s 20–200',des{dv});
        else
            rec = sprintf('IIR %s 2–10',des{dv});
        end
        set(d.hRec,'String',['Recommended: ' rec]);
    end

    function updateGainLabel(src,~)
        d = guidata(hFig);
        idx = find(d.hSliders==src);
        val = round(get(src,'Value'));
        set(d.hGainVals(idx),'String',sprintf('%d dB',val));
    end

    function onLoadAudio(~,~)
        [f,p] = uigetfile({'*.wav;*.mp3;*.ogg;*.flac','Audio Files (*.wav, *.mp3, *.ogg, *.flac)'});
        if isequal(f,0), return; end
        
        try
            [sig,fs] = audioread(fullfile(p,f));
            sig = mean(sig,2); % Convert to mono if stereo
            d = guidata(hFig); 
            d.Signal = sig; 
            d.fs = fs;
            set(d.hOrigSR,'String',num2str(fs)); 
            guidata(hFig,d);
            
            msgbox('Audio loaded successfully!', 'Success', 'help');
        catch ME
            errordlg(sprintf('Error loading audio file:\n%s', ME.message), 'File Error');
        end
    end

    function createCustomModeDialog(~,~)
        d = guidata(hFig);
        
        % Close any existing custom dialog
        if ~isempty(d.CustomFig) && ishandle(d.CustomFig)
            delete(d.CustomFig);
        end
        
        % Create figure for custom mode settings
        customFig = figure('Name','Custom Mode Settings','NumberTitle','off',...
            'MenuBar','none','ToolBar','none','Units','normalized',...
            'Position',[0.3 0.3 0.4 0.4], 'Color', [0.94 0.94 0.94],...
            'CloseRequestFcn',@closeCustomDialog);
        
        % Use existing custom bands if available, otherwise use defaults
        if ~isempty(d.CustomBands) && ~isempty(d.CustomGains) && ...
           length(d.CustomBands) == length(d.CustomGains)+1
            numBands = length(d.CustomBands)-1;
            tableData = cell(numBands,3);
            for i = 1:numBands
                tableData{i,1} = d.CustomBands(i);
                tableData{i,2} = d.CustomBands(i+1);
                tableData{i,3} = d.CustomGains(i);
            end
        else
            % Default bands (5 bands)
            defaultBands = [0, 500, 1500, 5000, 10000, 20000];
            defaultGains = zeros(1,5);
            
            % Create table data
            tableData = cell(5,3);
            for i = 1:5
                tableData{i,1} = defaultBands(i);
                tableData{i,2} = defaultBands(i+1);
                tableData{i,3} = 0; % 0 dB gain
            end
        end
        
        % Create table
        hTable = uitable(customFig, 'Data', tableData,...
            'ColumnName', {'Start Freq (Hz)', 'End Freq (Hz)', 'Gain (dB)'},...
            'ColumnFormat', {'numeric', 'numeric', 'numeric'},...
            'ColumnEditable', [true true true],...
            'Units', 'normalized', 'Position', [0.1 0.3 0.8 0.6],...
            'CellEditCallback', @validateTableInput);
        
        % Add row button
        uicontrol(customFig, 'Style', 'pushbutton', 'String', 'Add Band',...
            'Units', 'normalized', 'Position', [0.1 0.15 0.2 0.1],...
            'Callback', @addTableRow, 'BackgroundColor', [0.8 0.9 0.8]);
        
        % Remove row button
        uicontrol(customFig, 'Style', 'pushbutton', 'String', 'Remove Band',...
            'Units', 'normalized', 'Position', [0.35 0.15 0.2 0.1],...
            'Callback', @removeTableRow, 'BackgroundColor', [0.9 0.8 0.8]);
        
        % Save button - stores settings without processing
        uicontrol(customFig, 'Style', 'pushbutton', 'String', 'Save Settings',...
            'Units', 'normalized', 'Position', [0.6 0.05 0.3 0.08],...
            'Callback', @saveCustomSettings, 'BackgroundColor', [0.8 0.8 1]);
        
        % Process button - processes with custom settings
        uicontrol(customFig, 'Style', 'pushbutton', 'String', 'Process Audio',...
            'FontWeight','bold','Units', 'normalized', 'Position', [0.6 0.15 0.3 0.08],...
            'Callback', @processCustomAudio, 'BackgroundColor', [0.7 1 0.7]);
        
        % Store handles
        d.CustomFig = customFig;
        d.CustomTable = hTable;
        guidata(hFig, d);
        
        function validateTableInput(~, event)
            % Validate frequency inputs
            if event.Indices(2) == 1 || event.Indices(2) == 2
                newVal = event.NewData;
                if newVal < 0 || newVal > 20000
                    errordlg('Frequency must be between 0 and 20000 Hz', 'Invalid Input');
                    data = get(hTable, 'Data');
                    data{event.Indices(1), event.Indices(2)} = event.PreviousData;
                    set(hTable, 'Data', data);
                end
            % Validate gain input
            elseif event.Indices(2) == 3
                newVal = event.NewData;
                if newVal < -20 || newVal > 20
                    errordlg('Gain must be between -20 and 20 dB', 'Invalid Input');
                    data = get(hTable, 'Data');
                    data{event.Indices(1), event.Indices(2)} = event.PreviousData;
                    set(hTable, 'Data', data);
                end
            end
        end
        
        function addTableRow(~,~)
            data = get(hTable, 'Data');
            if size(data,1) >= 10
                errordlg('Maximum of 10 bands allowed', 'Limit Reached');
                return;
            end
            
            % Add new row with default values
            lastEndFreq = data{end,2};
            newEndFreq = min(20000, lastEndFreq + 1000);
            newRow = {lastEndFreq, newEndFreq, 0};
            set(hTable, 'Data', [data; newRow]);
        end
        
        function removeTableRow(~,~)
            data = get(hTable, 'Data');
            if size(data,1) <= 5
                errordlg('Minimum of 5 bands required', 'Limit Reached');
                return;
            end
            set(hTable, 'Data', data(1:end-1,:));
        end
        
        function saveCustomSettings(~,~)
            data = get(hTable, 'Data');
            bands = cell2mat(data(:,1:2)');
            bands = unique([bands(:); 20000]'); % Ensure last band is 20kHz and no duplicates
            
            % Check if frequencies are in order
            if ~issorted(bands)
                errordlg('Frequency bands must be in increasing order', 'Invalid Input');
                return;
            end
            
            % Store custom settings
            d = guidata(hFig);
            d.CustomBands = bands;
            d.CustomGains = cell2mat(data(:,3)');
            d.CustomMode = true;
            guidata(hFig, d);
            
            msgbox('Custom settings saved! Click "Process Audio" to apply them.', 'Settings Saved', 'help');
        end
        
        function processCustomAudio(~,~)
            data = get(hTable, 'Data');
            bands = cell2mat(data(:,1:2)');
            bands = unique([bands(:); 20000]'); % Ensure last band is 20kHz and no duplicates
            
            % Check if frequencies are in order
            if ~issorted(bands)
                errordlg('Frequency bands must be in increasing order', 'Invalid Input');
                return;
            end
            
            % Store custom settings
            d = guidata(hFig);
            d.CustomBands = bands;
            d.CustomGains = cell2mat(data(:,3)');
            d.CustomMode = true;
            d.CustomProcessing = true; % Flag for custom processing
            
            % Clear existing plots
            for k = 1:6
                cla(d.hAxes(k)); 
                axis(d.hAxes(k), 'on');
                grid(d.hAxes(k), 'on');
            end
            
            % Process audio with custom settings
            d = processAudio(d, true); % Get the updated handles
            guidata(hFig, d); % Store the updated handles
            
            % Close the custom dialog
            if ~isempty(d.CustomFig) && ishandle(d.CustomFig)
                delete(d.CustomFig);
                d.CustomFig = [];
                guidata(hFig, d);
            end
        end
        
        function closeCustomDialog(~,~)
            d = guidata(hFig);
            d.CustomFig = [];
            guidata(hFig, d);
            delete(gcbf); % Close the custom window
        end
    end

    function onFilterType(src,~)
        d = guidata(hFig);
        if get(src,'Value')==1
            set(d.hDesign,'String',{'Hamming','Hanning','Blackman'});
        else
            set(d.hDesign,'String',{'Butterworth','Chebyshev I','Chebyshev II'});
        end
        updateRecommendation();
        guidata(hFig,d);
    end

    function onProcessAudio(~,~)
        d = guidata(hFig);
        if isempty(d.Signal)
            errordlg('Please load an audio file first', 'No Audio');
            return; 
        end
        
        % Clear existing plots
        for k = 1:6
            cla(d.hAxes(k)); 
            axis(d.hAxes(k), 'on');
            grid(d.hAxes(k), 'on');
        end
        
        % Process in standard mode (9 bands)
        d.CustomProcessing = false;
        d = processAudio(d, false);
        guidata(hFig, d);
    end

    function d = processAudio(d, isCustom)
        try
            if isCustom
                % Process with custom settings
                bands = d.CustomBands;
                gains = d.CustomGains;
                numBands = length(gains);
            else
                % Process with standard settings (9 bands)
                bands = d.StandardBands;
                gains = zeros(1,9);
                for i = 1:9
                    gains(i) = get(d.hSliders(i),'Value');
                end
                numBands = 9;
            end
            
            sig = d.Signal; 
            fs0 = d.fs; 
            newFS = str2double(get(d.hNewSR,'String'));
            if isnan(newFS) || newFS <= 0
                errordlg('Invalid sample rate value', 'Input Error');
                return;
            end
            
            orderVal = str2double(get(d.hOrder,'String'));
            if isnan(orderVal) || orderVal <= 0
                errordlg('Invalid filter order value', 'Input Error');
                return;
            end
            
            designs = get(d.hDesign,'String'); 
            winType = designs{get(d.hDesign,'Value')};
            filtType = get(d.hFiltType,'Value');
            
            filters(1:numBands) = struct('b',[],'a',[],'y',[]);
            
            % Process each band
            for i = 1:numBands
                % Original frequency normalization
                Wn = bands(i:i+1)*2/fs0;
                if Wn(1) == 0, Wn(1) = eps; end
                if Wn(2) >= 1, Wn(2) = 1-eps; end
                
                if filtType == 1 % FIR
                    switch winType
                        case 'Hamming'
                            b = fir1(orderVal, Wn, hamming(orderVal+1));
                        case 'Hanning'
                            b = fir1(orderVal, Wn, hanning(orderVal+1));
                        case 'Blackman'
                            b = fir1(orderVal, Wn, blackman(orderVal+1));
                    end
                    a = 1;
                else % IIR
                    switch winType
                        case 'Butterworth'
                            [b,a] = butter(orderVal, Wn);
                        case 'Chebyshev I'
                            [b,a] = cheby1(orderVal, 1, Wn);
                        case 'Chebyshev II'
                            [b,a] = cheby2(orderVal, 40, Wn);
                    end
                end
                
                % Apply gain (convert from dB to linear)
                g_db = gains(i);
                g_lin = 10^(g_db/20);
                
                % Filter the signal
                y = g_lin * filter(b, a, sig);
                
                % Store filter parameters and output
                filters(i).b = b; 
                filters(i).a = a; 
                filters(i).y = y;
            end
            
            % Combine all bands and normalize
            out = sum(cat(2, filters.y), 2);
            out = out / max(abs(out));
            
            % Resample if needed
            if newFS ~= fs0
                [P,Q] = rat(newFS/fs0);
                out = resample(out, P, Q);
            end
            
            % Store results
            d.OutputSignal = out;
            d.Player = audioplayer(out, newFS); % Always create player
            d.Filters = filters; 
            d.CurrentFig = 1; 
            d.Bands = bands;
            d.BandNum = numBands;
            
            % Plot the first band
            plotCycle(d, 1);
            
            msgbox('Audio processed successfully!', 'Success', 'help');
        catch ME
            errordlg(sprintf('Error processing audio:\n%s', ME.message), 'Processing Error');
        end
    end

    function plotCycle(d, idx)
        if idx < 1 || idx > d.BandNum, return; end
        
        % Clear and prepare axes
        for k = 1:6
            cla(d.hAxes(k)); 
            axis(d.hAxes(k), 'on');
            grid(d.hAxes(k), 'on');
        end
        
        f = d.Filters(idx); 
        fs0 = d.fs;
        
        % Magnitude response
        [H,F] = freqz(f.b, f.a, fs0/2, fs0);
        plot(d.hAxes(1), F, abs(H));
        title(d.hAxes(1), sprintf('Magnitude - Band %d', idx));
        xlabel(d.hAxes(1), 'Frequency (Hz)'); ylabel(d.hAxes(1), '|H(f)|');
        xlim(d.hAxes(1), [d.Bands(idx)/2 d.Bands(idx+1)*2]);
        
        % Phase response
        plot(d.hAxes(2), F, angle(H)*180/pi);
        title(d.hAxes(2), 'Phase Response');
        xlabel(d.hAxes(2), 'Frequency (Hz)'); ylabel(d.hAxes(2), 'Phase (degrees)');
        
        % Step response
        step_resp = filter(f.b, f.a, ones(1, min(fs0, 1000)));
        plot(d.hAxes(3), (0:length(step_resp)-1)/fs0, step_resp);
        title(d.hAxes(3), 'Step Response');
        xlabel(d.hAxes(3), 'Time (s)'); ylabel(d.hAxes(3), 'Amplitude');
        
        % Impulse response
        imp_resp = filter(f.b, f.a, [1 zeros(1, min(fs0, 1000)-1)]);
        plot(d.hAxes(4), (0:length(imp_resp)-1)/fs0, imp_resp);
        title(d.hAxes(4), 'Impulse Response');
        xlabel(d.hAxes(4), 'Time (s)'); ylabel(d.hAxes(4), 'Amplitude');
        
        % Time domain output
        y = f.y;
        t = (1:length(y))/fs0;
        plot(d.hAxes(5), t, y);
        title(d.hAxes(5), 'Time Domain Output');
        xlabel(d.hAxes(5), 'Time (s)'); ylabel(d.hAxes(5), 'Amplitude');
        xlim(d.hAxes(5), [0 min(1, max(t))]);
        
        % Frequency domain output
        N = length(y);
        Yf = fftshift(abs(fft(y)));
        freqs = linspace(-fs0/2, fs0/2, N);
        plot(d.hAxes(6), freqs, Yf);
        title(d.hAxes(6), 'Frequency Domain Output');
        xlabel(d.hAxes(6), 'Frequency (Hz)'); ylabel(d.hAxes(6), 'Magnitude');
        xlim(d.hAxes(6), [0 fs0/2]);
        
        d.CurrentFig = idx; 
        guidata(hFig, d);
    end

    function onPrevPlot(~,~)
        d = guidata(hFig); 
        if ~isempty(d.Filters)
            newIdx = max(1, d.CurrentFig-1);
            plotCycle(d, newIdx);
        end
    end

    function onNextPlot(~,~)
        d = guidata(hFig); 
        if ~isempty(d.Filters)
            newIdx = min(d.BandNum, d.CurrentFig+1);
            plotCycle(d, newIdx);
        end
    end

    function onPlay(~,~)
        d = guidata(hFig); 
        if isfield(d, 'Player') && ~isempty(d.Player) && isvalid(d.Player)
            if d.Playing
                stop(d.Player);
            end
            play(d.Player);
            d.Playing = true;
            guidata(hFig, d);
        else
            errordlg('No processed audio available. Please process audio first.', 'Playback Error');
        end
    end

    function onStop(~,~)
        d = guidata(hFig); 
        if isfield(d, 'Player') && ~isempty(d.Player) && isvalid(d.Player) && d.Playing
            stop(d.Player);
            d.Playing = false;
            guidata(hFig, d);
        end
    end
end