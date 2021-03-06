function hbm_move_dicom_to_raw(subject_code, study_imaging_dir, run_n, varargin)
% Moving dicom file to RAW directory

% The function move dicom files to corresponding directories in raw
% folders.
% YOU SHOULD CHECK YOUR DIRECTORY STRUCTURE OF DICOM FILES BEFORE USING THIS FUNCTION.
% This function is based on the directory structure of Cocoan lab.
%
% :Usage:
% ::
%    move_dicom_to_raw(subject_code, study_imaging_dir)
%
% :Inputs:
%
% - subject_code       the subject id
%                      (e.g., subject_code = {'sub-caps001', 'sub-caps002'});
% - study_imaging_dir  the directory information for the study imaging data
%                      (e.g., study_imaging_dir = '/NAS/data/CAPS2/Imaging')
%
% - run_n              number of runs: Previously decided in Setting.
%                      Equal to length of 'func_run_nums'
%
% :Optional inputs:
%
% - 'copy'          If you want to copy dicom files instead of moving it,
%                   you can put 'copy' option to this function.
%                   Without 'copy' option, as a default, it will
%                   move dicom files from dicom directory to raw directory.
%
%
% ..
%     Author and copyright information:
%
%     Copyright (C) Jan 2019  Hongji Kim
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
% ..

task_runs = {'RUN', 'RUN', 'RUN', 'RUN', 'RUN', 'RUN', 'RUN', 'RUN'};

move_files = true;
 

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            case {'copy'}
                move_files = false;
        end
end


if ~iscell(subject_code)
    subject_codes{1} = subject_code;
else
    subject_codes = subject_code;
end

for sub_i = 1:numel(subject_codes)
    raw_dir = fullfile(study_imaging_dir, 'raw', subject_codes{1,sub_i});
    dicom_dir = fullfile(study_imaging_dir, 'dicom_from_scanner');
    dicom_dir_2 = filenames(fullfile(dicom_dir, [upper(subject_codes{1,sub_i}(5:end)) '*']), 'char'); % change this part according to your project folder names
    sub_dicom_dir = filenames(fullfile(dicom_dir_2, ['HEAD_PI_CNIR_IBS*']), 'char');
    
    % anat
    raw_anat_dir = fullfile(raw_dir, 'dicom', 'anat');
    T1_dir = filenames(fullfile(sub_dicom_dir, ['T1*']), 'char');
    if isempty(T1_dir)
        input_key = input(' *** T1 directory is empty. Want to continue anyway? (c) Want to stop? (s):', 's');
        if input_key == 's'
            error('There is no T1 directory. Please check.')
        end
    else
        if move_files == true
            movefile(T1_dir,raw_anat_dir);
        else % copy instead of move
            fprintf('\ncopying ...\nSource: %s\nDestination: %s\n', T1_dir, raw_anat_dir);
            system(['cp -r ' T1_dir ' ' raw_anat_dir]);
        end
    end
    
    % fmap
    raw_fmap_dir = fullfile(raw_dir, 'dicom', 'fmap');
    DC_dir = filenames(fullfile(sub_dicom_dir, ['DISTORTION*']), 'char');
    if isempty(DC_dir)
        input_key = input(' *** Distortion Correction directory is empty. Want to continue anyway? (c) Want to stop? (s):', 's');
        if input_key == 's'
            error('There is no Distortion Correction directory. Please check.')
        end
    else
        if size(DC_dir, 1) ==2
            for dc_i = 1:2
                if move_files == true
                    movefile(deblank(DC_dir(dc_i,1:end)), raw_fmap_dir);
                else % copy instead of move
                    fprintf('\ncopying ...\nSource: %s\nDestination: %s\n', deblank(DC_dir(dc_i,1:end)), raw_fmap_dir);
                    system(['cp -r ' deblank(DC_dir(dc_i,1:end)) ' ' raw_fmap_dir]);
                end
            end
        else
            rep_num_dc = (size(DC_dir, 1)/2);
            for dc_i = [rep_num_dc*1, rep_num_dc*2]
                if move_files == true
                    movefile(deblank(DC_dir(dc_i,1:end)), raw_fmap_dir)
                else
                    fprintf('\ncopying ...\nSource: %s\nDestination: %s\n', deblank(DC_dir(dc_i,1:end)), raw_fmap_dir);
                    system(['cp -r ' deblank(DC_dir(dc_i,1:end)) ' ' raw_fmap_dir]);
                end
            end
        end
    end
    
    % task run
    for run_i = 1:run_n
        raw_run_dir = filenames(fullfile(raw_dir, 'dicom', ['*' num2str(run_i, '%02d') '*']), 'char');
        
        task_run = task_runs{run_i};
        if task_run == "RUN" % RUN 1~8
            dicom_run_dir = filenames(fullfile(sub_dicom_dir, [task_run '0' num2str(run_i) '*']), 'char');       
        end
        
        if size(dicom_run_dir, 1) == 2
            for mb_i = 1:2
                if move_files == true
                    cd(deblank(raw_run_dir(mb_i,:)));
                    movefile(deblank(dicom_run_dir(mb_i,1:end)));
                else % copy instead of move
                    fprintf('\ncopying ...\nSource: %s\nDestination: %s\n', dicom_run_dir(mb_i,:), raw_run_dir(mb_i,:));
                    system(['cp -r ' dicom_run_dir(mb_i,:) ' ' raw_run_dir(mb_i,:)]);
                end
            end
        else % when you restarted the run
            rep_num = (size(dicom_run_dir, 1)/2);
            for mb_i = [rep_num*1, rep_num*2]
                if move_files == true
                    cd(deblank(raw_run_dir(mb_i/rep_num,:)));
                    movefile(deblank(dicom_run_dir(mb_i,1:end)));
                else % copy instead of move
                    fprintf('\ncopying ...\nSource: %s\nDestination: %s\n', dicom_run_dir(mb_i,:), raw_run_dir(mb_i/rep_num,:));
                    system(['cp -r ' dicom_run_dir(mb_i,:) ' ' raw_run_dir(mb_i/rep_num,:)]);
                end
            end
        end
    end
    disp([subject_codes{1,sub_i} ': DONE']);
end

end