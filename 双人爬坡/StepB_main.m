function coresult = StepB_main(varargin)
Screen('Preference','SkipSyncTests', 1);
% % �汾��20210714
% % ��;���Ե�Эͬ������Ϸ
% % ��Դ��functions - �������бر�����
% %       images     - ͼ��
% %       music     - ��������


% % ���廷�� 
HideCursor;
addpath(genpath(fileparts(mfilename('fullpath'))));

% % % �������
% param = finputcheck(varargin, { ...
%     'mode' , 'string' , {'demo','play'}, 'demo'; ...
%     'window' , 'string' , {'window','full'}, 'window'; ...
%     });


param.mode= 'demo';
param.window='window';

% % ����Ϸ����
if strcmpi(param.mode,'demo')
    flag_exit = bcrDemo(param);
else
    [flag_exit, coresult] = bcrPlay(param);
end

% % �˳���Ϸ
if flag_exit == 1
    
%     % % ֹͣ��������
%     PsychPortAudio('Stop', pahandle);
%     PsychPortAudio('Close');
%     WaitSecs(2);
    % % �ر���ʾ����
    sca;
    ShowCursor;
    
end


end
