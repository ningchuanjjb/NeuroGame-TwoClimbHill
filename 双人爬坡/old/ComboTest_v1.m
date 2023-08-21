%ComboQuery
%ComboOpen
%ComboClose

%ComboGetData
%ComboGetLength


%�򿪴����豸������ر����ĳ�ʼ��
if ~isempty(instrfind)
    delete(instrfindall);
end
com = ComboQuery							%#ok<*NOPTS> % comΪ�ַ������飬�������еĵ�����һ����豸����
if isempty(com)
    msgbox('û���豸���ӣ���ô�氡��');
    return;
elseif length(com(:,1))<2
    msgbox('ֻ��һ���豸���ҶԿ�ɶ����');
    return;
end
obj1 = ComboOpen(com(1,:));
obj2 = ComboOpen(com(2,:));

Fs = 30000; %sample frequency is 30kHz;
GameTime = 10;
readInterval = 20; % set frequency of read signal from Combo each readInterval ms
readCount = 0;
SignalPoint1 = zeros(round(GameTime*1000/readInterval),1);
SignalPoint2 = zeros(round(GameTime*1000/readInterval),1);
parity = 0;

t0 = tic;
t = toc(t0);
while t< GameTime    
    t = toc(t0);
    if floor(t*1000/readInterval)>readCount % read data from Combo each readInterval time
        readCount = floor(t*1000/readInterval) +1;
        %read data from Combo 
        if parity == 0
            [sigtmp1,SignalPoint1(readCount)] = ReadSignal(obj1);
            parity = 1;
        elseif parity == 1
            [sigtmp2,SignalPoint2(readCount)] = ReadSignal(obj2);
            signal1 = 10000 * sigtmp1;
            signal2 = 10000 * sigtmp2;
            a=corr(signal1(end-100:end)', signal2(end-100:end)');
            fprintf("correlation = %.2f\n", a);
%             if abs(mean(signal1)) > 1
%                 fprintf("signal1 = %.4f\n", mean(signal1));
%             end
%             if abs(mean(signal2)) > 1
%                 fprintf("signal2 = %.4f\n", mean(signal2));
%             end
            parity = 0;
        end
      
    end    
end


ComboClose(obj1);
obj1 = 0;
ComboClose(obj2);
obj2 = 0;
close all

