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

%% Experiment parameter(1)
expt_param.subjectID='test02'; %Subject ID

LowPain = 41;
MidPain = 44; 
HighPain = 47;
%% Pain intensity from calibration (only after calibration)
loaddir = fullfile(pwd,'Data/calibration');
fname = fullfile(loaddir, [cali, '_', expt_param.subjectID, '_HBM', '.mat']);
load(fname);

LowPain = reg.FinalLMH_5Level(2);
MidPain = reg.FinalLMH_5Level(3); 
HighPain = reg.FinalLMH_5Level(4);
%% Experiment parameter(2)
expt_param.max_heat = false; % {true, false}

expt_param.cue_types = ["HighCue", "LowCue"];
expt_param.cue_shapes = ["●", "★"];


expt_param.heat_intensity_table = [LowPain, MidPain, HighPain]; % stimulus intensity

expt_param.condition_nums = 3;
expt_param.trial_nums_per_condition = 10;
expt_param.midpain_per_condition = 2;
expt_param.trial_nums = expt_param.condition_nums * expt_param.trial_nums_per_condition;

% pathway computer IP and port
expt_param.ip = '192.168.0.2';
expt_param.port = 20121;
%% Start experiment
data = data_save(expt_param, basedir);
data.expt_param = expt_param;

screen_param = setscreen(expt_param);

explain(screen_param);
  
practice(screen_param, expt_param);

data = run(screen_param, expt_param, data);
  
data = close(screen_param, data);