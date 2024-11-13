local Types = require(script.Parent.Parent.Types)
local Fusion = require(script.Parent.Parent.Parent.Fusion)

local Router = {}
Router.__index = Router

local function recursiveGet(Value: any): any
	local LastValue

	while (LastValue ~= Value) do
		LastValue = Value
		Value = Fusion.peek(Value)
	end

	return Value
end

local function loopRoute(Routes: {Types.Route})
	local Output = {}

	for _, Route: Types.Route in pairs(Routes or {}) do
		local ChildrenRoutes: {[string]: Types.Route} = loopRoute(Route.Routes)
		ChildrenRoutes["Route"] = Route

		Output[Route.Path] = ChildrenRoutes
	end

	return Output
end

function Router.new(scope: Fusion.Scope<unknown>, Routes: {Types.Route})
	local self = setmetatable({
		Path = Fusion.Value(scope, "");
		_currentRoute = nil;

		_pathProps = {} :: {[string]: {}};
		Routes = {};

		_scope = scope;
		_routeScope = Fusion.innerScope(scope);
	}, Router)

	for _, Route: Types.Route in Routes do
		self:AddRoute(Route)
	end

	self._fixedRoutes = loopRoute(self.Routes)

	self._pageValue = Fusion.Value(scope, nil)
	self._pageChildren = Fusion.Value(scope, {})
	self._pageProps = Fusion.Value(scope, {})
	self._pageFrame = Fusion.New(scope, "Frame"){
		Name = "Page";

		Size = UDim2.fromScale(1, 1);

		Position = UDim2.fromScale(.5, .5);
		AnchorPoint = Vector2.new(.5, .5);

		BackgroundTransparency = 1;

		[Fusion.Children] = {
			self._pageChildren;
			Fusion.Computed(scope, function(use, scope)
				return use(self._pageValue)
			end);
		};
	};

	self:Home()

	return self
end

-->-----------------<--
--> Private Methods <--
-->-----------------<--

function Router:_update()
	local CurrentPath: Types.Path = self._fixedRoutes

	CurrentPath = CurrentPath[table.concat(self.CurrentPath)] or {Route = nil}

	self._currentRoute = CurrentPath.Route :: Types.Route?

	if (self.LastRoute ~= self.CurrentPath) then
		-- self.Janitor:Cleanup()
		Fusion.doCleanup(self._routeScope)
		self._routeScope = Fusion.innerScope(self._scope)
		self.Path:set(table.concat(self.CurrentPath))
		self:_setupPage()
	end

	local Page: Instance?
	if (self._currentRoute) then
		Page = self._currentRoute:Construct(self, self._pathProps[Fusion.peek(self.Path)], self._routeScope)
	elseif (self._fixedRoutes["404"]) and (self._fixedRoutes["404"].Route) then
		Page = self._fixedRoutes["404"].Route:Construct(self, nil, self._routeScope)
	end
	self._pageValue:set(recursiveGet(Page))

	self.LastRoute = self._currentRoute
end

function Router:_setupPage()
	if not (self._pageFrame) then return end

	local props: {[any]: any?} = Fusion.peek(self._pageProps) or {}

	self._pageChildren:set(props[Fusion.Children] or {})
end

-->---------<--
--> Methods <--
-->---------<--

function Router:GoTo(Path: string, props: {[string]: any}?)
	local NewPath = {}

	for Route: string in Path:gmatch("/%w*") do
		table.insert(NewPath, Route)
	end

	if (#NewPath == 0) then
		table.insert(NewPath, if (#Path > 0) then "404" else "/")
	end

	self._pathProps[Path] = props

	self.Path:set(Path)
	self.CurrentPath = NewPath

	self:_update()
end

function Router:Back(Amount: number?)
	for _ = 1, (Amount or 1) do
		table.remove(self.CurrentPath, #self.CurrentPath)
	end
	if (#self.CurrentPath == 0) then
		table.insert(self.CurrentPath, "/")
	end
	self:_update()
end

function Router:Home()
	self.CurrentPath = {"/"}
	self:_update()
end

function Router:AddRoute(Route: Types.Route)
	table.insert(self.Routes, Route)
	self._fixedRoutes = loopRoute(self.Routes)
end

return Router