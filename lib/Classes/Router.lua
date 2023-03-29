local Types = require(script.Parent.Parent.Types)
local Fusion = require(script.Parent.Parent.Parent.Fusion)
local RouteClass = require(script.Parent.Route)

local Router = {}
Router.__index = Router

function Router.new(Routes: {Types.Route})
	local self = setmetatable({}, Router)

	self.CurrentPathRaw = ""
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

	local Page =
		if (self.CurrentRoute) then self.CurrentRoute:Construct(self,self.PathProps[self.CurrentPathRaw])
		elseif (self.FixedRoutes["404"]) and (self.FixedRoutes["404"].Route) then self.FixedRoutes["404"].Route:Construct(self)
		else nil
	self.PageValue:set(Page)
end

function Router:GoTo(Path: string, props: {[string]: any}?)
	local NewPath = {}

	for Route: string in Path:gmatch("/%w*") do
		table.insert(NewPath,Route)
	end

	if (#NewPath == 0) then
		if (#Path > 0) then
			table.insert(NewPath,"404")
		else
			table.insert(NewPath,"/")
		end
	end
	
	self.PathProps[Path] = props
	
	self.CurrentPathRaw = Path
	self.CurrentPath = NewPath

	self:__Update()
end

function Router:Back(Amount: number?)
	for _ = 1, (Amount or 1) do
		table.remove(self.CurrentPath, #self.CurrentPath)
	end
	if (#self.CurrentPath == 0) then
		table.insert(self.CurrentPath,"/")
	end
	self:__Update()
end

function Router:Home()
	self.CurrentPath = {"/"}
	self:__Update()
end

return Router