local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.lib.Fusion) :: any
local Froute = require(ReplicatedStorage.lib.lib) :: any

local mainScope = Fusion.scoped(Fusion)

local router = Froute.Router(mainScope, {
	Froute.Route("/"){
		Construct = function(router, props, scope)
			table.insert(scope, function()
				print("Cleanup '/'")
			end)

			return scope:ForValues({"/players","/settings"}, function(use, scope, path: string)
				return scope:New("TextButton"){
					Size = UDim2.fromOffset(200, 50),

					Text = path,

					[Fusion.OnEvent("Activated")] = function()
						router:GoTo(path)
					end,
				}
			end)
		end,
	},
	Froute.Route("404"){
		Construct = function(router, props, scope)
			table.insert(scope, function()
				print("Cleanup 404")
			end)

			return {
				scope:New("TextLabel"){
					Size = UDim2.fromOffset(200, 50),
					Text = "Page not found! (404)",
				};
				scope:New("TextButton"){
					Size = UDim2.fromOffset(100, 50),
					Text = "Home",

					[Fusion.OnEvent("Activated")] = function()
						router:Home()
					end,
				},
			}
		end,
	},
	Froute.Route("/players"){
		Construct = function(router, props, scope)
			return scope:ForValues(Players:GetPlayers(), function(use, scope, player: Player)
				return scope:New("TextButton"){
					Size = UDim2.fromOffset(200, 50),
					Text = player.Name,

					[Fusion.OnEvent("Activated")] = function()
						router:GoTo("/players/player", {UserId = player.UserId})
					end,
				}
			end)
		end,
		[Fusion.Children] = {
			Froute.Route("/player"){
				Construct = function(router, props, scope)
					return scope:New("TextButton"){
						Size = UDim2.fromOffset(200, 50),
						Text = `Viewing {props.UserId}`,
						BackgroundColor3 = Color3.fromRGB(0, 255, 0),

						[Fusion.OnEvent("Activated")] = function()
							router:Back()
						end,
					}
				end,
			},
		},
	},
	Froute.Route("/settings"){
		Construct = function(router, props, scope)
			return scope:New("TextButton"){
				Size = UDim2.fromOffset(200, 0),

				Text = "This is the settings :)",

				BackgroundColor3 = Color3.fromRGB(0, 255, 0),

				[Fusion.OnEvent("Activated")] = function()
					-- Router:Back()
					-- Router:Home()
					router:GoTo("/players/haha")
				end,
			}
		end,
	}
})

mainScope:Observer(router.Path):onChange(function()
	print(Fusion.peek(router.Path))
end)

mainScope:New("ScreenGui"){
	Name = "App",
	Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),

	[Fusion.Children] = {
		Froute.Mount(mainScope, router){
			[Fusion.Children] = {
				mainScope:New("UIListLayout"){
					FillDirection = Enum.FillDirection.Vertical,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0,5),
				},
			},
		},
	},
}