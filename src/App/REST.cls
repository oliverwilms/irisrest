Class App.REST Extends %CSP.REST
{

Parameter HandleCorsRequest = 1;

Parameter CONTENTTYPE = "application/json";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<!-- Swagger specs -->
<Route Url="/_spec" Method="GET" Call="SwaggerSpec" />
<!-- Tester method -->
<Route Url="/test" Method="GET" Call="test"/>
<!-- Get All Tasks -->
<Route Url="/all" Method="GET" Call="GetAll" />
<!-- Post New Task -->
<Route Url="/newtask" Method="POST" Call="NewTask" />
<!-- Get task # id -->
<Route Url="/:id" Method="GET" Call="GetTaskInfo" />
<!-- Put task # id -->
<Route Url="/:id" Method="PUT" Call="UpdateTask" />
<!-- Delete task # id -->
<Route Url="/:id" Method="DELETE" Call="DeleteTask"/>
</Routes>
}

/// Tester method
ClassMethod test() As %Status
{
	Set task = {
		"what": "doing something",
		"when": "",
		"who": ""
	}
	Write task.%ToJSON()
	Quit $$$OK
}

// DATABASE METHODS

ClassMethod GetAll() As %Status
{
    Write "["
    Set count = 0
	Set rset = ##class(%SQL.Statement).%ExecDirect(,"SELECT * FROM App.Task")
	While rset.%Next() {
        If ($Increment(count) > 1) Write ","
		Set task = ##class(App.Task).%OpenId(rset.ID)
        Do task.%JSONExport()
	}
    Write "]"
	Quit $$$OK
}

ClassMethod NewTask() As %Status
{
	Set tSC = ..GetJSONFromRequest(.obj)
	If 'tSC {
		Set %response.Status = ..#HTTP400BADREQUEST
		Set error = {"errormessage": "JSON not found"}
		Write error.%ToJSON()
		Quit $$$OK
	}

	Set tSC = ..ValidateJSON(obj,.error) 
	If 'tSC {
		Set %response.Status = ..#HTTP400BADREQUEST
		Write error.%ToJSON()
		Quit $$$OK
	}
	
	Set task = ##class(App.Task).%New()
	Set tSC = task.SetWhenToCurrentTimestamp()
	Do ..CopyToTaskFromJSON(.task,obj)
	
	Set sc = task.%Save()
	
	Set result={}
	Do result.%Set("Status",$Select($$$ISERR(sc):$system.Status.GetOneErrorText(sc),1:"OK"))
	Write result.%ToJSON()
	Quit sc
}

ClassMethod GetTaskInfo(id As %String) As %Status
{
	Set task = ##class(App.Task).%OpenId(id)
	If $IsObject(task) {
		Do task.%JSONExport()
	} Else {
		Set %response.Status = ..#HTTP204NOCONTENT
	}
	Quit $$$OK
}

ClassMethod UpdateTask(id As %String = "") As %Status
{
	If '..GetJSONFromRequest(.obj) {
		Set %response.Status = ..#HTTP400BADREQUEST
		Set error = {"errormessage": "JSON not found"}
		Write error.%ToJSON()
		Quit $$$OK
	}
	
	If '..ValidateJSON(obj,.error) {
		Set %response.Status = ..#HTTP400BADREQUEST
		Write error.%ToJSON()
		Quit $$$OK
	}
	
	Set task = ##class(App.Task).%OpenId(id)
	If '$IsObject(task) {
		Set %response.Status = ..#HTTP404NOTFOUND
		Set error = {"errormessage": "Task does not exist"}
		Write error.%ToJSON()
		Quit $$$OK
	}
	
	Do ..CopyToTaskFromJSON(.task,obj)
	
	Set sc = task.%Save()
	
	Set result={}
	Do result.%Set("Status",$s($$$ISERR(sc):$system.Status.GetOneErrorText(sc),1:"OK"))
	Write result.%ToJSON()
	Quit sc
}

ClassMethod DeleteTask(id As %String) As %Status
{
	Set result={}
	Set sc=0
	
	If id'="",##class(App.Task).%ExistsId(id) {
	  Set sc=##class(App.Task).%DeleteId(id)
	  Do result.%Set("Status",$Select($$$ISERR(sc):$system.Status.GetOneErrorText(sc),1:"OK"))
	}
	Else  {
	  Do result.%Set("Status","")	
	}
	
	Write result.%ToJSON()
	
  	Quit sc
}

// HELPER METHODS

/// Helper method
ClassMethod ValidateJSON(obj As %DynamicObject, Output error As %DynamicObject) As %Boolean
{
	Set error = {}

	If obj.%Get("what") = "" {
		Set error.errormessage = "what is required"
		Quit 0
	}	

	Quit 1
}

/// Helper method
ClassMethod CopyToTaskFromJSON(ByRef task As App.Task, obj As %DynamicObject) [ Private ]
{
	Set task.What = obj.what
}

/// Helper method
ClassMethod GetJSONFromRequest(Output obj As %DynamicObject) As %Boolean
{
	Set ok = 1
	Try {
		Set obj = ##class(%DynamicObject).%FromJSON(%request.Content)
	} Catch ex {
		Set ok = 0
	}
	Quit ok
}

ClassMethod SwaggerSpec() As %Status
{
	Set tSC = ##class(%REST.API).GetWebRESTApplication($NAMESPACE, %request.Application, .swagger)
	Do swagger.info.%Remove("x-ISC_Namespace")
	Set swagger.basePath = "/"
	Set swagger.info.title = "Task REST App"
	Set swagger.info.description = "IRIS REST Contest Entry"
	Set swagger.info.version = "0.1"
	Set swagger.host = "localhost:52773"
	Return ..%ProcessResult($$$OK, swagger)
}

/// forms JSON error from status (if any) and sends it
/// or sends a JSON of different types
ClassMethod %ProcessResult(pStatus As %Status = {$$$OK}, pResult As %DynamicObject = "") As %Status [ Internal ]
{
	#dim %response As %CSP.Response
	Set tSC = $$$OK
	If $$$ISERR(pStatus) {
		Set %response.Status = 500
		Set tSC = ..StatusToJSON(pStatus, .tJSON)
		If $IsObject(tJSON) {
			Set pResult = tJSON
		} Else {
			Set pResult = { "errors": [ { "error": "Unknown error parsing status code" } ] }
		}
	} 
	ElseIf pStatus=1 {
		If '$IsObject(pResult){
			Set pResult = {}
		}
	}
	Else {
		Set %response.Status = pStatus
		Set error = $Piece(pStatus, " ", 2, *)
		Set pResult = { "error": (error) }
	}

	If pResult.%Extends("%Library.DynamicAbstractObject") {
		Write pResult.%ToJSON()
	}
	ElseIf pResult.%Extends("%JSON.Adaptor") {
		Do pResult.%JSONExport()
	}
	ElseIf pResult.%Extends("%Stream.Object") {
		Do pResult.OutputToDevice()
	}
	Quit tSC
}

}
