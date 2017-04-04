function classIndexMatrix = createIndexMatrix(nbPtPerClass, nClass, nPt)  % npt  =ndescr, nclass = nPics, nbPtperClass = param.lWpx


classIndexMatrix = sparse([],[],[],nPt, nClass);

classIndexMatrix([1;cumsum(nbPtPerClass(1:end-1))+1]' +  nPt*(0:(nClass-1))) = 1;
classIndexMatrix( cumsum(nbPtPerClass(:))'            +  nPt*(0:(nClass-1))) = -1;

classIndexMatrix = cumsum(classIndexMatrix);

