
%% config
addpath '..\Functions'
dim = 1;


% Hyperparameters of the reservoir
n = 400;
k = 210;
eig_rho = 1.47;
W_in_a = 2.13;
tp_W = 0.54; %k_p 1.15
tp_bias = -0.30;
a = 0.86;
beta = 1 * 10^(-6);


reservoir_tstep = 1;
ratio_tstep = 1;
% reservoir_tstep/ratio_tstep = length of time step for RK4

train_r_step_cut = round( 10 / reservoir_tstep );  % drop the transient in data
train_r_step_length = round( 1000 /reservoir_tstep );
validate_r_step_length = round( 15 /reservoir_tstep );


bo = 5; % best of


para_train_set = [3.8 3.85 3.9 3.95];
tp_train_set = para_train_set;



tmax_timeseries_train = (train_r_step_cut + train_r_step_length + validate_r_step_length + 20) * reservoir_tstep; % time, for timeseries
rng('shuffle');
tic;
%% main
rmse_min = 10000;
for bo_i = 1:bo
    %% preparing training data
    fprintf('preparing training data...\n');
    
    train_data_length = train_r_step_length + validate_r_step_length + 10;
    train_data = zeros(length(tp_train_set), train_data_length,dim+1); % data that goes into reservior_training
    for tp_i = 1:length(tp_train_set)
        tp = tp_train_set(tp_i);
        logi_a = para_train_set(tp_i);  %% system sensitive

        
        ts_train = zeros(tmax_timeseries_train,1);
        ts_train(1) = rand;
        for t_i = 2:tmax_timeseries_train
            ts_train(t_i) = logi_a * ts_train(t_i-1) * (1-ts_train(t_i-1));
        end
        ts_train = ts_train(1:ratio_tstep:end,:);
        ts_train = ts_train(train_r_step_cut+1:end,:); % cut
        t = 1:train_data_length;
        
        train_data(tp_i,:,1:dim) = ts_train(1:train_data_length,:);        
        train_data(tp_i,:,dim+1) = tp_W * (tp + tp_bias) * ones(train_data_length,1);    %% system sensitive        
    end
    
    %% train
    fprintf('training...\n');
    flag_r_train = [n k eig_rho W_in_a a beta train_r_step_cut train_r_step_length validate_r_step_length...
        reservoir_tstep dim];
    [rmse,W_in_temp,res_net_temp,P_temp,t_validate_temp,x_real_temp,x_validate_temp] = ...
        func_STP_train(train_data,tp_train_set,flag_r_train,1,1,1);
    fprintf('attempt rmse = %f\n',rmse)
    
    if rmse < rmse_min
        W_in = W_in_temp;
        res_net = res_net_temp;
        P = P_temp;
        t_validate = t_validate_temp;
        x_real = x_real_temp;
        x_validate = x_validate_temp;        
        rmse_min = rmse;
    end
    
    fprintf('%f is done\n',bo_i/bo)
    toc;
end

fprintf('best rmse = %f\n',rmse_min)

%% plot
plot_dim = 1; % change the ylabel
for tp_i = 1:length(tp_train_set)
    figure('Name','Reservoir Predict');
    subplot(2,1,1)
    hold on
    plot(t_validate,x_real(tp_i,:,plot_dim));
    plot(t_validate,x_validate(tp_i,:,plot_dim),'--');
    xlabel('time');
    ylabel('x');
    title(['tp = ' num2str( para_train_set(tp_i),6 )]);
    set(gcf,'color','white')
    hold off
    subplot(2,1,2)
    hold on
    plot(t_validate,abs(x_validate(tp_i,:,plot_dim)-x_real(tp_i,:,plot_dim))/...
        ( max(x_real(tp_i,:,plot_dim)) - min(x_real(tp_i,:,plot_dim)) ) )
    line([t_validate(1) t_validate(end)],[0.05 0.05])
    xlabel('time');
    ylabel('relative error');
    hold off
end



%
% plotting training data
figure('Name','Training Data','Position',[50 50 480 390]);
hold on
for tp_i = 1:length(tp_train_set)
    
    
    plot(train_data(tp_i,:,1));
    xlabel('step');
    ylabel('x');
    title(['training data at' newline 'tp = ' num2str( para_train_set(tp_i),8 )]);
    set(gcf,'color','white')
    
end
hold off

%