local RouterClass = require(script.Classes.Router)
local Types = require(script.Types)
local Fusion = require(script.Parent.Fusion)
local RouteClass = require(script.Classes.Route)

local Froute = {}

export type Router = Types.Router

function Froute.Router(scope: Fusion.Scope<unknown>, Routes: {Types.Route}): Types.Router
	return RouterClass.new(scope, Routes or {})
end

function Froute.Route(Path: string): (props: Types.RouteInfo) -> Types.Route
	return function(props: Types.RouteInfo)
		return RouteClass.new(Path, props)
	end
end

function Froute.Mount(scope: Fusion.Scope<unknown>, Router: Types.Router): (props: {}) -> Fusion.StateObject<Instance>
	return function(props: {})
		local Router: any = Router
		Router._pageProps:set(props)
		Router:_setupPage(scope)
		return Router._pageFrame
	end
end

return Froute