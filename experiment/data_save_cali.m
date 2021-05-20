function [cali_param]= data_save_cali(cali_param, basedir)
    % data
    
    savedir = fullfile(basedir, 'Data/calibration');
    
    if ~exist(savedir, 'dir')
        mkdir(savedir);
    else

    nowtime = clock;
    SubjDate = sprintf('%.2d%.2d%.2d', nowtime(1), nowtime(2), nowtime(3));

    cali_param.datafile = fullfile(savedir, [SubjDate, '_', cali_param.subject, '_HBM', '.mat']);
    cali_param.version = 'HBM-05-11-2021';  % month-date-year
    cali_param.starttime = datestr(clock, 0);
    cali_param.cali_start_time = GetSecs; 
    
    % if the same file exists, break and retype subject info
    if exist(cali_param.datafile, 'file')
        fprintf('\n ** EXSITING FILE: %s %s **', cali_param.subject, SubjDate);
        cont_or_not = input(['\nThe typed subject are already saved.', ...
            '\nWill you go on with the subject file that saved before?', ...
            '\n1: Yes, continue with new file.  ,   2: No, it`s a mistake. I`ll break.\n:  ']);
        if cont_or_not == 2
            error('Breaked.')
        elseif cont_or_not == 1
            save(cali_param.datafile, 'cali_param');
        end
    else
        save(cali_param.datafile, 'cali_param');
    end

end


