(* ::Package:: *)

(* ::Section:: *)
(*DocsPlug*)


(* ::Text:: *)
(*Implements the stuff behind the Docs plugin commands*)


(* ::Subsection:: *)
(*Exposed*)


BeginPackage["`DocsPlugin`"]
docsPluginCommands;
EndPackage[]


(* ::Subsection:: *)
(*Private*)


Begin["`DocsPlugin`Private`"]


(* ::Subsubsection::Closed:: *)
(*Shared Stuff*)


(* ::Text:: *)
(*This is shared between toolbar and plugin*)


overrideGetNbData[nb_, k_, d_]:=
	CurrentValue[nb, 
	  Flatten@{TaggingRules, "EasyIDE", "Options", TaggingRules, k}, d];
overrideGetNbData[nb_, k_]:=
	CurrentValue[nb, 
	  Flatten@{TaggingRules, "EasyIDE", "Options", TaggingRules, k}];
overrideSetNbData[nb_, k_, d_]:=
	(CurrentValue[nb, 
	  Flatten@{TaggingRules, "EasyIDE", "Options", TaggingRules, k}] = d);


patchTaggingRules[e_]:=
  e/.TaggingRules:>(Sequence@@{TaggingRules, "EasyIDE", "Options", TaggingRules});

ensureLoadProject[nb_]:=
  SimpleDocs@"EnsureLoadProject"[IDEPath[nb]];


createDocsNotebook//Clear
createDocsNotebook[notebook_]:= (* assumes already inside withIDE*)
	With[{nb=$CurrentIDENotebook},
		Block[
	    {
	      FrontEnd`$TrackingEnabled = False,
	      type = 
	        Replace[
	          Fold[Lookup[#, #2, <||>]&, Options[notebook], {TaggingRules, "Metadata", "type"}],
	          Except[_String]->"Symbol"
	          ],
	       load = ensureLoadProject[nb],
	       file = $currentFileName
	      },
	    If[StringQ@file,
	      file = StringTrim[file, "."<>FileExtension[file]]<>".nb";
	      Export[file, notebook, "Package"],
	      file = 
	        CreateProjectScratchFile[
    	      notebook,
    	      ProjectSaveDirectory[load//First, type],
    	      type
    	      ]
       ];
	    IDEOpen[nb, file];
	    IDEData[nb, {"Options", TaggingRules, "SimpleDocs", "Project"}]=
	      (Thread[{"Name", "Directory", "Config"}->load]);
	    ]
	  ];


catchCreateDocument//Clear
catchCreateDocument[expr_]:=
  Block[
    {
      CreateDocument=createDocsNotebook
      },
    expr
    ];
catchCreateDocument~SetAttributes~HoldFirst;


withIDE[expr_]:=
  Block[
   {
     EasyIDE`Dependencies`SimpleDocs`Package`Private`getNbData =
       overrideGetNbData,
     EasyIDE`Dependencies`SimpleDocs`Package`Private`setNbData =
       overrideSetNbData,
     EasyIDE`Dependencies`SimpleDocs`Package`Private`prepNotebookForDocs =
       overridePrepNotebookForDocs,
     SystemOpen = (IDEOpen[$CurrentIDENotebook, #]&),
     e = Hold[expr] // patchTaggingRules,
     $currentFileName
     },
    catchCreateDocument[
      ReleaseHold[DeleteCases[e, Verbatim[Needs]["SimpleDocs`"], \[Infinity]]]
      ]
   ];
withIDE~SetAttributes~HoldFirst;


overridePrepNotebookForDocs[nb_]:=
  Notebook[
		DeleteCases[
			NotebookGet[nb][[1]],
			Cell[_, "Metadata", ___],
			\[Infinity],
			1
			],
		Flatten@{
			FilterRules[
				IDEData[nb, "Options"], 
				Except[ScreenStyleEnvironment|StyleDefinitions|Visible]
				],
			Visible->True,
			ScreenStyleEnvironment->"Working",
			StyleDefinitions->
				Notebook[
					{
						(*Cell[
							StyleData[
								StyleDefinitions\[Rule]
									FrontEnd`FileName[{"SimpleDocs"}, "SimpleDocs.nb"]
								]
							],*)
						Cell[
							StyleData[
								StyleDefinitions->
									FrontEnd`FileName[{ParentDirectory[]}, "SimpleDocsStyles.nb"]
								]
							],
						Cell[
							StyleData[
								StyleDefinitions->
									FrontEnd`FileName[{ParentDirectory[], ParentDirectory[]}, "SimpleDocsStyles.nb"]
								]
							],
						Cell[StyleData[StyleDefinitions->"Default.nb"]],
						Cell[StyleData[All, "Editing"], MenuSortingValue->None]
						},
					StyleDefinitions->"PrivateStylesheetFormatting.nb"
					]
			}
		]


(* ::Subsubsection:: *)
(*Elements*)


docsPluginCommands = {
  "Initialize":>
    Replace[
      SimpleDocs@"InitializeProject"[IDEPath[$CurrentIDENotebook]],
      {
        s_String:>
          withIDE[SimpleDocs@"OpenConfig"[FileBaseName[s]]],
        e_:>
          CreateMessagePopup[
            StringForm["Failed to initialize docs. Got:\n``",
              e
              ]
            ]
        }
      ],
  "New Symbol":>
    withIDE@Module[
      {
        p= IDEPath[$CurrentIDENotebook],
        fn
        },
        fn = SystemDialogInput["FileSave", 
          ProjectSaveDirectory[SimpleDocs@"EnsureLoadProject"[p]//First, "Symbol"],
          WindowTitle->"Symbol Name"
          ];
        If[StringQ@fn,
          $currentFileName = fn;
          Replace[
            Names[FileBaseName[p]<>"`*"<>FileBaseName[fn]],
            {
              {f_, ___}:>
                ToExpression[f, StandardForm,
                  Function[Null, SimpleDocs@"TemplateNotebook"[#], HoldFirst]
                  ],
              _:>
                ToExpression[
                  StringDelete[FileBaseName[p], Except[WordCharacter]]<>"`"<>
                    FileBaseName[fn], StandardForm,
                  Function[Null, SimpleDocs@"TemplateNotebook"[#], HoldFirst]
                  ]
              }
            ];
          ]
        ],
  "New Guide":>
    withIDE@Module[
      {
        p= ensureLoadProject[$CurrentIDENotebook],
        fn
        },
        fn = SystemDialogInput["FileSave", 
          ProjectSaveDirectory[p//First, "Guide"],
          WindowTitle->"Guide Name"
          ];
        If[StringQ@fn,
          $currentFileName = fn;
          SimpleDocs@"TemplateNotebook"["Guide", FileBaseName[fn]];
          ]
        ],
  "New Tutorial":>
    withIDE@Module[
      {
        p= ensureLoadProject[$CurrentIDENotebook],
        fn
        },
        fn = SystemDialogInput["FileSave", 
          ProjectSaveDirectory[p//First, "Tutorial"],
          WindowTitle->"Tutorial Name"
          ];
        If[StringQ@fn,
          $currentFileName = fn;
          SimpleDocs@"TemplateNotebook"["Tutorial", FileBaseName[fn]];
          ]
        ]
  }


(* ::Subsubsection:: *)
(*Private*)


End[]


(* ::Section:: *)
(*Exposed*)


docsPluginCommands
