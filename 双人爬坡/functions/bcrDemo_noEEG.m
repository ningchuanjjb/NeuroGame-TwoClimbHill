function flag_exit = bcrDemo(param)

% % last edit, 20210714
% % demo for BrainCooperate game


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
initA = -screenYpixels/12^2; % initial acceleration
% CoopA = screenYpixels/2^2; % acceleration when clicking 'UP'
CoopA = screenYpixels/2^2; % acceleration when clicking 'UP'
TimeWindow = 0.02; % s
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

% Loop the animation until the escape key is pressed
while exitDemo == false
    
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
    XPos = XPos + SpdX*ifi+A*ifi^2/2;
    YPos = YPos + SpdY*ifi-A*ifi^2/2;
    SpdX = SpdX + A*ifi;
    SpdY = SpdY - A*ifi;
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
        WaitSecs(3);
        exitDemo = true;
    elseif XPos >= xCenter + s1/2 - 200
        Screen('TextSize', win, 100);
        DrawFormattedText(win,double(sprintf('You win!')), 'center', screenYpixels*0.4, ...
            [1 0 0]);
        Screen('Flip',win);
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

% % % 停止背景音乐
% PsychPortAudio('Stop', pahandle);
% PsychPortAudio('Close');
% % WaitSecs(2);

% Clear the screen
sca;


% Wait for one seconds
WaitSecs(2);


end