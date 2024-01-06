local Types = require(script.Parent.Parent.Types)
local Fusion = require(script.Parent.Parent.Parent.Fusion)
local Janitor = require(script.Parent.Parent.Parent.Janitor)

local Router = {}
Router.__index = Router

local function get(Value: any): any
	if (type(Value) == "table") and (type(Value.get) == "function") then
		return Value:get()
	end

	return Value
end

local function recursiveGet(Value: any): any
	local LastValue

	while (LastValue ~= Value) do
		LastValue = Value
		Value = get(Value)
	end

	return Value
end

function Router.new(Routes: {Types.Route})
	local self = setmetatable({
		Janitor = Janitor.new();

		Path = Fusion.Value("");
		CurrentRoute = nil;

		PathProps = {} :: {[string]: {}};
		Routes = Routes;
	}, Router)

	local function LoopRoute(Routes: {Types.Route})
		local Output = {}

		for _, Route: Types.Route in Routes or {} do
			local ChildrenRoutes: {Types.Route} = LoopRoute(Route.Routes)
			ChildrenRoutes["Route"] = Route

			Output[Route.Path] = ChildrenRoutes
		end

		return Output
	end

	self.FixedRoutes = LoopRoute(self.Routes)

	self.PageValue = Fusion.Value()
	self.PageChildren = Fusion.Value{}
	self.PageProps = Fusion.Value{}
	self.PageFrame = Fusion.New("Frame"){
		Name = "Page";

		Size = UDim2.fromScale(1,1);

		Position = UDim2.fromScale(.5,.5);
		AnchorPoint = Vector2.new(.5,.5);

		BackgroundTransparency = 1;

		[Fusion.Children] = {
			self.PageChildren;
			Fusion.Computed(function()
				return self.PageValue:get()
			end,Fusion.cleanup);
		};
	};

	self:Home()

	return self
end

function Router:__Update()
	local CurrentPath: {
		Route: Types.Route;
		[string]: {};
	} = self.FixedRoutes

	CurrentPath = CurrentPath[table.concat(self.CurrentPath)] or {}

	self.CurrentRoute = CurrentPath.Route :: Types.Route?

	if (self.LastRoute ~= self.CurrentPath) then
		self.Janitor:Cleanup()
		self.Path:set(table.concat(self.CurrentPath))
		self:SetupPage()
	end

	local Page =
		if (self.CurrentRoute) then self.CurrentRoute:Construct(self, self.PathProps[self.Path:get()])
		elseif (self.FixedRoutes["404"]) and (self.FixedRoutes["404"].Route) then self.FixedRoutes["404"].Route:Construct(self)
		else nil
	self.PageValue:set(recursiveGet(Page))

	self.LastRoute = self.CurrentRoute
end

function Router:SetupPage()
	if not (self.PageFrame) then return end

	local props: {[string]: any?} = self.PageProps:get() or {}

	self.PageChildren:set(props[Fusion.Children] or {})
end

function Router:GoTo(Path: string, props: {[string]: any}?)
	local NewPath = {}

	for Route: string in Path:gmatch("/%w*") do
		table.insert(NewPath, Route)
	end

	if (#NewPath == 0) then
		table.insert(NewPath, if (#Path > 0) then "404" else "/")
	end
	
	self.PathProps[Path] = props
	
	self.Path:set(Path)
	self.CurrentPath = NewPath

	self:__Update()
end

function Router:Back(Amount: number?)
	for _ = 1, (Amount or 1) do
		table.remove(self.CurrentPath, #self.CurrentPath)
	end
	if (#self.CurrentPath == 0) then
		table.insert(self.CurrentPath, "/")
	end
	self:__Update()
end

function Router:Home()
	self.CurrentPath = {"/"}
	self:__Update()
end

return Router