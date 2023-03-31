local FusionTypes = require(script.Parent.FusionTypes)

local Types = {}

export type Froute = {
	Router: (Routes: {}) -> Router;
	Route: (Path: string) -> (props: {}) -> Route;
	Mount: (Router: Router) -> FusionTypes.StateObject<Instance>;
}

export type Router = {
	GoTo: (self: Router, Path: string, props: {}?) -> nil;
	Back: (self: Router, Amount: number?) -> nil;
	Home: (self: Router) -> nil;

	Path: FusionTypes.Value<string>;
}

export type Route = {
	
}

export type RouteInfo = {
	Construct: (Router: Router, props: {}) -> Instance?;
	
	[FusionTypes.Children]: {Route};
}

return Types