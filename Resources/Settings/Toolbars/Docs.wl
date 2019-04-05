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
batchDocs;
showMenuButton;
EndPackage[];


(* ::Subsection:: *)
(*Private*)


Begin["`DocsToolbar`Private`"];


(* ::Subsubsection:: *)
(*Elements*)


metadataEditor =
 Button[
  "Edit Metadata",
  OpenMetadataEditor[EvaluationNotebook[]],
  Appearance->Inherited,
  FrameMargins->{{10,10},{0,0}},
  ImageSize->{Automatic,28},
  Method->"Queued"
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
          (k:>WithDocsIDE[$CurrentIDENotebook, v])
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


batchDocs=
  Button[
    "Create Batch Docs",
    CreateMessagePopup[
      Row@{"Creating docs", ProgressIndicator[Appearance->"Ellipsis"]}
      ];
    CreateBatchSymbolPages[EvaluationNotebook[]];
    CreateMessagePopup["Batch docs created"],
    Appearance->Inherited,
    FrameMargins->{{10,10},{0,0}},
    ImageSize->{Automatic,28},
    Method->"Queued"
    ]


edits = {
  "Insert Raw Markdown":>
    {
      NotebookWrite[EvaluationNotebook[], Cell["", "RawMarkdown"]],
      Method->"Preemptive"
      },
  "Function Link":>
    {
      NotebookWrite[EvaluationNotebook[], 
        TextData@{
          Cell[" | ", "Text"], 
          ButtonBox["FunctionName", 
            BaseStyle->{"Link", "Input"},
            ButtonData->"paclet:Paclet/ref/FunctionName"
            ]
          }
        ],
      Method->"Preemptive"
      }
  }
If[!ValueQ[menuState], menuState  = <||>];
showMenuButton=
  Button[
    "Edits Menu",
    If[KeyExistsQ[menuState, "RootCell"],
      DestroyDropDownMenu[Dynamic[menuState]],
      AttachDropDownMenu[
        Dynamic[menuState],
        edits,
        "AttachToCell"->True,
        "DestroyOnClick"->False
        ]
      ],
    Appearance->Inherited,
    FrameMargins->{{10,10},{0,0}},
    ImageSize->{Automatic,28},
    Method->"Queued"
    ]


(* ::Subsubsection:: *)
(*End*)


End[]


(* ::Section:: *)
(*Exposed Content*)


{
  metadataEditor,
  docsTemplates,
  docsOpsMenu,
  batchDocs,
  showMenuButton
  }
