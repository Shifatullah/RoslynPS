cls
$dir = Split-Path $MyInvocation.MyCommand.Path
Push-Location $dir

try{
	Add-Type -Path "..\packages\System.Collections.Immutable.1.1.37\lib\portable-net45+win8+wp8+wpa81\System.Collections.Immutable.dll"
	Add-Type -Path "..\packages\System.Reflection.Metadata.1.2.0\lib\portable-net45+win8\System.Reflection.Metadata.dll"
	Add-Type -Path "..\packages\Microsoft.Composition.1.0.27\lib\portable-net45+win8+wp8+wpa81\System.Composition.AttributedModel.dll"
	Add-Type -Path "..\packages\Microsoft.Composition.1.0.27\lib\portable-net45+win8+wp8+wpa81\System.Composition.TypedParts.dll"
	Add-Type -Path "..\packages\Microsoft.CodeAnalysis.Common.1.3.2\lib\net45\Microsoft.CodeAnalysis.dll"
	Add-Type -Path "..\packages\Microsoft.CodeAnalysis.CSharp.1.3.2\lib\net45\Microsoft.CodeAnalysis.CSharp.dll"
	Add-Type -Path "..\packages\Microsoft.CodeAnalysis.Workspaces.Common.1.3.2\lib\net45\Microsoft.CodeAnalysis.Workspaces.dll"
	Add-Type -Path "..\packages\Microsoft.CodeAnalysis.CSharp.Workspaces.1.3.2\lib\net45\Microsoft.CodeAnalysis.CSharp.Workspaces.dll"
	Add-Type -Path "..\packages\Microsoft.CodeAnalysis.Workspaces.Common.1.3.2\lib\net45\Microsoft.CodeAnalysis.Workspaces.Desktop.dll"
}
catch{
	Write-Host $_.Exception
}
Import-Module -Name (Resolve-Path('Modules\RoslynPS\RoslynPS.psm1'))


$solutionPath = (Resolve-Path('..\RoslynPS.sln'))
Solution -Path $solutionPath | Projects | Classes | Methods | Statements | ForEach-Object { Write-Host $_ }