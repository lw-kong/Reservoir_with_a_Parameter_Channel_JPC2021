
%% config
addpath '..\Functions'

warmup_r_step_cut = round( 500 /reservoir_tstep );  % drop the transient in warming up data
warmup_r_step_length = ( 0.1 / reservoir_tstep );

predict_r_step_cut = round( 0 /reservoir_tstep );
predict_r_step_length = round( 250 / reservoir_tstep );


% rho_period_to_intermittency = 166.06
Lorenz_rho = 166.05;  % bifurcation parameter

tp = Lorenz_rho;
Lorenz_rho_warmup = max(Lorenz_rho,min(para_train_set));

tmax_timeseries_predict = (warmup_r_step_cut + warmup_r_step_length + 5 ) * reservoir_tstep;

rng('shuffle');
tic;

%% prepare warming up data
flag_Lorenz = [Lorenz_sigma Lorenz_rho Lorenz_beta];
ts_predict = NaN;
while isnan(ts_predict(end,1))
    x0 = [ 28 * rand - 14; 30 * rand - 15; 20 * rand];
    [t,ts_predict] = ode4(@(t,x) eq_Lorenz(t,x,flag_Lorenz),0:reservoir_tstep/ratio_tstep:tmax_timeseries_predict,x0);
end
t = t(1:ratio_tstep:end);
ts_predict = ts_predict(1:ratio_tstep:end,:);
x_warmup = ts_predict( warmup_r_step_cut+1 : warmup_r_step_cut+warmup_r_step_length, :);

%% predict
fprintf('predicting...\n');
flag_r = [n dim a warmup_r_step_length predict_r_step_cut predict_r_step_length];
predict_r = func_STP_predict(x_warmup,tp_W * ( tp + tp_bias) ,W_in,res_net,P,flag_r);
toc;

%% plot
label_font_size = 12;
ticks_font_size = 12;

figure()
plot( reservoir_tstep * (0:1:length(predict_r)-1) ,predict_r(:,1))
title(['rho =' num2str(Lorenz_rho,8)])
xlabel('t','FontSize',label_font_size)
ylabel('x','FontSize',label_font_size)
set(gca,'FontSize',ticks_font_size)
set(gcf,'color','white')

%
figure()
plot3(predict_r(700:end,1),predict_r(700:end,2),predict_r(700:end,3))
title(['prediction of reservoir' newline 'rho =' num2str(Lorenz_rho,8)])
set(gcf,'color','white')
%
