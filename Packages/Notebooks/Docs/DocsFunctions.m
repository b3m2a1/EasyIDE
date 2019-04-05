(* ::Package:: *)

(* Autogenerated Package *)

(* ::Text:: *)
(*
	Provides some functions to more easily hook SimpleDocs into a regular documentation workflow
*)



LoadIDEDocsProject::usage="";
SetIDEDocsProject::usage="";
CreateDocsNotebook::usage="";


$CreatedDocsNotebookFile::usage="";


WithDocsIDE::usage="";
OpenMetadataEditor::usage="";


CreateBatchSymbolPages::usage="";


Begin["`Private`"];


(* ::Subsection:: *)
(*WithDocsIDE*)



(* ::Subsubsection::Closed:: *)
(*LoadIDEDocsProject*)



LoadIDEDocsProject[nb_]:=
  SimpleDocs@"EnsureLoadProject"[IDEPath[nb]];
LoadIDEDocsProject[]:=
  LoadIDEDocsProject[$CurrentIDENotebook];


(* ::Subsubsection::Closed:: *)
(*SetIDEDocsProject*)



SetIDEDocsProject[nb_]:=
  Module[{load = LoadIDEDocsProject[nb]},
    IDEData[nb, {"Options", TaggingRules, "SimpleDocs", "Project"}]=
      (Thread[{"Name", "Directory", "Config"}->load])
    ];


(* ::Subsubsection::Closed:: *)
(*CreateDocsNotebook*)



$CreatedDocsNotebookFile; 
(* this is a special symbol we'll use to bind docs notebook file names without having to pass them*)


CreateDocsNotebook[nb_, notebook_Notebook, fileName:_String|Automatic:Automatic]:=
  Block[
    {
      type = 
        Replace[
          Fold[Lookup[#, #2, <||>]&, Options[notebook], {TaggingRules, "Metadata", "type"}],
          Except[_String]->"Symbol"
          ],
      file = Replace[fileName, Automatic:>$CreatedDocsNotebookFile]
      },
    If[StringQ@file,
      file = StringTrim[file, "."<>FileExtension[file]]<>".nb";
        Export[file, notebook, "Package"],
      file = 
        CreateProjectScratchFile[
          notebook,
          ProjectSaveDirectory[LoadIDEDocsProject[nb][[1]], type],
          type
          ]
      ];
    IDEOpen[nb, file];
    SetIDEDocsProject[nb]
    ];


CreateDocsNotebook[notebook_Notebook, fileName:_String|Automatic:Automatic]:=
  CreateDocsNotebook[$CurrentIDENotebook, notebook, fileName]


(* ::Subsubsection::Closed:: *)
(*catchCreateDocument*)



catchCreateDocument//Clear
catchCreateDocument[expr_]:=
  Block[
    {
      CreateDocument=createDocsNotebook
      },
    expr
    ];
catchCreateDocument~SetAttributes~HoldFirst;


(* ::Subsubsection::Closed:: *)
(*WithDocsIDE*)



WithDocsIDE[nb_, expr_]:=
  Block[
   {
     SystemOpen = (IDEOpen[nb, #]&),
     $CreatedDocsNotebookFile
     },
    WithIDEData[
      nb,
      catchCreateDocument[expr]
      ]
   ];
WithDocsIDE[expr:Except[_NotebookObject]]:=
  WithDocsIDE[$CurrentIDENotebook, expr];
WithDocsIDE[nb_NotebookObject]:=
  Function[Null, WithDocsIDE[nb, #], HoldAllComplete];
WithDocsIDE~SetAttributes~HoldAll;


(* ::Subsection:: *)
(*Interfaces*)



(* ::Subsubsection::Closed:: *)
(*OpenMetadataEditor*)



OpenMetadataEditor[nb_]:=
  CreateDialog[
    Column[
      {
        Pane[$MetadataEditor, {500, {600, 1000}}],
        Row@{
            DefaultButton[
              WithoutCurrentValueUpdating[
                SetCurrentValue[nb, 
                  {TaggingRules, "EasyIDE", "Options", TaggingRules, "Metadata"}, 
                  CurrentValue[EvaluationNotebook[], {TaggingRules, "Metadata"}]
                  ];
                SetCurrentValue[nb, 
                  {TaggingRules, "EasyIDE", "Options", TaggingRules, "ColorType"}, 
                  CurrentValue[EvaluationNotebook[], {TaggingRules, "ColorType"}]
                  ]
                ];
              NotebookClose[EvaluationNotebook[]]
              ],
            CancelButton[]
            }
       }
       ],
    TaggingRules->
      WithoutCurrentValueUpdating@
        CurrentValue[nb, {TaggingRules, "EasyIDE", "Options", TaggingRules}],
    WindowFloating->True,
    Background->White
    ]


(* ::Subsection:: *)
(*Batching*)



(* ::Subsubsection::Closed:: *)
(*CreateBatchSymbolPages*)



(* ::Subsubsubsection::Closed:: *)
(*createBatchDocsPages*)



createBatchDocsPages[projData_, context_, relatedCells_, generatedTypes_]:=
  (* assumes projName is already loaded *)
  Module[
   {
     fns
     },
   fns = getNeedsDocsFunctions[projData[[1]], context];
   AssociationMap[
     doTemplateDocs[projData, context, relatedCells, generatedTypes, #]&,
     fns
     ]
   ];


(* ::Subsubsubsection::Closed:: *)
(*getNeedsDocsFunctions*)



getNeedsDocsFunctions[projName_, context_]:=
  Module[
    {
      names = Names[context<>"*"],
      pdir = ProjectSaveDirectory[projName, "Symbol"]
      },
    ToExpression[#, StandardForm, 
       Function[Null, 
         If[
           Length@OwnValues[#]==0||
               MatchQ[
                 OwnValues[#], 
                 {_:>_?(SymbolName[#]=="PackageLoadPackage"&)[___]}
                 ],
             #,
             Nothing
             ], 
           HoldAllComplete
           ]
         ]&@
       Select[
      names, 
      !FileExistsQ@
        FileNameJoin@{pdir, "ref", StringSplit[#, "`"][[-1]]<>".nb"}&
      ]
    ];


(* ::Subsubsubsection::Closed:: *)
(*correctMetadata*)



correctMetadata[nb_, context_]:=
 Module[{cname = StringSplit[context, "`"][[1]]},
   CurrentValue[nb, {TaggingRules, "Metadata", "context"}]=
      cname<>"`";
    CurrentValue[nb, {TaggingRules, "Metadata", "uri"}]=
      StringReplace[
        CurrentValue[nb, {TaggingRules, "Metadata", "uri"}],
        a__~~"/ref":>cname<>"/ref"
        ];
   ]


(* ::Subsubsubsection::Closed:: *)
(*correctTitleBar*)



correctTitleBar[nb_, context_]:=
  With[{c=Cells[nb, CellStyle->"TitleBar"][[1]]},
    NotebookWrite[c, Cell[StringSplit[context, "`"][[1]]<>" Symbol", "TitleBar"]];
    ]


(* ::Subsubsubsection::Closed:: *)
(*correctRelatedStuff*)



correctRelatedStuff[nb_, relatedCells_]:=
  Module[{cells, firstCell},
    firstCell=Cells[nb, CellStyle->"SeeAlso"][[1]];
    cells=
      Cells[nb, 
        CellStyle->"SeeAlso"|"Related"|"RelatedLinks"|"Footer"|"Text"|"Item"
        ];
    cells=Join@@SplitBy[cells, #=!=firstCell&][[2;;]];
    SelectionMove[cells[[-1]], After, Cell];
    NotebookDelete@cells;
    NotebookWrite[nb, relatedCells]
    ];


(* ::Subsubsubsection::Closed:: *)
(*doTemplateDocs*)



doTemplateDocs[projData_, context_, relatedCells_, generatedTypes_, fn_]:=
  Module[{nb, file, docs, md, pname=projData[[1]]},
    nb=SimpleDocs@"TemplateNotebook"["Symbol", fn, Visible->False];
    CurrentValue[nb, {TaggingRules, "SimpleDocs", "Project"}]=
      (Thread[{"Name", "Directory", "Config"}->projData]);
    SimpleDocs@"SaveToProject"[nb];
    file = NotebookFileName@nb;
    correctMetadata[nb, context];
    correctTitleBar[nb, context];
    If[relatedCells=!=None,
     correctRelatedStuff[nb, relatedCells]
     ];
    Export[file, DeleteCases[NotebookGet[nb], (Visible->False), Infinity]];
    If[MemberQ[generatedTypes, "Documentation"],
      docs = SimpleDocs@"SaveToDocumentation"[nb];
      ];
    If[MemberQ[generatedTypes, "Markdown"],
      md = SimpleDocs@"SaveToMarkdown"[nb];
      ];
    NotebookClose@nb;
    Lookup[
      <|
        "Notebook"->file,
        "Documentation"->docs,
        "Markdown"->md
        |>,
      Append[generatedTypes, "Notebook"]
      ]
    ]


(* ::Subsubsubsection::Closed:: *)
(*getContExt*)



getContExt[nbObject_, contexts_]:=
    Replace[
      Flatten@List@contexts,
      Except[{__String}]:>
        With[
          {
            basic = 
              Fold[
                Lookup[#, <||>]&,
                PacletExecute["Association", IDEPath[nbObject]],
                {"Extensions", "Kernel"}
                ]
            },
          Flatten@List@Lookup[basic, "Context", Lookup[basic, "Contexts"]]
          ]
      ]


(* ::Subsubsubsection::Closed:: *)
(*CreateBatchSymbolPages*)



Options[CreateBatchSymbolPages]=
  {
    "Contexts"->Automatic,
    "GeneratedTypes"->Automatic,
    "RelatedCells"->Automatic
    };
CreateBatchSymbolPages[
  nbObject_,
  ops:OptionsPattern[]
  ]:=
  PackageExceptionBlock["Docs"]@
    Module[
      {
        projData,
        configData,
        contexts,
        relatedCells,
        generatedTypes
        },
      projData = LoadIDEDocsProject[nbObject];
      SimpleDocs@"ReloadProject"[projData[[1]]]; (* ensures up-to-dateness *)
      configData = Lookup[SimpleDocs@"Projects"[projData[[1]]], "BatchDocsSettings", <||>];
      contexts = Lookup[configData, "Contexts", Automatic];
      contexts = getContExt[nbObject, contexts];
      If[!MatchQ[contexts, {__String}],
        PackageRaiseException[
          Automatic,
          "Couldn't determine documentation contexts"
          ]
        ];
      Do[
        relatedCells = 
          Replace[Lookup[configData, "RelatedCells", <||>],
            a_Association:>Lookup[a, cont, Automatic]
            ];
        relatedCells = 
          Replace[relatedCells,
            Except[_Cell|{__Cell}]:>None
            ];
        generatedTypes = 
          Replace[Lookup[configData, "GenerateTypes", <||>],
            a_Association:>Lookup[a, cont, Automatic]
            ];
        generatedTypes = 
          Replace[generatedTypes,
            Except[{___String}]:>{}
            ];
        createBatchDocsPages[projData, cont, relatedCells, generatedTypes],
        {cont, contexts}
        ];
      ]


End[];



