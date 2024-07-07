local container = require "laravel.container":new()

---@param abstract string|nil
---@return any
return function(abstract)
  if not abstract then
    return container
  end

  return container:get(abstract)
end
