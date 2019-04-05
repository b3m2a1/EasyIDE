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


(* ::Subsubsection:: *)
(*Elements*)


docsPluginCommands = {
  "Initialize":>
    Replace[
      SimpleDocs@"InitializeProject"[IDEPath[$CurrentIDENotebook]],
      {
        s_String:>
          WithDocsIDE[SimpleDocs@"OpenConfig"[FileBaseName[s]]],
        e_:>
          CreateMessagePopup[
            StringForm["Failed to initialize docs. Got:\n``",
              e
              ]
            ]
        }
      ],
  "New Symbol":>
    WithDocsIDE@Module[
      {
        p= IDEPath[$CurrentIDENotebook],
        fn
        },
        fn = SystemDialogInput["FileSave", 
          ProjectSaveDirectory[SimpleDocs@"EnsureLoadProject"[p]//First, "Symbol"],
          WindowTitle->"Symbol Name"
          ];
        If[StringQ@fn,
          $CreatedDocsNotebookFile = fn;
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
    WithDocsIDE@Module[
      {
        p= LoadIDEDocsProject[$CurrentIDENotebook],
        fn
        },
        fn = SystemDialogInput["FileSave", 
          ProjectSaveDirectory[p//First, "Guide"],
          WindowTitle->"Guide Name"
          ];
        If[StringQ@fn,
          $CreatedDocsNotebookFile = fn;
          SimpleDocs@"TemplateNotebook"["Guide", FileBaseName[fn]];
          ]
        ],
  "New Tutorial":>
    WithDocsIDE@Module[
      {
        p= LoadIDEDocsProject[$CurrentIDENotebook],
        fn
        },
        fn = SystemDialogInput["FileSave", 
          ProjectSaveDirectory[p//First, "Tutorial"],
          WindowTitle->"Tutorial Name"
          ];
        If[StringQ@fn,
          $CreatedDocsNotebookFile = fn;
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
