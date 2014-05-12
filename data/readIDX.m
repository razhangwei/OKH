function A = readIDX (filename)
  fid = fopen(filename);
  mg = fread(fid, 4, '*uint8');
  D = mg(4);
  sizeA = fread(fid, D, '*uint32', 0, 'b');
  A = fread(fid, prod(double(sizeA)), '*uint8');
  if D > 1
    A = reshape(A, fliplr(sizeA'));
  end
  fclose(fid);
end
