%* *****************************************************************
%* - Function of STAPMAT in initialization phase                   *
%*                                                                 *
%* - Purpose:                                                      *
%*     Read input file of STAPMAT                                  *
%*                                                                 *
%* - Call procedures:                                              *
%*     SRC/Initiation/ReadFile.m - InitBasicData()                 *
%*                                                                 *
%* - Called by :                                                   *
%*     stapmat.m                                                   *
%*                                                                 *
%* - Programmed by:                                                *
%*     LeiYang Zhao, Yan Liu,                                      *
%*     Computational Dynamics Group, School of Aerospace           *
%*     Engineering, Tsinghua University, 2019.02.21                *
%*                                                                 *
%* *****************************************************************

function ReadFile(fname)
fname = strcat('.\Data\', fname);           % Deal the filename

% Get global class
global cdata;
global sdata;

% Open files
cdata.IIN = fopen(fname, 'r');
if (cdata.IIN == -1)
    error('The input file cannot be found');
end

% Begin Read input file
fprintf('Input phase ...\n\n');

% the first time stamp
cdata.TIM = zeros(5, 6, 'double');
cdata.TIM(1,:) = clock;

IIN = cdata.IIN;
%% Read Control data
cdata.HED = fgetl(IIN);

tmp = str2num(fgetl(IIN));
cdata.NUMNP = round(tmp(1));
cdata.NUMEG = round(tmp(2));
cdata.NLCASE = round(tmp(3));
cdata.MODEX = round(tmp(4));

if (cdata.NUMNP == 0) return; end

%% Read nodal point data
NUMNP = cdata.NUMNP;
% Init basic data
cdata.NPAR = zeros(10, 1, 'int64');
ID = zeros(3,NUMNP, 'int64');
X = zeros(NUMNP, 1, 'double');
Y = zeros(NUMNP, 1, 'double');
Z = zeros(NUMNP, 1, 'double');
% Define local variables to speed
for i = 1:NUMNP
    tmp = sscanf(fgetl(IIN), '%d %d %d %d %f %f %f');
    ID(:, i) = tmp(2:4);
    X(i) = tmp(5);
    Y(i) = tmp(6);
    Z(i) = tmp(7);
end
sdata.IDOrigin = ID; sdata.X = X; sdata.Y = Y; sdata.Z = Z;
%% Compute the number of equations
NEQ = 0;
for N=1:NUMNP
    for I=1:3
        if (ID(I,N) == 0)
            NEQ = NEQ + 1;
            ID(I,N) = NEQ;
        else
            ID(I,N) = 0;
        end
    end
end
sdata.ID = ID;
sdata.NEQ = NEQ;
%% Read load data
% Init control data
NLCASE = cdata.NLCASE;
R = zeros(NEQ, NLCASE, 'double');
NLOAD = zeros(NLCASE, 1, 'double');
NOD = zeros(NLCASE*NUMNP, 1, 'double');
IDIRN = zeros(NLCASE*NUMNP, 1, 'double');
FLOAD = zeros(NLCASE*NUMNP, 1, 'double');

% Read data
Count = 0;
for N = 1:NLCASE
    tmp = sscanf(fgetl(IIN), '%d %d');
    NNLOAD = tmp(2);
    NLOAD(N) = tmp(2);
    
%   Read load data
    for I = 1+Count:NNLOAD+Count
        tmp = sscanf(fgetl(IIN), '%d %d %f');
        NOD(I) = tmp(1);
        IDIRN(I) = tmp(2);
        FLOAD(I) = tmp(3);
    end
    
%   Compute load vector
    for L = 1+Count:NNLOAD+Count
       II = ID(IDIRN(L), NOD(L));
       if (II > 0) R(II, N) = R(II, N) + FLOAD(L); end
    end
    Count = Count + NNLOAD;
end
if (cdata.MODEX == 0) return; end
NOD = NOD(1:Count);
IDIRN = IDIRN(1:Count);
FLOAD = FLOAD(1:Count);
sdata.NOD = NOD; sdata.IDIRN = IDIRN; sdata.FLOAD = FLOAD;
sdata.R = R; sdata.NLOAD = NLOAD;
end
