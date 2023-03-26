local Router = {}
Router.__index = Router

function Router.new()
	local self = setmetatable({}, Router)

	self.CurrentPath = {--[["/players","/player"]]}

	return self
end

function Router:GoTo(Path: string, props: {[string]: any}?)
	local NewPath = {}

	for Route: string in Path:gmatch("/%w+") do
		table.insert(NewPath,Route)
	end

	-- Not done

	self.CurrentPath = NewPath
end

function Router:Back(Amount: number)
	table.remove(self.CurrentPath, #self.CurrentPath)
end

return Router