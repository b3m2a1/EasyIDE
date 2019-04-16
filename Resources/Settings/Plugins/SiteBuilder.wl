(* ::Package:: *)

(* ::Section:: *)
(*SiteBuilder/Markdown Plugin*)


BeginPackage["`MarkdownPlugin`"];
siteBuilderCommands;
EndPackage[];


(* ::Subsection:: *)
(*Private*)


Begin["`Private`"];


(* ::Subsubsection:: *)
(*createNewSite*)


createNewSite[]:=
  CreateAttachedInputDialog[
      <|
        "Header"->"Create a New Site",
        "Fields"->
          {
				    	"Provide a name for the site:",
				    	<|
				    	  "ID"->"SiteName",
				    	  "Name"->None
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
  					 		  "ID"->"SiteTemplate",
  					 		  "Name"->None,
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
  				    CreateMessagePopup[
  				      StringForm[
    				      "Created new site in ``",
                Ems["New", FileNameJoin@{IDEPath[], #SiteName}, #SiteTemplate]
                ]
              ]
  				    ]
  				|>
      ]


(* ::Subsubsection::Closed:: *)
(*getWebSitePath*)


getWebSitePath[]:=
  FileNameJoin@Flatten@
    Replace[
      SplitBy[
         FileNameSplit[IDEPath[]],
         #=="content"&
         ],
      {a___, {"content"}, _}:>{a}
      ]


(* ::Subsubsection::Closed:: *)
(*createNewPost*)


createNewPost[]:=
  Block[
     {
       NotebookOpen=IDEOpen,
       SystemOpen=IDEOpen
       },
     Ems["NewPost", getWebSitePath[]]
     ]


(* ::Subsubsection::Closed:: *)
(*createNewPage*)


createNewPage[]:=
  Block[
     {
       NotebookOpen=IDEOpen,
       SystemOpen=IDEOpen
       },
     Ems["NewPost", getWebSitePath[]]
     ]


(* ::Subsubsection::Closed:: *)
(*createNewMd*)


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


(* ::Subsubsection::Closed:: *)
(*openSite*)


openSite[]:=
  Ems["Open", getWebSitePath[]]


(* ::Subsubsection::Closed:: *)
(*buildSite*)


buildSite[]:=
  CreateWindowedInputDialog[
    <|
      "Header"->"Build Site",
      "State"->Dynamic[buildSiteState],
      "Fields"-> <|
        <|
          "ID"->"Settings",
          "Name"->None,
          "Type"->{CheckboxBar, 
            {
              "GC"->"Generate Content",
              "GA"->"Generate Aggregations",
              "GI"->"Generate Index",
              "GS"->"Generate Search",
              "CT"->"Copy Theme",
              "UC"->"Use Cache",
              "OP"->"Open on Build",
              "BS"->"Build Silently",
              "RA"->"Rebuild All"
              },
            Appearance->"Horizontal"->{Automatic, 2}
            },
          "Default"->{
            If[$generatContentFlag=!=False, "GC", Nothing],
            If[$generateAggregationsFlag=!=False, "GA", Nothing],
            If[$generatIndexFlag=!=False, "GI", Nothing],
            If[$generateSearchFlag=!=False, "GS", Nothing],
            If[$copyThemeFlag=!=False, "CT", Nothing],
            If[$useCacheFlag=!=False, "UC", Nothing],
            If[$buildSilentFlag//TrueQ, "BS", Nothing],
            If[$openOnGenerateFlag//TrueQ, "OP", Nothing],
            If[$rebuildAllFlag//TrueQ, "RA", Nothing]
            }
          |>
        |>,
      "SubmitAction"->
        {
          Function[
            $generatContentFlag=MemberQ[#Settings, "GC"];
            $generateAggregationsFlag=MemberQ[#Settings, "GA"];
            $generatIndexFlag=MemberQ[#Settings, "GI"];
            $generateSearchFlag=MemberQ[#Settings, "GS"];
            $copyThemeFlag=MemberQ[#Settings, "CT"];
            $useCacheFlag=MemberQ[#Settings, "UC"];
            $buildSilentFlag=MemberQ[#Settings, "BS"];
            $openOnGenerateFlag=MemberQ[#Settings, "OP"];
            $rebuildAllFlag=MemberQ[#Settings, "RA"];
            Module[{popup, r},
              popup = 
                CreateMessagePopup@
                  Row@{"Building site", ProgressIndicator[Appearance->"Ellipsis"]};
              r=
    		      		Ems["Build",
              			getWebSitePath[],
              			Monitor->TrueQ@Not@$buildSilentFlag,
              			"GenerateAggregations"->
              				$generateAggregationsFlag=!=False,
              			"GenerateIndex"->
              				$generatIndexFlag=!=False,
              			"GenerateContent"->
              				$generatContentFlag=!=False,
              			"CopyTheme"->
              				$copyThemeFlag=!=False,
              			"GenerateSearchPage"->
              				$generateSearchFlag=!=False,
              			"UseCache"->
              				$useCacheFlag=!=False,
              			If[TrueQ@$rebuildAllFlag,
              				"LastBuild"->None,
              				Sequence@@{}
              				]
              			];
              		If[$openOnGenerateFlag=!=False,
              			Ems["Open", getWebSitePath[]]
              			];
              NotebookDelete[popup];
              CreateMessagePopup@"Site built"
        				]
            ],
          Method->"Queued"
          }
      |>
    ];


(* ::Subsubsection::Closed:: *)
(*commands*)


siteBuilderCommands=
  {
    "Initialize":>
      createNewSite[],
     "New"->{
        "Post":>
         createNewPost[],
       "Page":>
         createNewPage[],
       "Markdown":>
         createNewMarkdown[]
         },
     "Open Site":>
       openSite[],
     "Build Site":>
       buildSite[]
    };


(* ::Subsubsection::Closed:: *)
(*End*)


End[]


(* ::Subsection:: *)
(*Exports*)


siteBuilderCommands
