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

subjdir = fullfile(datdir, 'sub-hbm002');

imgs = filenames(fullfile(subjdir ,'sub-*_run*-Heat_level*.nii'));
dat = fmri_data(imgs, which('gray_matter_mask.nii'),'noverbose');

%%
csv = readmatrix('/home/donghee/Downloads/data_mid_pain_high_cue.csv');
idx = csv(:,3);
imgs = imgs(idx);

imgs_highbelief = imgs(csv(:,7) > 0.7);
imgs_lowbelief = imgs(csv(:,7) < 0.3);

dat_highbelief = fmri_data(imgs_highbelief, which('gray_matter_mask.nii'),'noverbose');
dat_lowbelief = fmri_data(imgs_lowbelief, which('gray_matter_mask.nii'),'noverbose');

%%
dat = fmri_data(imgs, which('gray_matter_mask.nii'),'noverbose');

diff = dat_highbelief.dat - dat_lowbelief.dat(:,3);

mdat = fmri_data;
mdat.dat = diff;
mdat.volInfo = dat.volInfo;

tdat = ttest(mdat, 0.05, 'unc');
tdat.volInfo = dat.volInfo;

% pruning 
p = [0.005 0.005 0.001];
k = [1 1 5];
[dat2, r] = pruning_img(tdat, p, k);

data = tdat.dat(tdat.sig ==1);
[out, o2] = brain_activations_wani(r, 'all', 'cmaprange', [prctile(data(data<0), 5) prctile(data(data>0), 95)]);
