function flag_exit = bcrDemo(param)
% % last edit, 20221215
% % demo for BrainCooperate game

correlation_threshold = 0.6;%0.425-->0.77-->0.7

Screen('Preference','SkipSyncTests', 1);
Screen('Preference', 'VisualDebuglevel', 3);% disable the startup screen, replace it by a black display until calibration is finished

flag_exit =1;
[win, winRect] = bcrwindow(param);
ifi = Screen('GetFlipInterval', win); % s
[screenXpixels, screenYpixels] = Screen('WindowSize', win);
[xCenter, yCenter] = RectCenter(winRect); % Get the centre coordinate of the window
vbl = Screen('Flip', win); % Sync us and get a time stamp
waitframes = 1;
baseRect = [0 0 150 150]; % Make a base Rect of 150 by 150 pixels
time = 0;
disp(ifi);

% % background music
% pahandle = bcrbgm;

%% Set
initX = xCenter;
initY = yCenter-50;
initSpd = 0;
% initA = -screenYpixels/25^2; % initial acceleration
% initA = -screenYpixels/12^2; % initial acceleration
initA = -screenYpixels/170; % initial acceleration
CoopA = screenYpixels/3; % acceleration when clicking 'UP'
% CoopA = screenYpixels; % acceleration when clicking 'UP'
% TimeWindow = 0.02; % s
TimeWindow = 0.055; % s
GameTime = 60; % s
upFlag = 0;
downFlag = 0;

%% Background
backgroundLocation = 'images\road1.png';
background = imread(backgroundLocation);
[s1, s2, s3] = size(background);
if s1 > screenXpixels || s2 > screenYpixels
    disp('ERROR! Image is too big to fit on the screen');
    sca;
    return;
end
backgroundTexture = Screen('MakeTexture', win, background);

cloudLocation = 'images\cloud.png';
[cloud,~,alpha] = imread(cloudLocation);
cloud(:,:,4) = alpha;
cloudTexture = Screen('MakeTexture', win, cloud);



%% the car we need control by keys
thecarLocation = 'images\car.png';
[thecar,~,alpha] = imread(thecarLocation);
thecar(:,:,4) = alpha;
carTexture = Screen('MakeTexture', win, thecar);


%% Parameters
% The available keys to press
escapeKey = KbName('ESCAPE');
upKey = KbName('UpArrow');
downKey = KbName('DownArrow');

% Intial position
XPos = initX;
YPos = initY;
SpdX = initSpd;
SpdY = -initSpd;
cloudXPos = xCenter-350;
cloudYPos = 150;

% XPos_leftBoundaryCoeff = 0.39;
% XPos_rightBoundaryCoeff = 0.61;

% Maximum priority level
topPriorityLevel = MaxPriority(win);
Priority(topPriorityLevel);

% This is the cue which determines whether we exit the demo
exitDemo = false;

% %% 打开串口设备及其相关变量的初始化
% if ~isempty(instrfind)
%     delete(instrfindall);
% end
% com = ComboQuery							%#ok<*NOPTS> % com为字符串数组，包含所有的电生理一体机设备名称
% if isempty(com)
%     msgbox('没有设备连接，怎么玩啊？');
%     return;
% elseif length(com(:,1))<2
%     msgbox('只有一个设备，我对抗啥啊？');
%     return;
% end
% obj1 = ComboOpen(com(1,:));
% obj2 = ComboOpen(com(2,:));

fileID1 =  fopen('mSignalState1.dat','r+');
m1 = memmapfile('mSignalState1.dat', 'Writable', true, 'Format', 'double');
fileID2 =  fopen('mSignalState2.dat','r+');
m2 = memmapfile('mSignalState2.dat', 'Writable', true, 'Format', 'double');


Fs = 30000; %sample frequency is 30kHz;
readInterval = 100; % set frequency of read signal from Combo each readInterval ms
% readInterval = 20; % set frequency of read signal from Combo each readInterval ms

readCount = 0;
% SignalPoint11 = zeros(round(GameTime*1000/readInterval),1);
% SignalPoint12 = zeros(round(GameTime*1000/readInterval),1);
% SignalPoint21 = zeros(round(GameTime*1000/readInterval),1);
% SignalPoint22 = zeros(round(GameTime*1000/readInterval),1);
SignalPoint11 = 0;
SignalPoint12 = 0;
SignalPoint21 = 0;
SignalPoint22 = 0;

correlation = 0; %#ok<*NASGU>
% correlation_threshold = 0.68;%0.425-->0.77-->0.7
parity = 1;
parity2 = 1;
parity2_done = 0;

sigtmp11 = [];
sigtmp12 = [];
sigtmp21 = [];
sigtmp22 = [];
signal1_baseline = 1;
signal2_baseline = 1;
normalization_ok = 0;

% % 播放背景音乐
% pahandle = bcrbgm;
pahandle = bcrbgm_jjb('doubleBGM.ogg',1,0.25);
% pahandle = bcrbgm_jjb('03_Fantasy_Forest.ogg',1,0.25);

bgm_flag = 1;

t0 = tic;
t = toc(t0);

flag_ongoing0_lose1_win2 = 0;

% Loop the animation until the escape key is pressed
while exitDemo == false
    t = toc(t0);
    
    %if t > 2 && bgm_flag == 1
    if t > 200 && bgm_flag == 1
        % % 停止背景音乐
        PsychPortAudio('Stop', pahandle);
        PsychPortAudio('Close');
        bgm_flag = 0;
    end
    
    % read data from Combo each readInterval time
    if t < 2
    else
        if normalization_ok == 0
%                 [sigtmp1,temp1] = ReadSignal(obj1);
%                 [sigtmp2,temp2] = ReadSignal(obj2);
                sigtmp1 = m1.Data;
                %temp1 = length(sigtmp1);
                sigtmp2 = m2.Data;
                %temp2 = length(sigtmp2);                
                signal1 = 10000 * sigtmp1;
                signal2 = 10000 * sigtmp2;
                signal1_baseline = mean(signal1);
                signal2_baseline = mean(signal2);
                
                m1.Data = zeros(1,70000);%40000
                m2.Data = zeros(1,70000);
                
                normalization_ok = 1;
        else
            if floor(t*1000/readInterval)>readCount
                readCount = floor(t*1000/readInterval) +1;
                %read data from Combo
%                 [sigtmp1,SignalPoint1(readCount)] = ReadSignal(obj1);
%                 [sigtmp2,SignalPoint2(readCount)] = ReadSignal(obj2);
%                 signal1 = 10000 * sigtmp1/signal1_baseline;
%                 signal2 = 10000 * sigtmp2/signal1_baseline;
%                 correlation = corr(signal1(end-299:end)', signal2(end-299:end)');
%                 %         if abs(correlation) > correlation_threshold && ...
%                 %                 abs(mean(signal1)) > 0.2 && ...
%                 %                 abs(mean(signal2)) > 0.2
%                 if abs(correlation) > correlation_threshold
%                     tempT = time;
%                     A = initA + CoopA;
%                     upFlag = 1;
%                     fprintf("correlation = %.2f", correlation);
%                 end

                %[sigtmp1,SignalPoint1] = ReadSignal(obj1); 
                %[sigtmp2,SignalPoint2] = ReadSignal(obj2);
                sigtmp1 = m1.Data;
                m1.Data = zeros(1,70000);
                SignalPoint1 = length(sigtmp1);
                sigtmp2 = m2.Data;
                m2.Data = zeros(1,70000);
                SignalPoint2 = length(sigtmp2);
                
                signal1 = 10000 * sigtmp1/signal1_baseline;
                signal2 = 10000 * sigtmp2/signal1_baseline;
                
                %filter
                windowSize = 100;%10
                b = (1/windowSize)*ones(1,windowSize);
                a = 1;
                signal1 = filter(b,a,signal1);
                signal2 = filter(b,a,signal2);

                %correlation
                %correlation = corr(signal1', signal2');
                signal1_noneZero = signal1(signal1~=0)';
                signal2_noneZero = signal2(signal2~=0)';
                
                %temp_signal1 = signal1';
                %temp_signal2 = signal2';
                temp_signal1 = signal1_noneZero;
                temp_signal2 = signal2_noneZero;
                %[xcorrelation, lags] = xcorr(signal1', signal2');
                %stem(lags,c)
                temp_length = min(length(temp_signal1), ...
                    length(temp_signal2));
                if temp_length > 0
                    xcorrelation = xcorr(temp_signal1(1:temp_length)',...
                        temp_signal2(1:temp_length)', 'normalized');
                    %correlation = max(xcorrelation);
                    correlation = max(abs(xcorrelation));
%                     correlation = corr(temp_signal1(1:temp_length)',...
%                         temp_signal2(1:temp_length)');
                    if abs(correlation) > correlation_threshold
                        tempT = time;
                        A = initA + CoopA;
                        upFlag = 1;
                        fprintf("correlation = %.2f\n", correlation);
                    end
                end

                
%                 if parity == 1
%                     %[sigtmp11,SignalPoint11] = ReadSignal(obj1);
%                     sigtmp11 = m1.Data;
%                     SignalPoint11 = length(sigtmp11);
%                     parity = 2;
%                 elseif parity == 2
%                     %[sigtmp21,SignalPoint21] = ReadSignal(obj2);
%                     sigtmp21 = m2.Data;
%                     SignalPoint21 = length(sigtmp21);                    
%                     parity = 1;
%                     parity2_done = 1;                    
%                 end
%                             
% %                         if parity2 == 1
% %                             if parity == 1
% %                                 [sigtmp11,SignalPoint11] = ReadSignal(obj1);
% %                                 parity = 2;
% %                             elseif parity == 2
% %                                 [sigtmp21,SignalPoint21] = ReadSignal(obj2);
% %                                 parity = 3;
% %                             elseif parity == 3
% %                                 [sigtmp12,SignalPoint12] = ReadSignal(obj1);
% %                                 parity = 4;
% %                             elseif parity == 4
% %                                 [sigtmp22,SignalPoint22] = ReadSignal(obj2);
% %                                 parity = 1;
% %                                 parity2 = 2;
% %                                 parity2_done = 1;
% %                             end
% %                         elseif parity2 == 2
% %                             if parity == 1
% %                                 [sigtmp21,SignalPoint21] = ReadSignal(obj2);
% %                                 parity = 2;
% %                             elseif parity == 2
% %                                 [sigtmp11,SignalPoint11] = ReadSignal(obj1);
% %                                 parity = 3;
% %                             elseif parity == 3
% %                                 [sigtmp22,SignalPoint22] = ReadSignal(obj2);
% %                                 parity = 4;
% %                             elseif parity == 4
% %                                 [sigtmp12,SignalPoint12] = ReadSignal(obj1);
% %                                 parity = 1;
% %                                 parity2 = 1;
% %                                 parity2_done = 1;
% %                             end
% %                         end
%                         if parity2_done == 1
% %                             signal1_length = min(SignalPoint11,...
% %                                 SignalPoint12);
% %                             signal2_length = min(SignalPoint21,...
% %                                 SignalPoint22);                            
% %                             signal1_length = min(length(SignalPoint11),...
% %                                 length(SignalPoint12));
% %                             signal2_length = min(length(SignalPoint21),...
% %                                 length(SignalPoint22));
% 
%                             signal1_length = SignalPoint11;
%                             signal2_length = SignalPoint21;
%                             signal_length = min(signal1_length, signal2_length);
%                             
%                             signal1 = 10000 * [sigtmp11(end-signal_length+1:end)];
%                             signal2 = 10000 * [sigtmp21(end-signal_length+1:end)];                            
% %                             signal1 = 10000 * [sigtmp11(end-signal_length+1:end)...
% %                                 sigtmp12(end-signal_length+1:end)];
% %                             signal2 = 10000 * [sigtmp21(end-signal_length+1:end)...
% %                                 sigtmp22(end-signal_length+1:end)];
%                             
% %                             signal1 = 10000 * [sigtmp11(1:signal_length)...
% %                                 sigtmp12(1:signal_length)];
% %                             signal2 = 10000 * [sigtmp21(1:signal_length)...
% %                                 sigtmp22(1:signal_length)];                            
%                             
%                             %filter
%                             windowSize = 10;%10
%                             b = (1/windowSize)*ones(1,windowSize);
%                             a = 1;
%                             signal1 = filter(b,a,signal1);
%                             signal2 = filter(b,a,signal2);
%                             
% 
%                 
%                             correlation = corr(signal1', signal2');
%                 %             correlation = corr(signal1(end-999:end)', signal2(end-999:end)');
% %                             if abs(correlation) > correlation_threshold && ...
% %                                     abs(mean(signal1)) > 0.2 && ...
% %                                     abs(mean(signal2)) > 0.2
%                             if abs(correlation) > correlation_threshold
%                                 tempT = time;
%                                 A = initA + CoopA;
%                                 upFlag = 1;
%                                 fprintf("correlation = %.2f\n", correlation);
%                             end
%                 
%                             parity2_done = 0;
%                         end
                
            end
        end
    end

    
    % Check the keyboard to see if a button has been pressed
    [keyIsDown,secs, keyCode] = KbCheck; %#ok<*ASGLU>
    
    % Depending on the button press, either move ths position of the square
    % or exit the demo
    if keyCode(escapeKey)
        exitDemo = true;
    elseif keyCode(upKey) && lastKeyCode(upKey) == 0
        tempT = time;
        A = initA + CoopA;
        upFlag = 1;
    elseif keyCode(downKey) && lastKeyCode(downKey) == 0
        tempT = time;
        A = initA - CoopA;
        downFlag = 1;
    elseif exist('tempT','var') && time-tempT < TimeWindow
        if upFlag == 1
            A = initA + CoopA;
        elseif downFlag == 1
            A = initA - CoopA;
        end
    elseif exist('tempT','var') && time-tempT >= TimeWindow
        upFlag = 0;
        downFlag = 0;
        A = initA;
    else
        A = initA;
    end
    
    lastKeyCode = keyCode;
    %     % Center the rectangle on the centre of the screen
    %     centeredRect = CenterRectOnPointd(baseRect, XPos, YPos);
    
    %% Position of the car
    if normalization_ok == 1
        XPos = XPos + SpdX*ifi+A*ifi^2/2;
        YPos = YPos + SpdY*ifi-A*ifi^2/2;
        SpdX = SpdX + A*ifi;
        SpdY = SpdY - A*ifi;        
    end
    carRect = CenterRectOnPointd(baseRect, XPos, YPos);
    
    %% Position of cloud
    Vcloud = randi([0,15]);
    cloudXPos = cloudXPos + Vcloud*ifi;
    cloudRect = CenterRectOnPointd(baseRect, cloudXPos, cloudYPos);
        
    
    %% Show the score
    if XPos <= xCenter - s1/2 + 50 || time > GameTime
        Screen('TextSize', win, 70);
        DrawFormattedText(win,double(sprintf('得分：')), 'center', screenYpixels*0.4, ...
            [1 0 0]);
        Screen('TextSize', win, 120);
        DrawFormattedText(win,double( sprintf('%.2f', roundn(time,-2)) ), ...
            'center', 'center', [1 0 0]);
        Screen('Flip',win);
        pahandle_lose = bcrbgm_jjb('loseSound.mp3',1,1);
        flag_ongoing0_lose1_win2 = 1;
        WaitSecs(3);
        exitDemo = true;
    elseif XPos >= xCenter + s1/2 - 200
        Screen('TextSize', win, 100);
        DrawFormattedText(win,double(sprintf('You win!')), 'center', screenYpixels*0.4, ...
            [1 0 0]);
        Screen('Flip',win);
        pahandle_win = bcrbgm_jjb('winSound.mp3',1,1);
        flag_ongoing0_lose1_win2 = 2;

        WaitSecs(3);
        exitDemo = true;
    end
    
    %% Show images
    if exitDemo == false
        Screen('DrawTexture', win,backgroundTexture, [], [], 0);
        Screen('DrawTexture', win,carTexture, [],carRect);
        Screen('DrawTexture', win,cloudTexture, [],cloudRect);
        
        
        text1 = double(sprintf('时间'));
        DrawFormattedText(win,text1, screenXpixels*0.8, winRect(4)/4, [1 0 0]);
        text2 = double(sprintf('\n%.2f', time));
        DrawFormattedText(win,text2, screenXpixels*0.8, winRect(4)/4, [1 0 0]);
    end
    
    vbl  = Screen('Flip', win, vbl + (waitframes - 0.5) * ifi);
    time = time + ifi;
end

% % 停止背景音乐
PsychPortAudio('Stop', pahandle);
if flag_ongoing0_lose1_win2 == 1
    PsychPortAudio('Stop', pahandle_lose);
elseif flag_ongoing0_lose1_win2 == 2
    PsychPortAudio('Stop', pahandle_win);
end
PsychPortAudio('Close');
% WaitSecs(2);

% Clear the screen
sca;


% Wait for one seconds
WaitSecs(2);

% ComboClose(obj1);
% obj1 = 0;
% ComboClose(obj2);
% obj2 = 0;
% close all

end