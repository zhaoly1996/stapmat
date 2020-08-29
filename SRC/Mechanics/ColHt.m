%* *****************************************************************
%* - Function of STAPMAT in stiffness phase                        *
%*                                                                 *
%* - Purpose:                                                      *
%*     To calculate column heights                                 *
%*                                                                 *
%* - Call procedures: None                                         *
%*                                                                 *
%* - Called by :                                                   *
%*     ./Truss/ReadTruss.m                                         *
%*                                                                 *
%* - Programmed in Fortran 90 by Xiong Zhang                       *
%*                                                                 *
%* - Adapted to Matlab by:                                         *
%*     LeiYang Zhao, Yan Liu, Computational Dynamics Group,        *
%*     School of Aerospace Engineering, Tsinghua University,       *
%*     2019.02.22                                                  *
%*                                                                 *
%* *****************************************************************

function MHT = ColHt(LM, MHT)

% Get global data
LS = min(LM(LM ~= 0));
for I = 1:length(LM)
    II = LM(I);
    if (II ~= 0)
        ME = II - LS;
        if (ME > MHT(II)) MHT(II) = ME; end
    end
end

end