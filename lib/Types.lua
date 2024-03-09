local FusionTypes = require(script.Parent.FusionTypes)
local Janitor = require(script.Parent.Parent.Janitor)

local Types = {}

export type Froute = {
	Router: (Routes: {Route}) -> Router;
	Route: (Path: string) -> (props: {}) -> Route;
	Mount: (Router: Router) -> (props: {}) -> FusionTypes.StateObject<Instance>;
}

export type Router = {
	GoTo: (self: Router, Path: string, props: {}?) -> nil;
	Back: (self: Router, Amount: number?) -> nil;
	Home: (self: Router) -> nil;

	Path: FusionTypes.Value<string>;
	Janitor: Janitor.Janitor;
}

export type Route = {
	Path: string,
	props: RouteInfo,
	Routes: {Route},
}

export type RouteInfo = {
	Construct: (Router: Router, props: {}) -> Instance?;
	
	[FusionTypes.SpecialKey]: {Route};
}

export type Path = {
	Route: Route;
	[string]: Path;
}

return Types