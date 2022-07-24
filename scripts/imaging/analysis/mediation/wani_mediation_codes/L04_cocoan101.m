%% fMRI data analysis tutorial for COCOAN101-L04
% 
% 
% by Choong-Wan (Wani) Woo
% 
% Agenda
% 1. Introducing canlab tools
%% 
% * <https://canlab.github.io/ https://canlab.github.io/>
% * some important objects: fmri_data (and image_vector), region, statistic_image, 
% fmridisplay, atlas 
% * cf. <https://canlab.github.io/objectoriented/ https://canlab.github.io/objectoriented/>
%% 
% 2. Install! 
%% 
% * <https://github.com/canlab https://github.com/canlab>
% * <https://github.com/canlab/CanlabCore https://github.com/canlab/CanlabCore>
% * cf. <https://canlab.github.io/setup/ https://canlab.github.io/setup/>
%% 
% 3. Getting example dataset
%% 
% * <https://www.dropbox.com/sh/7yqf9r2ncttkcix/AAAgOAMkGeSWX3PTOhBBaqE9a?dl=0 
% https://www.dropbox.com/sh/7yqf9r2ncttkcix/AAAgOAMkGeSWX3PTOhBBaqE9a?dl=0>
%% 
% 4. Let's try setup your computer... - how much do we want?? 
% 
% 5. Load data and basic QC (plot)

% key functions: fmri_data, plot

basedir = '/Users/clinpsywoo/Dropbox/2011-yr/Teaching/COCOAN101/L04';
datdir = '/Users/clinpsywoo/Dropbox/2011-yr/Teaching/R_advancedfmri/advancedfmrianalysis2_2020spring/tutorials/wani_session/example_data/bmrk3_temp_avg';

imgs = filenames(fullfile(datdir, 'sub*heat*nii'));

dat = fmri_data(imgs);
%%
% default mask: >> which('brainmask_canlab.nii')
% or you can also use different masks, e.g., 

dat_gray = fmri_data(imgs, which('gray_matter_mask.nii'));
%%
plot(dat)
%%
plot(dat_gray)
%% 
% 6. Mean and one-sample t-test

% key funtions: mean, ttest

mdat = mean(dat);
orthviews(mdat);

% tdat = ttest(dat, 0.05, 'unc');
% tdat = ttest(dat, 0.05, 'fdr');
tdat = ttest(dat, 0.05, 'bfr');

orthviews(tdat);
%% 
% 7. multiple-testing correction and visualize brain maps

%% key functions: threshold, canlab_results_fmridisplay or
% brain_activations_wani

tdat = threshold(tdat, 0.05, 'unc')
tdat = threshold(tdat, 0.05, 'fdr')
tdat = threshold(tdat, 0.05, 'bfr')

o2 = canlab_results_fmridisplay(tdat)
%%


% you need this to use brain_activations_wani: https://github.com/cocoanlab/cocoanCORE

% [out, o2] = brain_activations_wani(region(tdat))

% useful function: pruning_img

p = [0.00001 0.000001 0.05/size(tdat.dat,1)];
k = [1 1 10]
[dat, r] = pruning_img(tdat, p, k);

[out, o2] = brain_activations_wani(region(tdat))

[out, o2] = brain_activations_wani(r, o2, 'outline')

close all;
% o2 = canlab_results_fmridisplay(dat);

tdat.fullpath = 'temp_avg_bfr.nii';
write(tdat, 'thresh')

%% 
% 8. making a thalamus mask and reading the data from thalamus for two different 
% temperatures

% mask atlas: CANlab_combined_atlas_object_2018.mat
% key functions: select_atlas_subset, 
% apply_mask or extract_roi_averages

load(which('CANlab_combined_atlas_object_2018.mat'));
thal = select_atlas_subset(atlas_obj, 'Thal');
nac = select_atlas_subset(atlas_obj, 'NAC');
amyg = select_atlas_subset(atlas_obj, 'Amygdala');

thal = remove_empty(thal);
nac = remove_empty(nac);
amyg = remove_empty(amyg);

dat_thal = apply_mask(dat, thal);
dat_nac = apply_mask(dat, nac);
dat_amyg = apply_mask(dat, amyg);

%% 
% 9. one-sample t-test and plotting for two different temperatures

% key functions: ttest, plot_specificity_box
temp_idx = repmat((1:6)', 1, 33);
temp_idx = temp_idx(:);

dat_heatlv2 = dat_thal.dat(:, temp_idx==2);
dat_heatlv5 = dat_thal.dat(:, temp_idx==5);

[h, p, ci, tstat] = ttest((mean(dat_heatlv5)-mean(dat_heatlv2))');

out = plot_specificity_box(mean(dat_heatlv5)', mean(dat_heatlv2)');
%%
% mediation
load(fullfile(datdir, 'bmrk3_temp_data_descript.mat'));

x = temp_idx;
% m = mean(dat_thal.dat)';
m = mean(dat_nac.dat)';
y = bmrkdata.ratings';
y = y(:);

[paths, stats] = mediation(x, y, m, 'verbose');
%%
sub_idx = repmat(1:33, 6, 1);
sub_idx = sub_idx(:);

for i = 1:33
    x2{i} = [1:6]';
    m2{i} = mean(dat_thal.dat(:,sub_idx==i))';
    y2{i} = bmrkdata.ratings(i,:)';
    m2_2{i} = mean(dat_amyg.dat(:,sub_idx==i))';
    
    cov2{i} = mean(dat_nac.dat(:,sub_idx==i))';
end

[paths, stats] = mediation(x2, y2, m2, 'verbose');
[paths, stats] = mediation(x2, y2, m2, 'covs', cov2, 'verbose');
[paths, stats] = mediation(x2, y2, m2, 'M', m2_2,  'verbose');
%%
[paths, stats] = mediation(x2, y2, m2, 'verbose', 'boot', 'bootsamples', 10000);
[paths, stats] = mediation(x2, y2, m2, 'covs', cov2, 'verbose', 'boot', 'bootsamples', 10000);
%%
[paths, stats] = mediation_threepaths(x2, y2, m2, m2_2, 'covs', cov2, 'verbose', 'boot', 'bootsamples', 10000);
%%
% prediction

dat_gray = fmri_data(imgs, which('gray_matter_mask.nii'));
pred_y = bmrkdata.ratings';
dat_gray.covariates = pred_y(:);
dat_gray.Y = temp_idx;

wh_fold = sub_idx;
%%
[cverr, stats, optout] = predict(dat_gray, 'algorithm_name', 'cv_pcr', 'nfolds', wh_fold);

orthviews(stats.weight_obj)
%% 
%