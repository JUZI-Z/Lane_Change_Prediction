function prepareData()
    %% Initialization and Configuration
    clear all; clc;
    
    configFile = '../preamble/configuration.ini';
    [homePath, dataRootPath, outputPath] = loadGlobalPathSetting(configFile);
    addpath(genpath(homePath)); % only for debug
    
    mkdir_if_not_exist(outputPath);

    dataPreparationOutput = createOutputFolder(outputPath, 'dataPreparationOutput');

    %% Get information of Dataset
    disp('Get information of Dataset');
    [numRecordData, nameRecordData] = getDatasetInfo(dataRootPath);
    fprintf('Total number of record file collections is: %d\n', numRecordData);
    
    signalVector = {'GSR', 'ECG', 'RSP', ...
                    'GSRraw', 'ECGraw', 'RSPraw', ...
                    'OBD'};
    numSignal = size(signalVector, 2);

    %% Malloc memory size to store start info
    disp('Malloc memory size to store start info');
    startTimeTable = cell(numRecordData, numSignal);
    endTimeTable = cell(numRecordData, numSignal);
    
    %%
    recordDataPathList = strcat(dataRootPath, '/', nameRecordData);
    
    tic;
    for i = 1:size(recordDataPathList, 2)
        fprintf('start analysising record files: %d\n', i);
        recordDataPath = cell2mat(recordDataPathList(1, i));
        
        % analysis OBD date first to extract video record date information
        prepedOBD = extractSiginfo(signalVector(7), recordDataPath);
        
        [prepedGSR, prepedECG, prepedRSP, prepedGSRraw, prepedECGraw, ...
            prepedRSPraw] = analysisRecordFiles(recordDataPath, ...
                                                            signalVector);                                                       
                                                        
        startTimeTable(i, :) = strcat(prepedOBD.startDate, {' '}, ...
                            {prepedGSR.startTime, prepedECG.startTime, ...
                                prepedRSP.startTime, prepedGSRraw.startTime, ...
                                prepedECGraw.startTime, prepedRSPraw.startTime, ...
                                prepedOBD.startTime});
         
        endTimeTable(i, :) = strcat(prepedOBD.startDate, {' '}, ...
                            {prepedGSR.endTime, prepedECG.endTime, ...
                                prepedRSP.endTime, prepedGSRraw.endTime, ...
                                prepedECGraw.endTime, prepedRSPraw.endTime, ...
                                prepedOBD.endTime});
        
        prepedTarget = extractLabellingResult(recordDataPath);
        
        fprintf('start saving record files: %d\n', i);
        
        savefile = strcat(dataPreparationOutput, '/prepedData_', cell2mat(nameRecordData(1, i)), '.mat');
        parsave(savefile, prepedGSR, prepedECG, prepedRSP, ...
                        prepedGSRraw, prepedECGraw, ...
                        prepedRSPraw, prepedOBD, prepedTarget);
        
        fprintf('Finished saving record files %d\n', i);
        fprintf('Finished analysising record files: %d\n', i);
    end
    toc;
    
    disp('save start time reference table');
    savefile = strcat(dataPreparationOutput, '/startTimeTable.mat');
    save(savefile, 'startTimeTable');
    
    disp('save end time reference table');
    savefile = strcat(dataPreparationOutput, '/endTimeTable.mat');
    save(savefile, 'endTimeTable');
    
    disp('Program finished');
end