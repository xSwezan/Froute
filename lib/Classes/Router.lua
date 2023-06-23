local Types = require(script.Parent.Parent.Types)
local Fusion = require(script.Parent.Parent.Parent.Fusion)

local Router = {}
Router.__index = Router

function Router.new(Routes: {Types.Route})
	local self = setmetatable({}, Router)

	self.Path = Fusion.Value("")
	self.CurrentRoute = nil

	self.PathProps = {} :: {[string]: {}}
	self.Routes = Routes

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

	for _, Path: string in ipairs(self.CurrentPath) do
		CurrentPath = CurrentPath[Path]

		if not (CurrentPath) then
			CurrentPath = {}
			break
		end
	end

	self.CurrentRoute = CurrentPath.Route :: Types.Route?

	if (self.LastRoute ~= self.CurrentPath) then
		self.Path:set(table.concat(self.CurrentPath))
		self:SetupPage()
	end

	local Page =
		if (self.CurrentRoute) then self.CurrentRoute:Construct(self, self.PathProps[self.Path:get()])
		elseif (self.FixedRoutes["404"]) and (self.FixedRoutes["404"].Route) then self.FixedRoutes["404"].Route:Construct(self)
		else nil
	self.PageValue:set(Page)

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