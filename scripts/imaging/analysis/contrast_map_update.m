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
datdir = fullfile(basedir, 'result/first_level/iti/cocoan_prep_ica_nonaggr');

subjdir = fullfile(datdir, 'sub-hbm002');

imgs = filenames(fullfile(subjdir ,'sub-*_run*-ITI.nii'));
dat = fmri_data(imgs, which('gray_matter_mask.nii'),'noverbose');

%%
csv_hh = readmatrix('/home/donghee/Downloads/high_update_high_pain.csv');
csv_hl = readmatrix('/home/donghee/Downloads/high_update_low_pain.csv');
csv_lh = readmatrix('/home/donghee/Downloads/low_update_high_pain.csv');
csv_ll = readmatrix('/home/donghee/Downloads/low_update_low_pain.csv');

idx_hh = csv_hh(:,3);
idx_hl = csv_hl(:,3);
idx_lh = csv_lh(:,3);
idx_ll = csv_ll(:,3);

imgs_hh = imgs(idx_hh);
imgs_hl = imgs(idx_hl);
imgs_lh = imgs(idx_lh);
imgs_ll = imgs(idx_ll);

dat_hh = fmri_data(imgs_hh, which('gray_matter_mask.nii'),'noverbose');
dat_hl = fmri_data(imgs_hl, which('gray_matter_mask.nii'),'noverbose');
dat_lh = fmri_data(imgs_lh, which('gray_matter_mask.nii'),'noverbose');
dat_ll = fmri_data(imgs_ll, which('gray_matter_mask.nii'),'noverbose');

%% HH - LH

diff = dat_hh.dat - dat_lh.dat(:,1:7);

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

%% HL LL
diff = dat_hl.dat(:,1:5) - dat_ll.dat;

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
