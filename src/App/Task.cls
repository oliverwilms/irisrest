Class App.Task Extends (%Persistent, %JSON.Adaptor, %Populate)
{

Property TaskID As %Integer [ Calculated, SqlComputeCode = {Set {*} = {ID} }, SqlComputed ];

Property Who As %String;

Property When As %TimeStamp;

Property What As %String;

Method SetWhenToCurrentTimestamp() As %Status
{
	&sql(SELECT CURRENT_TIMESTAMP INTO :tCurrentTimestamp)
	Set ..When = $Get(tCurrentTimestamp)
	Quit $$$OK
}

Storage Default
{
<Data name="TaskDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Who</Value>
</Value>
<Value name="3">
<Value>When</Value>
</Value>
<Value name="4">
<Value>What</Value>
</Value>
</Data>
<DataLocation>^App.TaskD</DataLocation>
<DefaultData>TaskDefaultData</DefaultData>
<IdLocation>^App.TaskD</IdLocation>
<IndexLocation>^App.TaskI</IndexLocation>
<StreamLocation>^App.TaskS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
