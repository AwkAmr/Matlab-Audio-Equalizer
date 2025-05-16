%% Clear Previous Outputs %%
clc; clear; close all;

%% Preparations %%
File = uigetfile('.wav');
[Signal, fs] = audioread(File);
Len = length(Signal);

%% Get Input %%

InputMode = input(sprintf("1: Standard Mode\t2: Custom Mode"));
if (InputMode == 1)
    BandNum = 9;
    Bands = [0.01, 200, 500, 800, 1200, 3000, 6000, 12000, 16000,20000];
    % Find way to make 0 work instead of 0.01
    TimeY = zeros(BandNum,n);
    FreqY = zeros(BandNum,n);
    Gains = zeros(1,BandNum);
elseif (InputMode ==2)
    BandNum = input("",BandNum);
    Bands = [0.01,zeros(1,BandNum-1) ,20000];
    TimeY = zeros(BandNum,n);
    FreqY = zeros(BandNum,n);
    Gains = zeros(1,BandNum);
    %%for
        %  %
    %%end
end

%% Get Gain from User %%

for i = 1:BandNum
    Gains(i) = input("",i); %TODO
    Gains(i) = 10^(Gains(i)/20);
end

%% Get new Rate %%
NewSampleRate = input("Enter new sample rate",NewSampleRate); %TODO
%% %%
StepInput = ones(1,fs);
% can change fs to x*fs to change numnber of seconds to plot in
ImpulseInput = [1 zeros(1,fs-1)];

%% %%
Type = input(sprintf("TODO / FIR OR IR"));
if (Type == 1)
    FIRType = input(sprintf("")); %TODO
    switch FIRType
        case 1
            Num = fir1(order, [bands(i) bands(i+1)]*2/fs, hamming(order+1));
            Denum = 1;
        case 2
            Num = fir1(order, [bands(i) bands(i+1)]*2/fs, hanning(order+1));
            Denum = 1;
        case 3
            Num = fir1(order, [bands(i) bands(i+1)]*2/fs, blackman(order+1));
            Denum = 1;
    end
else
    IIRType = input(sprintf("")); %TODO
    switch IIRType
        case 1
            [Num,Denum] = butter(order, [bands(i) bands(i+1)]*2/fs);
        case 2
            [Num,Denum] = cheby1(order, 1, [bands(i) bands(i+1)]*2/fs);
            % 0.1 to 3 TODO: Change Range
            % 0.1 to 2 safer
        case 3
            [Num,Denum] = cheby2(order, 40, [bands(i) bands(i+1)]*2/fs);
            % 30 to 60 TODO: Change Range
            % Where did i get the ranges from? From Matlab documentation ;)
    end
end

y(i, :) = gain(i) * filter(Num, Denum, Signal);
Step = filter(Num, Denum, StepInput);
Impulse = filter(Denum, Num, ImpulseInput);
[H, F] = freqz(Num, Denum, fs/2 ,fs);

% TODO: Change plotting settings
figure(i)
subplot(3,2,1);
plot(F, abs(H));
xlim([bands(i)/2 bands(i+1)*2])
title('') 
grid on 

subplot(3,2,2);
plot(F, angle(H)*180/pi);
title('')
grid on

% TODO: Draw rest of 4 plots
% TODO: check user input band number less than 5 or more than 9

%% %%
X_axis = (-n/2:n/2-1) * (fs/n);
for i = 1:k
    Y(i, :) = (1/fs) * fftshift(fft(y(i, :)));

end
    

