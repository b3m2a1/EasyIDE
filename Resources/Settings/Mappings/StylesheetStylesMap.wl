(* ::Package:: *)

{
  FrontEnd`FileName[{___, "SimpleDocs", ___}, "SimpleDocs.nb", ___]:>
    FrontEnd`FileName[{"EasyIDE", "Extensions"}, "-Docs.nb"],
  FrontEnd`FileName[{___, "BTools", ___}, "CodePackage.nb", ___]:>
    FrontEnd`FileName[{"EasyIDE", "Extensions"}, "-CodePackage.nb"],
  FrontEnd`FileName[{__}, _String?(StringContainsQ["Markdown"]), ___]:>
    FrontEnd`FileName[{"EasyIDE", "Extensions"}, "-Markdown.nb"],
  FrontEnd`FileName[{___, "BugTracker", ___}, "BugTracker.nb", ___]:>
    FrontEnd`FileName[{"EasyIDE", "Extensions"}, "-BugTracker.nb"]
}
