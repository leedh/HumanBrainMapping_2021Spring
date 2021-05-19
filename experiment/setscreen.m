function screen_param = setscreen(expt_param)

    screens = Screen('Screens');
    window_num = screens(end);
    Screen('Preference', 'SkipSyncTests', 1); % when a monitor isn't that good.. ex. LCD
    window_info = Screen('Resolution', window_num);
    
    switch expt_param.screen_mode
        case 'Full'
            window_rect = [0 0 window_info.width window_info.height]; % full screen
            %window_rect = [0 0 1440 900]; % full screen
            %window_rect = [0 0 window_info.width/2 window_info.height/2]; % full screen
            fontsize = 32;
            HideCursor;
        case 'Test'
            window_rect = [0 0 600 300];  % 1920 1080; full screen for window
            fontsize = 20;
    end
    
    % size
    W = window_rect(3); % width
    H = window_rect(4); % height
    
    lb1 = W*(1/6); % rating scale left bounds 1/6
    rb1 = W*(5/6); % rating scale right bounds 5/6
    lb2 = W*(1/4); % rating scale left bounds 1/4
    rb2 = W*(3/4); % rating scale right bounds 3/4
    
    scale_W = W*0.1;
    scale_H = H*0.1;
    
    anchor_lms = [W/2-0.014*(W/2-lb1) W/2-0.061*(W/2-lb1) W/2-0.172*(W/2-lb1) W/2-0.354*(W/2-lb1) W/2-0.533*(W/2-lb1);
        W/2+0.014*(W/2-lb1) W/2+0.061*(W/2-lb1) W/2+0.172*(W/2-lb1) W/2+0.354*(W/2-lb1) W/2+0.533*(W/2-lb1)];
    %W/2-lb1 = rb1-W/2
    
    % color
    % Grayscale colors can be specified using a single number
    bgcolor = 50; % background color 
    white = 255; 
    black = 0;
    red = [255 051 051];
    orange = [255 164 0];
    
    % font
    font = 'NanumBarunGothic';
    Screen('Preference', 'TextEncodingLocale', 'ko_KR.UTF-8');
    
    
    theWindow = Screen('OpenWindow', window_num, bgcolor, window_rect); % start the screen
    Screen('TextFont', theWindow, font);
    Screen('TextSize', theWindow, fontsize);
    
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    Screen('Flip', theWindow);
    
    
    %Making dictionary for return variables
    screen_param.window_info = struct('W',W, 'H',H, 'window_num',window_num, 'window_rect',window_rect, 'theWindow',theWindow, 'fontsize',fontsize, 'font',font);
    screen_param.line_parameters = struct('lb1',lb1, 'rb1',rb1, 'lb2',lb2, 'rb2',rb2, 'scale_W',scale_W, 'scale_H',scale_H, 'anchor_lms',anchor_lms);
    screen_param.color_values = struct('bgcolor',bgcolor, 'white',white, 'orange',orange, 'red',red);
        
end