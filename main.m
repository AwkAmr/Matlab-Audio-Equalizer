function AudioEqualizerApp
% Main figure
hFig = figure('Name','Audio Equalizer','NumberTitle','off','MenuBar','none','ToolBar','none','Units','normalized','Position',[0.1 0.1 0.8 0.8], 'Color', [0.94 0.94 0.94]);

% Left panel 
hLeft = uipanel(hFig,'Title','Controls','FontSize',12,'Units','normalized','Position',[0.01 0.05 0.30 0.9],'BackgroundColor',[0.94 0.94 0.94], 'BorderType', 'etchedout');

% Right panel
hRight = uipanel(hFig,'Title','Visualization','FontSize',12,'Units','normalized','Position',[0.32 0.05 0.67 0.9],'BackgroundColor',[0.94 0.94 0.94], 'BorderType', 'etchedout');

%% Left panel layout
rowHeight = 0.045; 
spacing = 0.01;
startY = 0.96; 

% Load Audio Button
uicontrol(hLeft,'Style','pushbutton','String','Load Audio File','FontSize',11,'FontWeight','bold','Units','normalized','Position',[0.1 startY-rowHeight 0.8 rowHeight],'Callback',@onLoadAudio, 'BackgroundColor', [0.8 0.8 1]);

% Custom Mode Button
uicontrol(hLeft,'Style','pushbutton','String','Custom Mode','FontSize',11,'FontWeight','bold','Units','normalized','Position',[0.1 startY-2*rowHeight-spacing 0.8 rowHeight],'Callback',@createCustomModeDialog, 'BackgroundColor', [0.8 1 0.8]);

% Sample Rates
uicontrol(hLeft,'Style','text','String','Original SR:','FontSize',11,'Units','normalized','Position',[0.05 startY-3*rowHeight-2*spacing 0.3 rowHeight],'BackgroundColor',[0.94 0.94 0.94]);
hOrigSR = uicontrol(hLeft,'Style','text','String','N/A','FontSize',11,'Units','normalized','Position',[0.4 startY-3*rowHeight-2*spacing 0.55 rowHeight],'BackgroundColor','white', 'HorizontalAlignment', 'left');

uicontrol(hLeft,'Style','text','String','New SR (Hz):','FontSize',11,'Units','normalized','Position',[0.05 startY-4*rowHeight-3*spacing 0.3 rowHeight],'BackgroundColor',[0.94 0.94 0.94]);
hNewSR = uicontrol(hLeft,'Style','edit','String','','FontSize',10,'Units','normalized','Position',[0.4 startY-4*rowHeight-3*spacing 0.55 rowHeight],'BackgroundColor','white');

% Filter
uicontrol(hLeft,'Style','text','String','Filter Type:','FontSize',11,'Units','normalized','Position',[0.05 startY-5*rowHeight-4*spacing 0.25 rowHeight],'BackgroundColor',[0.94 0.94 0.94]);
hFiltType = uicontrol(hLeft,'Style','popupmenu','String',{'FIR','IIR'},'Units','normalized','Position',[0.3 startY-5*rowHeight-4*spacing 0.65 rowHeight],'Callback',@onFilterType, 'BackgroundColor','white');

uicontrol(hLeft,'Style','text','String','Design:','FontSize',11,'Units','normalized','Position',[0.05 startY-6*rowHeight-5*spacing 0.2 rowHeight],'BackgroundColor',[0.94 0.94 0.94]);
hDesign = uicontrol(hLeft,'Style','popupmenu','String',{'Hamming','Hanning','Blackman'},'Units','normalized','Position',[0.3 startY-6*rowHeight-5*spacing 0.65 rowHeight],'Callback',@updateRecommendation, 'BackgroundColor','white');

% Order
uicontrol(hLeft,'Style','text','String','Order:','FontSize',11,'Units','normalized','Position',[0.05 startY-7*rowHeight-6*spacing 0.2 rowHeight],'BackgroundColor',[0.94 0.94 0.94]);
hOrder = uicontrol(hLeft,'Style','edit','String','100','FontSize',10,'Units','normalized','Position',[0.3 startY-7*rowHeight-6*spacing 0.65 rowHeight],'Callback',@updateRecommendation, 'BackgroundColor','white');
hRec = uicontrol(hLeft,'Style','text','String','Recommended: FIR Hamming 20–200','FontSize',9,'Units','normalized','Position',[0.05 startY-8*rowHeight-7*spacing 0.9 rowHeight],'HorizontalAlignment','left', 'BackgroundColor',[0.9 0.95 1]);

%% Gain Sliders
hSliders = gobjects(9,1);
hGainVals = gobjects(9,1);
bandNames = {'0-200Hz', '200-500Hz', '500-800Hz', '800-1200Hz','1.2-3kHz', '3-6kHz', '6-12kHz', '12-16kHz', '16-20kHz'};

for i=1:9
    posY = startY-(9+i)*rowHeight-8*spacing;
    uicontrol(hLeft,'Style','text','String',bandNames{i},'Units','normalized','Position',[0.05 posY 0.4 rowHeight],'HorizontalAlignment','left', 'BackgroundColor',[0.94 0.94 0.94]);
    
    hSliders(i) = uicontrol(hLeft,'Style','slider','Min',0,'Max',100,'Value',0, 'SliderStep',[0.01 0.1],'Units','normalized','Position',[0.45 posY 0.45 rowHeight],'Callback',@updateGainLabel, 'BackgroundColor',[0.9 0.9 1]);
    
    hGainVals(i) = uicontrol(hLeft,'Style','text','String','0 dB','Units','normalized','Position',[0.92 posY 0.08 rowHeight],'BackgroundColor','white');
end

% Process Audio Button
uicontrol(hLeft,'Style','pushbutton','String','Process Audio','FontSize',11,'FontWeight','bold','Units','normalized','Position',[0.25 0.01 0.5 rowHeight],'Callback',@onProcessAudio, 'BackgroundColor', [0.8 0.8 1]);

%% Right panel
hAxes = gobjects(7,1);
plotStartY = 0.8; 
plotHeight = 0.15; 
verticalStep = 0.2;

for i = 1:6
    row = ceil(i/2);
    col = mod(i-1,2)+1;
    axPos = [0.05 + 0.47*(col-1), plotStartY - verticalStep*(row-1), 0.45, plotHeight];
    hAxes(i) = axes('Parent',hRight,'Units','normalized','Position',axPos,'Box','on', 'XGrid','on', 'YGrid','on');
    axis(hAxes(i), 'on');
end

axPos = [0.05, plotStartY - verticalStep*3, 0.9, plotHeight];
hAxes(7) = axes('Parent',hRight,'Units','normalized','Position',axPos,'Box','on', 'XGrid','on', 'YGrid','on');
axis(hAxes(7), 'on');

% Navigation controls
controlY = 0.02;
controlHeight = 0.06;
uicontrol(hRight,'Style','pushbutton','String','< Previous','FontSize',11,'Units','normalized','Position',[0.25 controlY 0.12 controlHeight],'Callback',@onPrevPlot, 'BackgroundColor',[0.9 0.9 1]);
uicontrol(hRight,'Style','pushbutton','String','Next >','FontSize',11,'Units','normalized','Position',[0.38 controlY 0.12 controlHeight],'Callback',@onNextPlot, 'BackgroundColor',[0.9 0.9 1]);
uicontrol(hRight,'Style','pushbutton','String','Play','FontSize',11,'FontWeight','bold','Units','normalized','Position',[0.52 controlY 0.12 controlHeight],'Callback',@onPlay, 'BackgroundColor',[0.7 1 0.7]);
uicontrol(hRight,'Style','pushbutton','String','Stop','FontSize',11,'FontWeight','bold','Units','normalized','Position',[0.65 controlY 0.12 controlHeight],'Callback',@onStop, 'BackgroundColor',[1 0.7 0.7]);

%% Store Data
data = struct('hFiltType',hFiltType,'hDesign',hDesign,'hOrder',hOrder,'hRec',hRec,'hOrigSR',hOrigSR,'hNewSR',hNewSR,'hSliders',{hSliders},'hGainVals',{hGainVals},'hAxes',{hAxes},'Signal',[],'fs',[],'Filters',[],'BandNum',9,'Player',[],'OutputSignal',[],'CurrentFig',1, 'Playing', false, 'Bands', [0, 200, 500, 800, 1200, 3000, 6000, 12000, 16000, 20000],'CustomMode', false, 'CustomBands', [], 'CustomGains', [], 'StandardBands', [0, 200, 500, 800, 1200, 3000, 6000, 12000, 16000, 20000],'CustomFig', [], 'CustomTable', [], 'CustomProcessing', false,'ShowSummary', false, 'SummaryPlots', []); % New fields for summary
guidata(hFig,data);

%% Callbacks
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
            sig = mean(sig,2); % Convert to mono
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
        
        if ~isempty(d.CustomFig) && ishandle(d.CustomFig)
            delete(d.CustomFig);
        end
        
        customFig = figure('Name','Custom Mode Settings','NumberTitle','off','MenuBar','none','ToolBar','none','Units','normalized','Position',[0.3 0.3 0.4 0.4], 'Color', [0.94 0.94 0.94],'CloseRequestFcn',@closeCustomDialog);
        
        if ~isempty(d.CustomBands) && ~isempty(d.CustomGains) && length(d.CustomBands) == length(d.CustomGains)+1
            numBands = length(d.CustomBands)-1;
            tableData = cell(numBands,3);
            for i = 1:numBands
                tableData{i,1} = d.CustomBands(i);
                tableData{i,2} = d.CustomBands(i+1);
                tableData{i,3} = d.CustomGains(i);
            end
        else
            % Default 5 bands
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
        hTable = uitable(customFig, 'Data', tableData,'ColumnName', {'Start Freq (Hz)', 'End Freq (Hz)', 'Gain (dB)'},'ColumnFormat', {'numeric', 'numeric', 'numeric'},'ColumnEditable', [true true true],'Units', 'normalized', 'Position', [0.1 0.3 0.8 0.6],'CellEditCallback', @validateTableInput);
        
        % Add row button
        uicontrol(customFig, 'Style', 'pushbutton', 'String', 'Add Band','Units', 'normalized', 'Position', [0.1 0.15 0.2 0.1],'Callback', @addTableRow, 'BackgroundColor', [0.8 0.9 0.8]);
       
        % Remove row button
        uicontrol(customFig, 'Style', 'pushbutton', 'String', 'Remove Band','Units', 'normalized', 'Position', [0.35 0.15 0.2 0.1],'Callback', @removeTableRow, 'BackgroundColor', [0.9 0.8 0.8]);
        
        % Save button 
        uicontrol(customFig, 'Style', 'pushbutton', 'String', 'Save Settings','Units', 'normalized', 'Position', [0.6 0.05 0.3 0.08],'Callback', @saveCustomSettings, 'BackgroundColor', [0.8 0.8 1]);
        
        % Process button 
        uicontrol(customFig, 'Style', 'pushbutton', 'String', 'Process Audio','FontWeight','bold','Units', 'normalized', 'Position', [0.6 0.15 0.3 0.08],'Callback', @processCustomAudio, 'BackgroundColor', [0.7 1 0.7]);
        
        d.CustomFig = customFig;
        d.CustomTable = hTable;
        guidata(hFig, d);
        
        function validateTableInput(~, event)
            if event.Indices(2) == 1 || event.Indices(2) == 2
                newVal = event.NewData;
                if newVal < 0 || newVal > 20000
                    errordlg('Frequency must be between 0 and 20000 Hz', 'Invalid Input');
                    data = get(hTable, 'Data');
                    data{event.Indices(1), event.Indices(2)} = event.PreviousData;
                    set(hTable, 'Data', data);
                end
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
            bands = unique([bands(:); 20000]');
            
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
            bands = unique([bands(:); 20000]'); 
            
            if ~issorted(bands)
                errordlg('Frequency bands must be in increasing order', 'Invalid Input');
                return;
            end
            
            d = guidata(hFig);
            d.CustomBands = bands;
            d.CustomGains = cell2mat(data(:,3)');
            d.CustomMode = true;
            d.CustomProcessing = true; 
            
            % Clear existing plots
            for k = 1:6
                cla(d.hAxes(k)); 
                axis(d.hAxes(k), 'on');
                grid(d.hAxes(k), 'on');
            end
            
            % Process audio 
            d = processAudio(d, true); 
            guidata(hFig, d);
            
            if ~isempty(d.CustomFig) && ishandle(d.CustomFig)
                delete(d.CustomFig);
                d.CustomFig = [];
                guidata(hFig, d);
            end

            d.CurrentFig = 1;
            d.ShowSummary = false;
            guidata(hFig, d);
        end
        
        function closeCustomDialog(~,~)
            d = guidata(hFig);
            d.CustomFig = [];
            guidata(hFig, d);
            delete(gcbf); 
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
        
        for k = 1:6
            cla(d.hAxes(k)); 
            axis(d.hAxes(k), 'on');
            grid(d.hAxes(k), 'on');
        end
        
        % Process in standard mode
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
                % Process with standard mde
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
            
            for i = 1:numBands
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
                
                % Convert from dB to linear
                g_db = gains(i);
                g_lin = 10^(g_db/20);
                
                % Filter
                y = g_lin * filter(b, a, sig);
                
                filters(i).b = b; 
                filters(i).a = a; 
                filters(i).y = y;
            end
            
            out = sum(cat(2, filters.y), 2);
            out = out / max(abs(out));
            
            % Store results
            d.OutputSignal = out;
            d.newFS = newFS;  
            d.Player = audioplayer(out, newFS);
            d.Filters = filters; 
            d.CurrentFig = 1;
            d.Bands = bands;
            d.BandNum = numBands;  
            d.ShowSummary = false; 
            
            % Outputting 4x and 1/2 sample rate
            audiowrite('SampleMul4.wav', d.OutputSignal, d.newFS * 4);
            audiowrite('SampleDiv2.wav', d.OutputSignal, d.newFS / 2);
            plotCycle(d, 1);
            
            msgbox('Audio processed successfully!', 'Success', 'help');
        catch ME
            errordlg(sprintf('Error processing audio:\n%s', ME.message), 'Processing Error');
        end
    end

    function plotCycle(d, idx)
        % Clear all axes first
        arrayfun(@cla, d.hAxes)
        set(d.hAxes, 'Visible', 'off');

        if idx <= d.BandNum
            % Restore original axes positions
            positions = [
                [0.05 0.80 0.45 0.18];  % Magnitude
                [0.52 0.80 0.45 0.18];  % Phase
                [0.05 0.58 0.45 0.18];  % Step
                [0.52 0.58 0.45 0.18];  % Impulse
                [0.05 0.36 0.45 0.18];  % Time
                [0.52 0.36 0.45 0.18];  % Frequency
                [0.05 0.14 0.90 0.18];  % Poles/Zeros
            ];
            for k = 1:7
                set(d.hAxes(k), 'Position', positions(k,:));
                set(d.hAxes(k), 'Visible', 'on');
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
            
            % Frequency domain output
            N = length(y);
            Yf = (1/fs0)*fftshift((abs(fft(y))));
            freqs = (-N/2:N/2-1)*(fs0/N);
            stem(d.hAxes(6), freqs, Yf);
            title(d.hAxes(6), 'Frequency Domain Output');
            xlabel(d.hAxes(6), 'Frequency (Hz)'); ylabel(d.hAxes(6), 'Magnitude');
            xlim(d.hAxes(6), [-fs0/2 fs0/2]);
        
            % Poles and Zeros plot
            axes(d.hAxes(7));
            zplane(f.b, f.a);
            title(d.hAxes(7), 'Poles and Zeros');
            grid(d.hAxes(7), 'on');
            
            set(d.hAxes(1:7), 'Visible', 'on');
        else
            set(d.hAxes(1), 'Position', [0.05 0.60 0.45 0.35]);
            set(d.hAxes(2), 'Position', [0.52 0.60 0.45 0.35]);
            set(d.hAxes(3), 'Position', [0.05 0.15 0.45 0.35]);
            set(d.hAxes(4), 'Position', [0.52 0.15 0.45 0.35]);
            set(d.hAxes(1:4), 'Visible', 'on');
            
            % Plot data
            sig = d.Signal;
            out = d.OutputSignal;
            fs = d.fs;
            
            % Time domain original
            axes(d.hAxes(1));
            t = (0:length(sig)-1)/fs;
            plot(t, sig);
            title('Original (Time)');
            xlabel('Time (s)');
            ylabel('Amplitude');
            
            % Time domain filtered
            axes(d.hAxes(2));
            t_out = (0:length(out)-1)/fs;
            plot(t_out, out);
            title('Filtered (Time)');
            xlabel('Time (s)');
            ylabel('Amplitude');
            
            % Frequency domain original
            axes(d.hAxes(3));
            Y_orig = (1/fs)*fftshift(abs(fft(sig)));
            N0 = length(Y_orig);
            f_orig = (-N0/2:N0/2-1)*(fs/N0);
            stem(f_orig, abs(Y_orig));
            title('Original (Freq)');
            xlabel('Frequency (Hz)');
            ylabel('Magnitude');
            xlim([-fs/2 fs/2]);
            
            % Frequency domain filtered
            axes(d.hAxes(4));
            Y_filt = (1/fs)*fftshift(abs(fft(out)));
            N1 = length(Y_filt);
            f_filt = (-N1/2:N1/2-1)*(fs/N1);
            stem(f_filt, abs(Y_filt));
            title('Filtered (Freq)');
            xlabel('Frequency (Hz)');
            ylabel('Magnitude');
            xlim([-fs/2 fs/2]);

        end
        d.CurrentFig = idx;
        guidata(hFig, d);
    end

    function onNextPlot(~,~)
        d = guidata(hFig); 
        if ~isempty(d.Filters)
            maxIdx = d.BandNum + 1;
            newIdx = min(maxIdx, d.CurrentFig + 1);
            plotCycle(d, newIdx);
        end
    end

    function onPrevPlot(~,~)
        d = guidata(hFig); 
        if ~isempty(d.Filters)
            newIdx = max(1, d.CurrentFig - 1);
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
