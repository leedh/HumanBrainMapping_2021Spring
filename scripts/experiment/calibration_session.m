%% SESSION 1
clc;
clear;
close all;

%% SETUP: DIRECTORY
% ~/experiment
addpath(genpath(pwd));
%% SETUP: PARAMETER
% 1) PC A: computer connected with the Pathway and also inter-connected PC B 
% 2) PC B: computer for present stimulus and send command to trigger
% pathway also connected with PC A using TCP-IP protocal(i.e., hub or cross
% UTP calbe)

% should put the PC A's IP and port
ip = '192.168.0.2'; %ip = '115.145.189.133'; %ip = '203.252.54.21';
port = 20121;

basedir=pwd;

cali_param.screen_mode = 'Test'; %{'Test','Full'}
cali_param.pathway = 0;

cali_param.subjectID = 'test02'; %subject ID 

%% Calibration
cali_param = data_save_cali(cali_param, basedir);

screen_param = setscreen(cali_param);

calibration(ip, port, cali_param, screen_param); % run calibration task 
