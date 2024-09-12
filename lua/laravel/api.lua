local ApiResponse = require("laravel.dto.api_response")

local combine_tables = require "laravel.utils".combine_tables

---@class LaravelApi
---@field env LaravelEnvironment
local api = {}

---@return LaravelApi
function api:new(env)
  local instance = setmetatable({}, { __index = api })
  instance.env = env
  return instance
end

---@return string[]
function api:generate_command(name, args)
  local executable = self.env:get_executable(name)
  if not executable then
    error(string.format("Executable %s not found", name), vim.log.levels.ERROR)
  end

  return combine_tables(executable, args)
end

---@param program string
---@param args string[]
---@param opts table|nil
---@return ApiResponse
function api:sync(program, args, opts)
  opts = opts or {}
  local res = {}
  self
      :async(program, args, function(result)
        res = result
      end, opts)
      :wait()

  return res
end

---@param program string
---@param args string[]
---@param callback fun(response: ApiResponse)
---@param opts table|nil
---@return vim.SystemObj
function api:async(program, args, callback, opts)
  opts = opts or {}

  local cmd = self:generate_command(program, args)

  local cb = function (out)
    callback(ApiResponse:new({out.stdout}, out.code, {out.stderr}))
  end

  if opts.wrap then
    cb = vim.schedule_wrap(cb)
  end

  local sysObj = vim.system(cmd, {}, cb)

  return sysObj
end

---@param code string
---@param callback fun(response: ApiResponse)
---@param opts table|nil
---@return vim.SystemObj
function api:tinker(code, callback, opts)
  assert(code, "Code is required")

  return self:async("artisan", { "tinker", "--execute", code }, callback, opts)
end

return api
