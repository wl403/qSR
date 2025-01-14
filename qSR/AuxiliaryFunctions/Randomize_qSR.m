function Randomize_qSR(directory)

% Randomizes the order of data presented to qSR and displayes a
% corresponding average intensity projection image to aid in identifying
% features in the pointillist image. 

% Makes the following assumptions about the structure of the data. 
%    directory/ExperimentalCondition/cell##*{PALM|488}*/cell##*{PALM|488}*{.ome.tif|results.mat}
%
%    The reference is hardcoded to refer to the 488 channel using in
%    dendra2 preconversion imaging. This can be adjusted by changing the
%    dir_rec call in the section "Find all 488 and PALM images". 
%
%    The super-resolution data is hard-coded to refer to outputs from MTT.
%    This can be adjusted by changing the
%    dir_rec call in the section "Find all 488 and PALM images" to search
%    for a supported super-resolution file format.
%    
%    Each PALM and 488 data set are contained within a folder of the same
%    name, which is contained within a folder labeling the experimental
%    conditions. 
%
%    Within each experimental condition, each roi should be
%    named with a cell#_{condition} where the imaging mode is labeled in
%    condition (PALM for superres, and 488 for the reference file) and #
%    uniquely refers to to specific regions of interest. 
%
%    For example:
%    directory/Dish1_starved/cell1_PALM/cell1_PALM_results.mat
%    directory/100nM_dye/cell9_488/cell8_488.ome.tif


current_directory = pwd;
cd(directory)

%% Find all 488 and PALM images

    PALM_files = dir_rec('*PALM*_results.mat');
    pre_files = dir_rec('*488*.ome.tif');

%% Link the 488 and PALM images


    folder_id_pre = zeros(1,length(pre_files));
    cell_id_pre = zeros(1,length(pre_files));
    
    folder_id_PALM = zeros(1,length(PALM_files));
    cell_id_PALM = zeros(1,length(PALM_files));
    
    folder_dictionary = {}; %Records the names of every experiment folder.

    current_file_struct = dir(pre_files{1});
    current_folder = current_file_struct.folder;

    filesep_locs = strfind(current_folder,filesep);
    current_folder = current_folder(1:filesep_locs(end));

    folder_dictionary{1} = current_folder;

    % Determine which experiment and which cell number within the
    % experiment the file belongs to. 
    for i = 1:length(pre_files)
        current_file_struct = dir(pre_files{i});
        current_folder = current_file_struct.folder;
        filesep_locs = strfind(current_folder,filesep);
        current_folder = current_folder(1:filesep_locs(end));
        for j = 1:length(folder_dictionary)
            if strcmp(folder_dictionary{j},current_folder)
                folder_id_pre(i) = j;
                break
            elseif j == length(folder_dictionary)
                folder_id_pre(i) = j+1;
                folder_dictionary{end+1} = current_folder;
            end
        end
        
        [cell_id_pre(i),~] = ParseMTTFileName(pre_files{i});
        
    end
    
    for i = 1:length(PALM_files)
        current_file_struct = dir(PALM_files{i});
        current_folder = current_file_struct.folder;
        filesep_locs = strfind(current_folder,filesep);
        current_folder = current_folder(1:filesep_locs(end));
        for j = 1:length(folder_dictionary)
            if strcmp(folder_dictionary{j},current_folder)
                folder_id_PALM(i) = j;
                break
            elseif j == length(folder_dictionary)
                folder_id_PALM(i) = j+1;
                folder_dictionary{end+1} = current_folder;
            end
        end
        
        [cell_id_PALM(i),~] = ParseMTTFileName(PALM_files{i});
        
    end

%% Randomize the order

    random_order = randperm(numel(PALM_files));

%% Call qSR sequentially on the PALM images while opening the corresponding 488. 
    
    for i = 1:numel(PALM_files)
        % Create a popup with a "Continue" button that lets you advance to the
        % next cell. 
        f1 = figure;
        h = uicontrol('Position',[20 20 200 40],'String','Continue',...
                      'Callback','uiresume(gcbf)');
        
        current_file_id = folder_id_PALM(random_order(i));
        current_cell_id = cell_id_PALM(random_order(i));
        
        is_corresponding = and(folder_id_pre == current_file_id     ,   cell_id_pre == current_cell_id) ; 
        
        file_info = dir(PALM_files{i});
        
        if isdir([file_info.folder,filesep,'qSR_Analysis_Output'])
            box1 = msgbox('qSR Analysis Output already exists.');
        end
        
        switch sum(is_corresponding)
            case 1
                %Create an average projection 488 image.
                current_488_file = pre_files{is_corresponding};
                number_of_frames = numel(imfinfo(current_488_file));
                current_frame = imread(current_488_file,1);
                mean_image = zeros(size(current_frame));
                for j = 1:number_of_frames
                    current_frame = double(imread(current_488_file,j));
                    mean_image = mean_image + current_frame;
                end
                mean_image = uint16(round(mean_image / number_of_frames));

                f2 = figure;
                imshow(mean_image(:,end:-1:1)')
                imcontrast
            case 0
                display('No corresponding 488 could be identified')
            otherwise
                display('A corresponding 488 could not be unambiguously identified')
        end
                
        

        display('FIX check for analyzed files. It doesnt seem to work right')
        current_PALM_file = PALM_files{random_order(i)};
        gui1 = qSR(current_PALM_file);   

        % Pause here until the user presses "Continue"
        uiwait(f1);
        
        try
            close(f1);
        catch
        end
        
        try
            close(f2);
        catch
        end
        
        try
            close(gui1);
        catch
        end
        
        try
            close(box1);
        catch
        end
    end

    cd(current_directory)