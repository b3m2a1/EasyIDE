(* ::Package:: *)

(* ::Section:: *)
(*DocsToolbar*)


(* ::Text:: *)
(*Implements the toolbar for the Docs stylesheets*)


(* ::Subsection:: *)
(*Exported*)


BeginPackage["`DocsToolbar`"];
metadataEditor;
docsTemplates;
docsOpsMenu;
EndPackage[];


(* ::Subsection:: *)
(*Private*)


Begin["`DocsToolbar`Private`"];


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


metadataEditor =
  RawBoxes@
    ReplaceAll[
      ToBoxes@
        Framed[
          $MetadataEditor // patchTaggingRules,
          ImageSize->{{100, 500}, {55, 1000}},
          Background->White,
          RoundingRadius->5,
          BaseStyle->"Panel",
          FrameStyle->GrayLevel[.8]
          ],
      TagBox[g_GridBox, "Grid"]:>g
      ]


docsTemplates = 
  ReplacePart[$InsertionMenu, 
    1-> 
     Button[
      "Insert",
      BaseStyle->"PluginMenu",
      Appearance->Inherited,
      FrameMargins->{{10,10},{0,0}},
      ImageSize->{Automatic,28}
      ]
    ];


docsOpsMenu=
  ReplacePart[
    Replace[$HamburgerMenu, 
      {
        (k_:>v_):>
          k:>withIDE[v]
        },
      2
      ],
    1-> 
     Button[
      "Menu",
      BaseStyle->"PluginMenu",
      Appearance->Inherited,
      FrameMargins->{{10,10},{0,0}},
      ImageSize->{Automatic,28}
      ]
    ]


(* ::Subsubsection:: *)
(*End*)


End[]


(* ::Section:: *)
(*Exposed Content*)


{
  metadataEditor,
  docsTemplates,
  docsOpsMenu
  }
