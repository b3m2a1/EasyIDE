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
    Git["PushOrigin", IDEPath[$CurrentIDENotebook]],
  "Pull":>
    Git["PullOrigin", IDEPath[$CurrentIDENotebook]]
}
