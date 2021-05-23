function data = trial_heat(screen_param, expt_param, trial_num, data, heat_param, shuffled_cue)
%% Assign variables
font = screen_param.window_info.font ;
fontsize = screen_param.window_info.fontsize;
theWindow = screen_param.window_info.theWindow;
window_num = screen_param.window_info.window_num ;
window_rect = screen_param.window_info.window_rect;
H = screen_param.window_info.H ;
W = screen_param.window_info.W;

lb1 = screen_param.line_parameters.lb1 ;
lb2 = screen_param.line_parameters.lb2 ;
rb1 = screen_param.line_parameters.rb1;
rb2 = screen_param.line_parameters.rb2;
scale_H = screen_param.line_parameters.scale_H ;
scale_W = screen_param.line_parameters.scale_W;
anchor_lms = screen_param.line_parameters.anchor_lms;

bgcolor = screen_param.color_values.bgcolor;
orange = screen_param.color_values.orange;
red = screen_param.color_values.red;
white = screen_param.color_values.white;   

ip = expt_param.ip;
port = expt_param.port;

%% Saving cue type 
data.dat.cue_type(trial_num) = shuffled_cue;

%% Random generation for stimulus parameters and jittering
rng('shuffle')
jitter_index_rand = rand();
intensity_index_rand = rand();

if jitter_index_rand < 0.333
    jitter_index = 1;
elseif jitter_index_rand < 0.666
    jitter_index = 2;
else
    jitter_index = 3;
end


%% Wait secs parameters
first_jitter = [3,4,5];
second_jitter = [5,4,3];
iti1 = 1;
iti2 = 3;

wait_after_iti = iti1; % iti: 4 (1+3) sec
wait_after_belief_rating = 4.5; % belief rating: 4.5 sec
wait_after_first_jitter = wait_after_belief_rating + first_jitter(jitter_index); % 1st jitter: 3,4,5 sec
wait_after_cue = wait_after_first_jitter + 2; % cue: 2 sec
wait_after_delay = wait_after_cue + 5; % delay: 5 sec
wait_after_stimulus = wait_after_delay + 8; % stimulus: 8 sec
wait_after_second_jitter = wait_after_stimulus + second_jitter(jitter_index); % 2nd jitter: 3,4,5 sec
wait_after_heat_rating = wait_after_second_jitter + 4.5; % heat rating: 4.5 sec
total_trial_time = wait_after_heat_rating + iti2;


%% Adjusting between trial time
if trial_num > 1
    waitsec_fromstarttime(data.dat.trial_endtime(trial_num-1), wait_after_iti)
else
    waitsec_fromstarttime(data.dat.run_starttime(trial_num), wait_after_iti)
end


%% Checking trial start time
data.dat.trial_starttime(trial_num) = GetSecs;
data.dat.between_run_trial_starttime(trial_num) = data.dat.trial_starttime(trial_num) - data.dat.run_starttime(1);


%% Data recording
Screen(theWindow, 'FillRect', bgcolor, window_rect);

data.dat.jitter_value = {first_jitter second_jitter};
data.dat.iti_value = iti1 + iti2;
data.dat.jitter_index(trial_num) = jitter_index;

%% (1) Cue Belief rating
start_t = GetSecs;
data.dat.belief_rating_starttime(trial_num) = start_t;

rating_types_pls = call_ratingtypes_pls('belief');

scale = ('belief_int');
[lb, rb, start_center] = draw_scale_pls(scale, screen_param.window_info, screen_param.line_parameters, screen_param.color_values);
Screen(theWindow, 'FillRect', bgcolor, window_rect);

ratetype = strcmp(rating_types_pls.alltypes, scale);

cue_shapes = expt_param.cue_shapes;
shape_tstring=char((strcat(cue_shapes(1),": 강한 열자극","\n",cue_shapes(2),": 약한 열자극")));

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
    
    
    DrawFormattedText(theWindow, double(shape_tstring), 'center', H*(3/10), white,[],[],[],2); % match relationship
    
    DrawFormattedText(theWindow, double(rating_types_pls.prompts{ratetype}), 'center', H*(1/4), white, [], [], [], 2);
    Screen('DrawLine', theWindow, orange, x, H*(1/2)-scale_H/3, x, H*(1/2)+scale_H/3, 6); %rating bar
    Screen('Flip', theWindow);
    
    if button(1)
        while button(1)
            [~,~,button] = GetMouse(theWindow);
        end
        break
    end
    
    [~,~,keyCode] = KbCheck;
    if keyCode(KbName('q')) == 1
        abort_experiment('manual');
        break
    end
    if GetSecs - data.dat.belief_rating_starttime(trial_num) > 4.5
        break
    end
end

% saving rating result
end_t = GetSecs;

data.dat.belief_rating(trial_num) = (x-lb)/(rb-lb);
data.dat.belief_rating_endtime(trial_num) = end_t;
data.dat.belief_rating_duration(trial_num) = end_t - start_t;

Screen(theWindow, 'FillRect', bgcolor, window_rect);
Screen('Flip', theWindow);


% belief rating time adjusting
waitsec_fromstarttime(data.dat.trial_starttime(trial_num), wait_after_belief_rating)

%% (2) First Jittering

Screen(theWindow, 'FillRect', bgcolor, window_rect);
Screen('TextSize', theWindow, 60);
DrawFormattedText(theWindow, double('+'), 'center', 'center', white, [], [], [], 1.2);
Screen('Flip', theWindow);
Screen('TextSize', theWindow, fontsize);

% -------------Setting Pathway------------------
if expt_param.pathway
    main(ip,port,1, heat_param.program);     % select the program
end

waitsec_fromstarttime(data.dat.trial_starttime(trial_num), wait_after_first_jitter-2)

% -------------Ready for Pathway------------------
if expt_param.pathway
    main(ip,port,2); %ready to pre-start
end

waitsec_fromstarttime(data.dat.trial_starttime(trial_num), wait_after_first_jitter)

%% (3) Cue
start_t = GetSecs;
data.dat.cue_starttime(trial_num) = start_t;

switch shuffled_cue
    case "HighCue"
        Screen(theWindow, 'FillRect', bgcolor, window_rect);
        Screen('TextSize', theWindow, 120);
        DrawFormattedText(theWindow, double(char(expt_param.cue_shapes(1))), 'center', 'center', white, [], [], [], 1.2);
        Screen('Flip', theWindow);
        Screen('TextSize', theWindow, fontsize);
    case "LowCue"
        Screen(theWindow, 'FillRect', bgcolor, window_rect);
        Screen('TextSize', theWindow, 120);
        DrawFormattedText(theWindow, double(char(expt_param.cue_shapes(2))), 'center', 'center', white, [], [], [], 1.2);
        Screen('Flip', theWindow);
        Screen('TextSize', theWindow, fontsize);
end


% belief rating time adjusting
waitsec_fromstarttime(data.dat.trial_starttime(trial_num), wait_after_cue)

% saving rating result
end_t = GetSecs;
data.dat.cue_duration(trial_num) = end_t - start_t;

%% (4)Delay
start_t = GetSecs;
data.dat.delay_starttime(trial_num) = start_t;

Screen(theWindow, 'FillRect', bgcolor, window_rect);
Screen('TextSize', theWindow, 60);
DrawFormattedText(theWindow, double('+'), 'center', 'center', white, [], [], [], 1.2);
Screen('Flip', theWindow);
Screen('TextSize', theWindow, fontsize);

% delay time adjusting
waitsec_fromstarttime(data.dat.trial_starttime(trial_num), wait_after_delay)

% saving rating result
end_t = GetSecs;
data.dat.delay_duration(trial_num) = end_t - start_t;


%% (5) Heat stimulus
% Heat pain stimulus
if ~expt_param.pathway
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    DrawFormattedText(theWindow, double(num2str(heat_param.intensity)), 'center', 'center', white, [], [], [], 1.2);
    Screen('Flip', theWindow);
end

% ------------- start to trigger thermal stimulus------------------
if expt_param.pathway
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    Screen('TextSize', theWindow, 60);
    DrawFormattedText(theWindow, double('+'), 'center', 'center', white, [], [], [], 1.2);
    Screen('Flip', theWindow);
    Screen('TextSize', theWindow, fontsize);
    main(ip,port,2);
end

% Check stimulus time
data.dat.stimulus_time(trial_num) = GetSecs;


% stimulus time adjusting
waitsec_fromstarttime(data.dat.trial_starttime(trial_num), wait_after_stimulus)

%% (5) Second Jittering
Screen(theWindow, 'FillRect', bgcolor, window_rect);
Screen('TextSize', theWindow, 60);
DrawFormattedText(theWindow, double('+'), 'center', 'center', white, [], [], [], 1.2);
Screen('Flip', theWindow);
Screen('TextSize', theWindow, fontsize);

waitsec_fromstarttime(data.dat.trial_starttime(trial_num), wait_after_second_jitter)

Screen(theWindow, 'FillRect', bgcolor, window_rect);
Screen('Flip', theWindow);


%% (6) Heat Rating
% Setting for rating
rating_types_pls = call_ratingtypes_pls('temp_vas');

%all_start_t = GetSecs;

scale = ('overall_int_vas');
[lb, rb, start_center] = draw_scale_pls(scale, screen_param.window_info, screen_param.line_parameters, screen_param.color_values);
Screen(theWindow, 'FillRect', bgcolor, window_rect);

start_t = GetSecs;
data.dat.heat_rating_starttime(trial_num) = start_t;

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
    
    if button(1)
        while button(1)
            [~,~,button] = GetMouse(theWindow);
        end
        break
    end
    
    [~,~,keyCode] = KbCheck;
    if keyCode(KbName('q')) == 1
        abort_experiment('manual');
        break
    end
    if GetSecs - data.dat.heat_rating_starttime(trial_num) > 4.5
        break
    end
end

% saving rating result
end_t = GetSecs;

data.dat.heat_rating(trial_num) = (x-lb)/(rb-lb);
data.dat.heat_rating_endtime(trial_num) = end_t;
data.dat.heat_rating_duration(trial_num) = end_t - start_t;

Screen(theWindow, 'FillRect', bgcolor, window_rect);
Screen('Flip', theWindow);

% rating time adjusting
waitsec_fromstarttime(data.dat.trial_starttime(trial_num), wait_after_heat_rating)

%% Adjusting total trial time
Screen(theWindow, 'FillRect', bgcolor, window_rect);
Screen('TextSize', theWindow, 60);
DrawFormattedText(theWindow, double('+'), 'center', 'center', white, [], [], [], 1.2);
Screen('Flip', theWindow);
Screen('TextSize', theWindow, fontsize);

waitsec_fromstarttime(data.dat.trial_starttime(trial_num), total_trial_time)

%% saving trial end time
data.dat.trial_endtime(trial_num) = GetSecs;
data.dat.trial_duration(trial_num) = data.dat.trial_endtime(trial_num) - data.dat.trial_starttime(trial_num);

if trial_num > 1
    data.dat.between_trial_time(trial_num) = data.dat.trial_starttime(trial_num) - data.dat.trial_endtime(trial_num-1);
else
    data.dat.between_trial_time(trial_num) = 0;
end

end