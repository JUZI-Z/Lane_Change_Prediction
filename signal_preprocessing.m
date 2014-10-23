%% signal_preprocessing.m

%% Description
%  File type:       Procedure
%
%  Summary:
%  This is the first file need to be excute for the whole project.
%  This script converts all .xlsx data into .mat format for further
%  processing

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

clc; clear all;

vedio_signals = dir('./synchronization_1_Output/*_Before_Denoised_Data.mat');      % list all the .mat files
[num_trips, ~] = size(vedio_signals);        % find how many trips here
load('./Synchronized_Dataset/vedio_1_Synchronized_Data.mat');
[~, lane_change_labels] = size(data_All_cal);

% modify some information of previous generated synchronized data
for i=1:num_trips
    load(strcat('./Synchronized_Dataset/vedio_', num2str(i), '_Synchronized_Data.mat'));
    Text_Index{20,:} = 'GSR RAW';        % rename 'GSR (...)' into GSR RAW ???
    save(strcat('./Synchronized_Dataset/vedio_', num2str(i), '_Synchronized_Data.mat'), 'Text_Index', 'data_All_cal', 'data_All_ECG', 'data_All_BELT');
end

signal_selection(num_trips, lane_change_labels);
