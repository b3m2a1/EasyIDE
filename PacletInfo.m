Paclet[
  Name -> "EasyIDE",
  Version -> "1.0.1",
  Extensions -> {
    	{
     		"Kernel",
     		"Root" -> ".",
     		"Context" -> {"EasyIDE`"}
     	},
    	{
     		"FrontEnd",
     		"Prepend" -> True,
     		Prepend -> True
     	},
    	{
     		"Resource",
     		"Root" -> "Resources",
     		"Resources" -> {
       			"Plugins",
       			"Settings",
       			"StyleSheets",
       			{
        				"Apps",
        				"Plugins/Apps.wl"
        			},
       			{
        				"FileMenu",
        				"Plugins/FileMenu.wl"
        			},
       			{
        				"Git",
        				"Plugins/Git.wl"
        			},
       			{
        				"ExtensionStylesMap",
        				"Settings/ExtensionStylesMap.wl"
        			},
       			{
        				"Custom",
        				"StyleSheets/Custom.nb"
        			}
       		}
     	}
    }
 ]