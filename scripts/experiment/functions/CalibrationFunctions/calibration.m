function calibration(ip, port, cali_param, screen_param)
% Calibration function
% dependent function: cali_regression.m
%% Assign variables
global reg; % regression data

% window information
global theWindow 
font = screen_param.window_info.font ;
fontsize = screen_param.window_info.fontsize;
theWindow = screen_param.window_info.theWindow;
window_num = screen_param.window_info.window_num ;
window_rect = screen_param.window_info.window_rect;
H = screen_param.window_info.H ;
W = screen_param.window_info.W;
% line parameters
lb1 = screen_param.line_parameters.lb1 ;
lb2 = screen_param.line_parameters.lb2 ;
rb1 = screen_param.line_parameters.rb1;
rb2 = screen_param.line_parameters.rb2;
scale_H = screen_param.line_parameters.scale_H ;
scale_W = screen_param.line_parameters.scale_W;
anchor_lms = screen_param.line_parameters.anchor_lms;
% color values
bgcolor = screen_param.color_values.bgcolor;
orange = screen_param.color_values.orange;
red = screen_param.color_values.red;
white = screen_param.color_values.white;  

% one-directional
x = W*(1/4);
y = H*(1/2);

%% Test mode
testmode = false;
if strcmp(cali_param.screen_mode,'Test')
    testmode=true;
end

%% SETUP: DATA and Subject INFO
% savedir = fullfile(pwd,'Data/calibration');
% fname = fullfile(savedir,['cali_' SID '.mat']);
% % What to do if the file exits?
% if ~exist(savedir, 'dir')
%     mkdir(savedir);
%     whattodo = 1;
% else
%     if exist(fname, 'file')
%         str = ['The Subject ' SID ' data file exists. Press a button for the following options'];
%         disp(str);
%         whattodo = input('1:Save new file, 2:Save the data from where we left off, Ctrl+C:Abort? ');
%     else
%         whattodo = 1;        
%     end
% end
% 
% if whattodo == 2
%     load(fname);
%     start_trial = numel(reg.stim_degree) + 1;
% else
%     start_trial = 1;
% end


% [fname, start_trial , SID] = subjectinfo_check_SEMIC(SID, savedir,1,'Cali'); % subfunction %start_trial
% save data using the canlab_dataset object
reg.version = 'SEMIC_Calibration_v1_01-03-2018_Cocoanlab';
reg.subject = cali_param.subject;
reg.datafile = cali_param.datafile;
reg.starttime = datestr(clock, 0); % date-time
reg.starttime_getsecs = GetSecs; % in the same format of timestamps for each trial

%% SETUP: Parameter
PathPrg = load_PathProgram('HBM2021');

init_stim={'00101111' '00111001' '01000011'}; % Initial degrees of a heat pain [43.4 45.4 47.4]
stim_n = length(init_stim);
site_n = 6;

practice_n = 2; % number of rating practice trial
trial_n = stim_n*site_n;

start_trial = 1;

% save?
save(reg.datafile,'reg','init_stim');

%% Setup: generate sequence of skin site and LMH (Low, middle and high)
rng('shuffle');
reg.skin_site = zeros(trial_n,1);

while sum(prod(reshape(reg.skin_site, site_n, stim_n))==prod(1:site_n)) ~= stim_n
    reg.skin_LMH = repmat(1:stim_n, site_n, 1)';
    reg.skin_LMH = reg.skin_LMH(:);
    
    reg.skin_site = zeros(trial_n,1);
    for i=1:stim_n
        reg.skin_site(reg.skin_LMH == i) = randperm(site_n); % site mix
    end
    
    for i=1:site_n
        idx = (i-1)*3+1:(i-1)*3+3;
        temp = reg.skin_site(idx);
        rand_temp = randperm(stim_n);
        reg.skin_site(idx) = temp(rand_temp);
        reg.skin_LMH(idx) = rand_temp;
    end    
end

%% START: Calibration
%: PART 1: Rating practice
%: PART 2: Calibration
try
    %PART 1. Rating practice
    if start_trial <= practice_n    
        % 1. pathwaty test
        %pathway_test(ip, port, 'basic');
        
        % 2. Rating bar
        explain(screen_param);
        
        SetMouse(x,y)
        expt_param.dofmri = 0;
        expt_param.max_heat = 0;
        practice(screen_param, expt_param);
    end
    
    %PART 2. Calibrtaion
    % 0. Instruction
    msgtxt = ['지금부터는 캘리브레이션을 시작하겠습니다.\n참가자는 편안하게 계시고 진행자의 지시를 따라주시기 바랍니다.'];
    display_expmessage(msgtxt, screen_param)
    
    WaitSecs(3);
    random_value = randperm(stim_n); %randomized order for 1st, 2nd and 3rd stimulus
    
    % 
    for i=start_trial:trial_n %Total trial
        start_t=GetSecs;
        reg.trial_start_timestamp{i,1}=start_t; % trial_star_timestamp
        
        % manipulate the current stim
        if i < 4
            current_stim=bin2dec(init_stim{random_value(i)});
        else
            % current_stim=reg.cur_heat_LMH(i,rn); % random
            for j=1:length(PathPrg) %find degree
                if reg.cur_heat_LMH(i,reg.skin_LMH(i)) == PathPrg{j,1}
                    current_stim = bin2dec(PathPrg{j,2});
                end
            end
        end
        
        %find current degree
        for k=1:length(PathPrg) 
            if str2double(dec2bin(current_stim)) == str2double(PathPrg{k,2})
                degree = PathPrg{k,1};
            else
                % do nothing
            end
        end
            

    % 1. Display where the skin site stimulates
        if cali_param.pathway
            main(ip,port,1,current_stim); % Select the program
            WaitSecs(2);
        
            main(ip,port,2); %ready to pre-start
            WaitSecs(2);
        end
        
        msgtxt = strcat('연구자는 다음 위치의 열패드를 이동하신 후 SPACE 키를 누르십시오 :  ', num2str(reg.skin_site(i)), '\n (화면종료: q)');
        while true
            [~,~,keyCode] = KbCheck(-1);
            if keyCode(KbName('space'))==1
                break;
            elseif keyCode(KbName('q'))==1
                abort_experiment('manual');
            end
            display_expmessage(msgtxt, screen_param);
        end
        
    % 2. Heat pain stimulus
        if cali_param.pathway
            Screen('TextSize', theWindow, 60);
            display_expmessage('+', screen_param);
            Screen('TextSize', theWindow, fontsize);
            main(ip,port,2);
        else
            Screen(theWindow, 'FillRect', bgcolor, window_rect);
            DrawFormattedText(theWindow, double(num2str(degree)), 'center', 'center', white, [], [], [], 1.2);
            Screen('Flip', theWindow);
        end
        start_while=GetSecs;
        stim_dura = 8;
        waitsec_fromstarttime(start_while, stim_dura);
        
    % 3. Rating
        start_rating = GetSecs;
        
        rating_types_pls = call_ratingtypes_pls('temp');
        scale = ('overall_int');
        
        [lb, rb, start_center] = draw_scale_pls(scale, screen_param.window_info, screen_param.line_parameters, screen_param.color_values);
        Screen(theWindow, 'FillRect', bgcolor, window_rect);

        ratetype = strcmp(rating_types_pls.alltypes, scale);
        
        % Initial mouse position
        if start_center
            SetMouse(W/2,H/2); % set mouse at the center
        else
            SetMouse(lb,H/2); % set mouse at the left
        end
        
        % Rating start
        while true
            [x,~,button] = GetMouse(theWindow);
            [lb, rb, start_center] = draw_scale_pls(scale, screen_param.window_info, screen_param.line_parameters, screen_param.color_values);
            if x < lb; x = lb; elseif x > rb; x = rb; end

            DrawFormattedText(theWindow, double(rating_types_pls.prompts{ratetype}), 'center', H*(1/4), white, [], [], [], 2);
            Screen('DrawLine', theWindow, orange, x, H*(1/2)-scale_H/3, x, H*(1/2)+scale_H/3, 6); %rating bar
            Screen('Flip', theWindow);
            
            [~,~,keyCode] = KbCheck;

            if button(1)
                while button(1)
                    [~,~,button] = GetMouse(theWindow);
                end
                break
                
            elseif keyCode(KbName('q')) == 1
                abort_experiment('manual');
                break
                
            elseif GetSecs - start_rating > 5.5
                break
                
            end

        end
        
        % 5. Inter-stimulus inteval, 3 seconds / saving rating result
        Screen(theWindow, 'FillRect', bgcolor, window_rect);
        Screen('Flip', theWindow);
        
        
        % Calculating regression line
        end_t = GetSecs;
        rating = (x-lb)/(rb-lb);
        rating=rating*100;
        reg.trial_end_timestamp = end_t;
        reg.trial_duration(i) = end_t - start_t;
        
        cali_regression(degree, rating, i, trial_n); % cali_regression (stim_degree in this trial, rating, order of trial, Number of Trial)
        save(reg.datafile, '-append', 'reg');
        
        % fixation screen
        start_fix = GetSecs; % Start_time_of_Fixation_Stimulus
        Screen('TextSize', theWindow, 60);
        display_expmessage('+', screen_param);
        waitsec_fromstarttime(start_fix, 3);
        Screen('TextSize', theWindow, fontsize);

    end % trials
    
    % END: Calibration
    reg.endtime_getsecs = GetSecs;
    reg.skinSite_rs = [0,0,0,0,0,0];
    
    while ~((numel(find(diff(reg.skinSite_rs)==0))) < 1)
        rng('shuffle');
        reg.skinSite_rs = [reg.studySkinSite reg.studySkinSite];
        reg.skinSite_rs=reg.skinSite_rs(randperm(6));
    end
    
    
    save(reg.datafile, '-append', 'reg');
    msgtxt='캘리브레이션이 종료되었습니다\n이제 연구자의 지시를 따라주시기 바랍니다\n(5초 후 화면 자동꺼짐)';
    display_expmessage(msgtxt, screen_param);
    waitsec_fromstarttime(reg.endtime_getsecs, 5);
    sca;
    ShowCursor();
    Screen('CloseAll');
    
    if reg.total_fit.Rsquared.Ordinary <= 0.4
        disp("===================WARNING=======================");
        disp("=================================================");
        disp("PLEASE, check calibration data carefully.");
        disp("This participant may inappripriate for pain experiment");
        disp("=================================================");
    end
catch err
    % ERROR
    disp(err);
    for i = 1:numel(err.stack)
        disp(err.stack(i));
    end
    abort_experiment;
end
end

