<p align="center">
	<img src=".github/FrouteBackground.svg" height="150">
</p>

# Installation
* [Wally](https://wally.run/package/xswezan/froute)

# Documentation
The docs are WIP, but I'll show you an example of how to use it for now.
```lua
local Router = Froute.Router{
	Froute.Route("/"){ -- Home page
		Construct = function(Router, props){
			return Fusion.New("Frame"){}	
		};
	};
	Froute.Route("404"){ -- Page not found (NOT NECESSARY)
		Construct = function(Router, props)
			return Fusion.New("TextButton"){
				Size = UDim2.fromOffset(200,50);
				
				Text = "Page not found (404)";
				
				[Fusion.OnEvent("Activated")] = function()
					Router:Home() -- Go home if button clicked
				end;
			};
		end;
	};
	Froute.Route("/settings"){
		Construct = function(Router, props)
			return Fusion.New("Frame"){}
		end;
	};
	Froute.Route("/players"){
		Construct = function(Router, props)
			return Fusion.New("Frame"){}
		end;

		[Fusion.Children] = {
			Froute.Route("/player"){
				Construct = function(Router, props)
					return Fusion.New("TextLabel"){Text = props.UserId}
				end;
			};
		};
	};
}

local App = Fusion.New("ScreenGui"){
	Name = "App";
	
	[Fusion.Children] = {
		Froute.Mount(Router); -- Returns a StateObject that contains current page
	};
}
```
And here are some of the methods of the Router
```lua
Router:GoTo(path: string, props: {[string]: any}?) -- Go to path with custom props (basically just data sent to the constructor function)
Router:Back(Amount: number?) -- Go back one or more steps
Router:Home() -- Goes to the home page
```
Froute does also have typings, so those can help you too.
