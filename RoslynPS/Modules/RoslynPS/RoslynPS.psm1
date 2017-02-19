
class SyntaxClassesVisitor : Microsoft.CodeAnalysis.CSharp.CSharpSyntaxWalker
{
	[System.Collections.Generic.List[Microsoft.CodeAnalysis.CSharp.Syntax.ClassDeclarationSyntax]] $SyntaxClasses

	SyntaxClassesVisitor ([Microsoft.CodeAnalysis.SemanticModel] $semanticModel) {
		$this.SyntaxClasses = New-Object System.Collections.Generic.List[Microsoft.CodeAnalysis.CSharp.Syntax.ClassDeclarationSyntax]
	}

	[void] VisitClassDeclaration([Microsoft.CodeAnalysis.CSharp.Syntax.ClassDeclarationSyntax] $node)
	{
		[Microsoft.CodeAnalysis.CSharp.Syntax.ClassDeclarationSyntax](([Microsoft.CodeAnalysis.CSharp.CSharpSyntaxWalker]$this).VisitClassDeclaration($node))		
		$this.SyntaxClasses.Add($node)		
	}
}

class SyntaxMethodsVisitor : Microsoft.CodeAnalysis.CSharp.CSharpSyntaxWalker
{
	[System.Collections.Generic.List[Microsoft.CodeAnalysis.CSharp.Syntax.MethodDeclarationSyntax]] $SyntaxMethods

	SyntaxMethodsVisitor ([Microsoft.CodeAnalysis.SemanticModel] $semanticModel) {
		$this.SyntaxMethods = New-Object System.Collections.Generic.List[Microsoft.CodeAnalysis.CSharp.Syntax.ClassDeclarationSyntax]
	}

	[void] VisitMethodDeclaration([Microsoft.CodeAnalysis.CSharp.Syntax.MethodDeclarationSyntax] $node)
	{
		[Microsoft.CodeAnalysis.CSharp.Syntax.MethodDeclarationSyntax](([Microsoft.CodeAnalysis.CSharp.CSharpSyntaxWalker]$this).VisitClassDeclaration($node))		
		$this.SyntaxMethods.Add($node)		
	}
}

function Get-Workspace {
	$workspace = [Microsoft.CodeAnalysis.MSBuild.MSBuildWorkspace]::Create()
	Write-Output $workspace
}

function Get-Solution {
	param(
	[Parameter(ValueFromPipeline = $true)] [Microsoft.CodeAnalysis.MSBuild.MSBuildWorkspace] $workspace,
    [Parameter(Mandatory=$true)] [string]$path
    )
	if ($workspace -eq $null)
	{
		$workspace = Get-Workspace
	}
	$solution = $workspace.OpenSolutionAsync($path).Result
	Write-Output $solution
}

function Get-Projects {
	param(
	[Parameter(Mandatory=$true, ValueFromPipeline = $true)] [Microsoft.CodeAnalysis.Solution] $solution
    )	
	return $solution.Projects
}

function Get-Classes {
	param(
		[Parameter(ValueFromPipeline = $true, ParameterSetName="Solution")] [Microsoft.CodeAnalysis.Solution] $solution,
		[Parameter(ValueFromPipeline = $true, ParameterSetName="Project")] [Microsoft.CodeAnalysis.Project] $project	
	)

	process {				
		switch ($PsCmdlet.ParameterSetName){
			"Solution" { 
				return $solution | Get-Projects | Get-Classes
				break
			}
			"Project"  { 
				$classes = New-Object System.Collections.Generic.List[Microsoft.CodeAnalysis.CSharp.Syntax.ClassDeclarationSyntax]		
				$compilation = $project.GetCompilationAsync().Result	
				foreach($syntaxTree in $compilation.SyntaxTrees){
					$semanticModel = $compilation.GetSemanticModel([Microsoft.CodeAnalysis.SyntaxTree]$syntaxTree)
					$syntaxClassesVisitor = New-Object SyntaxClassesVisitor($semanticModel)
					$syntaxClassesVisitor.Visit($syntaxTree.GetRoot())
					$classes.AddRange($syntaxClassesVisitor.SyntaxClasses)
				}
				return $classes
				break
			}
		}
	}
}

function Get-Methods {
	param(
		[Parameter(ValueFromPipeline = $true, ParameterSetName="Solution")] [Microsoft.CodeAnalysis.Solution] $solution,
		[Parameter(ValueFromPipeline = $true, ParameterSetName="Project")] [Microsoft.CodeAnalysis.Project] $project,
		[Parameter(ValueFromPipeline = $true, ParameterSetName="Class")] [Microsoft.CodeAnalysis.CSharp.Syntax.ClassDeclarationSyntax] $class
	)	
	process {	
		switch ($PsCmdlet.ParameterSetName){
			"Solution" { 
				return $solution | Get-Projects | Get-Classes | Get-Methods
				break
			}
			"Project" { 
				return $project | Get-Classes | Get-Methods
				break
			}
			"Class"  { 		
				$methods = $class.Members | Where { $_.GetType().FullName -ceq "Microsoft.CodeAnalysis.CSharp.Syntax.MethodDeclarationSyntax" }		
				return $methods	
				break
			}
		}
	}
}

function Get-Statements {
	param(
		[Parameter(ValueFromPipeline = $true, ParameterSetName="Solution")] [Microsoft.CodeAnalysis.Solution] $solution,
		[Parameter(ValueFromPipeline = $true, ParameterSetName="Project")] [Microsoft.CodeAnalysis.Project] $project,
		[Parameter(ValueFromPipeline = $true, ParameterSetName="Class")] [Microsoft.CodeAnalysis.CSharp.Syntax.ClassDeclarationSyntax] $class,
		[Parameter(ValueFromPipeline = $true, ParameterSetName="Method")] [Microsoft.CodeAnalysis.CSharp.Syntax.MethodDeclarationSyntax] $method
	)	
	process {	
		switch ($PsCmdlet.ParameterSetName){
			"Solution" { 
				return $solution | Get-Projects | Get-Classes | Get-Methods | Get-Statements
				break
			}
			"Project" { 
				return $project | Get-Classes | Get-Methods | Get-Statements
				break
			}
			"Class"  { 		
				return $class | Get-Methods	| Get-Statements			
				break
			}
			"Method" {
				$statements = $method.Body.Statements
				return $statements
			}
		}			
	}
}

function Get-HelloWorld{
	Write-Host "Hello World"
}