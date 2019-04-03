(* ::Package:: *)

{
  "Commit":>
    (
      Git["Add", IDEPath[$CurrentIDENotebook], "All"->True];
      Git["Commit", "Committed via EasyIDE @ ``"~TemplateApply~Now]
      ),
  "Push":>
    Git["PushOrigin", IDEPath[$CurrentIDENotebook]],
  "Pull":>
    Git["PullOrigin", IDEPath[$CurrentIDENotebook]]
}
