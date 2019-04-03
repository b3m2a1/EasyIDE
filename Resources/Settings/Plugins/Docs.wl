(* ::Package:: *)

{
  "Initialize":>
    Replace[
      SimpleDocs@"InitializeProject"[IDEPath[$CurrentIDENotebook]],
      {
        s_String:>
          With[{cf=Block[{SystemOpen=#&}, SimpleDocs@"OpenConfig"[FileBaseName[s]]]},
            IDEOpen[$CurrentIDENotebook, cf]
            ],
        e_:>
          CreateMessagePopup[
            StringForm["Failed to initialize docs. Got:\n``",
              e
              ]
            ]
        }
      ],
  "New Symbol":>
    Module[
      {
        p= IDEPath[$CurrentIDENotebook],
        fn
        },
        fn = SystemDialogInput["FileSave", 
          ProjectSaveDirectory[SimpleDocs@"EnsureLoadProject"[p]//First, "Symbol"],
          WindowTitle->"Symbol Name"
          ];
        If[StringQ@fn,
          Block[{CreateDocument=#&, nbExpr},
            nbExpr = Replace[
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
           IDEOpen[$CurrentIDENotebook, Export[fn, nbExpr, "Package"]]
          ]
        ]
      ]
  }
