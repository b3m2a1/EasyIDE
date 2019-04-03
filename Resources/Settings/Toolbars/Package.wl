(* ::Package:: *)

BeginPackage["`PackageToolbar`"];
packageTemplates;
EndPackage[];


Begin["`Private`"];


opsTemplate = 
  RowBox[{
    RowBox[{
      RowBox[{
        "Options","[",TagBox[FrameBox["\"FunctionName\""],"Placeholder"],"]"}],
          " ","="," ",
        RowBox[{"{"," ",TagBox[FrameBox["\"ops...\""],"Placeholder"]," ","}"}]
      }],
    ";"
    }];


msgTemplate= 
  RowBox[{
    RowBox[{
      RowBox[{
        TagBox[FrameBox["\"FunctionName\""],"Placeholder"],"::","usage"
        }],
      "=",
      "\"FunctionName[args...] ...\""
      }],
    ";"
    }];


fnDefTemplate =
  RowBox[{
    RowBox[{
      RowBox[{
        TagBox[FrameBox["\"FunctionName\""],"Placeholder"],
          "[",
        RowBox[{
          TagBox[FrameBox["\"args___\""],"Placeholder"],
          ",",
          " ",
          RowBox[{"ops",":",RowBox[{"OptionsPattern","[","]"}]}]
          }],
        "]"
        }],
     ":=",
     "\n",
     "\t",
     TagBox[FrameBox["\"def\""],"Placeholder"]
     }],
   ";"}];


attrsTemplate=
  RowBox[{
    RowBox[
      {
        "SetAttributes","~",
          TagBox[FrameBox["\"FunctionName\""],"Placeholder"],"~",
          RowBox[{"{",TagBox[FrameBox["\"attrs...\""],"Placeholder"],"}"}]
        }],
    ";"
    }]


full=
  RowBox@{
    opsTemplate, "\n",
    msgTemplate, "\n",
    fnDefTemplate, "\n",
    attrsTemplate, "\n"
   };


packageTemplates=
  {
    "Function"->full,
    "Options"->opsTemplate,
    "Message"->msgTemplate,
    "Definition"->fnDefTemplate,
    "Attributes"->attrsTemplate
    };


End[]


{
  ActionMenu[
    Button[
      "Insert",
      BaseStyle->"PluginMenu",
      Appearance->Inherited,
      FrameMargins->{{10,10},{0,0}},
      ImageSize->{Automatic,28}
      ],
    With[{k=#[[1]], t=#[[2]]},
      k:>
        FrontEndExecute@
          FrontEnd`NotebookWrite[
            FrontEnd`InputNotebook[],
            t
            ]
      ]&/@packageTemplates,
    Appearance->None,
    MenuAppearance->"Dropdown"
    ]
  }
