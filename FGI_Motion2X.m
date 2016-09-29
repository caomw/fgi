function motionOut = FGI_Motion2X( motionIn, imgRef, param)

uInit = imresize(motionIn(:,:,1),2,'bicubic')*2;
vInit = imresize(motionIn(:,:,2),2,'bicubic')*2;
mask = zeros(size(uInit));
mask(1:2:end,1:2:end) = motionIn(:,:,3);

%% Guided Interpolation - Eq.(4)
U = FGS(uInit.*mask, param.FGS1_SIGMA, param.FGS1_LAMDA^2, imgRef, 3, 4);
V = FGS(vInit.*mask, param.FGS1_SIGMA, param.FGS1_LAMDA^2, imgRef, 3, 4);
M = FGS(mask, param.FGS1_SIGMA, param.FGS1_LAMDA^2, imgRef, 3, 4);
uOut = U./M;
vOut = V./M;

%% Joint filtering - Eq.(6)
uOut = FGS(uInit, param.FGS2_SIGMA, param.FGS2_LAMDA^2, uOut, 3, 4);
vOut = FGS(vInit, param.FGS2_SIGMA, param.FGS2_LAMDA^2, vOut, 3, 4);

%% Consensus mapping
newseed = minValPos((abs(uInit-uOut)+abs(vInit-vOut)),2, param.CONSENSUS_THR);
motionOut = cat(3,uOut,vOut,double(or(newseed,mask)));
end

