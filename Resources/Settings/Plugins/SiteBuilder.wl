(* ::Package:: *)

BeginPackage["`MarkdownPlugin`"];
createNewSite;
createNewPost;
createNewPage;
createNewMd;
EndPackage[];


Begin["`Private`"];


createNewSite[]:=
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
      ]


getWebSitePath[]:=
  FileNameJoin@Flatten@
    Replace[
      SplitBy[
         FileNameSplit[IDEPath[]],
         #=="content"&
         ],
      {a___, {"content"}, _}:>{a}
      ]


createNewPost[]:=
  Block[
     {
       NotebookOpen=IDEOpen,
       SystemOpen=IDEOpen
       },
     Ems["NewPost", getWebSitePath[]]
     ]


createNewPage[]:=
  Block[
     {
       NotebookOpen=IDEOpen,
       SystemOpen=IDEOpen
       },
     Ems["NewPost", getWebSitePath[]]
     ]


createNewMd[]:=
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
   ];


End[]


{
  "Initialize":>
    createNewSite[],
   "New Post":>
     createNewPost[],
   "New Page":>
     createNewPage[],
   "New Markdown":>
     createNewMarkdown[]
}
