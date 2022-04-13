% requires 'Optimization Toolbox' and 'Global Optimization Toolbox'

%% config
addpath '..\Functions'

iter_max = 400; % number of optimization iteratoins
n = 800; % size of reservoir network
bo = 1; % best of. onlying pick the best one among bo reservoirs
repeat_num = 10; % repeating time in each iteration to reduce fluctuations
func = @(x) (func_train_repeat(x,n,bo,repeat_num));

% optimizatin config
% 1~4: eig_rho W_in_a tp_w tp_bias
% 5~7: a beta k
lb = [0 0  0 -3    0 10^-10 1]; % lower bounds
ub = [3 3  3  3    1 10^-3 n]; % upper bounds
options = optimoptions('surrogateopt','MaxFunctionEvaluations',iter_max,'PlotFcn','surrogateoptplot');

filename = ['opt_Lorenz_IM_1_' datestr(now,30) '_' num2str(randi(999)) '.mat'];

rng('shuffle')

%% optimization
tic
[opt_result,opt_fval,opt_exitflag,opt_output,opt_trials] = surrogateopt(func,lb,ub,options);
toc

%% save and exit
save(filename)
if ~ispc
    exit;
end

function mean_rmse = func_train_repeat(hyperpara_set,n,bo,repeat_num)
% repeat in each iteration to reduce fluctuations
tic
rmse_set = zeros(repeat_num,1);
parfor repeat_i = 1:repeat_num
    rng(repeat_i*20000 + (now*1000-floor(now*1000))*100000)
    rmse_set(repeat_i) = func_Lorenz_train(hyperpara_set,n,bo);    
end

mean_rmse = mean(rmse_set);
fprintf('\nmean rmse is %f\n',mean_rmse)
toc
end
