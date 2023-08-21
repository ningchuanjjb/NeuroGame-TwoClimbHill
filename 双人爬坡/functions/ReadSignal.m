function [ data, Npoint] = ReadSignal( h )
%READSIGNAL  Read signal from Combo Amplifier
%   Input, obj, the COM port connected to Combo Amplifier
%   Output, data��  signal
%           Npoint, number of signal point
% Citing from YQ Wen, Modified by Zhiwei Wang
% Modified by Bluesky
% 2021/07/18

    len = ComboGetLength(h);				% ȡ��һ������Ѿ��ɼ������ݳ���
	[data Adc1 DIO] = ComboGetData(h, len);	% �����������ݳ��ȣ���������
	% ��鲢�����������
	if len >= 20
		if data(end-4:end) == [-1437269761, 1, 1702194242, 7957363, 112]
			Edata = data;			% ��¼��������
			data = data(1:end-5);
			Adc1 = Adc1(:, 1:end-5);
			DIO = DIO(1:end-5);
			fprintf('\n���һ�ζ����ݴ���\n')
		end
	end

    data = double(data).*9.9341e-09;
    Npoint = length(data);
end

