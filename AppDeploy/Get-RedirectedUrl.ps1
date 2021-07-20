Function Get-RedirectedUrl {
    Param (
        [Parameter(Mandatory = $true)]
        [String]$url
    )
    
    $request = [System.Net.WebRequest]::Create($url)
    $request.AllowAutoRedirect = $true
    
    try {
        $response = $request.GetResponse()
        $response.ResponseUri.AbsoluteUri
        $response.Close()
    }
    
    catch {
        "ERROR: $_"
    }
    
}
