function cleanData()
    clear all; clc;     % Clear environment, and start counting running time
    close all;
    addpath(genpath('../utility/'));
    
    %%
    configFile = '../preamble/configuration.ini';
    [~, ~, outputPath] = loadGlobalPathSetting(configFile);
    
    dataCleanOutput = createOutputFolder(outputPath, 'dataCleanOutput');
    
    folderFiles = dir(strcat(outputPath, '/dataPreprocessOutput'));
    folderFilesName = {folderFiles.name};
    
    expression = 'preprocData_*';
    DataFileIndex = ~cellfun(@isempty, (regexpi(folderFilesName,expression)));
    procDataFilesName = folderFilesName(DataFileIndex);
    numProcDataFiles = size(procDataFilesName, 2);
    
    [ allGSRdata, allECGdata, allRSPdata, ...
           allGSRrawData, allECGrawData, ...
           allRSPrawData, allTarget] = loadpreprocDataset(outputPath, ...
                                      numProcDataFiles, procDataFilesName);

    %% ================ Deal with GSR signal =======================
    [cleanedGSRdata, statis.GSR.valMean, statis.GSR.valStd, ...
        statis.GSR.maxVariance, statis.GSR.minVariance] = ...
                                                cleanOneSig(allGSRdata);
    
    %% ================ Deal with ECG signal =======================
    [cleanedECGdata, statis.ECG.valMean, statis.ECG.valStd, ...
        statis.ECG.maxVariance, statis.ECG.minVariance] = ...
                                                cleanOneSig(allECGdata);
    
    %% ================ Deal with RSP signal =======================
    [cleanedRSPdata, statis.RSP.valMean, statis.RSP.valStd, ...
        statis.RSP.maxVariance, statis.RSP.minVariance] = ...
                                                cleanOneSig(allRSPdata);
    
    %% ================ Deal with GSR signal =======================
    [cleanedGSRrawData, statis.GSRraw.valMean, statis.GSRraw.valStd, ...
        statis.GSRraw.maxVariance, statis.GSRraw.minVariance] = ...
                                                cleanOneSig(allGSRrawData);
    
    %% ================ Deal with ECG signal =======================
    [cleanedECGrawData, statis.ECGraw.valMean, statis.ECGraw.valStd, ...
        statis.ECGraw.maxVariance, statis.ECGraw.minVariance] = ...
                                                cleanOneSig(allECGrawData);
    
    %% ================ Deal with RSP signal =======================
    [cleanedRSPrawData, statis.RSPraw.valMean, statis.RSPraw.valStd, ...
        statis.RSPraw.maxVariance, statis.RSPraw.minVariance] = ...
                                                cleanOneSig(allRSPrawData);
    
    savefile = strcat(dataCleanOutput, '/signalStatistics.mat');
    save(savefile, 'statis');
    
    for i = 1:numProcDataFiles
        PreprpcDataFilePath = strcat(outputPath, '/dataPreprocessOutput/', ...
            procDataFilesName{1, i});
        [~, name, ~] = fileparts(PreprpcDataFilePath);
        expression = '_';
        splitStr = regexp(name, expression,'split');
        savefile = strcat(dataCleanOutput, '/', ...
                        strrep(name, splitStr{1}, 'cleanedData'), '.mat');
                    
        cleanedGSR      = cleanedGSRdata(i);
        cleanedECG      = cleanedECGdata(i);
        cleanedRSP      = cleanedRSPdata(i);
        cleanedGSRraw   = cleanedGSRrawData(i);
        cleanedECGraw   = cleanedECGrawData(i);
        cleanedRSPraw   = cleanedRSPrawData(i);
        cleanedTarget   = allTarget(i);
        save(savefile, 'cleanedGSR', 'cleanedECG', 'cleanedRSP', ...
                    'cleanedGSRraw', 'cleanedECGraw', 'cleanedRSPraw', ...
                    'cleanedTarget');
    end
end