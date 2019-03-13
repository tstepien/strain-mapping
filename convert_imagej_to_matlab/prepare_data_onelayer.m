function [exp_densratios,exp_boundaries] = prepare_data_onelayer(foldername)
% [exp_densratios,exp_boundaries] = prepare_data_onelayer(foldername)
%
% Takes the x-, y-, xy-, and yx- strains and computes the density ratio
% det F.  Also imports boundary data and exports it as a MATLAB data file.
%
% inputs:
%   foldername = script name of the folder with the data files
%
% output:
%   exp_densratios = density ratios det F of the experimental data
%   exp_boundaries = coordinates of points along the boundaries

tic

framestart = 1;
frameend_strain = length(imfinfo(fullfile(pwd,foldername,'strains',...
    'epsx_crop.tif'),'tif'));
frameend_bdy = numel(dir(fullfile(pwd,foldername,...
    'boundaries','*.txt')));

exp_densratios = cell(1,frameend_strain-framestart);
exp_boundaries = cell(1,frameend_bdy-framestart);
for i = framestart:frameend_strain
    epsx = fullfile(pwd,foldername,'strains','epsx_crop.tif');
    epsy = fullfile(pwd,foldername,'strains','epsy_crop.tif');
    epsxy = fullfile(pwd,foldername,'strains','epsxy_crop.tif');
    epsyx = fullfile(pwd,foldername,'strains','epsyx_crop.tif');
    
    exp_densratios{i} = prepare_data_subfun(epsx,epsy,epsxy,epsyx,i);
end

for i = framestart:frameend_bdy
    exp_boundaries{i} = dlmread(fullfile(pwd,foldername,'boundaries',...
                            strcat(num2str(i),'.txt')));
    exp_boundaries{i} = exp_boundaries{i}(:,1:2);
end

exp_densratios = exp_densratios(framestart:frameend_strain);
exp_boundaries = exp_boundaries(framestart:frameend_bdy);

save(strcat('densratios'),'exp_densratios')
save(strcat('boundaries'),'exp_boundaries')

toc