(* ::Package:: *)

{
  "Initialize":>
    CreateAttachedDialog[
      <|
        "Fields"->
          {
				    	"Provide a name for the site:",
				    	<|
				    	  "Name"->"SiteName"
				    	  |>,
    					"Pick a template for the site:",
    					With[
  					 		{
  							 	ops=
  							 	  FileBaseName/@Select[DirectoryQ]@
    					 				FileNames["*", 
                     PackageFilePath["Dependencies", "Ems", "Resources", "Templates"]
                     ]
  					 			},
  					 		<|
  					 		  "Name"->"SiteTemplate",
  					 		  "Type"->{RadioButtonBar, ops},
  					 		  "Default"->First@ops,
  					 		  "Options"->{
  					 		    Appearance -> "Horizontal" -> {Automatic, 2}
  					 		    }
  					 		  |>
  						  ]
  					 },
  				"SubmitAction"->
  				  Function[
  				    CreatePopupMessage[
  				      StringForm[
    				      "Created new site in ``",
                Ems["New",
                  IDEPath[],
                  #SiteName,
                  #SiteTemplate
                  ]
                ]
              ]
  				    ]
  				|>
      ],
   "New Post":>
     Block[
       {
         NotebookOpen=IDEOpen
         },
       Ems["NewPost", 
         SplitBy[
           FileNameJoin@FileNameSplit[IDEPath[]],
           #=="content"&
           ]
         ]
       ],
   "New Page":>
     IDEOpen[
       Ems["NewPage", IDEPath[]]
       ],
   "New Markdown":>
     Block[
       {
         NotebookOpen=IDEOpen,
         SystemOpen=IDEOpen
         },
       Ems["NewPost", 
         If[!DirectoryQ[#],
           CreateDirectory[#, CreateIntermediateDirectories->True]
           ]&@FileNameJoin@{IDEPath[".scratch"], "content", "posts"};
         IDEPath[".scratch"]
         ]
       ]
}
