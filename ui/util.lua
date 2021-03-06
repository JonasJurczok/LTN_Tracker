local match = string.match
local function item2sprite(iname, itype)
  if not itype then
    itype, iname= match(iname, "(.+),(.+)")
  end
  if iname and (game.item_prototypes[iname] or game.fluid_prototypes[iname]) then
    return itype .. "/" .. iname
  else
    return nil
  end
end
-- display a shipment of items as icons
local function build_item_table(args)
  -- !TODO go over this once more, should be as efficient as possible
  -- !TODO disable assert for release
  --required arguments: parent (without any of provided / requestd / signals an empty frame is produced)
  --optional arguments: provided, requested, signals, columns, enabled, type, no_negate, max_rows


  out.assert(args.parent, "Parent not defined.\nArgs provided:", args)
  -- parse arguments
  local columns = args.columns
  local type = args.type

  -- outer frame
	local frame = args.parent.add{type = "frame", style = "ltnt_slot_table_frame"}

  if args.max_rows then
    frame.style.maximal_height = args.max_rows * 38
    frame = frame.add{type = "scroll-pane", style = "ltnt_sp_vertical"}
  end

  -- table for item sprites
	local tble = frame.add{type = "table", column_count = columns, style = "slot_table"}
  local enabled
	if args.enabled then
    enabled = args.enabled
  else
		enabled = false
    tble.ignored_by_interaction = true
	end
  local count = 0
  -- add items to table
	if args.provided then
		for item, amount in pairs(args.provided) do
			local test = tble.add{
				type = "sprite-button",
				sprite = item2sprite(item, type),
				number = amount,
				enabled = enabled,
        style = "ltnt_provided_button",
			}
      count = count + 1
		end
	end
  if args.requested then
		for item, amount in pairs(args.requested) do
      if not args.no_negate then
        amount = -amount -- default to numbers for requests
      end
			tble.add{
				type = "sprite-button",
				sprite = item2sprite(item, type),
				number = amount,
				enabled = enabled,
        style = "ltnt_requested_button",
			}
      count = count + 1
		end
	end
  if args.signals then
		for name, amount in pairs(args.signals) do
			tble.add{
				type = "sprite-button",
				sprite = "virtual-signal/" .. name,
				number = amount,
				enabled = enabled,
        style = "ltnt_empty_button",
			}
      count = count + 1
		end
	end
  while count == 0 or count % columns > 0  do
    tble.add{
      type = "sprite-button",
      sprite = "",
      enabled = enabled,
      style = "ltnt_empty_button",
    }
    count = count + 1
  end
	return frame
end

return {build_item_table = build_item_table}