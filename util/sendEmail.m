function sendEmail (subject, content)

  if ~getConst('EMAIL_ENABLE')
    return;
  end

  if ~exist('content', 'var')
    content = 'No content.';
  end

  username = getConst('EMAIL_SERVER_USER');
  password = getConst('EMAIL_SERVER_PASS');

  setpref('Internet', 'E_mail', username);
  setpref('Internet', 'SMTP_Server', 'smtp.gmail.com');
  setpref('Internet', 'SMTP_Username', username);
  setpref('Internet', 'SMTP_Password', password);

  props = java.lang.System.getProperties;
  props.setProperty('mail.smtp.auth', 'true');
  props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
  props.setProperty('mail.smtp.socketFactory.port', '465');

  sid = onServer(true);
  if ~sid
    sname = 'Local';
  else
    sname = sprintf('Node-%d', sid);
  end
  subject = sprintf('[LWP] %s: %s', sname, subject);

  try
    sendmail(getConst('EMAIL_TARGET'), subject, content);
  catch
    fprintf('Error while sending email titled "%s"\n', subject);
  end

end
