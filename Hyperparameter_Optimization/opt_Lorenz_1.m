
%% config
addpath '..\Functions'

iter_max = 400;
n = 800;
bo = 1;
repeat_num = 10;


% 1~4: eig_rho W_in_a tp_w wp_bias
% 5~7: a beta k
lb = [0 0  0 -3    0 10^-10 1];
ub = [3 3  3  3    1 10^-3 n];
rng('shuffle')
tic
options = optimoptions('surrogateopt','MaxFunctionEvaluations',iter_max,'PlotFcn','surrogateoptplot');
filename = ['opt_Lorenz_IM_1_' datestr(now,30) '_' num2str(randi(999)) '.mat'];

func = @(x) (func_train_repeat(x,n,bo,repeat_num));
[opt_result,opt_fval,opt_exitflag,opt_output,opt_trials] = surrogateopt(func,lb,ub,options);
toc

save(filename)
if ~ispc
    exit;
end

function mean_rmse = func_train_repeat(hyperpara_set,n,bo,repeat_num)
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