function [lb, rb, start_center] = draw_scale_pls(scale, window_info, line_parameters, color_values)

font = window_info.font ;
fontsize = window_info.fontsize;
theWindow = window_info.theWindow;
window_num = window_info.window_num ;
window_rect = window_info.window_rect;
H = window_info.H ;
W = window_info.W;

lb1 = line_parameters.lb1 ;
lb2 = line_parameters.lb2 ;
rb1 = line_parameters.rb1;
rb2 = line_parameters.rb2;
scale_H = line_parameters.scale_H ;
scale_W = line_parameters.scale_W;
anchor_lms = line_parameters.anchor_lms;

bgcolor = color_values.bgcolor;
orange = color_values.orange;
red = color_values.red;
white = color_values.white;   

%% Basic Settings
start_center = true;
lb = lb2;
rb = rb2;
bar_space = rb - lb;

%% Drawing scale
switch scale
    case 'belief_int'  % one-directional
        %start_center = false;
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('0%'), lb-scale_H/2, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('50%'), W/2-scale_H/2, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('100%'), rb-scale_H/2, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
       
    case 'cont_glms'
        lb = lb1; % rating scale left bounds 1/6
        rb = rb1; % rating scale right bounds 5/6
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('상상할 수 있는\n가장 강한 불쾌'), lb-scale_H-10, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('상상할 수 있는\n가장 강한 유쾌'), rb-scale_H-10, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);
        
    case 'overall_glms'
        lb = lb1; % rating scale left bounds 1/6
        rb = rb1; % rating scale right bounds 5/6
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('상상할 수 있는\n가장 강한 불쾌'), lb-scale_H-10, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('상상할 수 있는\n가장 강한 유쾌'), rb-scale_H-10, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);
        
    case 'overall_int'  % one-directional
        start_center = false;
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
%         DrawFormattedText(theWindow, double('전혀 느껴지지\n      않음'), lb-scale_H/0.8, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        DrawFormattedText(theWindow, double(''), lb-scale_H/0.8, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);

        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);
%         DrawFormattedText(theWindow, double('상상할 수 있는\n가장 강한 통증'), rb-scale_H/0.7, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        DrawFormattedText(theWindow, double(''), rb-scale_H/0.7, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
    case 'overall_int_vas'  % one-directional
        start_center = false;
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
%         DrawFormattedText(theWindow, double('전혀 느껴지지\n      않음'), lb-scale_H/0.8, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        %DrawFormattedText(theWindow, double('0'), H*(1/2)-scale_H/3, H*(1/2)+scale_H/0.8, white,[],[],[],1.2);
        DrawFormattedText(theWindow, double('0'), lb-scale_H/2, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        
        Screen('DrawLine', theWindow, white, lb+bar_space*0.5, H*(1/2)-scale_H/3, lb+bar_space*0.5, H*(1/2)+scale_H/3, 6); % score 5 bar
        Screen('DrawLine', theWindow, white, lb+bar_space*0.1, H*(1/2)-scale_H/3, lb+bar_space*0.1, H*(1/2)+scale_H/3, 6);
        Screen('DrawLine', theWindow, white, lb+bar_space*0.2, H*(1/2)-scale_H/3, lb+bar_space*0.2, H*(1/2)+scale_H/3, 6);
        Screen('DrawLine', theWindow, white, lb+bar_space*0.3, H*(1/2)-scale_H/3, lb+bar_space*0.3, H*(1/2)+scale_H/3, 6);
        Screen('DrawLine', theWindow, white, lb+bar_space*0.4, H*(1/2)-scale_H/3, lb+bar_space*0.4, H*(1/2)+scale_H/3, 6);
        Screen('DrawLine', theWindow, white, lb+bar_space*0.6, H*(1/2)-scale_H/3, lb+bar_space*0.6, H*(1/2)+scale_H/3, 6);
        Screen('DrawLine', theWindow, white, lb+bar_space*0.7, H*(1/2)-scale_H/3, lb+bar_space*0.7, H*(1/2)+scale_H/3, 6);
        Screen('DrawLine', theWindow, white, lb+bar_space*0.8, H*(1/2)-scale_H/3, lb+bar_space*0.8, H*(1/2)+scale_H/3, 6);
        Screen('DrawLine', theWindow, white, lb+bar_space*0.9, H*(1/2)-scale_H/3, lb+bar_space*0.9, H*(1/2)+scale_H/3, 6);

        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);
%         DrawFormattedText(theWindow, double('상상할 수 있는\n가장 강한 통증'), rb-scale_H/0.7, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        %DrawFormattedText(theWindow, double('10'), rb-scale_H/0.7, H*(1/2)+scale_H/0.8, white,[],[],[],1.2);
        DrawFormattedText(theWindow, double('10'), rb-scale_H/2, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);

    case 'resting_int'  % one-directional
        start_center = false;
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double(''), lb-scale_H/0.8, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double(''), rb-scale_H/0.7, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        
    case 'general_sensitivity'  % one-directional
        start_center = false;
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('느낄 수\n  없음'), lb-scale_H/2, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('      상상할 수 있는\n가장 강한 정도의 자극'), rb-scale_H/0.7, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        
    case 'overall_boredness'
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('전혀 지겹지\n     않음'), lb-scale_H/1.3, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('매우 지겨움'), rb-scale_H/1.5  , H*(1/2)+scale_H/1.2, white);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);
        
    case 'overall_alertness'
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('매우 졸림'), lb-scale_H/1.4, H*(1/2)+scale_H/1.2, white);
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('보통'), W/2-scale_W/5, H*(1/2)+scale_H/1.2, white);
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('매우 또렷'), rb-scale_H/1.4, H*(1/2)+scale_H/1.2, white);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);
        
    case 'overall_relaxed'
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('매우 불편함'), lb-scale_H/1.3, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('보통'), W/2-scale_W/5, H*(1/2)+scale_H/1.2, white);
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('매우 편함'), rb-scale_H/1.4, H*(1/2)+scale_H/1.2, white);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);
        
    case 'overall_attention'
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('전혀 집중되지\n      않음'), lb-scale_H/0.9, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('보통'), W/2-scale_W/5, H*(1/2)+scale_H/1.2, white);
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('매우 집중\n   잘 됨'), rb-scale_H/1.4, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);
        
    case 'overall_resting_valence'
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double(' 부정'), lb-scale_H/1.3, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('중립'), W/2-scale_W/5, H*(1/2)+scale_H/1.2, white);
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double(' 긍정'), rb-scale_H/1.4, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);  
        
    case 'overall_resting_self'
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('관련없음'), lb-scale_H/1.3, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('관련있음'), rb-scale_H/1.5, H*(1/2)+scale_H/1.2, white);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);
        
    case 'overall_resting_vivid'
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double(' 전혀'), lb-scale_H/1.3, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double(' 생생'), rb-scale_H/1.5, H*(1/2)+scale_H/1.2, white);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);     
          
    case 'overall_resting_time'
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double(' 과거'), lb-scale_H/1.3, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('현재'), W/2-scale_W/5, H*(1/2)+scale_H/1.2, white);
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double(' 미래'), rb-scale_H/1.4, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6); 
        
    case 'overall_resting_safethreat'
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('위협적'), lb-scale_H/1.3, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('중립'), W/2-scale_W/5, H*(1/2)+scale_H/1.2, white);
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double(' 안전'), rb-scale_H/1.4, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);             
        
        
    case 'overall_resting_positive'
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('전혀 그렇지\n     않다'), lb-scale_H/1.3, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('매우 그렇다'), rb-scale_H/1.5, H*(1/2)+scale_H/1.2, white);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);        
        
    case 'overall_resting_negative'
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('전혀 그렇지\n     않다'), lb-scale_H/1.3, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('매우 그렇다'), rb-scale_H/1.5, H*(1/2)+scale_H/1.2, white);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);
        
    case 'overall_resting_myself'
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('전혀 그렇지\n     않다'), lb-scale_H/1.3, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('매우 그렇다'), rb-scale_H/1.5, H*(1/2)+scale_H/1.2, white);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);
        
    case 'overall_resting_others'
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('전혀 그렇지\n     않다'), lb-scale_H/1.3, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('매우 그렇다'), rb-scale_H/1.5, H*(1/2)+scale_H/1.2, white);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);
        
    case 'overall_resting_imagery'
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('전혀 그렇지\n     않다'), lb-scale_H/1.3, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('매우 그렇다'), rb-scale_H/1.5, H*(1/2)+scale_H/1.2, white);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);
        
    case 'overall_resting_present'
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('전혀 그렇지\n     않다'), lb-scale_H/1.3, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('매우 그렇다'), rb-scale_H/1.5, H*(1/2)+scale_H/1.2, white);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);
        
    case 'overall_resting_past'
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('전혀 그렇지\n     않다'), lb-scale_H/1.3, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('매우 그렇다'), rb-scale_H/1.5, H*(1/2)+scale_H/1.2, white);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);
        
    case 'overall_resting_future'
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('전혀 그렇지\n     않다'), lb-scale_H/1.3, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('매우 그렇다'), rb-scale_H/1.5, H*(1/2)+scale_H/1.2, white);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);
        
    case 'overall_resting_bitter_int'  % one-directional
        start_center = false;
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('전혀 느껴지지\n             않음'), lb-scale_H*2+5, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('상상할 수 있는\n가장 강한 자극'), rb-scale_H/0.9, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        
    case 'overall_resting_bitter_glms'
        lb = lb1;
        rb = rb1;
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('상상할 수 있는\n가장 강한 불쾌'), lb-scale_H-10, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('상상할 수 있는\n가장 강한 유쾌'), rb-scale_H-10, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);
        
    case 'overall_resting_capsai_int'  % one-directional
        start_center = false;
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('전혀 느껴지지\n             않음'), lb-scale_H*2+5, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('상상할 수 있는\n가장 강한 자극'), rb-scale_H/0.9, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        
    case 'overall_resting_capsai_glms'
        lb = lb1;
        rb = rb1;
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('상상할 수 있는\n가장 강한 불쾌'), lb-scale_H-10, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('상상할 수 있는\n가장 강한 유쾌'), rb-scale_H-10, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);
        
    case 'overall_resting_sweet_int'  % one-directional
        start_center = false;
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('전혀 느껴지지\n             않음'), lb-scale_H*2+5, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('상상할 수 있는\n가장 강한 자극'), rb-scale_H/0.9, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        
    case 'overall_resting_sweet_glms'
        lb = lb1;
        rb = rb1;
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('상상할 수 있는\n가장 강한 불쾌'), lb-scale_H-10, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('상상할 수 있는\n가장 강한 유쾌'), rb-scale_H-10, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);
        
    case 'overall_resting_touch_int'  % one-directional
        start_center = false;
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('전혀 느껴지지\n             않음'), lb-scale_H*2+5, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('상상할 수 있는\n가장 강한 자극'), rb-scale_H/0.9, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        
    case 'overall_resting_touch_glms'
        lb = lb1;
        rb = rb1;
        Screen('DrawLine', theWindow, white, lb, H*(1/2), rb, H*(1/2), 4); % penWidth: 0.125~7.000
        Screen('DrawLine', theWindow, white, W/2, H*(1/2)-scale_H/3, W/2, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('상상할 수 있는\n가장 강한 불쾌'), lb-scale_H-10, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, lb, H*(1/2)-scale_H/3, lb, H*(1/2)+scale_H/3, 6);
        DrawFormattedText(theWindow, double('상상할 수 있는\n가장 강한 유쾌'), rb-scale_H-10, H*(1/2)+scale_H/1.2, white,[],[],[],1.2);
        Screen('DrawLine', theWindow, white, rb, H*(1/2)-scale_H/3, rb, H*(1/2)+scale_H/3, 6);
        
end

end