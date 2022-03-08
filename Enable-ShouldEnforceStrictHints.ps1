# THIS SCRIPT IS PROVIDED "AS IS", USE IS AT YOUR OWN RISK, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS/CREATORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THIS SCRIPT OR THE USE OR OTHER DEALINGS IN THIS
# SCRIPT.

#--- part 1, get info ---

$accesshost = Read-Host "Access Tenant Host Name (i.e. td-zzz-zzz.vidmpreview.com)"
$userName = Read-Host "User Name"
$password = Read-Host "Password" -AsSecureString
$usp = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

if (($accesshost -eq "") -or ($userName -eq "") -or ($usp -eq ""))
	{
		Write-Error "One or more mandatory parameters (host name, user name, password) are missing!"
		break
	}

#--- part 2, get token ---

$header = @{
    "Accept" = "application/json";
    "Content-Type" = "application/json"
}

$body = @{
	"username" = $userName;
	"password" = $usp;
	"issueToken" = "true"
}

$result = ""
try {
		$result = Invoke-RestMethod -Uri "https://$accesshost/SAAS/API/1.0/REST/auth/system/login" -Method Post -Headers $header -Body ($body | ConvertTo-Json) -UseBasicParsing
} catch {
		Write-Error "`n($error.Exception.Message)`n"
		break
}

$token = $result.sessionToken

$userName = ""
$password = ""
$usp = ""


#--- part 3, configure setting ---

$header = @{
		"Authorization" = "HZN $token";
		"Content-Type" = "application/vnd.vmware.horizon.manager.launcher.tenant.config+json";
		"Accept" = "application/vnd.vmware.horizon.manager.launcher.tenant.config+json"
}

$body = @{
	"name" = "shouldEnforceStrictHints";
	"value" = "true"
}

$result = ""
try {
		$result = Invoke-RestMethod -Uri "https://$accesshost/launch/configs/config/tenant/shouldEnforceStrictHints" -Method Put -Headers $header -Body ($body | ConvertTo-Json) -UseBasicParsing
} catch {
		Write-Error "`n($error.Exception.Message)`n"
		break
}

$result
