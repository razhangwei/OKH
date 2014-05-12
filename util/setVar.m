% set a variable by name
function setVar (varname, value)

  assignin('caller', varname, value);

end
