% get a variable by name
function value = getVar (varname)

  value = evalin('caller', varname);

end
