function [ data, Npoint] = ReadSignal( h )
%READSIGNAL  Read signal from Combo AmDIOifier
%   Input, obj, the COM port connected to Combo AmDIOifier
%   Output, data，  signal
%           Npoint, number of signal point
% Citing from YQ Wen, Modified by Zhiwei Wang
% 2015/06/27

    len = ComboGetLength(h);				% 取得一体机内已经采集的数据长度
	[data Adc1 DIO] = ComboGetData(h, len);	% 根据已有数据长度，读出数据
	% 检查并修正传输错误
	if data(end-4:end) == [-1437269761, 1, 1702194242, 7957363, 112]
		EAl = data;			% 记录错误数据
		data = data(1:end-5);
		Adc1 = Adc1(:, 1:end-5);
		DIO = DIO(1:end-5);
		%fprintf('\n恢复一次传输错误\n');
	end    
    data = double(data).*9.9341e-09;
    Npoint = length(data);
end

