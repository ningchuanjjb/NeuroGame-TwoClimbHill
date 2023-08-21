function pahandle = bcrbgm_jjb(file_name,repetitions,masterVolume)
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
bgmfile = file_name;

[bgmload,bgmfreq] = audioread(bgmfile);
channels = size(bgmload,2);

if size(bgmload,1) > channels
    bgmload = bgmload';
end

% % ����Ƶ�豸
pahandle = PsychPortAudio('Open', deviceID, [], 1, bgmfreq, channels, buffersize);
PsychPortAudio('FillBuffer', pahandle, bgmload); % loads data into buffer

PsychPortAudio('Volume', pahandle ,masterVolume);

% % ���ű�������
PsychPortAudio('Start', pahandle, repetitions, 0, 1); % starts sound immediatley

end
