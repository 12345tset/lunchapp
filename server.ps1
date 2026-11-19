$port = 8080
$htmlPath = Join-Path $PSScriptRoot "index.html"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://*:$port/")

try {
    $listener.Start()
} catch {
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://localhost:$port/")
    $listener.Start()
}

Write-Output "HTTP Server listening on port $port"

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $response = $context.Response
        if (Test-Path $htmlPath) {
            $bytes = [System.IO.File]::ReadAllBytes($htmlPath)
            $response.ContentType = "text/html; charset=utf-8"
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
        }
        $response.OutputStream.Close()
    } catch {
        # ignore client disconnects
    }
}
