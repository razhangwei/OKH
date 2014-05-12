function value = getConst (key)

  global CONST;
  if isempty(CONST)
    if onServer()
      initConstServer;
    else
      initConstLocal;
    end
  end

  value = getfield(CONST, key);

end
