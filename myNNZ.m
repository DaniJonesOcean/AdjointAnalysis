function numberOfNonZeros = myNNZ(f,mygrid);
%function numberOfNonZeros = myNNZ(f,mygrid);
% number of non-zero entries for gcmfaces

  % start counter at zero
  nnz0 = 0;
  nf = mygrid.nFaces;

  % for all faces, count number of non-zero entries
  for nface = 1:nf

    evalc(strcat('nnz0 = nnz0 + nnz(f.f',int2str(nface),');'));

  end

  % output
  numberOfNonZeros = nnz0;

end
