(* ::Package:: *)

Paclet[
  Name -> "EasyIDE",
  Version -> "1.0.0",
  Extensions -> {
    	{
     		"Kernel",
     		"Root" -> ".",
     		"Context" -> {"EasyIDE`"}
     	},
    	{
     		"Resource",
     		"Root" -> "Resources",
     		"Resources" -> {
       			{
        				"Tab.9",
        				"Tab.9.png"
        			}
       		}
     	},
    	{
     		"FrontEnd",
     		Prepend -> True
     	}
    }
 ]
