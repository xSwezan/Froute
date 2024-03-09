local RouterClass = require(script.Classes.Router)
local Types = require(script.Types)
local FusionTypes = require(script.FusionTypes)
local RouteClass = require(script.Classes.Route)

local Froute = {}

export type Router = Types.Router

function Froute.Router(Routes: {Types.Route}): Types.Router
	return RouterClass.new(Routes or {})
end

function Froute.Route(Path: string): (props: Types.RouteInfo) -> Types.Route
	return function(props: Types.RouteInfo)
		return RouteClass.new(Path, props)
	end
end

function Froute.Mount(Router: Types.Router): (props: {}) -> FusionTypes.StateObject<Instance>
	return function(props: {})
		local Router: any = Router
		Router.PageProps:set(props)
		Router:SetupPage()
		return Router.PageFrame
	end
end

return Froute