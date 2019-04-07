(* ::Package:: *)

{
  "Commit":>
    Module[{msg},
      CreateAttachedInputDialog[
        $CurrentIDENotebook,
        <|
          "Header"->"Commit to Git",
          "State"->Dynamic[msg],
          "Fields"->{
            "Provide a commit message",
            <|
              "ID"->"Message",
              "Name"->None,
              "Default"->"Committed via EasyIDE @ ``"~TemplateApply~Now,
              "Options"->{
                FieldSize->{25, {5, 25}},
                FieldHint->"Commit message..."
                }
              |>
            },
        "SubmitAction"->Function[
          With[{m=msg["Message"]},
            Remove[msg];
            NotebookDelete[EvaluationCell[]];
            Git["Add", IDEPath[$CurrentIDENotebook], "All"->True];
            CreateMessagePopup[
              $CurrentIDENotebook, 
              StringForm["Committed to git: \n``", 
                Git["Commit", 
                  IDEPath[$CurrentIDENotebook],
                  "Message"->m
                  ]
                ]
              ]
            ]
          ],
        "CancelAction"->
          Function[
            Remove[msg];
            NotebookDelete[EvaluationCell[]]
            ]
        |>,
      <|
        "Position"->{15, 15},
        "Alignment"->{Top, Right},
        "Anchor"->{Top, Right}
        |>,
      CellSize->{350, Automatic},
      "CreateCloseButton"->False
      ]
    ],
  "Push":>
    CreateMessagePopup[
      $CurrentIDENotebook, 
      StringForm["Pushed to origin: \n``", 
        Git["PushOrigin", IDEPath[$CurrentIDENotebook]]
        ]
      ],
  "Pull":>
    CreateMessagePopup[
      $CurrentIDENotebook, 
      StringForm["Pulled from origin: \n``", 
        Git["PullOrigin", IDEPath[$CurrentIDENotebook]]
        ]
      ]
}
