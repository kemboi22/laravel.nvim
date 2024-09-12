---@class LaravelRoute
---@field uri string
---@field action string
---@field controller string|nil
---@field method string|nil
---@field domain string|nil
---@field methods string[]
---@field middlewares string[]

---@class LaravelRouteProvider
---@field api LaravelApi
local routes = {}

local function split(str, sep)
  local result = {}
  local regex = ("([^%s]+)"):format(sep)
  for each in str:gmatch(regex) do
    table.insert(result, each)
  end
  return result
end

function routes:new(api)
  local instance = setmetatable({}, { __index = routes })
  instance.api = api
  return instance
end

---@param callback fun(commands: LaravelRoute[])
---@param error_callback fun(error: string)|nil
---@return vim.SystemObj
function routes:get(callback, error_callback)
  return self.api:async("artisan", { "route:list", "--json" }, function(result)
    if result:failed() then
      if error_callback then
        error_callback(result:prettyErrors())
      end
      return
    end

    callback(vim
      .iter(result:json() or {})
      :map(function(route)
        local controller = nil
        local method = nil

        local parts = split(route.action, "@")
        if #parts == 2 then
          controller = parts[1]
          method = parts[2]
        end

        return {
          uri = route.uri,
          action = route.action,
          controller = controller,
          method = method,
          domain = route.domain,
          methods = split(route.method, "|"),
          middlewares = route.middleware,
          name = route.name,
        }
      end)
      :totable())
  end, { wrap = true })
end

return routes
