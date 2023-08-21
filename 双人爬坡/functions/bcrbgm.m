function pahandle = bcrbgm
Screen('Preference','SkipSyncTests', 1);

% % �汾��20210602
% % ��;��ѭ�����ű�������
% % ��Ȩ��Peng Gui, pgui@ion.ac.cn
% % �ο���http://peterscarfe.com/ptbtutorials.html


% % ��ʼ��
% PsychPortAudio('Close'); % close the audio device
% dv = PsychPortAudio('GetDevices');
deviceID = 2;
InitializePsychSound(1);
% channels = 2;
buffersize = 0;

% % ������Դ
% bgmfile = '03_Fantasy_Forest.ogg';
bgmfile = 'doubleBGM.ogg';

[bgmload,bgmfreq] = audioread(bgmfile);
channels = size(bgmload,2);

if size(bgmload,1) > channels
    bgmload = bgmload';
end

% % ����Ƶ�豸
pahandle = PsychPortAudio('Open', deviceID, [], 1, bgmfreq, channels, buffersize);
PsychPortAudio('FillBuffer', pahandle, bgmload); % loads data into buffer

% % ���ű�������
PsychPortAudio('Start', pahandle, 0, 0, 1); % starts sound immediatley

end
