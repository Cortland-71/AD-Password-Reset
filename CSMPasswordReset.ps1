[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[Void] [System.Windows.Forms.Application]::EnableVisualStyles()

Import-Module ActiveDirectory

$Form = New-Object System.Windows.Forms.Form
$Form.formborderstyle = "Fixed3D" 
$form.MaximizeBox = $false 
$Form.Size = New-Object System.Drawing.Size(450,275) 
$Form.StartPosition = "CenterScreen"
$Form.Text = "WINDOWS password reset"

#GUI Starts here ---

# Username hint label ----
$userNameHintLabel = New-Object System.Windows.Forms.Label 
$userNameHintLabel.Text = "example: jsmith" 
$userNameHintLabel.AutoSize = $true 
$userNameHintLabel.ForeColor = "Gray"
$userNameHintLabel.Location = New-Object System.Drawing.Point(130,5) 
$Font = New-Object System.Drawing.Font("Arial",8,[System.Drawing.FontStyle]::Italic) 
$userNameHintLabel.Font = $Font 
$Form.Controls.Add($userNameHintLabel)

# Username label ----
$userNameLabel = New-Object System.Windows.Forms.Label 
$userNameLabel.Text = "Employee User Name:" 
$userNameLabel.AutoSize = $true 
$userNameLabel.Location = New-Object System.Drawing.Point(130,20) 
$userNameLabel.Font = New-Object System.Drawing.Font("Arial",12,[System.Drawing.FontStyle]::Bold) 
$Form.Controls.Add($userNameLabel)

# User name input box ----
$userNameInputBox = New-Object System.Windows.Forms.TextBox
$userNameInputBox.Location = New-Object System.Drawing.Point(130,45)
$userNameInputBox.Size = New-Object System.Drawing.Size(180,0)
$userNameInputBox.Font = New-Object System.Drawing.Font("Arial",12,[System.Drawing.FontStyle]::Bold)
$Form.Controls.Add($userNameInputBox)

# New Password label ----
$newPasswordLabel = New-Object System.Windows.Forms.Label 
$newPasswordLabel.Text = "New Password:" 
$newPasswordLabel.AutoSize = $true 
$newPasswordLabel.Location = New-Object System.Drawing.Point(130,90) 
$newPasswordLabel.Font = New-Object System.Drawing.Font("Arial",12,[System.Drawing.FontStyle]::Bold) 
$Form.Controls.Add($newPasswordLabel)

# Generated Password label ----
$generatedPasswordLabel = New-Object System.Windows.Forms.Label 
$generatedPasswordLabel.Text = $null
$generatedPasswordLabel.AutoSize = $true 
$generatedPasswordLabel.Location = New-Object System.Drawing.Point(130,115) 
$generatedPasswordLabel.ForeColor = "DarkBlue"
$generatedPasswordLabel.Font = New-Object System.Drawing.Font("Arial",12,[System.Drawing.FontStyle]::Bold) 
$Form.Controls.Add($generatedPasswordLabel)

# Submit Button ----
$submitButton = New-Object System.Windows.Forms.Button 
$submitButton.Location = New-Object System.Drawing.Point(170,180) 
$submitButton.Size = New-Object System.Drawing.Size(100,30) 
$submitButton.Text = "Submit" 
$submitButton.Font = New-Object System.Drawing.Font("Arial",12,[System.Drawing.FontStyle]::Regular) 
$submitButton.ForeColor = "Green"
$submitButton.Add_Click({submitClick}) 
$Form.Controls.Add($submitButton)

#\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

$minNumber = 0
$maxNumber = 10
$numberOfInsertedValues = 7
$specialChars = "!","@","$","%","*","?"

$passwordResetLogPath = "\\yganas01\YDrive\MIS\CSMPasswordResetLog.txt"

#\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

function checkIfUserExists() {
	$userName = $userNameInputBox.text.Trim()
	if ($userName -eq "") {Write-Warning -Message "User $userName does not exist."; return}
	if (@(Get-ADUser -Filter { SamAccountName -eq $userName }).Count -eq 0) {
		Write-Warning -Message "User $userName does not exist."
		return $false
	}
	Write-Host "$userName Exists"
	return $true
}

$rand = New-Object System.Random
function generateNewPassword() {
	$userName = $userNameInputBox.text.Trim()
	$randomNumber = $rand.Next($minNumber, $maxNumber)
	$stringNumber = $randomNumber.ToString()
	$fullNumber = ""
	for ($i=0; $i -lt $numberOfInsertedValues; $i++) {$fullNumber += $stringNumber}
	$front = (Get-Culture).TextInfo.ToTitleCase($userName.substring(0,3))
	$randChar = $specialChars[$rand.Next(0,$specialChars.count)]
	$pass = $($front + $fullNumber + $randChar)
	$generatedPasswordLabel.Text = $pass
	return $pass
} 

function changePassword($pass) {
	$user = $userNameInputBox.text
	$userNameInputBox.text = ""
	Write-Host $pass
	#Set-ADAccountPassword -Identity $user -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$pass" -Force)
	#Set-ADUser -Identity $user -ChangePasswordAtLogon $true

	Add-Content $passwordResetLogPath "`r`nCSM: $env:UserName
	Date Time: $((Get-Date).ToString())
	User: $user
	Password changed to: $($generatedPasswordLabel.text.ToString())"
}

function submitClick(){
	if (checkIfUserExists) {
		changePassword(generateNewPassword)
	}
}

$Form.ShowDialog()






