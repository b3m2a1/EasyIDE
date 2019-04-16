(* ::Package:: *)

{
  FrontEnd`FileName[{___, "SimpleDocs", ___}, "SimpleDocs.nb", ___]:>
    "Docs",
  FrontEnd`FileName[{___, "BTools", ___}, s_String?(StringContainsQ["CodePackage"]), ___]:>
    "CodePackage",
  FrontEnd`FileName[{___, "BTools", ___}, s_String?(StringContainsQ["CodeNotebook"]), ___]:>
    "CodeNotebook",
  FrontEnd`FileName[{__}, _String?(StringContainsQ["Markdown"]), ___]:>
    "Markdown",
  FrontEnd`FileName[{___, "BugTracker", ___}, "BugTracker.nb", ___]:>
    "BugTracker"
}
