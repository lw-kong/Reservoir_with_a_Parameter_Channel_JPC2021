function rmse = func_Lorenz_train(hyperpara_set,n,bo)

dim = 3;

Lorenz_sigma = 10;
Lorenz_beta = 8/3;

% n = 80
k = hyperpara_set(7);
eig_rho = hyperpara_set(1);
W_in_a = hyperpara_set(2);
tp_W = hyperpara_set(3);
tp_bias = hyperpara_set(4);
a = hyperpara_set(5);
beta = hyperpara_set(6);


reservoir_tstep = 0.01;
ratio_tstep = 4;

train_r_step_cut = round( 1000 / reservoir_tstep );
train_r_step_length = round( 400 /reservoir_tstep );
validate_r_step_length = round( 3.5 /reservoir_tstep );

%bo = 2;


para_train_set = [168 170 172 174]; % the one for the main articule

tp_train_set = para_train_set;



tmax_timeseries_train = (train_r_step_cut + train_r_step_length + validate_r_step_length + 20) * reservoir_tstep; % time, for timeseries
rmse_min = 10000;
for bo_i = 1:bo
    %% preparing training data
    train_data_length = train_r_step_length + validate_r_step_length + 10;
    train_data = zeros(length(tp_train_set), train_data_length,dim+1); % data that goes into reservior_training
    for tp_i = 1:length(tp_train_set)
        tp = tp_train_set(tp_i);
        Lorenz_rho = para_train_set(tp_i);  %% system sensitive

        flag_Lorenz = [Lorenz_sigma Lorenz_rho Lorenz_beta];
        ts_train = NaN;
        while isnan(ts_train(end,1))
            x0 = [ 28 * rand - 14; 30 * rand - 15; 20 * rand];
            [t,ts_train] = ode4(@(t,x) eq_Lorenz(t,x,flag_Lorenz),0:reservoir_tstep/ratio_tstep:tmax_timeseries_train,x0);
        end
        t = t(1:ratio_tstep:end);
        ts_train = ts_train(1:ratio_tstep:end,:);
        ts_train = ts_train(train_r_step_cut+1:end,:); % cut
        
        train_data(tp_i,:,1:dim) = ts_train(1:train_data_length,:);        
        train_data(tp_i,:,dim+1) = tp_W * (tp + tp_bias) * ones(train_data_length,1);     
    end
    

    %% train
    flag_r_train = [n k eig_rho W_in_a a beta train_r_step_cut train_r_step_length validate_r_step_length...
        reservoir_tstep dim];
    [rmse,~,~,~,~,~,~] = func_STP_train(train_data,tp_train_set,flag_r_train,1,1,1);
    
    if rmse < rmse_min     
        rmse_min = rmse;
    end

end
