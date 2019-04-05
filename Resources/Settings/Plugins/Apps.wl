(* ::Package:: *)

{ 
  "Update Dependencies":>
    (
      AppExecute["UpdateDependencies", IDEPath[$CurrentIDENotebook]];
      CreateMessagePopup["Updated dependencies"]
      ),
  "Regenerate Loader":>
    (
      AppExecute["RegenerateLoaderFile", IDEPath[$CurrentIDENotebook]];
      CreateMessagePopup["Regenerated loader"]
      ),
  "Regenerate Layout":>
    (
      AppExecute["RegenerateDirectories", IDEPath[$CurrentIDENotebook]];
      CreateMessagePopup["Rebuilt directory structure"]
      )
  }
