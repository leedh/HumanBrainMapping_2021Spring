clear;
clc
%% Setting parameters
basedir = '/media/das/HBM_2021spring/';
betadir = fullfile(basedir, 'result/first_level/iti/cocoan_prep_ica_nonaggr');

search_templete = 'sub-hbm%03d';
sub_list = [1 2];


%% Change Beta.nii filename to SPM xX name
for sub = sub_list
    p = fullfile(betadir, sprintf(search_templete, sub));
    sub_folder = filenames(p,'char');
   
    if isempty(sub_folder)
       fprintf("###########There is no folder %s###########\n", p) 
       continue
    end
    
    betafiles = filenames(fullfile(sub_folder, 'beta*.nii'));
    if isempty(betafiles)
        fprintf("###########There is no beta file %s###########\n", p)
        continue
    end
    
    p = fullfile(sub_folder, 'SPM.mat');
    spm_path = filenames(p, 'char');
    if isempty(spm_path)
        fprintf("###########There is no SPM file %s###########\n", p)
       continue
    end
    
    load(spm_path)
    for i = 1:numel(betafiles)
        beta = betafiles{i};
        betanum = regexp(basename(beta), '\d*', 'match');
        betanum = str2num(char(betanum));
        
        xXname = SPM.xX.name(betanum);
        s = split(xXname,' ');
        s = s(contains(s, 'sub'));
        s = split(s, '*');
        s = s(contains(s, 'sub'));
        
        if numel(s)>1
            fprintf("###########Please Check SPM xX name: %s###########\n", char(xXname))
            continue
        end
        
        savename = [char(s) '.nii'];
        [filepath, ~, ~] = fileparts(beta);
        savepath = fullfile(filepath, savename);
        movefile(beta, savepath)
        
        fprintf("####################################################\n")
        fprintf("FROM:%s \n TO:%s\n", beta, savepath)
        fprintf("####################################################\n")
    end
end