function densratio = prepare_data_subfun(epsxname,epsyname,epsxyname,...
    epsyxname,frame)
% densratio = prepare_data_subfun(epsxname,epsyname,epsxyname,epsyxname,frame)
%
% Takes the x-, y-, xy-, and yx- strains and computes the density ratio
% det F.
%
% inputs:
%   epsxname  = script name of tif file that defines the x-strain
%   epsyname  = script name of tif file that defines the y-strain
%   epsxyname = script name of tif file that defines the xy-strain
%   epsyxname = script name of tif file that defines the yx-strain
%   frame     = which frame of multi-image tiff
%
% output:
%   dens = density

epsx = imread(epsxname,'tif',frame);
epsy = imread(epsyname,'tif',frame);
epsxy = imread(epsxyname,'tif',frame);
epsyx = imread(epsyxname,'tif',frame);

[rows,cols] = size(epsx);
densratio = zeros(rows,cols);

for i = 1:rows
    for j = 1:cols
        %%% spots (1,1) and (2,1) have extraneous info
        if (i~=1 && j~=1) || (i~=2 && j~=1)
            if epsx(i,j)~=0 || epsy(i,j)~=0 || epsyx(i,j)~=0 || epsy(i,j)~=0
                %%% assuming epsxy=epsyx (thus epsxy*epsyx = epsxy^2)
                defgrad = eye(2) + [epsx(i,j) epsxy(i,j) ; epsxy(i,j) epsy(i,j)];
                determinant = defgrad(1,1)*defgrad(2,2) - defgrad(1,2)^2;
                
                %%% if epsxy~=epsyx
                % defgrad = eye(2) + [epsx(i,j) epsxy(i,j) ; epsyx(i,j) epsy(i,j)];
                % determinant = defgrad(1,1)*defgrad(2,2) - defgrad(1,2)*defgrad(2,1);
                
                densratio(i,j) = abs(determinant);
            end
        end
    end
end