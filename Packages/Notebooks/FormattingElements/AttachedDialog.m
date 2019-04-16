(* ::Package:: *)

(* Autogenerated Package *)

AttachedDialogPanel::usage="";
AttachedDialogInputPanel::usage="";
CreateAttachedDialog::usage="";
CreateAttachedInputDialog::usage="";


CreateWindowedDialog::usage="";
CreateWindowedInputDialog::usage="";


IDECreateDialog::usage="";


Begin["`Private`"];


(* ::Subsection:: *)
(*AttachedDialogPanel*)



(* ::Subsubsection::Closed:: *)
(*AttachedDialogPanel*)



(* ::Subsubsubsection::Closed:: *)
(*AttachedDialogPanel*)



AttachedDialogPanel[
  expr_,
  ops:OptionsPattern[]
  ]:=
  Panel[
    expr,
    BaseStyle->"AttachedDialog",
    ops
    ];


(* ::Subsubsubsection::Closed:: *)
(*destroyDialog*)



destroyDialog[]:=
  Replace[CurrentValue[EvaluationNotebook[], StyleDefinitions],
    {
      FrontEnd`FileName[_, _String?(StringEndsQ["-Dialog.nb"]), ___]:>
        NotebookClose[EvaluationNotebook[]],
      _:>NotebookDelete[EvaluationCell[]]
      }
    ]


(* ::Subsubsubsection::Closed:: *)
(*prepSubmitButton*)



prepSubmitButton[{label_, action_, ops___}]:=
  Button[label, action,
    ops,
    BaseStyle->"AttachedDialogDefaultButton",
    Appearance->Inherited,
    Evaluator->Inherited,
    Method->Inherited
    ];


(* ::Subsubsubsection::Closed:: *)
(*prepCancelButton*)



prepCancelButton[{label_, action_, ops___}]:=
  With[{act=
    If[action===Automatic, 
      destroyDialog[]&,
      action
      ]},
    Button[label, 
      act,
      ops,
      BaseStyle->"AttachedDialogCancelButton",
      Appearance->Inherited,
      Evaluator->Inherited,
      Method->Inherited
      ]
    ]


(* ::Subsubsubsection::Closed:: *)
(*iAttachedDialogPanel*)



iAttachedDialogPanel[
  header_,
  expr_,
  submitButton:{_, _Function|None, ___}:{"OK", None},
  closingButton:{_, _Function|Automatic, ___}:{"Cancel", Automatic},
  ops:OptionsPattern[]
  ]:=
  AttachedDialogPanel[
    Grid[
      {
        {Panel[Pane[header], BaseStyle->"AttachedDialogHeader"]},
        {Panel[expr, BaseStyle->"AttachedDialogBody"]},
        {
          Panel[
            Grid[
              {
                {
                  prepSubmitButton@submitButton, 
                  prepCancelButton@closingButton
                  }
                },
              GridBoxItemSize->Inherited
              ], 
            BaseStyle->"AttachedDialogButtons"
            ]
          }
        },
      GridBoxItemSize->Inherited
      ],
    ops
    ];


(* ::Subsubsubsection::Closed:: *)
(*AttachedDialogPanel*)



AttachedDialogPanel[
  a_Association,
  ops:OptionsPattern[]
  ]:=
  iAttachedDialogPanel[
    Lookup[a, "Header", ""],
    Lookup[a, "Body"],
    Lookup[a, "SubmitButton", 
      Flatten@{
        "OK",
        Lookup[a, "SubmitAction", None]
        }
      ],
    Lookup[a, "CancelButton", 
      Flatten@{
        "Cancel",
        Lookup[a, "CancelAction", Automatic]
        }
      ],
    ops
    ]


(* ::Subsubsection::Closed:: *)
(*AttachedDialogInputPanel*)



(* ::Subsubsubsection::Closed:: *)
(*normalizeInputField*)



normalizeInputField[a_Association]:=
  Module[
    {
      fid,
      fname,
      fieldDescription,
      default,
      fspec,
      ops
      },
    fid = 
      Lookup[a, "ID",
        Lookup[a, "Name", CreateUUID[]]
        ];
    fname = 
      Lookup[a, "Name", fid];
    fieldDescription = 
      Lookup[a, "Description", None];
    default =
      Lookup[a, "Default", ""];
    fspec = 
      Replace[Lookup[a, "Type", InputField],
       {
         InputField->{InputField, String},
         e_:>Flatten[{e}, 1]
         }
       ];
    ops =
      Lookup[a, "Options", {}];
    <|
      "ID"->fid,
      "Name"->fname,
      "Type"->fspec,
      "Description"->fieldDescription,
      "Default"->default,
      "Options"->ops
      |>
    ];
normalizeInputField[e_]:=
  e


(* ::Subsubsubsection::Closed:: *)
(*createInputFieldControl*)



createInputFieldControl[Dynamic[var_], 
  fieldID_, {argType_, ifo___}, ops___
  ]:=
  argType[
    Dynamic[var[fieldID]],
     ifo,
     ops,
     BoxID->fieldID
     ];


(* ::Subsubsubsection::Closed:: *)
(*createInputFieldElementName*)



createInputFieldElementName[None]:=
  Nothing;
createInputFieldElementName[fieldName_]:=
  Item[Row@{Spacer[15], fieldName, ":"}, 
    Alignment->Right
    ];


(* ::Subsubsubsection::Closed:: *)
(*createInputFieldElementDescription*)



createInputFieldElementDescription[fieldDescription_]:=
  fieldDescription;


(* ::Subsubsubsection::Closed:: *)
(*createInputFieldElement*)



createInputFieldElement//Clear


createInputFieldElement[
  Dynamic[var_],
  fieldID_, 
  fieldName_,
  fieldType_,
  fieldDescription_,
  default_,
  ops___
  ]:=
  {
    {
      createInputFieldElementName[fieldName],
      var[fieldID]=default;
      createInputFieldControl[Dynamic[var], fieldID, fieldType, ops]
     },
   If[fieldDescription=!=None,
     {"", createInputFieldElementDescription@fieldDescription},
     Nothing
     ]
   }


createInputFieldElement[
  d:Verbatim[Dynamic][var_],
  e:Except[_Association|_List]
  ]:=
  {
    {Pane[e, BaseStyle->"AttachedDialog"], SpanFromLeft}
    };
createInputFieldElement[
  d:Verbatim[Dynamic][var_],
  l_List
  ]:=
  Map[
    Pane[#, BaseStyle->"AttachedDialog"]&,
    l,
    {2}
    ];
createInputFieldElement[
  d:Verbatim[Dynamic][var_],
  a_Association
  ]:=
  Module[
    {
      f
      },
    createInputFieldElement[
      d,
      Lookup[a, "ID"],
      Lookup[a, "Name"],
      Lookup[a, "Type"],
      Lookup[a, "Description"],
      Lookup[a, "Default"],
      Sequence@@Flatten@{Lookup[a, "Options"]}
      ]
    ]


(* ::Subsubsubsection::Closed:: *)
(*createInputFields*)



createInputFields[
  Dynamic[var_],
  specs_
  ]:=
  createInputFieldElement[Dynamic[var], #]&/@specs;


(* ::Subsubsubsection::Closed:: *)
(*createInputFieldDialog*)



createInputFieldDialog[
  Dynamic[var_],
  fields_
  ]:=
  Grid[
    Join@@createInputFields[Dynamic[var], fields],
    GridBoxItemSize->Inherited,
    BaseStyle->"AttachedDialogInput"
    ];


(* ::Subsubsubsection::Closed:: *)
(*prepState*)



prepState[s_, ids_, remove_]:=
  With[{a=AssociationMap[s, ids]},
    If[remove, remove[s]];
    a
    ];
prepState~SetAttributes~HoldFirst


(* ::Subsubsubsection::Closed:: *)
(*attachedDialogInputSpec*)



attachedDialogInputSpec[
  a_Association
  ]:=
  Module[
    {
      s = Lookup[a, "State", Module[{state}, Dynamic[state]]],
      fields = normalizeInputField/@Flatten@List@Lookup[a, "Fields", {}]
      },
    With[
      {
        ids = Cases[fields, f_Association:>f["ID"]],
        remove = Lookup[a, "ClearState", Replace[Lookup[a, "State", True], _Dynamic:>False]],
        submit = Flatten@List@Lookup[a, "SubmitAction", None],
        cancel = Flatten@List@Lookup[a, "CancelAction", None],
        dest = Lookup[a, "DestroyOnClick", True]
        },
      Merge[
        {
          "Body"->
            createInputFieldDialog[
              s,
              fields
              ],
          "SubmitAction"->
             {
               Function[
                 Null,
                 submit[[1]]@prepState[#, ids, remove];
                 If[dest, destroyDialog[]],
                 HoldFirst
                 ],
               ButtonData->s,
               Sequence@@Rest[submit]
               },
           "CancelAction"->
             {
               Function[
                 Null,
                 cancel[[1]]@prepState[#, ids, remove];
                 If[dest, destroyDialog[]],
                 HoldFirst
                 ],
               ButtonData->s,
               Sequence@@Rest[cancel]
               },
           a
         },
       First
       ]
     ]
   ]


(* ::Subsubsubsection::Closed:: *)
(*AttachedDialogInputPanel*)



AttachedDialogInputPanel[
  a_Association,
  ops:OptionsPattern[]
  ]:=
  AttachedDialogPanel[
    attachedDialogInputSpec[a],
    ops
    ]


(* ::Subsection:: *)
(*CreateAttachedDialog*)



(* ::Subsubsection::Closed:: *)
(*createAttachSpec*)



attachSpecData=
  <|
    "Position"->
      <|"Pattern"->{_?NumberQ|_Scaled, _?NumberQ|_Scaled}, "Default"->{0, 0}|>,
    "Alignment"->
      <|"Pattern"->{Left|Center|Right, Bottom|Center|Top}, "Default"->{Center, Center}|>,
    "Anchor"->
      <|"Pattern"->{Left|Center|Right, Bottom|Center|Top}, "Default"->{Center, Center}|>,
    "ClosingActions"->
      <|"Pattern"->{("MouseExit"|"OutsideMouseClick"|"EvaluatorQuit")..}, 
        "Default"->{"EvaluatorQuit"}|>
    |>;


 createAttachSpec[a_Association]:=
  Merge[
    {
      KeyValueMap[
        #->
          Replace[#2,
            Except[Lookup[attachSpecData[#], "Pattern"]]->
              Lookup[attachSpecData[#], "Default"]
            ]&,
        KeyTake[a, Keys[attachSpecData]]
        ],
      #Default&/@attachSpecData
      },
    First
    ];
createAttachSpec[Automatic]:=
  createAttachSpec[<||>]


(* ::Subsubsection::Closed:: *)
(*insertCloseBox*)



insertCloseBox[panel_]:=
  ReplaceAll[
    panel,
    Grid[
      {
        {Panel[h_, BaseStyle->"AttachedDialogHeader"]},
        r___
        },
      o___
      ]:>
      Grid[
        {
          {
            Panel[
              Grid[
                {{
                  "",
                  h,
                  RawBoxes@
                    ButtonBox["", BaseStyle->"AttachedDialogCloseButton"]
                  }},
                BaseStyle->"AttachedDialogCloseButtonRow",
                GridBoxItemSize->Inherited
                ],
             BaseStyle->"AttachedDialogHeader"
             ]
            },
          r
          },
        o
        ]
    ];


(* ::Subsubsection::Closed:: *)
(*CreateAttachedDialog*)



attachables=
  _NotebookObject|_FrontEnd`EvaluationNotebook|_FrontEnd`InputNotebook|
  _FrontEnd`SelectedNotebook|_FrontEnd`ParentNotebook|_FrontEnd`ButtonNotebook|
  _CellObject|_FrontEnd`EvaluationCell|_FrontEnd`ParentCell|_FrontEnd`IndexedCell|
  _BoxObject|_FrontEnd`EvaluationBox|_FrontEnd`ParentBox;


CreateAttachedDialog//Clear
Options[CreateAttachedDialog]=
  {
    "CreateCloseButton"->False
    };
CreateAttachedDialog[
  nb:attachables, 
  expression_, 
  cellType:_String:"AttachedDialogCell",
  a:_Association|Automatic:Automatic,
  ops:OptionsPattern[]
  ]:=
  With[
    {
      sepc=createAttachSpec[a],
      panel=
        AttachedDialogPanel[expression]},
    FEAttachCell[
      nb,
      Cell[
        panel//
          If[Quiet[TrueQ@OptionValue["CreateCloseButton"]],
            insertCloseBox,
            Identity
            ]//ToBoxes//BoxData,
        cellType,
        FirstCase[
          panel,
          i:InputField[___, BoxID->boxID_, ___]:>
            ( 
              CellDynamicExpression:>
                Refresh[
                 SelectionMove[EvaluationCell[], Next, Word,
                   AutoScroll->False
                   ];
                  FE`Evaluate@
                    FrontEnd`MoveCursorToInputField[
                       EvaluationNotebook[], 
                        boxID
                        ],
                    None
                  ]
              ),
          Sequence@@{},
          Infinity
          ],
        FilterRules[
          {ops, CellSize->{400, Automatic}},
          Options[Cell]
          ]
        ],
      Offset[sepc["Position"], 0],
      sepc["Alignment"],
      sepc["Anchor"],
      sepc["ClosingActions"]
      ]
    ];
CreateAttachedDialog[ 
  expression:Except[attachables], 
  cellType:_String:"AttachedDialogCell",
  a:_Association|Automatic:Automatic,
  ops:OptionsPattern[]
  ]:=
  CreateAttachedDialog[
    $CurrentIDENotebook,
    expression,
    cellType,
    a,
    ops
    ]


(* ::Subsubsection::Closed:: *)
(*CreateAttachedInputDialog*)



CreateAttachedInputDialog//Clear
CreateAttachedInputDialog[
  nb:attachables, 
  fields_Association, 
  cellType:_String:"AttachedDialogCell",
  a:_Association|Automatic:Automatic,
  ops:OptionsPattern[]
  ]:=
  CreateAttachedDialog[
    nb, 
    attachedDialogInputSpec[fields],
    cellType,
    a,
    ops
    ];
CreateAttachedInputDialog[ 
  fields_Association, 
  cellType:_String:"AttachedDialogCell",
  a:_Association|Automatic:Automatic,
  ops:OptionsPattern[]
  ]:=
CreateAttachedInputDialog[
    $CurrentIDENotebook,
    fields,
    cellType,
    a,
    ops
    ]


(* ::Subsection:: *)
(*CreateDetachedDialog*)



(* ::Subsubsection::Closed:: *)
(*CreateWindowedDialog*)



CreateWindowedDialog//Clear
Options[CreateWindowedDialog]=
  {
    "CreateCloseButton"->False
    };
CreateWindowedDialog[
  nb:attachables, 
  expression_, 
  cellType:_String:"AttachedDialogCell",
  ops:OptionsPattern[]
  ]:=
  With[
    {
      nbb=
        Replace[nb, 
          {
            nbos:_FrontEnd`EvaluationNotebook|_FrontEnd`InputNotebook|
              _FrontEnd`SelectedNotebook|_FrontEnd`ParentNotebook|_FrontEnd`ButtonNotebook:>
              MathLink`CallFrontEnd@FrontEnd`Value[nbos],
            e:Except[_NotebookObject]:>
              ParentNotebook[e]
            }
          ],
      panel=
        AttachedDialogPanel[expression]
    },
    (SetSelectedNotebook[#];#)&@
      CreateDocument[
        Cell[
          ReplaceAll[panel, 
            {
              Function[a_]:>
                Function[Block[{$CurrentIDENotebook=nbb}, a]],
              Verbatim[Function][b_, a_, c___]:>
                Function[b, Block[{$CurrentIDENotebook=nbb}, a], c],
              HoldPattern[$CurrentIDENotebook]->nbb
              }]//
            If[Quiet[TrueQ@OptionValue["CreateCloseButton"]],
              insertCloseBox,
              Identity
              ]//ToBoxes//BoxData,
          cellType,
          FilterRules[
            {
              ops,
              CellSize->{
                Scaled[1], 
                Automatic
                }
              }, 
            CellSize|CellLabel|CellTags
            ]
          ],
        FilterRules[
          {
            ops,
            FirstCase[
              panel,
              i:InputField[___, BoxID->boxID_, ___]:>
                ( 
                  NotebookDynamicExpression:>
                    Refresh[
                      FE`Evaluate@
                        FrontEnd`MoveCursorToInputField[
                           EvaluationNotebook[], 
                            boxID
                            ],
                        None
                      ]
                  ),
              Sequence@@{},
              Infinity
              ],
            StyleDefinitions->(* need more flexibility here but ah well *)
              With[{n=GetMainStylesheetName[nb]},
                FrontEnd`FileName[{"EasyIDE", "Extensions", n}, "Dialog.nb"]
                ]
            },
          Options[Notebook]
          ]
        ]
    ];
CreateWindowedDialog[
  expression:Except[attachables], 
  cellType:_String:"AttachedDialogCell",
  ops:OptionsPattern[]
  ]:=
  CreateWindowedDialog[
    $CurrentIDENotebook,
    expression,
    cellType,
    ops
    ]


(* ::Subsubsection::Closed:: *)
(*CreateWindowedInputDialog*)



CreateWindowedInputDialog//Clear
CreateWindowedInputDialog[
  nb:attachables, 
  fields_Association, 
  cellType:_String:"AttachedDialogCell",
  ops:OptionsPattern[]
  ]:=
  CreateWindowedDialog[
    nb, 
    attachedDialogInputSpec[fields],
    cellType,
    ops
    ];
CreateWindowedInputDialog[ 
  fields_Association, 
  cellType:_String:"AttachedDialogCell",
  ops:OptionsPattern[]
  ]:=
CreateWindowedInputDialog[
    $CurrentIDENotebook,
    fields,
    cellType,
    ops
    ]


(* ::Subsection:: *)
(*IDECreateDialog*)



(* ::Subsubsection::Closed:: *)
(*createDialogDispatcher*)



createDialogDispatcher[{"Attached", "Normal"}]=
  CreateAttachedDialog;
createDialogDispatcher[{"Attached", "Input"}]=
  CreateAttachedInputDialog;
createDialogDispatcher[{"Detached", "Normal"}]=
  CreateWindowedDialog;
createDialogDispatcher[{"Detached", "Input"}]=
  CreateWindowedInputDialog;


(* ::Subsubsection::Closed:: *)
(*IDECreateDialog*)



IDECreateDialog[
  nb_NotebookObject, 
  mode:{"Attached"|"Detached", "Normal"|"Input"}:{"Attached", "Normal"},
  expr_, 
  args___
  ]:=
  createDialogDispatcher[mode][nb, expr, args];
IDECreateDialog[ide_IDENotebookObject, 
  mode:{"Attached"|"Detached", "Normal"|"Input"}:{"Attached", "Normal"},
  expr_, 
  args___
  ]:=
  createDialogDispatcher[mode][ide["Notebook"], expr, args];


End[];



