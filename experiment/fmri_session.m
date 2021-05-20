clc;
clear;
close all;
%% SETTING
addpath(genpath(pwd));
%PATH = getenv('PATH');
%setenv('PATH', [PATH ':/Users/donghee/anaconda3/bin:/Users/donghee/anaconda3/condabin']); %For biopack, you need to add your python3 path
%setenv('PATH', [PATH ':/Library/Frameworks/Python.framework/Versions/3.7/bin']);

basedir = pwd;

expt_param.screen_mode = 'Full'; %{'Test','Full'}

expt_param.run_name = 'run';
expt_param.run_num = 01;

expt_param.pathway = false; % {true, false}
expt_param.dofmri = false; % {true, false}

%% Experiment parameter
expt_param.subjectID='test02'; %Subject ID

loaddir = fullfile(pwd,'Data/calibration');
fname = fullfile(loaddir, [cali, '_', expt_param.subjectID, '_HBM', '.mat']);

load(fname);

% --
whichScreen = 1; % you can check the screen number by running Screen('Screens')

expt_param.max_heat = 0;

expt_param.cue_types = ["HighCue", "LowCue"];
expt_param.cue_shapes = ["△", "☐"];

%gLMS ; 
%(1) barely detectable, 1.4;
%(2) weak, 6;
%(3) moderate, 17;
%(4) strong, 34.7;
%(5)very strong, 52.5;
%(6) strongest imaginable sensation of any kind, 100
LowPain = reg.FinalLMH_5Level(2);
MidPain = reg.FinalLMH_5Level(3); 
HighPain = reg.FinalLMH_5Level(4);
expt_param.heat_intensity_table = [LowPain, MidPain, HighPain]; % stimulus intensity

expt_param.condition_nums = 3;
expt_param.trial_nums_per_condition = 10;
expt_param.midpain_per_condition = 2;
expt_param.trial_nums = expt_param.condition_nums * expt_param.trial_nums_per_condition;

%expt_param.run_type = 'Plus_High_Certainty'; % {'Plus_High_Certainty', 'Plus_Middle_Certainty', 'Plus_Low_Certainty'}

% {'no_movie_heat', 'movie_heat', 'caps', 'resting'}

% pathway computer IP and port
expt_param.ip = '192.168.0.2';
expt_param.port = 20121;

%% Start experiment
data = data_save(expt_param, basedir);
data.expt_param = expt_param;
%data.dat.experiment_start_time = GetSecs; %이걸 왜 또하지 data_save()에서 했는데

screen_param = setscreen(expt_param);

explain(screen_param);
  
practice(screen_param, expt_param);

data = run(screen_param, expt_param, data);
  
data = close(screen_param, data);