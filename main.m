%% Clear Previous Outputs %%
clc; clear; close all;

%% Load Audio File %%
[FileName, FilePath] = uigetfile('*.mp3', 'Select an audio file');
if isequal(FileName, 0)
    error("No file selected.");
end
[Signal, fs] = audioread(fullfile(FilePath, FileName));
Signal = mean(Signal, 2); % Convert to mono if stereo
Len = length(Signal);

%% Input Mode %%
InputMode = input(sprintf("1: Standard Mode\t2: Custom Mode: "));
if InputMode == 1
    BandNum = 9;
    Bands = [0, 200, 500, 800, 1200, 3000, 6000, 12000, 16000, 20000];
elseif InputMode == 2
    while true
        BandNum = input(sprintf("Enter number of bands (5–9): "));
        if BandNum >= 5 && BandNum <= 9
            break;
        else
            disp("Invalid input. Please enter a number between 5 and 9.");
        end
    end

    Bands = zeros(1, BandNum + 1);
    Bands(1) = 0;
    for i = 2:BandNum
        Bands(i) = input(sprintf("Enter band edge %d (Hz): ", i-1));
    end
    Bands(end) = 20000;

    if ~issorted(Bands)
        error("Band edges must be in increasing order.");
    end
else
    error("Invalid input mode.");
end

%% Gain Input %%
Gains = zeros(1, BandNum);
for i = 1:BandNum
    gain_db = input(sprintf("Enter Gain in dB for Band %d (%.0fHz–%.0fHz): ", i, Bands(i), Bands(i+1)));
    Gains(i) = 10^(gain_db/20); % Convert dB to linear
end

%% Sample Rate %%
NewSampleRate = input(sprintf("Enter new sample rate (Hz): "));
if NewSampleRate <= 0
    error("Invalid sample rate.");
end

%% Filter Type %%
FilterType = input(sprintf("Select filter type: 1: FIR\t2: IIR: "));
order = input(sprintf("Enter filter order (e.g., 100): "));
if FilterType == 1
    FIRType = input(sprintf("FIR window: 1: Hamming\t2: Hanning\t3: Blackman: "));
elseif FilterType == 2
    IIRType = input(sprintf("IIR type: 1: Butterworth\t2: Chebyshev I\t3: Chebyshev II: "));
else
    error("Invalid filter type.");
end

%% Initialize Arrays %%
y = zeros(BandNum, Len);
StepInput = ones(1, fs);
ImpulseInput = [1 zeros(1, fs - 1)];

%% Filtering Loop %%
for i = 1:BandNum
    Wn = [Bands(i), Bands(i+1)] * 2 / fs; % Normalize
    if Wn(1) == 0
        Wn(1) = eps; % Avoid 0 frequency
    end

    % Design Filter
    if FilterType == 1
        switch FIRType
            case 1
                Num = fir1(order, Wn, hamming(order+1));
            case 2
                Num = fir1(order, Wn, hanning(order+1));
            case 3
                Num = fir1(order, Wn, blackman(order+1));
            otherwise
                error("Invalid FIR type.");
        end
        Denum = 1;
    else
        switch IIRType
            case 1
                [Num, Denum] = butter(order, Wn);
            case 2
                [Num, Denum] = cheby1(order, 1, Wn); % 1 dB ripple
            case 3
                [Num, Denum] = cheby2(order, 40, Wn); % 40 dB stopband
            otherwise
                error("Invalid IIR type.");
        end
    end

    % Filter Signal
    y(i, :) = Gains(i) * filter(Num, Denum, Signal);

    % Plotting
    [H, F] = freqz(Num, Denum, fs/2, fs);

    figure(i)
    tiledlayout(3,2)
    nexttile
    plot(F, abs(H));
    title(sprintf("Magnitude Response - Band %d", i));
    xlabel("Frequency (Hz)"); ylabel("|H(f)|");
    xlim([Bands(i)/2 Bands(i+1)*2]); grid on;

    nexttile
    plot(F, angle(H) * 180/pi);
    title("Phase Response");
    xlabel("Frequency (Hz)"); ylabel("Phase (degrees)");
    grid on;

    nexttile
    plot(filter(Num, Denum, StepInput));
    title("Step Response");
    grid on;

    nexttile
    plot(filter(Num, Denum, ImpulseInput));
    title("Impulse Response");
    grid on;

    nexttile
    plot((1:Len)/fs, y(i,:));
    title("Filtered Signal (Time Domain)");
    xlabel("Time (s)"); grid on;

    nexttile
    Yf = fftshift(abs(fft(y(i,:))));
    freqs = linspace(-fs/2, fs/2, Len);
    plot(freqs, Yf);
    title("Filtered Signal (Freq Domain)");
    xlabel("Frequency (Hz)"); grid on;
end

%% Mix and Output %%
OutputSignal = sum(y, 1);
sound(OutputSignal, NewSampleRate);
audiowrite('Filtered_Output.wav', OutputSignal, NewSampleRate);
disp('Filtered audio saved as Filtered_Output.wav');
