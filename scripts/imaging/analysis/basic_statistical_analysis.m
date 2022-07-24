clear;clc;

%% path set up
%spm
addpath(genpath('/media/das/cocoanlab Dropbox/resources/spm12'))
%canlab
addpath(genpath('/home/donghee/Documents/resources/github/canlab'))
rmpath(genpath('/home/donghee/Documents/resources/github/canlab/CanlabCore/CanlabCore/External'))
%cocoanlab
addpath(genpath('/home/donghee/Documents/resources/github/cocoanlab'))

%%
basedir = '/media/das/HBM_2021spring/';
datdir = fullfile(basedir, 'result/first_level/cocoan_prep_ica_nonaggr');

subjdir = 'sub-hbm002';

imgs = filenames(fullfile(datdir, subjdir ,'sub*Heat*nii'));

dat = fmri_data(imgs); % default mask: >> which('brainmask_canlab.nii')
dat_gray = fmri_data(imgs, which('gray_matter_mask.nii'));

plot(dat_gray)

%% condition level image
imgs_Level1 = filenames(fullfile(datdir, subjdir ,'sub*Heat_level-1*nii'));
imgs_Level2 = filenames(fullfile(datdir, subjdir ,'sub*Heat_level-2*nii'));
imgs_Level3 = filenames(fullfile(datdir, subjdir ,'sub*Heat_level-3*nii'));

dat_Level1 = fmri_data(imgs_Level1



%% t-test
methods(dat_gray) % functions within 'fmri_data' object

mdat_gray = mean(dat_gray);
%tdat = ttest(dat_gray, 0.05, 'unc'); %uncorrection
%tdat = ttest(dat_gray, 0.05, 'fdr'); % FDR correction
tdat = ttest(dat,0.05,'bfr'); % Bonferonni correction

% multiple thresholding
tdat = threshold(tdat, 0.05, 'unc');
tdat = threshold(tdat, 0.05, 'fdr');
tdat = threshold(tdat, 0.05, 'bfr');

%% region
region_gray = region(tdat);
orthviews(region_gray); % whole regions
orthviews(region_gray(1)); % specific region

%% visualization
% canlabCore
close all;
o2 = canlab_results_fmridisplay(tdat);

% cocoanCore
close all;
[out, o2] = brain_activations_wani(region(tdat));

% useful function: pruning_img
p = [0.00001 0.000001 0.05/size(tdat.dat,1)];
k = [1 1 10];
[dat, r] = pruning_img(tdat, p, k);

[out, o2] = brain_activations_wani(r);

[out, o2] = brain_activations_wani(region(tdat), o2, 'outline');


%% making a thalamus mask and reading the data from thalamus for two different temperatures
% mask atlas: CANlab_combined_atlas_object_2018.mat
% key functions: select_atlas_subset
% apply_mask or extract_roi_averages

load(which('CANlab_combined_atlas_object_2018.mat')); % this atlas is defined by multiple atlases
thal = select_atlas_subset(atlas_obj, {'Thal'});
nac = select_atlas_subset(atlas_obj, {'NAC'});
amyg = select_atlas_subset(atlas_obj, {'Amygdala'});

thal = remove_empty(thal);
nac = remove_empty(nac);
amyg = remove_empty(amyg);

dat_thal = apply_mask(dat, thal);
dat_nac = apply_mask(dat, nac);
dat_amyg = apply_mask(dat, amyg);

%% one-sample t-test and plotting for two different temperatures
% key functions: ttest, plot_specificity_box
temp_indx = repmat((1:3)', 1, 1);

dat_heatLV1 = dat_thal.dat(:, temp_idx == 1);



