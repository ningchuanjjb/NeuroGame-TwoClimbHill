if exist('obj1', 'var') == 1 
    if obj1 ~= 0
        ComboClose(obj1);
    end
end
if exist('obj2', 'var') == 1
    if obj2 ~= 0
        ComboClose(obj2);
    end
end
obj1 = 0;
obj2 = 0;

sca;
close all;
clear all; %#ok<CLALL>

fileID1 =  fopen('mSignalState1.dat','w');   
fileID2 =  fopen('mSignalState2.dat','w');   

mSignalState1 = zeros(1,70000);%40000
mSignalState2 = zeros(1,70000);
% mSignalState1 = [];
% mSignalState2 = [];


fwrite(fileID1, mSignalState1, 'double');
fclose(fileID1);
fwrite(fileID2, mSignalState2, 'double');
fclose(fileID2);

m1 = memmapfile('mSignalState1.dat', 'Writable', true, 'Format', 'double');
m2 = memmapfile('mSignalState2.dat', 'Writable', true, 'Format', 'double');

%% 打开串口设备及其相关变量的初始化
if ~isempty(instrfind)
    delete(instrfindall);
end
com = ComboQuery;							%#ok<*NOPTS> % com为字符串数组，包含所有的电生理一体机设备名称
repeatIndex = [];
if length(com(:,1)) > 1
    repeatCount = 0;
    for tempi=1:length(com(:,1))-1
        if ismember(tempi, repeatIndex) == 0
            for tempj=tempi+1:length(com(:,1))
                if sum(com(tempi,:) == com(tempj,:)) == length(com(tempi,:))
                    %com(tempi,:) = [];
                    repeatCount = repeatCount + 1;
                    repeatIndex(repeatCount) = tempj; %#ok<*SAGROW>
                end
            end
        end
    end
end
com(repeatIndex,:) = []

if isempty(com)
    msgbox('没有设备连接，怎么玩啊？');
    return;
elseif length(com(:,1))<2
    msgbox('只有一个设备，我对抗啥啊？');
    return;
end
obj1 = ComboOpen(com(1,:));
obj2 = ComboOpen(com(2,:));

t0 = tic;
t = toc(t0);

exitDemo = false;
signal = cell(1,2);
signal{1} = [];
signal{2} = [];

while exitDemo == false    
    t = toc(t0);
    %if t > 2
    if length(signal{1}) > 20000 %30000
        fprintf('clear signal buffer!\n');
        fprintf('N1 = %d, N2 = %d!\n', ...
            length(signal{1}), length(signal{2}));        
        signal{1} = [];
        signal{2} = [];
        t0 = tic;

    end

    pause(10/1000);
    [sigtmp1,temp1] = ReadSignal(obj1);
    pause(10/1000);
    [sigtmp2,temp2] = ReadSignal(obj2);
    signal{1} = [signal{1} sigtmp1;];
    signal{2} = [signal{2} sigtmp2;];
    m1.Data(1:length(signal{1})) = signal{1};
    m2.Data(1:length(signal{2})) = signal{2};
    
    
end

ComboClose(obj1);
obj1 = 0;
ComboClose(obj2);
obj2 = 0;
close all

