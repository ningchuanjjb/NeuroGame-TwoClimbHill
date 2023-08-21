function [win, winRect] = bcrwindow(param)
Screen('Preference','SkipSyncTests', 1);

% % �汾��20210602
% % ��;������ʾ����
% % ��Ȩ��Peng Gui, pgui@ion.ac.cn
% % �ο���http://peterscarfe.com/ptbtutorials.html

Screen('Preference', 'VisualDebuglevel', 3);% disable the startup screen, replace it by a black display until calibration is finished

% % �򿪳��򴰿�
clear screen;
PsychDefaultSetup(2);
screenNumber = max(Screen('Screens')); % external screen if possible
Screen('Preference', 'SkipSyncTests', 1); % 1 = skip
bgcolor = BlackIndex(screenNumber);
% bgcolor = WhiteIndex(screenNumber);
if strcmpi(param.window,'full')
    [win, winRect] = PsychImaging('OpenWindow', screenNumber, bgcolor);
    HideCursor;
    commandwindow;
else
    [win, winRect] = PsychImaging('OpenWindow', screenNumber, bgcolor);
    HideCursor;
%     [win, winRect] = PsychImaging('OpenWindow', screenNumber, bgcolor, [20 50 1400 1000]);
end
Priority(MaxPriority(win)); % Maximum priority level
Screen('BlendFunction', win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); % Set up alpha-blending for smooth (anti-aliased) lines



% ���ƻ�ӭ�����ʱ
Screen('TextFont', win, '-:lang=zh-cn');
time_cd = 3;
% nominalFrameRate = Screen('NominalFrameRate', win);
for cdi = 1:time_cd
    Screen('TextSize', win, 70);
%     DrawFormattedText(win, '׼���ÿ�ʼ����', 'center', winRect(4)/4, [1 0 0]);
    text1 = double(sprintf('׼���ÿ�ʼ����\n \n����60s������ɽ��'));
    DrawFormattedText(win, text1, 'center', winRect(4)/4, [1 0 0]);
    Screen('TextSize', win, 120);
    DrawFormattedText(win, num2str(time_cd-cdi+1), 'center', 'center', [1 0 0]);
    Screen('Flip', win);
    WaitSecs(1);
end

% % ���Ʊ�������


% % ����С��


end
