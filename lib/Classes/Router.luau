local Types = require(script.Parent.Parent.Types)
local Fusion = require(script.Parent.Parent.Parent.Fusion)

local Router = {}
Router.__index = Router

local function recursiveGet(value: any): any
	local lastValue: any

	while (lastValue ~= value) do
		lastValue = value
		value = Fusion.peek(value)
	end

	return value
end

local function loopRoute(routes: {Types.Route})
	local output = {}

	for _, route: Types.Route in pairs(routes or {}) do
		local childrenRoutes: {[string]: Types.Route} = loopRoute(route.Routes)
		childrenRoutes["Route"] = route

		output[route.Path] = childrenRoutes
	end

	return output
end

function Router.new(scope: Fusion.Scope<unknown>, routes: {Types.Route})
	local self = setmetatable({
		Path = Fusion.Value(scope, "");
		_currentRoute = nil;

		_pathProps = {} :: {[string]: {}};
		Routes = {};

		_scope = scope;
		_routeScope = Fusion.innerScope(scope);
	}, Router)

	for _, route: Types.Route in routes do
		self:AddRoute(route)
	end

	self._fixedRoutes = loopRoute(self.Routes)

	self._pageValue = Fusion.Value(scope, nil)
	self._pageChildren = Fusion.Value(scope, {})
	self._pageProps = Fusion.Value(scope, {})
	self._pageFrame = Fusion.New(scope, "Frame"){
		Name = "Page";

		Size = UDim2.fromScale(1, 1),

		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),

		BackgroundTransparency = 1,

		[Fusion.Children] = {
			self._pageChildren,
			Fusion.Computed(scope, function(use, scope)
				return use(self._pageValue)
			end),
		}
	}

	self:Home()

	return self
end

-->-----------------<--
--> Private Methods <--
-->-----------------<--

function Router:_update()
	local currentPath: Types.Path = self._fixedRoutes
	currentPath = currentPath[table.concat(self.CurrentPath)] or {Route = nil}

	self._currentRoute = currentPath.Route :: Types.Route?

	if (self.LastRoute ~= self.CurrentPath) then
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

function Router:GoTo(path: string, props: {[string]: any}?)
	local newPath = {}

	for route: string in path:gmatch("/%w*") do
		table.insert(newPath, route)
	end

	if (#newPath == 0) then
		table.insert(newPath, if (#path > 0) then "404" else "/")
	end

	self._pathProps[path] = props

	self.Path:set(path)
	self.CurrentPath = newPath

	self:_update()
end

function Router:Back(amount: number?)
	for _ = 1, (amount or 1) do
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

function Router:AddRoute(route: Types.Route)
	table.insert(self.Routes, route)
	self._fixedRoutes = loopRoute(self.Routes)
end

return Router