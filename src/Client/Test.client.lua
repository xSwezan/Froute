local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.lib.Fusion)
local Froute = require(ReplicatedStorage.lib)

local Router = Froute.Router{
	Froute.Route("/"){
		Construct = function(Router, props)
			return Fusion.ForValues({"/players","/settings"},function(Path: string)
				return Fusion.New("TextButton"){
					Size = UDim2.fromOffset(200,50);
					
					Text = Path;
					
					[Fusion.OnEvent("Activated")] = function()
						Router:GoTo(Path)
					end;
				}
			end,Fusion.cleanup);
		end;
	};
	Froute.Route("404"){
		Construct = function(Router, props)
			return {
				Fusion.New("TextLabel"){
					Size = UDim2.fromOffset(200,50);
	
					Text = "Page not found! (404)";
				};
				Fusion.New("TextButton"){
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
		Construct = function(Router, props)
			return Fusion.ForValues(Players:GetPlayers(),function(Player: Player)
				return Fusion.New("TextButton"){
					Size = UDim2.fromOffset(200,50);
	
					Text = Player.Name;
	
					[Fusion.OnEvent("Activated")] = function()
						Router:GoTo("/players/player",{UserId = Player.UserId})
					end;
				}
			end,Fusion.cleanup);
		end;
		[Fusion.Children] = {
			Froute.Route("/player"){
				Construct = function(Router, props)
					return Fusion.New("TextButton"){
						Size = UDim2.fromOffset(200,50);
		
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
		Construct = function(Router, props)
			return Fusion.New("TextButton"){
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
}

Fusion.Observer(Router.Path):onChange(function()
	print(Router.Path:get())
end)

local App = Fusion.New("ScreenGui"){
	Name = "App";
	
	Parent = Players.LocalPlayer:WaitForChild("PlayerGui");
	
	[Fusion.Children] = {
		Froute.Mount(Router){
			[Fusion.Children] = {
				Fusion.New("UIListLayout"){
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