(* ::Package:: *)

Paclet[
  Name -> "EasyIDE",
  Version -> "1.0.10",
  Creator -> "b3m2a1 <b3m2a1@gmail.com>",
  URL -> "https://github.com/b3m2a1/EasyIDE",
  Description -> "An IDE for Mathematica written entirely within Mathematica",
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
     		"PacletServer",
     		"Description" -> 
      "An IDE for Mathematica. Supports tabbing, file browsing, plugins, customizable stylesheets, extension specific tweaks and toolbars, and is reasonably customizable",
     		"License" -> "MIT"
     	},
    	{
     		"Resource",
     		"Root" -> "Resources",
     		"Resources" -> {
       			"Settings",
       			"StyleSheets",
       			{
        				"ExtensionStylesMap",
        				"Settings/Mappings/ExtensionStylesMap.wl"
        			},
       			{
        				"ExtensionToolbarsMap",
        				"Settings/Mappings/ExtensionToolbarsMap.wl"
        			},
       			{
        				"FileViewerStylesMap",
        				"Settings/Mappings/FileViewerStylesMap.wl"
        			},
       			{
        				"StylesheetStylesMap",
        				"Settings/Mappings/StylesheetStylesMap.wl"
        			},
       			{
        				"StylesheetToolbarsMap",
        				"Settings/Mappings/StylesheetToolbarsMap.wl"
        			},
       			{
        				"Apps",
        				"Settings/Plugins/Apps.wl"
        			},
       			{
        				"BugTracker",
        				"Settings/Plugins/BugTracker.wl"
        			},
       			{
        				"Docs",
        				"Settings/Plugins/Docs.wl"
        			},
       			{
        				"FileMenu",
        				"Settings/Plugins/FileMenu.wl"
        			},
       			{
        				"Git",
        				"Settings/Plugins/Git.wl"
        			},
       			{
        				"Paclets",
        				"Settings/Plugins/Paclets.wl"
        			},
       			{
        				"ProjectMenu",
        				"Settings/Plugins/ProjectMenu.wl"
        			},
       			{
        				"SiteBuilder",
        				"Settings/Plugins/SiteBuilder.wl"
        			},
       			{
        				"CodePackage",
        				"Settings/Toolbars/CodePackage.wl"
        			},
       			{
        				"Markdown",
        				"Settings/Toolbars/Markdown.wl"
        			},
       			{
        				"Package",
        				"Settings/Toolbars/Package.wl"
        			},
       			{
        				"Custom",
        				"StyleSheets/Custom.nb"
        			},
       			{
        				"Mappings",
        				"Settings/Mappings"
        			},
       			{
        				"Plugins",
        				"Settings/Plugins"
        			},
       			{
        				"Toolbars",
        				"Settings/Toolbars"
        			}
       		}
     	},
    	{
     		"Documentation",
     		"Language" -> "English",
     		"MainPage" -> "English/SimpleDocsStyles"
     	}
    }
 ]
