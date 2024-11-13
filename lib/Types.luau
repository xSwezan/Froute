local Fusion = require(script.Parent.Parent.Fusion)

local Types = {}

export type Froute = {
	Router: (scope: Fusion.Scope<unknown>, Routes: {Route}) -> Router;
	Route: (Path: string) -> (props: {}) -> Route;
	Mount: (scope: Fusion.Scope<unknown>, Router: Router) -> (props: {}) -> Fusion.StateObject<Instance>;
}

export type Router = {
	GoTo: (self: Router, Path: string, props: {}?) -> nil;
	Back: (self: Router, Amount: number?) -> nil;
	Home: (self: Router) -> nil;
	AddRoute: (self: Router, Route: Route) -> nil;

	Path: Fusion.Value<string, Fusion.Scope<unknown>>;
}

export type Route = {
	Path: string,
	props: RouteInfo,
	Routes: {Route},
}

export type RouteInfo = {
	Construct: (Router: Router, props: {}, scope: Fusion.Scope<unknown>) -> Instance?;

	[Fusion.SpecialKey]: {Route};
}

export type Path = {
	Route: Route;
	[string]: Path;
}

return Types