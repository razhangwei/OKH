cd ..;
init;

try
  A = zeros(5);
  B = zeros(10);
  C = A + B;
catch err
  reportError(err, 'hello!');
end

sendEmail('Finished!');

cd test;
