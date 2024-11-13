local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.lib.Fusion)
local Froute = require(ReplicatedStorage.lib.lib)

local MainScope = Fusion.scoped(Fusion)

local Router = Froute.Router(MainScope, {
	Froute.Route("/"){
		Construct = function(Router, props, scope)
			table.insert(scope, function()
				print("Cleanup '/'")
			end)

			return scope:ForValues({"/players","/settings"}, function(use, scope, Path: string)
				return scope:New("TextButton"){
					Size = UDim2.fromOffset(200,50);

					Text = Path;

					[Fusion.OnEvent("Activated")] = function()
						Router:GoTo(Path)
					end;
				}
			end);
		end;
	};
	Froute.Route("404"){
		Construct = function(Router, props, scope)
			table.insert(scope, function()
				print("Cleanup 404")
			end)

			return {
				scope:New("TextLabel"){
					Size = UDim2.fromOffset(200,50);

					Text = "Page not found! (404)";
				};
				scope:New("TextButton"){
					Size = UDim2.fromOffset(100,50);

					Text = "Home";

					[Fusion.OnEvent("Activated")] = function()
						Router:Home()
					end;
				};
			}
		end;
	};
	Froute.Route("/players"){
		Construct = function(Router, props, scope)
			return scope:ForValues(Players:GetPlayers(), function(use, scope, Player: Player)
				return scope:New("TextButton"){
					Size = UDim2.fromOffset(200,50);

					Text = Player.Name;

					[Fusion.OnEvent("Activated")] = function()
						Router:GoTo("/players/player", {UserId = Player.UserId})
					end;
				}
			end);
		end;
		[Fusion.Children] = {
			Froute.Route("/player"){
				Construct = function(Router, props, scope)
					return scope:New("TextButton"){
						Size = UDim2.fromOffset(200, 50);

						Text = `Viewing {props.UserId}`;

						BackgroundColor3 = Color3.fromRGB(0,255,0);

						[Fusion.OnEvent("Activated")] = function()
							Router:Back()
						end;
					};
				end;
			};
		};
	};
	Froute.Route("/settings"){
		Construct = function(Router, props, scope)
			return scope:New("TextButton"){
				Size = UDim2.fromOffset(200,50);

				Text = "This is the settings :)";

				BackgroundColor3 = Color3.fromRGB(0,255,0);

				[Fusion.OnEvent("Activated")] = function()
					-- Router:Back()
					-- Router:Home()
					Router:GoTo("/players/haha")
				end;
			};
		end;
	};
})

MainScope:Observer(Router.Path):onChange(function()
	print(Fusion.peek(Router.Path))
end)

local App = MainScope:New("ScreenGui"){
	Name = "App";

	Parent = Players.LocalPlayer:WaitForChild("PlayerGui");

	[Fusion.Children] = {
		Froute.Mount(MainScope, Router){
			[Fusion.Children] = {
				MainScope:New("UIListLayout"){
					FillDirection = Enum.FillDirection.Vertical;

					VerticalAlignment = Enum.VerticalAlignment.Center;
					HorizontalAlignment = Enum.HorizontalAlignment.Center;

					SortOrder = Enum.SortOrder.LayoutOrder;

					Padding = UDim.new(0,5);
				};
			};
		};
	};
}