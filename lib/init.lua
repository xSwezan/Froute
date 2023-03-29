local RouterClass = require(script.Classes.Router)
local Types = require(script.Types)
local FusionTypes = require(script.FusionTypes)
local RouteClass = require(script.Classes.Route)

local Froute: Types.Froute = {}

export type Router = Types.Router

function Froute.Router(Routes: {Types.Route}): Types.Router
	return RouterClass.new(Routes or {})
end

function Froute.Route(Path: string): (props: {}) -> Router
	return function(props: Types.RouteInfo)
		return RouteClass.new(Path,props)
	end
end

function Froute.Mount(Router: Types.Router): FusionTypes.StateObject<Instance>
	return Router.PageValue
end

return Froute