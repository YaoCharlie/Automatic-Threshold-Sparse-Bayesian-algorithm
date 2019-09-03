% SB2_PARAMETERSETTINGS  User parameter initialisation for SPARSEBAYES
% SPARSEBAYES的用户参数初始化
% SETTINGS = SB2_PARAMETERSETTINGS(parameter1, value1, parameter2, value2,...)
%
% OUTPUT ARGUMENTS:
% 
%	SETTINGS	An initialisation structure to pass to SPARSEBAYES设置传递给SPARSEBAYES的初始化结构
% 
% INPUT ARGUMENTS:
% 
%	Optional number of parameter-value pairs to specify	some, all, or
%	none of the following:可选的参数-值对数目，以指定以下部分、全部或全部:
% 
%	BETA		(Gaussian) noise precision (inverse variance)噪音精度 倒转的差额
%	NOISESTD	(Gaussian) noise standard deviation噪声标准差
%	RELEVANT	Indices of columns of basis matrix to use at start-up启动时基矩阵列的索引
%	WEIGHTS		Corresponding vector of weights to RELEVANT 权值对应的向量
%	ALPHA		Corresponding vector of hyperparameter values to RELEVANT对应的向量的超参数值相关
%
% EXAMPLE:
%
%	SETTINGS = SB2_ParameterSettings('NoiseStd',0.1);
% 
% NOTES:
%
% 1.	If no input arguments are supplied, defaults (effectively an
%		empty structure) will be returned.
%
% 2.	If both BETA and NOISESTD are specified, BETA will take
%		precedence.
%
% 3.	RELEVANT may be specified without WEIGHTS or ALPHA (these will be
%		sensibly initialised later).	
% 
% 4.	If RELEVANT is specified, WEIGHTS may be specified also without ALPHA.
%

%
% Copyright 2009, Vector Anomaly Ltd
%
% This file is part of the SPARSEBAYES library for Matlab (V2.0).
%
% SPARSEBAYES is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the Free
% Software Foundation; either version 2 of the License, or (at your option)
% any later version.
%
% SPARSEBAYES is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
% more details.
%
% You should have received a copy of the GNU General Public License along
% with SPARSEBAYES in the accompanying file "licence.txt"; if not, write to
% the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston,
% MA 02110-1301 USA
%
% Contact the author: m a i l [at] m i k e t i p p i n g . c o m
%
function SETTINGS = SB2_ParameterSettings(varargin)

% Ensure arguments are supplied in pairs
% 
if rem(nargin,2)
  error('Arguments to SB2_ParameterSettings should be (property, value) pairs')
end
% Any settings specified?
numSettings	= nargin/2;

%% Defaults - over-ridden later if requested
% 默认值——稍后如果需要，将被覆盖
% Two options for setting noise level (purely for convenience)  设置噪音声级的两个选项(纯粹为了方便)
% - if 'beta' set, 'noiseStdDev' will be over-ridden  如果'beta'设置，'noiseStdDev'将被覆盖
% 
SETTINGS.beta			= [];
SETTINGS.noiseStdDev	= [];
%
SETTINGS.Relevant	= [];
SETTINGS.Mu			= [];
SETTINGS.Alpha		= [];

%% Requested overrides
% 要求覆盖
% Parse string/variable pairs 解析字符串/变量对
for n=1:numSettings
  property_	= varargin{(n-1)*2+1};
  value		= varargin{(n-1)*2+2};
  switch upper(property_)
   case 'BETA',
    SETTINGS.beta			= value;
   case 'NOISESTD',
    SETTINGS.noiseStdDev	= value;
   case 'ALPHA',
    SETTINGS.Alpha			= value;
   case 'WEIGHTS',
    SETTINGS.Mu				= value;
   case 'RELEVANT',
    SETTINGS.Relevant		= value;
   otherwise,
    error('Unrecognised initialisation property: ''%s''\n', property_)
  end
end
