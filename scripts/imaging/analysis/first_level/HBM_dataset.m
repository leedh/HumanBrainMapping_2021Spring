clear;
clc;

% updated version of MPC100_210325_dataset.m 
% added D.Subj_Level.issue_run_idx
% by Dong Hee Lee

% Human Brain Mapping 2021 Spring

%% path set up
addpath(genpath('/media/das/cocoanlab Dropbox/resources/spm12'))
addpath(genpath('/home/donghee/Documents/resources/github/cocoanlab'))
addpath(genpath('/home/donghee/Documents/resources/github/canlab'))
rmpath(genpath('/home/donghee/Documents/resources/github/canlab/CanlabCore/CanlabCore/External'))


%% setting: canlab_dataset and version description
D = canlab_dataset('fmri');
D.Description.Missing_Values = NaN;
D.Description.Experiment_Name = 'HBM';

version_description.date = date;
D.Description.version = version_description;
clear version_description;

%% D.Subj_Level: INPUT
sub_list = 1:2;


for sub_i = 1:numel(sub_list)
    D.Subj_Level.id{sub_i} = sprintf('hbm%03d', sub_i);
end

%% D.Subj_Level: setting
% TODO : Need to update
D.Subj_Level.id = cell(1,numel(sub_list));
D.Subj_Level.names = {'question1', 'question2', 'question3'};
D.Subj_Level.type = {'numeric', 'text', 'numeric'};
D.Subj_Level.units = {'text', 'contrast', 'score'};
D.Subj_Level.descrip = {'age (in years)','1:female, 2:male', 'date of fmri experiment'};

D.Subj_Level.data = NaN(numel(sub_list),numel(D.Subj_Level.names));
D.Subj_Level.textdata = cell(numel(sub_list),numel(D.Subj_Level.names));


%% D.Event_level: setting
D.Event_Level.names = {'Session_number', 'RunNumber', 'ConditionNum', 'CueType', 'TrialNumber', ...
                        'EventOnsetTime', 'EventDuration', 'EventName', 'PainRating', 'HeatPainLevel', ...
                        'BeliefRating'};

D.Event_Level.type = {'numeric', 'numeric', 'numeric', 'text', 'numeric' ...
                      'numeric', 'numeric', 'text', 'numeric', 'numeric', ...
                      'numeric'};

D.Event_Level.units = {'number', 'number', 'number', 'text', 'number', ...
                        'second', 'second', 'text', 'number', 'number', ...
                        'number'};

D.Event_Level.descrip = {'Session Number: 1(only)', ...
                        'Run Number: 1 ~ 8', ...
                        'Condition Number: each run has two conditions(Low certainty, Middle certainty, High certainty)', ...
                        'Cue Type: HighCue, Low Cue', ...
                        'Trial Number : 20 trials for each run', ...
                        'EventOnsets(seconds) : OnsetTime - fmri_start_time - 8.28(18TR * 0.46)', ...
                        'EventDuration(seconds) : OnsetTime - fmri_start_time - 8.28(18TR * 0.46)', ...
                        'EventName : Heat, HeatRating, Cue, Belief Rating', ...
                        'PainRating : 0 ~ 1', ...
                        'HeatPainLevel: 1 ~ 3 (Low, Medium, High)',...
                        'Belief Rating: Confidence level for upcoming heat stimulus'};

%% D.Event_level: INPUT

% directory and templete of experiment data
% basedir = '/media/das/dropbox/data/MPC/MPC_wani/behavioral';
% basedir = '/cocoanlab2/GPU3_sync/data/MPC/MPC_100/behavioral';
% basedir = '/media/cnir09/GPU3_sync/data/MPC/MPC_100/behavioral';
basedir = '/media/das/HBM_2021spring/behavioral';

raw_dir = fullfile(basedir);
templete = 'sub%02d/*_run%03d_*.mat';

% initialize data, textdata as cell
D.Event_Level.data = cell(1, 1);
D.Event_Level.textdata = cell(1, 1);

% Setting run list and name
run_list = 1:8;
            
%% Main iteration Summary 
%  There will be 4 for loops
%     """
%     for sub_list <- 1:22
%       for run_list <- 1:10
%           for trial_list <- 1:12 for Heat runs, 1 for Resting and Caps
%               for event_list <- Resting run {'Resting'}, 
%                                 NomovieHeat run {'Prestate', 'Heat', 'Rating'}
%                                 MovieHeat Run {'Movie', 'Prestate', 'Heat', 'Rating'}
%                                 Caps Run {'CapsDeliver', 'CapsRemove'}
%     """
% 
%  Every iteration will make one row of D.Event_Level.data and D.Event_Level.textdata
%  Each subject will have 363 rows
%     """
%     1[Resting trial] * 1[Resting event] +
%     (12[NomovieHeat trial] * 3[NomovieHeat event]) * 2[run number] +
%     (12[MovieHeat trial] * 4[MovieHeat event]) * 6[run number] +
%     1[Caps trial] * 2[Caps event] = 363
%     """


%% Main iteration

%% Iterating for subject (First iteration)
% post_scan_state = true;

for sub_idx = 1:numel(sub_list)
    sub_i = sub_list(sub_idx);
    
%     % Load Post scan movie data
%     post_dat = filenames(fullfile(post_scan_dir, sprintf('MPC%03d_*.mat', sub_i)), 'char');
%     
%     % if there is no file for post scan movie data, it will raise warning!
%     if isempty(post_dat)
%         fprintf('###### No Post Movie rating sub-%03d ######\n', sub_i);
%         post_scan_state=false;
%     else % if a file exists, load it.
%         post_scan_state = true;
%         post_scan = load(post_dat);
%     end
     
    % This is row index of D.Event_Level.data and D.Event_Level.textdata.
    index = 1;
    
    %% Iterating for run in subject (Second iteration)
    for run_idx = 1:numel(run_list)
        run_i = run_list(run_idx);
     
        
        %% Loading experiment data
        dat_file = filenames(sprintf(fullfile(raw_dir, templete) ,sub_i, run_i), 'char');
        
        % If subject-run is incomplete, skip to laod experiment data

        dat = load(dat_file);
        expm_dat = dat.data.dat;
        expm_dat2 = dat.data.expt_param;

        
        
        %% Setting fmri-start-time(when 'S' key arrived) and disdaq(around 8 sec) for subtracting from onset
        disdaq = 18 * 0.46; % 18 TR * 0.46 sec = 8.28 sec
        fmri_start_time = expm_dat.fmri_start_time;
        
        
        %% Setting heat level map

        heat_parameters = cell2mat(struct2cell(expm_dat.heat_param));
        

        stim = expm_dat2.heat_intensity_table;

           
        level = [1:3];
        heat_level_map = containers.Map(stim, level);
        
        
        %% Settings run events

        trial_list = 1:20;
        event_list = {'Belief_Rating', 'Cue', 'Heat', 'Heat_Rating', 'ITI'};
     
        %% Iterating for trial in run (Third iteration)
        for trial_idx = 1:numel(trial_list)
            trial_i = trial_list(trial_idx);
            
            
            %% Iterating for event in a trial (Fourth iteration)
             for event_idx = 1:numel(event_list)
                event = event_list{event_idx};
            
                %% Settings Onsets
                switch event 
                    case 'Belief_Rating'
                    onset = expm_dat.belief_rating_starttime(trial_idx) - fmri_start_time - disdaq;
                    dur = expm_dat.belief_rating_duration(trial_idx);
                    rating = expm_dat.heat_rating(trial_idx);
                    heat_level = heat_level_map(expm_dat.heat_param(trial_idx).intensity);
                    cue = expm_dat.cue_type(trial_idx);
                    belief_rating = expm_dat.belief_rating(trial_idx);


                    case 'Cue'
                    onset = expm_dat.cue_starttime(trial_idx) - fmri_start_time - disdaq;
                    dur = expm_dat.cue_duration(trial_i);
                    rating = expm_dat.heat_rating(trial_idx);
                    heat_level = heat_level_map(expm_dat.heat_param(trial_idx).intensity);
                    cue = expm_dat.cue_type(trial_idx);
                    belief_rating = expm_dat.belief_rating(trial_idx);


                    case 'Heat'
                    onset = expm_dat.stimulus_time(trial_idx) - fmri_start_time - disdaq;
                    dur = 8;
                    rating = expm_dat.heat_rating(trial_idx);
                    heat_level = heat_level_map(expm_dat.heat_param(trial_idx).intensity);
                    cue = expm_dat.cue_type(trial_idx);
                    belief_rating = expm_dat.belief_rating(trial_idx);

                    case 'Heat_Rating'
                    onset = expm_dat.heat_rating_starttime(trial_idx) - fmri_start_time - disdaq;
                    dur = expm_dat.heat_rating_duration(trial_idx);
                    rating = expm_dat.heat_rating(trial_idx);
                    heat_level = heat_level_map(expm_dat.heat_param(trial_idx).intensity);
                    cue = expm_dat.cue_type(trial_idx);
                    belief_rating = expm_dat.belief_rating(trial_idx);
                    
                    case 'ITI'
                    onset = expm_dat.heat_rating_endtime(trial_idx) - fmri_start_time - disdaq;
                    dur = 4;
                    rating = expm_dat.heat_rating(trial_idx);
                    heat_level = heat_level_map(expm_dat.heat_param(trial_idx).intensity);
                    cue = expm_dat.cue_type(trial_idx);
                    belief_rating = expm_dat.belief_rating(trial_idx);

                end


                %% Setting variables before making each row of data
                ses_num = 1;
                run_num = run_i;
                condition_num = expm_dat2.condition_nums;
                cue_type = cue;
                trial_num = trial_i;
                onset_t = onset;
                dur_t = dur;
                event_name = event;
                pain_reting = rating;
                pain_level = heat_level;
                belief_rating = belief_rating;
                 
                %% Making each row of data
                D.Event_Level.data{1,sub_i}(index,1) = ses_num; % 'Session_number'
                D.Event_Level.textdata{1,sub_i}(index,1) = {NaN}; % 'Session_number'
                
                D.Event_Level.data{1,sub_i}(index,2) = run_num; % 'RunNumber'
                D.Event_Level.textdata{1,sub_i}(index,2) = {NaN}; % 'RunNumber'
                
                D.Event_Level.data{1,sub_i}(index,3) = condition_num; % 'Condition Number'
                D.Event_Level.textdata{1,sub_i}(index,3) = {NaN}; % 'Condition Number'
                
                D.Event_Level.data{1,sub_i}(index,4) = NaN; % 'Cuetype'
                D.Event_Level.textdata{1,sub_i}(index,4) = {cue_type}; % 'Cuetype'
                
                D.Event_Level.data{1,sub_i}(index,5) = trial_num; % 'TrialNumber'
                D.Event_Level.textdata{1,sub_i}(index,5) = {NaN}; % 'TrialNumber'
                
                D.Event_Level.data{1,sub_i}(index,6) = onset_t; % 'EventOnsetTime'
                D.Event_Level.textdata{1,sub_i}(index,6) = {NaN}; % 'EventOnsetTime'
                
                D.Event_Level.data{1,sub_i}(index,7) = dur_t; % 'EventDuration'
                D.Event_Level.textdata{1,sub_i}(index,7) = {NaN}; % 'EventDuration'
                
                D.Event_Level.data{1,sub_i}(index,8) = NaN; % 'EventName'
                D.Event_Level.textdata{1,sub_i}(index,8) = {event_name}; % 'EventName'
                
                D.Event_Level.data{1,sub_i}(index,9) = pain_reting; % 'PainRating'
                D.Event_Level.textdata{1,sub_i}(index,9) = {NaN}; % 'PainRating'
                
                D.Event_Level.data{1,sub_i}(index,10) = pain_level; % 'HeatPainLevel'
                D.Event_Level.textdata{1,sub_i}(index,10) = {NaN}; % 'HeatPainLevel'
                
                D.Event_Level.data{1,sub_i}(index,11) = belief_rating; % 'Belief Rating'
                D.Event_Level.textdata{1,sub_i}(index,11) = {NaN}; % 'Belief Rating'
 
                
                %% increasing row index of D.Event_Level
                index = index + 1;
             end
        end
    end
end

%% Saving Dataset
formatOut = 'yymmdd';
save_file_name = sprintf('HBM_dataset_behavioral_%s', datestr(now,formatOut));
save(save_file_name, 'D')


%% Indexing example
% [~, prestate] = get_var(D, 'EventDuration', 'conditional', {'EventName' 'Prestate'});
% min(cat(2,prestate{:}))
% [~, prestate] =  get_var(D, 'EventDuration', 'conditional', {'RunNumber' 8});
