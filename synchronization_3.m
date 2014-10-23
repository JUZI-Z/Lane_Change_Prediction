%% Synchronization_3.m

%% Description
%  File type:       Procedure
%
%  Summary:
%  Detrend processing

%%
%  Examples: 
%Provide sample usage code here

%%
%  Algorithm:
%df
%dsf

%%
%  See also:
% * ITEM1
% * ITEM2

%%
%  Author:       Yuan Ma
%  Date:         Oct.18.2014
%  Revision:     0.1
%  Partner:      Worked with Tianyu Wang, Yulong Li
%  Copyright:    Intelligent System Laboratory
%               University of Michigan Dearborn


%%
clc; clear all;
num_Lane_Change = 0;
vedio_signals = dir('./synchronization_1_Output/Vedio_*.mat');

%% Processing
tic;
for m=1:size(vedio_signals,1)
    % load data generated from phase I and II of synchronization
    load(strcat('./synchronization_1_Output/Vedio_' ,num2str(m), '_Before_Denoised_Data.mat'));
    load(strcat('./synchronization_2_Output/Vedio_' ,num2str(m), '_After_Denoised_Data.mat'));
    
    Ecg_Data(:,2)=Ecg_Data_HR_New(:,2); % combine HR and RR singal together into Ecg signal
    Ecg_Data(:,3)=Ecg_Data_RR_New(:,2);
    % eliminate the row of Ecg_Data which has a nan value of HR or RR singal
    R = find( isnan(Ecg_Data(:,2)) | isnan(Ecg_Data(:,3)) ); 
    Ecg_Data(R,:) = [];
    
    %% detrend for HR
    % detrend means get rid of the low frequency part of the signal
    % using wavelet analysis method to find the trend
    wavelet_Levels = 6;          % levels for wavelet
    wavelet_Type = 'db3';        % the type of wavelet
    baseline_HR = 80;           % this constant set beacause of the result of current medical research, can be change

    [c, l] = wavedec(Ecg_Data(:,2), wavelet_Levels, wavelet_Type);    % wavelet decompose
    trend = wrcoef('a',c,l,wavelet_Type, wavelet_Levels);       % 'a' means approximation part / 'd' means detailed part
    Ecg_Data(:,2) = Ecg_Data(:,2) - trend;                    % detrend the sigal by doing subsctraction
    Ecg_Data(:,2) = Ecg_Data(:,2) + baseline_HR;             %  add a common trend to the detrend signal

    %% process vehicle data (OBD signal?)
    Base_Time = datenum(OBD_start_Time) - floor(datenum(OBD_start_Time));   % get the start time of Base_Time during a day
    Veh_Data(:,1) = Veh_Data(:,1)/3600/24 + Base_Time;              % translate the relative time into absolute time

    %% startTime information extraction for synchronizing signals
    % use lateset start time as the syncrhonized start time
    start_time = max([  datenum(OBD_start_Time)  - floor(datenum(OBD_start_Time));...
                       datenum(GSR_start_Time)  - floor(datenum(GSR_start_Time));...
                       datenum(ECG_start_Time)  - floor(datenum(ECG_start_Time));...
                       datenum(RSP_start_Time)  - floor(datenum(RSP_start_Time));...
                       datenum(ECG_RAW_start_Time)  - floor(datenum(ECG_RAW_start_Time));...
                       datenum(GSR_RAW_start_Time)  - floor(datenum(GSR_RAW_start_Time));...
                       datenum(BELT_RAW_start_Time)  - floor(datenum(BELT_RAW_start_Time));...
                     ]);
    % use earliest time as the syncrhonized end time
    stop_time = min( [Ecg_Data(end,1), Gsr_Data(end,1), Rsp_Data(end,1), ...
                    Veh_Data(end,1), ECG_RAW_Data(end,1), ...
                    GSR_RAW_Data(end,1), BELT_RAW_Data(end,1)]);

    %% synchronization : This part is used to synchronize the data
    Sample_Rate = 10;       % synchronization frequency: 10 Hz
    time_step = (1/Sample_Rate) / 24 / 3600;        % the time step between the two data next to each other
    time_length = abs((stop_time-start_time)) * 24 * 3600;  % duration between start time and stop time
    tq  = (0:0.1:time_length)';     % transportation here
    
    %% Up-Sampling for multiple signals
    % interpolation for Ecg data
    [~, idx_1]    = min( abs(Ecg_Data(:,1) - start_time) ); 
    [~, idx_2]    = min( abs(Ecg_Data(:,1) - stop_time) );  
    
    v   = Ecg_Data(idx_1:idx_2, [2,3]);
    t   = ( Ecg_Data(idx_1:idx_2, 1) - Ecg_Data(idx_1, 1) ) * 24 * 3600;
    vq_ecg = interp1(t, v, tq, 'linear');       % use linear interpolation

    % interpolation for Gsr data
    [none_use_1, idx_1] = min(abs(Gsr_Data(:,1) - start_time)); 
    [none_use_2, idx_2] = min(abs(Gsr_Data(:,1) - stop_time));  
    
    v   = Gsr_Data(idx_1:idx_2, 2:end);
    t   = (Gsr_Data(idx_1:idx_2, 1) - Gsr_Data(idx_1, 1)) * 24 * 3600;
    vq_gsr = interp1(t, v, tq, 'linear');

    % interpolation for Rsp data
    [none_use_1, idx_1] = min(abs(Rsp_Data(:,1) - start_time)); 
    [none_use_2, idx_2] = min(abs(Rsp_Data(:,1) - stop_time));  
    
    v = Rsp_Data(idx_1:idx_2, 2:end);
    t = (Rsp_Data(idx_1:idx_2, 1) - Rsp_Data(idx_1, 1)) * 24 * 3600;
    vq_rsp = interp1(t, v, tq, 'linear');

    %% Down-Sampling processing
    % Only for Ecg Raw Data
    [none_use_1,idx_1]  = min(abs(ECG_RAW_Data(:,1) - start_time));  
    vq_ecg_raw_time     = (ECG_RAW_Data(idx_1:end, 1) - ECG_RAW_Data(idx_1,1)) * 24 * 3600;
    vq_ecg_raw          = ECG_RAW_Data(idx_1:end, 2:end); 

    % Belt signal down-sampling
    [none_use_1,idx_1]=min(abs(BELT_RAW_Data(:,1) - start_time)); 
    vq_belt_raw_time    = (BELT_RAW_Data(idx_1:end, 1) - BELT_RAW_Data(idx_1,1)) * 24 * 3600;
    vq_belt_raw         = BELT_RAW_Data(idx_1:end, 2:end); 

    % GSR_RAW signal down-sampling
    [none_use_1, idx_1] = min(abs(GSR_RAW_Data(:,1) - start_time)); 
    [none_use_2, idx_2] = min(abs(GSR_RAW_Data(:,1) - stop_time));  
    
    v   = GSR_RAW_Data(idx_1:idx_2, 3);
    t   = ( GSR_RAW_Data(idx_1:idx_2,1) - GSR_RAW_Data(idx_1,1) ) * 24 * 3600;
    vq_gsr_raw = interp1(t, v, tq, 'linear');
    
    if isnan(vq_gsr_raw(end,1))
        vq_gsr_raw(end,1)=vq_gsr_raw(end-1,1);
    end
    
    data_All_cal    = [tq, vq_ecg, vq_rsp, vq_gsr, vq_gsr_raw];
    data_All_ECG    = [vq_ecg_raw_time,    vq_ecg_raw];
    data_All_BELT   = [vq_belt_raw_time,    vq_belt_raw];

    %% doing with target
    target_idx=target_Data;

    target_idx(:,1) = datenum(target_idx(:,1)) - floor(datenum(target_idx(:,1)));
    target_idx(:,2) = datenum(target_idx(:,2)) - floor(datenum(target_idx(:,2)));
    baseline        = datenum(OBD_start_Time) - floor(datenum(OBD_start_Time));
    target_idx(:,1) = target_idx(:,1) + baseline;
    target_idx(:,2) = target_idx(:,2) + baseline;
    
    % Retrive the number of Lane Change
    Lane_Change_event = length(find(target_idx(:,16)==1));  % find how many lange changes in one vedio
    num_Lane_Change = num_Lane_Change + Lane_Change_event;
    Target = zeros(size(data_All_cal(:,1)));

    for i=1:length(target_idx(:,1))
        index = find((data_All_cal(:,1) >= (target_idx(i,1) - start_time)*24*3600) ...
                    & (data_All_cal(:,1) <= (target_idx(i,2) - start_time)*24*3600) ...
                    & target_idx(i,16) == 1);
        Target(index) = 1;     %%
        
        index = find((data_All_cal(:,1) >= (target_idx(i,1)-start_time)*24*3600) ...
                    & (data_All_cal(:,1) <= (target_idx(i,2)-start_time)*24*3600) ...
                    & target_idx(i,16) == 2);
        Target(index) = 2;     %%
    end

    data_All_cal = [data_All_cal, Target];
    save(strcat('./synchronization_3_Output/Vedio_',num2str(m),'_Synchronized_Data.mat'),'data_All_cal','Text_Index','data_All_ECG','data_All_BELT');
end
save('./synchronization_3_Output/statistics.mat', 'num_Lane_Change');
toc;    % end of program

copyfile('./synchronization_3_Output', './Synchronized_Dataset');