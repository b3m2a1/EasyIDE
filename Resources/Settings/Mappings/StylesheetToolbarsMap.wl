(* ::Package:: *)

{
  FrontEnd`FileName[{___, "SimpleDocs", ___}, "SimpleDocs.nb", ___]:>
    "Docs",
  FrontEnd`FileName[{___, "BTools", ___}, "CodePackage.nb", ___]:>
    "CodePackage",
  FrontEnd`FileName[{___}, _String?(StringContainsQ["Markdown"]), ___]:>
    "Markdown",
  FrontEnd`FileName[{___, "BugTracker", ___}, "BugTracker.nb", ___]:>
    "BugTracker"
}
