function [ data, Npoint] = ReadSignal( h )
%READSIGNAL  Read signal from Combo Amplifier
%   Input, obj, the COM port connected to Combo Amplifier
%   Output, data，  signal
%           Npoint, number of signal point
% Citing from YQ Wen, Modified by Zhiwei Wang
% Modified by Bluesky
% 2021/07/18

    len = ComboGetLength(h);				% 取得一体机内已经采集的数据长度
	[data Adc1 DIO] = ComboGetData(h, len);	% 根据已有数据长度，读出数据
	% 检查并修正传输错误
	if len >= 20
		if data(end-4:end) == [-1437269761, 1, 1702194242, 7957363, 112]
			Edata = data;			% 记录错误数据
			data = data(1:end-5);
			Adc1 = Adc1(:, 1:end-5);
			DIO = DIO(1:end-5);
			fprintf('\n清除一次读数据错误。\n')
		end
	end

    data = double(data).*9.9341e-09;
    Npoint = length(data);
end

