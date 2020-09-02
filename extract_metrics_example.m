% Example of extraction of oculomotor metrics as described in Maniglia, 
%Visscher and Seitz (JOV, 2020)
clear all
      nameOffile = dir([ '*.mat']);

 
    for i=1:length(nameOffile)

        newest = nameOffile(i).name;
        load(['./' newest]);

saccadic_rereferencing_first_saccade_metrics
close all

clearvars -except  nameOffile 


    end