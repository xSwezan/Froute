local Fusion = require()
local Froute = require()

local Router = Froute.Router{
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

