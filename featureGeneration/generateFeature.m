function generateFeature()
    clear all; clc;     % Clear environment, and start counting running time
    
    configFile = '../preamble/configuration.ini';
    [~, ~, outputPath] = loadGlobalPathSetting(configFile);
    
    featureGenerationOutput = createOutputFolder(outputPath, ...
                                            'featureGenerationOutput');
    
    folderFiles = dir(strcat(outputPath, '/signalSelectionOutput'));
    folderFilesName = {folderFiles.name};
    
    expression = 'selectedSignalData_*';
    DataFileIndex = ~cellfun(@isempty, (regexpi(folderFilesName,expression)));
    selectedSigFilesName = folderFilesName(DataFileIndex);
    numselectedSigDataFiles = size(selectedSigFilesName, 2);
    
    lenFeatureWindow = 20;
    featureVecParams = {'Instant Value', 'Maximum', 'Minimum', ...
                        'Difference', 'Standard Deviation', 'Mean', ...
                        'Median', 'Energy', 'Skewness', 'Kurtosis'};
                    
    
    for i = 1:numselectedSigDataFiles
        selectedSigFilePath = strcat(outputPath, '/signalSelectionOutput/', ...
            selectedSigFilesName{1, i});
        savefile = strcat(featureGenerationOutput, '/featureVector_', ...
            num2str(i), '.mat');
        
        bar = load(selectedSigFilePath);
        calFeatureVec(lenFeatureWindow, featureVecParams, ...
                                    bar.selectedSigsData, savefile);
    end
end