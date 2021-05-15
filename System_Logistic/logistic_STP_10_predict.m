
%% config
addpath '..\Functions'

warmup_r_step_cut = round( 10 /reservoir_tstep );  % drop the transient
warmup_r_step_length = ( 30 / reservoir_tstep );

predict_r_step_cut = round( 0 /reservoir_tstep );
predict_r_step_length = round( 300 / reservoir_tstep );


% 4
logi_a = 4.01; % bifurcation parameter
tp = logi_a;
logi_a_warmup = max(para_train_set);


tmax_timeseries_predict = (warmup_r_step_cut + warmup_r_step_length + 5 ) * reservoir_tstep;

rng('shuffle');
tic;

%% prepare warming up data
fprintf('predicting...\n');
ts_warmup = zeros(tmax_timeseries_predict,1);
ts_warmup(1) = rand;
for t_i = 2:tmax_timeseries_predict
    ts_warmup(t_i) = logi_a_warmup * ts_warmup(t_i-1) * (1-ts_warmup(t_i-1));
end
ts_warmup = ts_warmup(1:ratio_tstep:end,:);
ts_warmup = ts_warmup( warmup_r_step_cut+1 : warmup_r_step_cut+warmup_r_step_length, :);

%% predict
fprintf('predicting...\n');
flag_r = [n dim a warmup_r_step_length predict_r_step_cut predict_r_step_length];
predict_r = func_STP_predict(ts_warmup,tp_W * ( tp + tp_bias) ,W_in,res_net,P,flag_r);
toc;

%% plot
label_font_size = 12;
ticks_font_size = 12;

figure()
plot( reservoir_tstep * (0:1:length(predict_r)-1) ,predict_r(:,1))
title(['rho =' num2str(logi_a,8)])
xlabel('t','FontSize',label_font_size)
ylabel('x','FontSize',label_font_size)
set(gca,'FontSize',ticks_font_size)
set(gcf,'color','white')

