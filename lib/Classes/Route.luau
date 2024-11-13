local Types = require(script.Parent.Parent.Types)
local Fusion = require(script.Parent.Parent.Parent.Fusion)

local Route = {}
Route.__index = Route

function Route.new(Path: string, props: Types.RouteInfo): Types.Route
	assert(type(Path) == "string","Expected a string as first argument 'Path' when creating a Route!")

	local self = setmetatable({}, Route)

	self.Path = Path
	self.props = props or {}

	self.Routes = self.props[Fusion.Children] or {}

	return self
end

function Route:Construct(Router: Types.Router, props: {}?, scope: Fusion.Scope<unknown>): Instance?
	if (type(self.props.Construct) == "function") then
		return self.props.Construct(Router, props or {}, scope)
	end

	return
end

return Route