function reportError (err, msg)

  if ~exist('msg', 'var')
    msg = '';
  end

  if ~isempty(msg) && ~endsWith(msg, sprintf('\n'))
    msg = [msg sprintf('\n')];
  end

  fprintf('%s\n', sprintf('%s\n%s', msg, getReport(err)));
  sendEmail('Error occured!', sprintf('%s\n%s', msg, getReport(err, 'extended', 'hyperlinks', 'off')));

end
