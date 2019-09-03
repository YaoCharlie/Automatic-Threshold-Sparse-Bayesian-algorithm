% SPARSEBAYESDEMO  Simple demonstration of the SPARSEBAYES algorithm
%
%	SPARSEBAYESDEMO(LIKELIHOOD, DIMENSION, NOISETOSIGNAL)
%
% OUTPUT ARGUMENTS: None
% 
% INPUT ARGUMENTS:
% 
%	LIKELIHOOD		Text string, one of 'Gaussian' or 'Bernoulli'
%	DIMENSION		Integer, 1 or 2
%	NOISETOSIGNAL	An optional positive number to specify the
%					noise-to-signal (standard deviation) fraction.
%					(Optional: default value is 0.2).
% 
% EXAMPLES:
% 
%	SPARSEBAYESDEMO("Bernoulli",2)
%	SPARSEBAYESDEMO("Gaussian",1,0.5)
%
% NOTES: 
% 
% This program offers a simple demonstration of how to use the
% SPARSEBAYES (V2) Matlab software.
% 
% Synthetic data is generated from an underlying linear model based
% on a set of "Gaussian" basis functions, with the generator being
% "sparse" such that 10% of potential weights are non-zero. Data may be
% generated in an input space of one or two dimensions.
% 
% This generator is then used either as the basis for real-valued data with
% additive Gaussian noise (whose level may be varied), or for binary
% class-labelled data based on probabilities given by a sigmoid link
% function.
% 
% The SPARSEBAYES algorithm is then run on the data, and results and
% diagnostic information are graphed.
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
function SparseBayesDemo

% Fix the random seed for reproducibility of results
% 
rseed	= 1;
rand('state',rseed);
randn('state',rseed);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% --- VALIDATE INPUT ARGUMENTS ---
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% (1) likelihood
% 
LIKELIHOOD	= SB2_Likelihoods('Gauss');
%
% Set up default for "noiseToSignal" variable.
% For ease of use, we'll just ignore it in the case of a non-Gaussian
% likelihood model.
noiseToSignal	= 0.2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% --- SET UP DEMO PARAMETERS ---
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Experiment with these values to vary the demo if you wish
%
N	= 100;	% Number of points
%
basisWidth	= 0.05;		% NB: data is in [0,1]
%
% Define probability of a basis function NOT being used by the generative
% model. i.e. if pSparse=0.90, only 10% of basis functions (on average) will
% be used to synthesise the data.
% 
pSparse		= 0.90;
iterations	= 500;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% --- SYNTHETIC DATA GENERATION ---
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% First define the input data over a regular grid
% 
  X	= [0:N-1]'/N;
%
% Now define the basis 
% 
% Locate basis functions at data points
% 
C	= X;
%
% Compute ("Gaussian") basis (design) matrix
% 
BASIS	= exp(-distSquared(X,C)/(basisWidth^2));%??
%
%
% Randomise some weights, then make each weight sparse with probability
% pSparse ?????????????????????pSparse?0.9?
% 
M			= size(BASIS,2);%??
w			= randn(M,1)*100 / (M*(1-pSparse));
sparse		= rand(M,1)<pSparse;
w(sparse)	= 0;
%
% Now we have the basis and weights, compute linear model
% 
z			= BASIS*w;
%
% Finally generate the data according to the likelihood model
% 
switch (LIKELIHOOD.InUse)
 case LIKELIHOOD.Gaussian,
  % Generate our data by adding some noise on to the generative function
  noise		= std(z) * noiseToSignal;
  Outputs	= z + noise*randn(N,1);
  %
 case LIKELIHOOD.Bernoulli,
  % Generate random [0,1] labels given by the log-odds 'z'
  Outputs	= double(rand(N,1)<SB2_Sigmoid(z));
end
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% --- SPARSE BAYES INFERENCE SECTION ---
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% The section of code below is the main section required to run the
% SPARSEBAYES algorithm.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Set up the options:
% 
% - we set the diagnostics level to 2 (reasonable)
% - we will monitor the progress every 10 iterations
% 
OPTIONS		= SB2_UserOptions('iterations',iterations,...
							  'diagnosticLevel', 2,...
							  'monitor', 10);
%
% Set initial parameter values:
% 
% - this specification of the initial noise standard deviation is not
% necessary, but included here for illustration. If omitted, SPARSEBAYES
% will call SB2_PARAMETERSETTINGS itself to obtain an appropriate default
% for the noise (and other SETTINGS fields).
% 
SETTINGS	= SB2_ParameterSettings('NoiseStd',0.1);
%
% Now run the main SPARSEBAYES function

%read the data file, 'BASIS' is the read path of basic candidate data.
%'Outputs' is the read path of observed data
p1='EN';p2='EO';
BASISREAD=strcat('A2:',p1,'132');
outread=strcat(p2,'2:',p2,'132');
BASIS=xlsread('D:\Project\sparsebayes\cross-validation\04-14.xlsx',BASISREAD);
Outputs=xlsread('D:\Project\sparsebayes\cross-validation\04-14.xlsx',outread);


[PARAMETER, HYPERPARAMETER, DIAGNOSTIC] = ...
    SparseBayes('Gauss', BASIS, Outputs, OPTIONS, SETTINGS)

new_basis=BASIS;
compare_new_MU=[1:M];
time_run=0;
UPDATE_vary_relevant=PARAMETER.Relevant;
while any(compare_new_MU)
    range=size(new_basis,2);
    A=[1:range];
    A(:,PARAMETER.Relevant')=[];
    new_basis(:,A)=[];
    current_size_MU=size(PARAMETER.Relevant,1);
    
    if length(PARAMETER.Value)>1
        threshold=min(PARAMETER.Value);
    end
    for check_toosmall=1:current_size_MU
        if PARAMETER.Value(check_toosmall)<=threshold
            PARAMETER.Value(check_toosmall)=0;
        end
    end

    compare_old_MU=zeros(M,1);
    for fill_MU=1:M
        for check_MU_position=1:current_size_MU
            if fill_MU==UPDATE_vary_relevant(check_MU_position)
                compare_old_MU(fill_MU)=PARAMETER.Value(check_MU_position);
            end
        end
    end
    
    which_MU_delete=find(PARAMETER.Value==0);%找向量中0的位置，并赋值
    UPDATE_vary_relevant(which_MU_delete,:)=[];%删除w=0的位置的行
    [vary_relevant,vary_index]=sort(UPDATE_vary_relevant);%加索引记住relevant的初始位置
    length_vary_relevant=size(vary_relevant,1);%记住长度
    new_basis(:,which_MU_delete)=[];%把小于阈值的0也删除，创造新的候选项
    [PARAMETER, HYPERPARAMETER, DIAGNOSTIC] = ...
        SparseBayes('Gauss', new_basis, Outputs, OPTIONS, SETTINGS)
    UPDATE_vary_relevant_before=[1:length_vary_relevant];
    UPDATE_vary_relevant_before(:,PARAMETER.Relevant)=[];%找到没有权重的项
    UPDATE_vary_relevant=vary_relevant;%迭代前的relevant
    UPDATE_vary_relevant(UPDATE_vary_relevant_before,:)=[];%找到有权重的项在原始矩阵中的位置
    compare_new_MU=zeros(M,1);%创造长度为M且值均为0的列向量
    current_size_MU=size(PARAMETER.Relevant,1);%计算新迭代的有几个w
    for fill_MU=1:M
        for check_MU_position=1:current_size_MU
            if fill_MU==UPDATE_vary_relevant(check_MU_position)
                compare_new_MU(fill_MU)=PARAMETER.Value(check_MU_position);
            end
        end
    end
    time_run=time_run+1;
    if isequal(compare_old_MU,compare_new_MU)
        break;
    end
end

index=UPDATE_vary_relevant;
fprintf('The selected equation is: %d',index);







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Support function to compute basis
%
function D2 = distSquared(X,Y)
%
nx	= size(X,1);
ny	= size(Y,1);
%
D2 = (sum((X.^2), 2) * ones(1,ny)) + (ones(nx, 1) * sum((Y.^2),2)') - ...
     2*X*Y';

 
