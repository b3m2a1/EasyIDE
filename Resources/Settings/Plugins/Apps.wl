(* ::Package:: *)

{
  "Update Dependencies":>
    (
      AppExecute["UpdateDependencies", IDEPath[$CurrentIDENotebook]];
      CreateMessagePopup["Updated dependencies"]
      ),
  "Update Directories":>
    (
      AppExecute["RegenerateDirectories", IDEPath[$CurrentIDENotebook]];
      CreateMessagePopup["Rebuilt directory structure"]
      )
  }
