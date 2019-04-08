(* ::Package:: *)

{
  "Commit":>
    CreateAttachedInputDialog[
      $CurrentIDENotebook,
      <|
        "Header"->"Commit to Git",
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
      "SubmitAction"->
        Function[
          Git["Add", IDEPath[$CurrentIDENotebook], "All"->True];
          CreateMessagePopup[
            $CurrentIDENotebook, 
            StringForm["Committed to git: \n``", 
              Git["Commit", 
                IDEPath[$CurrentIDENotebook],
                "Message"->#Message
                ]
              ]
            ]
          ]
      |>,
    <|
      "Position"->{-5, -5},
      "Alignment"->{Right, Top},
      "Anchor"->{Right, Top}
      |>,
    CellSize->{350, Automatic},
    "CreateCloseButton"->False
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
