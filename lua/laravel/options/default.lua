---@class NullLsFeature
---@field enable boolean

---@class RouteInfoFeature
---@field enable boolean
---@field position string

---@class LaravelFeatures
---@field null_ls NullLsFeature
---@field route_info RouteInfoFeature

---@class LaravelOptions
---@field lsp_server string
---@field features LaravelFeatures
---@field ui LaravelOptionsUI
---@field commands_options table
---@field environments LaravelOptionsEnvironments
---@field user_commands table
---@field resources table
return {
  lsp_server = "phpactor",
  features = {
    null_ls = {
      enable = true,
    },
    route_info = {
      enable = true,
      position = "top",
    },
  },
  ui = require "laravel.options.ui",
  commands_options = require "laravel.options.command_options",
  environments = require "laravel.options.environments",
  user_commands = require "laravel.options.user_commands",
  resources = require "laravel.options.resources",
  providers = {
    require("laravel.providers.provider"),
    require("laravel.providers.override_provider"),
    require("laravel.providers.route_info_provider"),
    require("laravel.providers.tinker_provider"),
    require("laravel.providers.telescope_provider"),
    require("laravel.providers.user_command_provider"),
    require("laravel.providers.status_provider"),
  },
  user_providers = {
  },
}
