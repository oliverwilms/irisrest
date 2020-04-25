Import User

Class App.FrontEnd Extends %CSP.Page [ Language = objectscript, Not ProcedureBlock ]
{

ClassMethod OnPage() As %Status
{
	Do ..OnPageCSPROOT()
	Quit $$$OK
}

ClassMethod OnPageBODY() As %Boolean
{
 	Write "<body>"
	Write !,"<form name=""test"" action=""/crud/task/test"" method=""GET"">"
	Write !,..InsertHiddenFields("/crud/task/test"),!
	Write !,"<input type=""SUBMIT"" name=""test"" value=""TEST"">"
	Write !,"</form>"
	Write !,"<form name=""newtask"" action="""" method=""POST"">"
	Write !,..InsertHiddenFields(""),!
	Write !,"<input type=""text"" name=""testfield"" value=""""/>"
	Write !,"<input type=""SUBMIT"" name=""newtask"" value=""NEW"">"
	Write !,"</form>"
	Write !,"</body>"
}

ClassMethod OnPageCSPROOT() As %Boolean
{
 	Do ..OnPageHTML()
}

ClassMethod OnPageHEAD() As %Boolean
{
 	Write "<head>"
	Write !,!,!,"<!-- Put your page Title here -->"
	Write !,"<title>	Cache Server Page </title>",!
	Write !,"</head>"
}

ClassMethod OnPageHTML() As %Boolean
{
 	Write "<html>"
	Write !
	Do ..OnPageHEAD()
	Write !,!
	Do ..OnPageBODY()
	Write !,"</html>"
}

ClassMethod OnPreHTTP() As %Boolean [ Language = objectscript ]
{
    #dim task As %DynamicObject
    If ($Data(%request.Data("testfield",1)) = 0) { QUIT 1 }
    If (%request.Data("testfield",1) = "") { QUIT 1 }
    Set httprequest=##class(%Net.HttpRequest).%New()
	Set httprequest.ContentType = "application/json"
    Set task = {}
    Do task.%Set("what",%request.Data("testfield",1))
    Set tWrite = task.%ToJSON()
    Set tWrite = httprequest.EntityBody.Write(tWrite)
 	Set httprequest.Port = 52773
    Do httprequest.Post("/crud/task/newtask")
    Do httprequest.HttpResponse.OutputToDevice()
    Quit 0
}

}
