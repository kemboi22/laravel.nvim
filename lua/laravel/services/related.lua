local related = {}

local types = { "observers", "relations", "policy" }

local build_relation = function(info, relation_type)
  if next(info) == nil then
    return nil
  end
  if relation_type == "observers" and info["observer"][2] ~= nil then
    return {
      class = info["observer"][2],
      type = relation_type,
      extra_information = info["event"],
    }
  elseif relation_type == "relations" then
    return {
      class = info["related"],
      type = relation_type,
      extra_information = info["type"] .. " " .. info["name"],
    }
  elseif relation_type == "policy" then
    return {
      class = info[1],
      type = relation_type,
      extra_information = "",
    }
  end
  return nil
end

function related:new(model)
  local instance = {
    model = model,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function related:get(bufnr)
  return self.model:parse(bufnr):thenCall(function(info)
    local relations = {}
    for _, relation_type in ipairs(types) do
      if info[relation_type] and #info[relation_type] > 0 then
        if type(info[relation_type]) == "table" and info[relation_type][1] then
          for _, inf in ipairs(info[relation_type]) do
            local relation = build_relation(inf, relation_type)
            if relation ~= nil then
              table.insert(relations, relation)
            end
          end
        else
          local relation = build_relation({ info[relation_type] }, relation_type)
          if relation ~= nil then
            table.insert(relations, relation)
          end
        end
      end
    end

    return relations
  end)
end

return related
