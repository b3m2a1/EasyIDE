(* ::Package:: *)

{
  "Commit":>
    (
      Git["Add", IDEPath[$CurrentIDENotebook], "All"->True];
      CreateMessagePopup[
        $CurrentIDENotebook, 
        StringForm["Committed to git: \n``", 
          Git["Commit", 
            IDEPath[$CurrentIDENotebook],
            "Message"->"Committed via EasyIDE @ ``"~TemplateApply~Now
            ]
          ]
        ]
      ),
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
