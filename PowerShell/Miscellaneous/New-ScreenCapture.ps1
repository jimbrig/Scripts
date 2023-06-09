Function New-ScreenCapture {
	<#
		.SYNOPSIS
			Captures a screenshot of the desktop and saves it to specified Path.
		.DESCRIPTION
			Captures a screenshot of the desktop and saves it to specified Path.
		.PARAMETER Path
			Path to save the screenshot to.
		.EXAMPLE
			New-ScreenCapture -Path D:\Screenshots

			Captures a screenshot of the desktop and saves it to D:\Screenshots\YYYY-mm-dd_hhmmss.bmp
		.NOTES
			If using multiple monitors, the screenshot will include all monitors in the generated image.
		.LINK
			https://www.pdq.com/blog/capturing-screenshots-with-powershell-and-net/
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Path
	)
	if (-not (Test-Path -Path $Path)) {
		New-Item -Path $Path -ItemType Directory -Force
	}
	$FileName = "$(Get-Date -f yyyy-MM-dd_HHmmss).bmp"
	$File = "$Path\$FileName"
	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing
	$Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
	$Width = $Screen.Width
	$Height = $Screen.Height
	$Left = $Screen.Left
	$Top = $Screen.Top
	# Create bitmap using the top-left and bottom-right bounds
	$bitmap = New-Object -TypeName System.Drawing.Bitmap -ArgumentList $Width, $Height
	# Create Graphics object
	$graphic = [System.Drawing.Graphics]::FromImage($bitmap)
	# Capture screen
	$graphic.CopyFromScreen($Left, $Top, 0, 0, $bitmap.Size)
	$bitmap.Save($File)
}