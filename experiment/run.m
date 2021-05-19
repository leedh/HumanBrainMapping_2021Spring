function [data] = run(screen_param, expt_param, data)  
%% Assign variables
global theWindow 
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

if numel(expt_param.heat_intensity_table) == 3
    HighPain = max(expt_param.heat_intensity_table);
    LowPain = min(expt_param.heat_intensity_table);
    MidPain = expt_param.heat_intensity_table(LowPain < expt_param.heat_intensity_table & expt_param.heat_intensity_table < HighPain);
else
    error('Value error : the number of values in "expt_param.heat_intensity_table" has to be 3.. \nNow it is %d.',numel(expt_param.heat_intensity_table))
end

cue_types = expt_param.cue_types;
%run_type = expt_param.run_type;

condition_nums = expt_param.condition_nums;
trial_nums_per_condition = expt_param.trial_nums_per_condition;
trial_nums = condition_nums * trial_nums_per_condition;
midpain_per_condition = expt_param.midpain_per_condition;

% Keyboard input setting
if expt_param.dofmri
    device(1).product = 'Apple Keyboard';
    device(1).vendorID= 1452;
    apple = IDkeyboards(device(1));
end 

%% Ready for start run
while true
    msgtxt = '\n모두 준비되었으면, a를 눌러주세요.';
    DrawFormattedText(theWindow, double(msgtxt), 'center', 'center', white, [], [], [], 2);
    Screen('Flip', theWindow);
    
    if expt_param.dofmri
        [~,~,keyCode] = KbCheck(apple);
    else
        [~,~,keyCode] = KbCheck(-1);
    end
    
    if keyCode(KbName('a')) == 1
        break
    elseif keyCode(KbName('q')) == 1
        abort_experiment('manual');
        break
    end
end


% ===== Scanner trigger setting
if expt_param.dofmri
    device(2).product = 'KeyWarrior8 Flex';
    device(2).vendorID= 1984;
    scanner = IDkeyboards(device(2));
end

%% Waitting for 's' or 't' key
while true
    msgtxt = '\n스캔(s) \n\n 테스트(t)';
    DrawFormattedText(theWindow, double(msgtxt), 'center', 'center', white, [], [], [], 2);
    Screen('Flip', theWindow);
    
    if expt_param.dofmri
        [~,~,keyCode] = KbCheck(scanner);
        [~,~,keyCode2] = KbCheck(apple);
    else
        [~,~,keyCode] = KbCheck;
    end
    % If it is for fMRI experiment, it will start with "s",
    % But if it is test time, it will start with "t" key.
    if expt_param.dofmri
        if keyCode(KbName('s'))==1
            break
        elseif keyCode2(KbName('q'))==1
            abort_experiment;
        end
    else
        if keyCode(KbName('t'))==1
            break
        elseif keyCode(KbName('q'))==1
            abort_experiment;
        end
    end
end


%% fMRI starts
data.dat.fmri_start_time = GetSecs;
if expt_param.dofmri
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    DrawFormattedText(theWindow, double('스캔이 시작됩니다.'), 'center', 'center', white, [], [], [], 1.2);
    Screen('Flip', theWindow);
    waitsec_fromstarttime(data.dat.fmri_start_time, 5);
else
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    DrawFormattedText(theWindow, double('테스트 스캔이 시작됩니다.'), 'center', 'center', white, [], [], [], 1.2);
    Screen('Flip', theWindow);
    waitsec_fromstarttime(data.dat.fmri_start_time, 5);
end


%% Making shuffled Heat intensity list and cue type list
% quotient = fix(expt_param.trial_nums/length(expt_param.heat_intensity_table));
% remainder = mod(expt_param.trial_nums, length(expt_param.heat_intensity_table));

%Error handling
% if not(remainder==0)
%     error('Value error! \nmod(Trial_nums, length(expt_param.heat_intensity_table)) have to be 0 which is now mod(%d, %d)=%d', ...
%     expt_param.Trial_nums, length(expt_param.heat_intensity_table), remainder);
% end
% 
% if not(mod(quotient, 2)==0)
%     error('Value error! \nmod(fix(Trial_nums/length(expt_param.heat_intensity_table)),2) have to be 0 which is now mod(%d, 2) = %d', ...
%         quotient, mod(quotient, 2));
% end


% creat heat program list
heat_program_table = [];
for i = 1:condition_nums
    heat_program_table = [heat_program_table repmat(MidPain,1,midpain_per_condition)];
    for j = 1:(trial_nums_per_condition-midpain_per_condition)/2
        heat_program_table = [heat_program_table HighPain];
        heat_program_table = [heat_program_table LowPain];
    end
end



% creat cue type list
if ~(cue_types(1) == "HighCue" || cue_types(2) == "LowCue")
    error('Value error : "cue_types" is wrong. Please check!')
end

% 
% High_Certainty = [repmat(cue_types(1),1,8) repmat(cue_types(2),1,2)];
% Middle_Certainty = [repmat(cue_types(1),1,5) repmat(cue_types(2),1,5)];
% Low_Certainty = [repmat(cue_types(1),1,2) repmat(cue_types(2),1,8)];

condition_list = ["High_Certainty" "Middle_Certainty" "Low_Certainty"];
% switch run_type
%     case 'Plus_High_Certainty'
%         condition_list = [condition_list "High_Certainty"];
%     case 'Plus_Middle_Certainty'
%         condition_list = [condition_list "Middle_Certainty"];
%     case 'Plus_Low_Certainty'
%         condition_list = [condition_list "Low_Certainty"];
% end

% shuffle condition order
rng('shuffle')
arr = 1:condition_nums;
sample_index = datasample(arr, length(arr), 'Replace',false);
condition_list = condition_list(sample_index);



cue_list = strings(1,trial_nums);
for i=1:condition_nums
    heat_program_condition = heat_program_table((i-1)*10+1:i*10);
    cue_list_condition = cue_list((i-1)*10+1:i*10);
    
    switch condition_list(i)
        case "High_Certainty"
            for j=1:numel(heat_program_condition)
                if j == 1
                    cue_list_condition(j) = "HighCue";
                elseif j == 2
                    cue_list_condition(j) = "LowCue";
                else
                    rng('shuffle')
                    prob=rand();
                    if prob >= 0.2 % match 80%
                        if heat_program_condition(j) == HighPain
                            cue_list_condition(j) = "HighCue";
                        else
                            cue_list_condition(j) = "LowCue";
                        end
                    else % mismatch 20%
                        if heat_program_condition(j) == HighPain
                            cue_list_condition(j) = "LowCue";
                        else
                            cue_list_condition(j) = "HighCue";
                        end
                    end
                end
            end
        case "Middle_Certainty"
            for j=1:numel(heat_program_condition)
                if j == 1
                    cue_list_condition(j) = "HighCue";
                elseif j == 2
                    cue_list_condition(j) = "LowCue";
                else
                    rng('shuffle')
                    prob=rand();
                    if prob >= 0.5 % match 50%
                        if heat_program_condition(j) == HighPain
                            cue_list_condition(j) = "HighCue";
                        else
                            cue_list_condition(j) = "LowCue";
                        end
                    else % mismatch 50%
                        if heat_program_condition(j) == HighPain
                            cue_list_condition(j) = "LowCue";
                        else
                            cue_list_condition(j) = "HighCue";
                        end
                    end
                end
            end
        case "Low_Certainty"
            for j=1:numel(heat_program_condition)
                if j == 1
                    cue_list_condition(j) = "HighCue";
                elseif j == 2
                    cue_list_condition(j) = "LowCue";
                else
                    rng('shuffle')
                    prob=rand();
                    if prob >= 0.8 % match 20%
                        if heat_program_condition(j) == HighPain
                            cue_list_condition(j) = "HighCue";
                        else
                            cue_list_condition(j) = "LowCue";
                        end
                    else % mismatch 80%
                        if heat_program_condition(j) == HighPain
                            cue_list_condition(j) = "LowCue";
                        else
                            cue_list_condition(j) = "HighCue";
                        end
                    end
                end
            end
    end
    cue_list((i-1)*10+1:i*10) = cue_list_condition;
end


% shuffle heat and cue order in a condition
shuffled_heat_list = [];
shuffled_cue_list = [];

for i = 1:condition_nums
    rng('shuffle')
    arr = 1:trial_nums_per_condition;
    sample_index = datasample(arr, length(arr), 'Replace',false);
    
    heat_program_table_condition = heat_program_table((i-1)*10+1:i*10);
    cue_list_condition = cue_list((i-1)*10+1:i*10);
    
    shuffled_heat_list = [shuffled_heat_list heat_program_table_condition(sample_index)];
    shuffled_cue_list = [shuffled_cue_list cue_list_condition(sample_index)];
end


% Making pathway program list
PathPrg = load_PathProgram('HBM2021');

for i = 1:length(shuffled_heat_list)
    index = find([PathPrg{:,1}] == shuffled_heat_list(i));
    heat_param(i).program = PathPrg{index, 4};
    heat_param(i).intensity = shuffled_heat_list(i);
end

data.dat.heat_param = heat_param;
%data.dat.cue_list = shuffled_cue_list;

%% Adjusting time from fmri started.
Screen(theWindow, 'FillRect', bgcolor, window_rect);
Screen('TextSize', theWindow, 60);
DrawFormattedText(theWindow, double('+'), 'center', 'center', white, [], [], [], 1.2);
Screen('Flip', theWindow);
Screen('TextSize', theWindow, fontsize);

[~,~,keyCode] = KbCheck;
if keyCode(KbName('q')) == 1
    abort_experiment('manual');
end


%% Wating 13 seconds from fmri started
waitsec_fromstarttime(data.dat.fmri_start_time, 13);


%% Saving Run start time
data.dat.run_starttime = GetSecs;
data.dat.between_fmri_run_start_time = data.dat.run_starttime - data.dat.fmri_start_time;


%% Run start
for trial_num = 1:trial_nums
    data = trial_heat(screen_param, expt_param, trial_num, data, heat_param(trial_num), shuffled_cue_list(trial_num));
end
    
     
% else % Resting Run
%     data = MPC_trial_resting(screen_param, expt_param, data);
% end



%% Saving Data
data.dat.run_end_time = GetSecs;
data.dat.run_duration_time = data.dat.run_end_time - data.dat.fmri_start_time;

save(data.datafile, 'data', '-append');

end