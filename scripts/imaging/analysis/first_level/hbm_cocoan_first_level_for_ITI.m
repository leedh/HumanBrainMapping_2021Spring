function hbm_cocoan_first_level(varargin)
% clear;
% clc;

sub_idx = [1 2]; 
project = 'hbm'; 

%% SET-UP: DIRECTORY
addpath(genpath('/media/das/cocoanlab Dropbox/resources/spm12'))
addpath(genpath('/home/donghee/Documents/resources/github/cocoanlab'))
addpath(genpath('/home/donghee/Documents/resources/github/canlab'))
rmpath(genpath('/home/donghee/Documents/resources/github/canlab/CanlabCore/CanlabCore/External'))

model_name = 'cocoan_prep_ica_nonaggr';

basedir = '/media/das/HBM_2021spring';
save_base = '/media/das/HBM_2021spring/result/first_level/iti';
    
img_dir = fullfile(basedir, '/imaging/preprocessed');
modeldir = fullfile(save_base, model_name); 

if ~exist(modeldir, 'dir'), mkdir(modeldir); end

dataset_dir = fullfile(basedir, 'codes/behavioral');
dataset_file = 'HBM_dataset_behavioral*.mat';


%%
fprintf('####### START!! \n')
fprintf('####### %s \n', datetime)
fprintf('####### project : %s \n', project)
fprintf('####### img_dir : %s \n', img_dir)
fprintf('####### modeldir : %s \n', modeldir)
fprintf('####### dataset_dir : %s \n', dataset_dir)
fprintf('####### subject : %d \n', sub_idx)


%% Set the parameters
TR = 0.46;
hpfilterlen = 180;

run_list = [1:8];

load_file = filenames(fullfile(dataset_dir, dataset_file), 'char');

load(load_file(end,:));
Edata = D.Event_Level.data;
Etdata = D.Event_Level.textdata;
Enames = D.Event_Level.names;

% Onsets and Durations from D
% [~, movie_onset] = get_var(D, 'EventOnsetTime', 'conditional', {'EventName' 'Movie'});
% [~, run_num] = get_var(D, 'RunNumber');
% [~, trial_num] = get_var(D, 'TrialNumber');
% [~, event_name] = get_var(D, 'EventName');
% [~, onset_list] = get_var(D, 'EventOnsetTime');
% [~, dur_list] = get_var(D, 'EventDuration');
% [~, heat_level] = get_var(D, 'HeatPainLevel');

%%
for sub_id = 1:numel(sub_idx)  
    
    sub_num = sub_idx(sub_id);
    subj_outputdir = fullfile(modeldir,sprintf('/sub-hbm%03d',sub_num));
    subj_dir = fullfile(img_dir, sprintf('sub-hbm%03d', sub_num));
    
    load(fullfile(subj_dir, 'PREPROC.mat'));
    nuisance_dir = fullfile(subj_dir, 'nuisance_mat'); 
        
    images_by_run = {};
    multi_nuisance_matfilenames = {};
    k = 1;
    for i =run_list
        img = filenames(fullfile(subj_dir, sprintf('func/sw*_run-%02d*.nii', i)), 'char');
        nui = fullfile(nuisance_dir, sprintf('nuisance_run%d.mat', i));
        
        if isempty(img)
           continue 
        end
        
        images_by_run{k,1} =img;
        multi_nuisance_matfilenames{k} = nui;
        k = k+1;
    end
    
    %
    sub_run_num = Edata{sub_num}(:, strcmp(Enames, 'RunNumber'));
    sub_trial_num = Edata{sub_num}(:, strcmp(Enames, 'TrialNumber'));
    sub_event_name = string(Etdata{sub_num}(:, strcmp(Enames, 'EventName')));
    sub_onset_list = Edata{sub_num}(:, strcmp(Enames, 'EventOnsetTime'));
    sub_dur_list = Edata{sub_num}(:, strcmp(Enames, 'EventDuration'));
    sub_heat_level = Edata{sub_num}(:, strcmp(Enames, 'HeatPainLevel'));

    ref_index = 1:numel(sub_onset_list)';
    ref_index = ref_index';
    
    onsets = [];
    durations = [];
    names = [];
    
    conditions_per_run = repmat(43, 1, 8);

    for run_i = min(sub_run_num):max(sub_run_num)
        % 'ITI' event regressor
        iti_idx = ref_index(sub_event_name == "ITI" & sub_run_num == run_i);
        onsets_temp = num2cell(sub_onset_list(iti_idx));
        onsets = [onsets; onsets_temp];
        durations_temp = num2cell(sub_dur_list(iti_idx));
        durations = [durations; durations_temp];
        
        names_temp = {};
        for trial_i = min(sub_trial_num):max(sub_trial_num)
            names_temp{trial_i} = sprintf('sub-%02d_run-%02d_trial-%02d_event-ITI', sub_num, run_i, trial_i);
        end
        names = [names; names_temp'];
        
        % 'Heat stimulus' event regressor
        heat_idx = ref_index(sub_event_name == "Heat" & sub_run_num == run_i);
        onsets_temp = num2cell(sub_onset_list(heat_idx));
        onsets = [onsets; onsets_temp];
        durations_temp = num2cell(sub_dur_list(heat_idx));
        durations = [durations; durations_temp];
        
        names_temp = {};
        for trial_i = min(sub_trial_num):max(sub_trial_num)
            heat_level_run = sub_heat_level(heat_idx);
            heat_level_trial = heat_level_run(trial_i);
            
            names_temp{trial_i} = sprintf('sub-%02d_run-%02d_trial-%02d_event-Heat_level-%d', sub_num, run_i, trial_i , heat_level_trial);
        end
        names = [names; names_temp'];
     
        % 'Belief rating' event regressor
        belief_rating_idx = ref_index(sub_event_name == "Belief_Rating" & sub_run_num == run_i);
        
        onsets_belief_temp = sub_onset_list(belief_rating_idx);
        onsets = [onsets; onsets_belief_temp];
        
        durations__belief_temp = sub_dur_list(belief_rating_idx);
        durations = [durations; durations__belief_temp];
        
        names_temp = sprintf('sub-%02d_run-%02d_event-Belief_rating', sub_num, run_i);
        names = [names; names_temp];
     

        % 'Cue' event regressor
        cue_idx = ref_index(sub_event_name == "Cue" & sub_run_num == run_i);
        
        onsets_cue_temp = sub_onset_list(cue_idx);
        onsets = [onsets; onsets_cue_temp];
        
        durations_cue_temp = sub_dur_list(cue_idx);
        durations = [durations; durations_cue_temp];
        
        names_temp = sprintf('sub-%02d_run-%02d_event-Cue', sub_num, run_i);
        names = [names; names_temp];
        
        % 'Heat rating' event regressor
        heat_rating_idx = ref_index(sub_event_name == "Heat_Rating" & sub_run_num == run_i);
        onsets_rating_temp = sub_onset_list(heat_rating_idx);
        onsets = [onsets; onsets_rating_temp];
        durations_rating_temp = sub_dur_list(heat_rating_idx);
        durations = [durations; durations_rating_temp];        
        
        names_temp = sprintf('sub-%02d_run-%02d_event-Heat_Rating', sub_num, run_i);
        names = [names; names_temp];        

    end
    
    %% first-level model job
    matlabbatch = canlab_spm_fmri_model_job(subj_outputdir, TR, hpfilterlen, images_by_run, conditions_per_run, onsets, durations, names, multi_nuisance_matfilenames, 'is4d', 'notimemod');
  
    if ~exist(subj_outputdir, 'dir'), mkdir(subj_outputdir); end
    save(fullfile(subj_outputdir, 'spm_model_spec_estimate_job.mat'), 'matlabbatch');
    spm_jobman('run', matlabbatch);
    %%
    
%     cd(subj_outputdir);
%     out = scn_spm_design_check(subj_outputdir, 'events_only');
%     savename = fullfile(subj_outputdir, 'vifs.mat');
%     save(savename, 'out');
    
    %% delete unneccessary files and make a symbolic links for later use
     load(fullfile(subj_outputdir, 'SPM.mat'));
     bimgs=dir(fullfile(subj_outputdir, 'beta_*nii'));
     betaimgs = filenames(fullfile(subj_outputdir, 'beta_*nii'));
    
     delete_file_idx = [find(contains(SPM.xX.name, 'R'))';find(contains(SPM.xX.name, 'constant'))'];
     for z = 1:numel(delete_file_idx)
         delete(fullfile(subj_outputdir,bimgs(delete_file_idx(z)).name));
         delete(betaimgs{delete_file_idx(z)});
     end
end

end