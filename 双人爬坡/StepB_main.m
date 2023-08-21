function coresult = StepB_main(varargin)
Screen('Preference','SkipSyncTests', 1);
% % 版本：20210714
% % 用途：脑电协同赛车游戏
% % 资源：functions - 程序运行必备函数
% %       images     - 图库
% %       music     - 背景音乐


% % 定义环境 
HideCursor;
addpath(genpath(fileparts(mfilename('fullpath'))));

% % % 定义参数
% param = finputcheck(varargin, { ...
%     'mode' , 'string' , {'demo','play'}, 'demo'; ...
%     'window' , 'string' , {'window','full'}, 'window'; ...
%     });


param.mode= 'demo';
param.window='window';

% % 打开游戏窗口
if strcmpi(param.mode,'demo')
    flag_exit = bcrDemo(param);
else
    [flag_exit, coresult] = bcrPlay(param);
end

% % 退出游戏
if flag_exit == 1
    
%     % % 停止背景音乐
%     PsychPortAudio('Stop', pahandle);
%     PsychPortAudio('Close');
%     WaitSecs(2);
    % % 关闭显示窗口
    sca;
    ShowCursor;
    
end


end
