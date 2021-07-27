$username = "jimbrig2011@gmail.com"
$email = "jimbrig2011@gmail.com"
$pw = "M1$$ysusy1993cod"

$response = Invoke-RestMethod 'https://profile.callofduty.com/cod/login' -Method 'GET' -Headers $headers -Body $body
$response | ConvertTo-Json

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Cookie", "XSRF-TOKEN={{XSRF-TOKEN}}")

$multipartContent = [System.Net.Http.MultipartFormDataContent]::new()
$stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
$stringHeader.Name = $username
$StringContent = [System.Net.Http.StringContent]::new("{{accountEmail}}")
$StringContent.Headers.ContentDisposition = $stringHeader
$multipartContent.Add($stringContent)

$stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
$stringHeader.Name = $pw
$StringContent = [System.Net.Http.StringContent]::new("{{accountPassword}}")
$StringContent.Headers.ContentDisposition = $stringHeader
$multipartContent.Add($stringContent)

$stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
$stringHeader.Name = "remember_me"
$StringContent = [System.Net.Http.StringContent]::new("true")
$StringContent.Headers.ContentDisposition = $stringHeader
$multipartContent.Add($stringContent)

$stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
$stringHeader.Name = "_csrf"
$StringContent = [System.Net.Http.StringContent]::new("{{XSRF-TOKEN}}")
$StringContent.Headers.ContentDisposition = $stringHeader
$multipartContent.Add($stringContent)

$body = $multipartContent

$response = Invoke-RestMethod 'https://profile.callofduty.com/do_login?new_SiteId=cod' -Method 'POST' -Headers $headers -Body $body
$response | ConvertTo-Json

