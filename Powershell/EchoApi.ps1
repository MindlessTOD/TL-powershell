# API Echo Test Script based on the KB https://threatlocker.kb.help/allowing-threatlocker-through-your-firewall/
# Simply run script to verify the status of the Instances of ThreatLocker. 
# Use to verify PRTG API status alerts prior to calling Infrastructure on overnights. 
# If the status of the instance reported down is returning a 200 Status Code then DON'T call for API down alerts.
# Author: Travis O'Dell, TL Support

Write-Host "
  ____ ____ ____        ___    __ __ __  ___  
 /    |    \    |      /  _]  /  ]  |  |/   \ 
|  o  |  o  )  |      /  [_  /  /|  |  |     |
|     |   _/|  |     |    _]/  / |  _  |  O  |
|  _  |  |  |  |     |   [_/   \_|  |  |     |
|  |  |  |  |  |     |     \     |  |  |     |
|__|__|__| |____|    |_____|\____|__|__|\___/ 
                                              " -ForegroundColor Green

# Define the possible values for Value1, Value2, and Value3
$Value1Options = @('portalapi', 'api')
$Value2Options = @('b', 'c', 'd', 'e', 'f', 'g', 'h', 'au1', 'ae1', 'ca1', 'eu1', 'sa1')
$Value3Options = @('webapi', 'legacyportal')
$Value4Options = @('b', 'c', 'd', 'e', 'f', 'g', 'ae1', 'ca1', 'eu1', 'sa1')
$Value5Options = @('portalapi', 'betaportalapi')

# Initialize an array to store the results
$results = @()

# Function to test the URL and get the status code
function Test-UrlStatusCode {
    param (
        [string]$Url
    )
    try {
        $response = Invoke-RestMethod -Uri $Url -Method Get -ErrorAction Stop
        $statusCode = 200
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
    }
    return $statusCode
}

# Function to display a loading bar
function Show-LoadingBar {
    param (
        [int]$total,
        [int]$current
    )
    $percent = [math]::Round(($current / $total) * 100)
    $bar = "#" * ($percent / 2)
    $spaces = " " * (50 - ($percent / 2))
    Write-Host -NoNewline "`r[$bar$spaces] $percent% Complete"
}

$totalTests = ($Value1Options.Count * $Value2Options.Count) + ($Value3Options.Count * $Value4Options.Count) + ($Value5Options.Count * $Value2Options.Count)
$currentTest = 0

# Run against: ('portalapi', 'api'), Instances: ('b', 'c', 'd', 'e', 'f', 'g', 'h', 'au1', 'ae1', 'ca1', 'eu1', 'sa1')
foreach ($Value1 in $Value1Options) {
    foreach ($Value2 in $Value2Options) {
        $url = "https://$Value1.$Value2.threatlocker.com/$Value1/echo"
        $statusCode = Test-UrlStatusCode -Url $url
        $results += [pscustomobject]@{
            URL        = $url
            StatusCode = $statusCode
        }
        $currentTest++
        Show-LoadingBar -total $totalTests -current $currentTest
    }
}
# Run against ('webapi', 'legacyportal'), Instances: ('b', 'c', 'd', 'e', 'f', 'g', 'ae1', 'ca1', 'eu1', 'sa1')
foreach ($Value3 in $Value3Options) {
    foreach ($Value4 in $Value4Options) {
        $url = "https://$Value3.$Value4.threatlocker.com/api/echo"
        $statusCode = Test-UrlStatusCode -Url $url
        $results += [pscustomobject]@{
            URL        = $url
            StatusCode = $statusCode
        }
        $currentTest++
        Show-LoadingBar -total $totalTests -current $currentTest
    }
}

# Run against ('webapi', 'legacyportal'), Instances: ('b', 'c', 'd', 'e', 'f', 'g', 'ae1', 'ca1', 'eu1', 'sa1')
foreach ($Value5 in $Value5Options) {
    foreach ($Value2 in $Value2Options) {
        $url = "https://$Value5.$Value2.threatlocker.com/swagger/index.html"
        $statusCode = Test-UrlStatusCode -Url $url
        $results += [pscustomobject]@{
            URL        = $url
            StatusCode = $statusCode
        }
        $currentTest++
        Show-LoadingBar -total $totalTests -current $currentTest
    }
}

# Write the results in a table format with colorized status codes
Write-Host "`nURL".PadRight(80) "Status Code"
Write-Host ("-" * 90)

foreach ($result in $results) {
    $url = $result.URL.PadRight(80)
    $statusCode = $result.StatusCode
    if ($statusCode -eq 200) {
        Write-Host "$url $statusCode" -ForegroundColor Green
    } else {
        Write-Host "$url $statusCode" -ForegroundColor Red
    }
}
 