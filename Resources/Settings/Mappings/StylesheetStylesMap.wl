(* ::Package:: *)

{
  FrontEnd`FileName[{___, "SimpleDocs", ___}, "SimpleDocs.nb", ___]->"Docs",
  FrontEnd`FileName[{___, "BTools", ___}, 
    s_String?(StringContainsQ["CodePackage"]), ___]->"CodePackage",
  FrontEnd`FileName[{___, "BTools", ___}, 
    s_String?(StringContainsQ["CodeNotebook"]), ___]->"CodeNotebook",
  FrontEnd`FileName[{__}, _String?(StringContainsQ["Markdown"]), ___]->"Markdown",
  FrontEnd`FileName[{___, "BugTracker", ___}, "BugTracker.nb", ___]->"BugTracker",
  "Package.nb"->"Package",
  FrontEnd`FileName[{"Article"}, "JournalArticle.nb"] -> "Article/JournalArticle",
  FrontEnd`FileName[{"Article"}, "Preprint.nb"] -> "Article/Preprint",
  FrontEnd`FileName[{"Book"}, "Monograph.nb"] -> "Book/Monograph",
  FrontEnd`FileName[{"Book"}, "Textbook.nb"] -> "Book/Textbook",
  FrontEnd`FileName[{"Utility"}, "Correspondence.nb"] -> "Utility/Correspondence",
  FrontEnd`FileName[{"Utility"}, "Memo.nb"] -> "Utility/Memo",
  FrontEnd`FileName[{"Utility"}, "Notepad.nb"] -> "Utility/Notepad",
  FrontEnd`FileName[{"Utility"}, "Outline.nb"] -> "Utility/Outline",
  FrontEnd`FileName[{"Report"}, "StandardReport.nb"] -> "Report/StandardReport",
  FrontEnd`FileName[{"Report"}, "AutomatedReport.nb"] -> "Report/AutomatedReport",
  FrontEnd`FileName[{"Report"}, "ConfidentialReport.nb"] -> "Report/ConfidentialReport"
}
