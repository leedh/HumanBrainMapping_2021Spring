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
dat = fmri_data(imgs, which('gray_matter_mask.nii'));

%% Condition level images
%run level heat 
cd(fullfile(subjdir))
for run_i = 1:8
    imgs_Level1 = filenames(fullfile(subjdir ,sprintf('sub*_run-%02d_*Heat_level-1.nii', run_i)));
    imgs_Level2 = filenames(fullfile(subjdir ,sprintf('sub*_run-%02d_*Heat_level-2.nii', run_i)));
    imgs_Level3 = filenames(fullfile(subjdir ,sprintf('sub*_run-%02d_*Heat_level-3.nii', run_i)));
    
    dat_Level1 = fmri_data(imgs_Level1, which('gray_matter_mask.nii'), 'noverbose');
    dat_Level2 = fmri_data(imgs_Level2, which('gray_matter_mask.nii'), 'noverbose');
    dat_Level3 = fmri_data(imgs_Level3, which('gray_matter_mask.nii'), 'noverbose');
    
    dat_Level1= mean(dat_Level1);
    dat_Level2= mean(dat_Level2);
    dat_Level3= mean(dat_Level3);
    
    dat_Level1.fullpath = sprintf('sub-02_run-%02d_event-Heat_level-1_Runlevel.nii', run_i);
    write(dat_Level1);

    dat_Level2.fullpath = sprintf('sub-02_run-%02d_event-Heat_level-2_Runlevel.nii', run_i);
    write(dat_Level2);

    dat_Level3.fullpath = sprintf('sub-02_run-%02d_event-Heat_level-3_Runlevel.nii', run_i);
    write(dat_Level3);
end
    
% individual level heat 
imgs_Level1 = filenames(fullfile(subjdir ,'sub*_run-*_trial-*Heat_level-1.nii'));
imgs_Level2 = filenames(fullfile(subjdir ,'sub*_run-*_trial-*Heat_level-2.nii'));
imgs_Level3 = filenames(fullfile(subjdir ,'sub*_run-*_trial-*Heat_level-3.nii'));

dat_Level1 = fmri_data(imgs_Level1, which('gray_matter_mask.nii'),'noverbose');
dat_Level2 = fmri_data(imgs_Level2, which('gray_matter_mask.nii'),'noverbose');
dat_Level3 = fmri_data(imgs_Level3, which('gray_matter_mask.nii'),'noverbose');

dat_Level1= mean(dat_Level1);
dat_Level2= mean(dat_Level2);
dat_Level3= mean(dat_Level3);

cd(fullfile(datdir, subjdir))

dat_Level1.fullpath = 'sub-02_event-Heat_level-1.nii';
write(dat_Level1);

dat_Level2.fullpath = 'sub-02_event-Heat_level-2.nii';
write(dat_Level2);

dat_Level3.fullpath = 'sub-02_event-Heat_level-3.nii';
write(dat_Level3);

%% contrast map with t-test 
constrast = dat_Level3.dat - dat_Level1.dat;

mdat = fmri_data;
mdat.dat = constrast;
mdat.volInfo = dat.volInfo;

tdat = ttest(mdat, 0.05, 'bfr');
tdat.volInfo = dat.volInfo;

data = tdat.dat(tdat.sig ==1);
[out, o2] = brain_activations_wani(region(tdat), 'all', 'cmaprange', [prctile(data(data<0), 5) prctile(data(data>0), 95)]);

