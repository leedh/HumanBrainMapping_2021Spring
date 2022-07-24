clear;clc;

%% path set up
%spm
addpath(genpath('/media/das/cocoanlab Dropbox/resources/spm12'))
%canlab
addpath(genpath('/home/donghee/Documents/resources/github/canlab'))
rmpath(genpath('/home/donghee/Documents/resources/github/canlab/CanlabCore/CanlabCore/External'))
%cocoanlab
addpath(genpath('/home/donghee/Documents/resources/github/cocoanlab'))

%% behavior data
behav_basedir = '/media/das/HBM_2021spring/behavioral';
raw_dir = fullfile(behav_basedir);
templete = 'sub%02d/*_run%03d_*.mat';

heat_tem = [];
belief_ratings = [];
heat_ratings = [];
cue = [];

for run_i = 2:8
    dat_file = filenames(sprintf(fullfile(raw_dir, templete) ,2, run_i), 'char');
    dat = load(dat_file);
    expm_dat = dat.data.dat;
    %heat levels
    for trial_i = 1:20
        heat_tem = [heat_tem; expm_dat.heat_param(trial_i).intensity];
    end
    %belief ratings
    belief_ratings = [belief_ratings; expm_dat.belief_rating'];

    % heat ratings
    heat_ratings = [heat_ratings; expm_dat.heat_rating'];

    % cue
    cue = [cue; expm_dat.cue_type'];
end

%%
heat_levels = [];
matches = [];
belief_levels = [];
pred_err = [];

for trial_i=1:160-20
    switch heat_tem(trial_i)
        case 44.8
            heat_levels = [heat_levels; 1];
        case 46.2
            heat_levels = [heat_levels; 2];
        case 47
            heat_levels = [heat_levels; 3];
    end
end

for trial_i=1:160-20
    if strcmp(cue(trial_i),"HighCue") && heat_levels(trial_i) == 3
        matches = [matches; 1];
    elseif strcmp(cue(trial_i),"HighCue") && heat_levels(trial_i) == 1
        matches = [matches; 2];
    elseif strcmp(cue(trial_i),"LowCue") && heat_levels(trial_i) == 1
        matches = [matches; 1];
    elseif strcmp(cue(trial_i),"LowCue") && heat_levels(trial_i) == 3
        matches = [matches; 2];
    elseif heat_levels(trial_i) == 2
        matches = [matches; 3];
    end
end

% matches: (1) match (2) unmatch (3)midpain

for trial_i=1:160-20
    if belief_ratings(trial_i) > 0.7
        belief_levels = [belief_levels; 1];
    elseif belief_ratings(trial_i) < 0.3
        belief_levels = [belief_levels; 2];
    else
        belief_levels = [belief_levels; 3];
    end
end

% belief_levels: (1) High belief (2) Low belief (3) Mid belief

for trial_i=1:160-20
    if belief_ratings(trial_i) > 0.7
        belief_levels = [belief_levels; 1];
    elseif belief_ratings(trial_i) < 0.3
        belief_levels = [belief_levels; 2];
    else
        belief_levels = [belief_levels; 3];
    end
end


%%
% low prediction error
hchbhp = heat_ratings(strcmp(cue, "HighCue") & belief_levels == 1 & heat_levels == 3);
lclbhp = heat_ratings(strcmp(cue, "LowCue") & belief_levels == 2 & heat_levels == 3);
lchblp = heat_ratings(strcmp(cue, "LowCue") & belief_levels == 1 & heat_levels == 1);
hclblp = heat_ratings(strcmp(cue, "HighCue") & belief_levels == 2 & heat_levels == 1);

hchbmp = heat_ratings(strcmp(cue, "HighCue") & belief_levels == 1 & heat_levels == 2);
lclbmp = heat_ratings(strcmp(cue, "LowCue") & belief_levels == 2 & heat_levels == 2);
lchbmp = heat_ratings(strcmp(cue, "LowCue") & belief_levels == 1 & heat_levels == 2);
hclbmp = heat_ratings(strcmp(cue, "HighCue") & belief_levels == 2 & heat_levels == 2);

low_pred_err_high_pain = [hchbhp; lclbhp];
low_pred_err_low_pain = [lchblp; hclblp];
low_pred_err_mid_pain = [hchbmp; lclbmp; lchbmp; hclbmp];

low_pred_err_high_pain_hb = hchbhp;
low_pred_err_low_pain_hb = lchblp;
low_pred_err_mid_pain_hb = [hchbmp; lchbmp];

low_pred_err_high_pain_lb = lclbhp;
low_pred_err_low_pain_lb = hclblp;
low_pred_err_mid_pain_lb = [lclbmp; hclbmp];


% high prediction error
hchblp = heat_ratings(strcmp(cue, "HighCue") & belief_levels == 1 & heat_levels == 1);
lclblp = heat_ratings(strcmp(cue, "LowCue") & belief_levels == 2 & heat_levels == 1);
lchbhp = heat_ratings(strcmp(cue, "LowCue") & belief_levels == 1 & heat_levels == 3);
hclbhp = heat_ratings(strcmp(cue, "HighCue") & belief_levels == 2 & heat_levels == 3);

high_pred_err_high_pain = [lchbhp;hclbhp];
high_pred_err_low_pain = [hchblp;lclblp];

high_pred_err_high_pain_hb = lchbhp;
high_pred_err_low_pain_hb = hchblp;

high_pred_err_high_pain_lb = hclbhp;
high_pred_err_low_pain_lb = lclblp;

% middle predition error
hcmbhp = heat_ratings(strcmp(cue, "HighCue") & belief_levels == 3 & heat_levels == 3);
lcmbhp = heat_ratings(strcmp(cue, "LowCue") & belief_levels == 3 & heat_levels == 3);
hcmblp = heat_ratings(strcmp(cue, "HighCue") & belief_levels == 3 & heat_levels == 1);
lcmblp = heat_ratings(strcmp(cue, "LowCue") & belief_levels == 3 & heat_levels == 1);
hcmbmp = heat_ratings(strcmp(cue, "HighCue") & belief_levels == 3 & heat_levels == 2);
lcmbmp = heat_ratings(strcmp(cue, "LowCue") & belief_levels == 3 & heat_levels == 2);

mid_pred_err_high_pain = [hcmbhp; lcmbhp];
mid_pred_err_low_pain = [hcmblp; lcmblp];
mid_pred_err_mid_pain = [hcmbmp; lcmbmp];

%%
basedir = '/media/das/HBM_2021spring/';
datdir = fullfile(basedir, 'result/first_level/cocoan_prep_ica_nonaggr');

subjdir = fullfile(datdir, 'sub-hbm002');

imgs = filenames(fullfile(subjdir ,'sub-*_run*-Heat_level*.nii'));
imgs = imgs(21:end,:);
dat = fmri_data(imgs, which('gray_matter_mask.nii'),'noverbose');

load(which('CANlab_combined_atlas_object_2018.mat'))
thal = select_atlas_subset(atlas_obj, {'Thal'});
nac = select_atlas_subset(atlas_obj, {'NAC'});
amyg = select_atlas_subset(atlas_obj, {'Amygdala'});
amyg1 = select_atlas_subset(atlas_obj, {'Amygdala'});
amyg2 = select_atlas_subset(atlas_obj, {'Amygdala'});

amyg.fullpath = fullfile(pwd, 'amyg.img');
write(amyg)

lim = select_atlas_subset(atlas_obj, {'Cortex_Limbic'}, 'labels_2');
fpA = select_atlas_subset(atlas_obj, {'Cortex_Fronto_ParietalA'}, 'labels_2');

thal = remove_empty(thal);
nac = remove_empty(nac);
amyg = remove_empty(amyg);
lim = remove_empty(lim);
fpA = remove_empty(fpA);

amyg.fullpath = fullfile(pwd, 'amyg2.img');
write(amyg)

dat_thal = apply_mask(dat,thal);
dat_nac = apply_mask(dat,nac);
dat_amyg = apply_mask(dat,amyg);
dat_lim = apply_mask(dat,lim);
dat_fpA = apply_mask(dat, fpA);

dat_amyg.fullpath = fullfile(pwd, 'amyg.img');
write(dat_amyg)
%% plot

% all trials
low_pain = heat_ratings(heat_levels == 1);
mid_pain = [heat_ratings(heat_levels == 2)];
mid_pain_nan = [heat_ratings(heat_levels == 2); nan(32,1)];
high_pain = heat_ratings(heat_levels == 3);
all_pain_rating = [low_pain mid_pain_nan high_pain];

mean_pain_rating = [mean(low_pain) mean(mid_pain) mean(high_pain)];
ste_pain_rating = [ste(low_pain) ste(mid_pain) ste(high_pain)];

plot(mean_pain_rating, '-k.','MarkerSize',25)


% low prediction error
low_pred_error_mean_pain_rating = [mean(low_pred_err_low_pain) mean(low_pred_err_mid_pain) mean(low_pred_err_high_pain)];
plot(low_pred_error_mean_pain_rating, '-r.','MarkerSize',25)

low_pred_error_mean_pain_rating_hb = [mean(low_pred_err_low_pain_hb) mean(low_pred_err_mid_pain_hb) mean(low_pred_err_high_pain_hb)];
low_pred_error_mean_pain_rating_lb = [mean(low_pred_err_low_pain_lb) mean(low_pred_err_mid_pain_lb) mean(low_pred_err_high_pain_lb)];


% high prediction error
high_pred_error_mean_pain_rating = [mean(high_pred_err_low_pain) mean(low_pred_err_mid_pain) mean(high_pred_err_high_pain)];
plot(high_pred_error_mean_pain_rating, '-b.','MarkerSize',25)

high_pred_error_mean_pain_rating_hb = [mean(high_pred_err_low_pain_hb) mean(low_pred_err_mid_pain_hb) mean(high_pred_err_high_pain_hb)];
high_pred_error_mean_pain_rating_lb = [mean(high_pred_err_low_pain_lb) mean(low_pred_err_mid_pain_lb) mean(high_pred_err_high_pain_lb)];

% mid prediction error
mid_pred_error_mean_pain_rating = [mean(mid_pred_err_low_pain) mean(mid_pred_err_mid_pain) mean(mid_pred_err_high_pain)];
plot(mid_pred_error_mean_pain_rating, '-g.','MarkerSize',25)


hold on
%lot(mean_pain_rating, '-k.','MarkerSize',25)
% plot(low_pred_error_mean_pain_rating, '-r.','MarkerSize',25)
% plot(high_pred_error_mean_pain_rating, '-b.','MarkerSize',25)
% plot(mid_pred_error_mean_pain_rating, '-g.','MarkerSize',25)
% xticks([1 2 3])
% yticks([linspace(0,1,11)])
% xticklabels({'Low Pain', 'Medium Pain', 'High Pain'})


% less cognitive load

%plot(mean_pain_rating, '-k.','MarkerSize',25)
plot(low_pred_error_mean_pain_rating_hb, '-r.','MarkerSize',25, 'LineWidth', 2.5)
plot(high_pred_error_mean_pain_rating_hb, '-b.','MarkerSize',25, 'LineWidth', 2.5)
plot(mid_pred_error_mean_pain_rating, '-g.','MarkerSize',25, 'LineWidth', 2.5)
xticks([1 2 3])
yticks([linspace(0,1,11)])
xticklabels({'Low Pain', 'Medium Pain', 'High Pain'})


% more cognitive load

%plot(mean_pain_rating, '-k.','MarkerSize',25)
plot(low_pred_error_mean_pain_rating_lb, '-rs','MarkerSize',15, 'LineWidth', 1.5)
plot(high_pred_error_mean_pain_rating_lb, '-bs','MarkerSize',15, 'LineWidth', 1.5)
plot(mid_pred_error_mean_pain_rating, '-gs','MarkerSize',15, 'LineWidth', 1.5)
xticks([1 2 3])
yticks([linspace(0,1,11)])
xticklabels({'Low Pain', 'Medium Pain', 'High Pain'})
hold off

%% prediction error
pred_err = zeros(140,1);

% low prediction error : 1
pred_err(strcmp(cue, "HighCue") & belief_levels == 1 & heat_levels == 3) = 1;
pred_err(strcmp(cue, "LowCue") & belief_levels == 2 & heat_levels == 3) = 1;
pred_err(strcmp(cue, "LowCue") & belief_levels == 1 & heat_levels == 1) = 1;
pred_err(strcmp(cue, "HighCue") & belief_levels == 2 & heat_levels == 1) = 1;

% mid pain
pred_err(strcmp(cue, "HighCue") & belief_levels == 1 & heat_levels == 2) = 4;
pred_err(strcmp(cue, "LowCue") & belief_levels == 2 & heat_levels == 2) = 4;
pred_err(strcmp(cue, "LowCue") & belief_levels == 1 & heat_levels == 2) = 4;
pred_err(strcmp(cue, "HighCue") & belief_levels == 2 & heat_levels == 2) = 4;

% high prediction error
pred_err(strcmp(cue, "HighCue") & belief_levels == 1 & heat_levels == 1) = 2;
pred_err(strcmp(cue, "LowCue") & belief_levels == 2 & heat_levels == 1) = 2;
pred_err(strcmp(cue, "LowCue") & belief_levels == 1 & heat_levels == 3) = 2;
pred_err(strcmp(cue, "HighCue") & belief_levels == 2 & heat_levels == 3) = 2;

% middle prediction error
pred_err(strcmp(cue, "HighCue") & belief_levels == 3 & heat_levels == 3) = 3;
pred_err(strcmp(cue, "LowCue") & belief_levels == 3 & heat_levels == 3) = 3;
pred_err(strcmp(cue, "HighCue") & belief_levels == 3 & heat_levels == 1) = 3;
pred_err(strcmp(cue, "LowCue") & belief_levels == 3 & heat_levels == 1) = 3;
pred_err(strcmp(cue, "HighCue") & belief_levels == 3 & heat_levels == 2) = 3;
pred_err(strcmp(cue, "LowCue") & belief_levels == 3 & heat_levels == 2) = 3;

%% mediation
% matches, pred_err, heat_levels

x = heat_levels;
m = mean(dat_amyg.dat)';
y = heat_ratings;

[paths, stats] = mediation(x, y, m, 'verbose', 'boot', 'bootsamples', 10000);


