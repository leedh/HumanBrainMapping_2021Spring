function [data]= data_save(expt_param, basedir)

    % data
    
    savedir = fullfile(basedir, 'Data');

    nowtime = clock;
    SubjDate = sprintf('%.2d%.2d%.2d', nowtime(1), nowtime(2), nowtime(3));

    data.run_name = expt_param.run_name;
    data.datafile = fullfile(savedir, [SubjDate, '_', expt_param.subjectID, '_', expt_param.run_name, sprintf('%.3d', expt_param.run_num), '_HBM', '.mat']);
    data.version = 'HBM-05-11-2021';  % month-date-year
    data.starttime = datestr(clock, 0);
    data.dat.experiment_start_time = GetSecs;
    
    % if the same file exists, break and retype subject info
    if exist(data.datafile, 'file')
        fprintf('\n ** EXSITING FILE: %s %s **', expt_param.run_num, SubjDate);
        cont_or_not = input(['\nThe typed Run name and number are already saved.', ...
            '\nWill you go on with your Run name and number that saved before?', ...
            '\n1: Yes, continue with Run name and number.  ,   2: No, it`s a mistake. I`ll break.\n:  ']);
        if cont_or_not == 2
            error('Breaked.')
        elseif cont_or_not == 1
            save(data.datafile, 'data');
        end
    else
        save(data.datafile, 'data');
    end

end