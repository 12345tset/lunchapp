$port = 8080
$htmlPath = Join-Path $PSScriptRoot "index.html"
$endpoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, $port)
$listener = New-Object System.Net.Sockets.TcpListener($endpoint)
$listener.Start()

Write-Output "TCP Web Server listening on port $port"

while ($true) {
    try {
        $client = $listener.AcceptTcpClient()
        $stream = $client.GetStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $writer = New-Object System.IO.StreamWriter($stream)
        
        # Read HTTP request header line
        $line = $reader.ReadLine()
        while (![string]::IsNullOrEmpty($line)) {
            $line = $reader.ReadLine()
        }

        if (Test-Path $htmlPath) {
            $bytes = [System.IO.File]::ReadAllBytes($htmlPath)
            $header = "HTTP/1.1 200 OK`r`nContent-Type: text/html; charset=utf-8`r`nContent-Length: " + $bytes.Length + "`r`nConnection: close`r`n`r`n"
            $headerBytes = [System.Text.Encoding]::UTF8.GetBytes($header)
            $stream.Write($headerBytes, 0, $headerBytes.Length)
            $stream.Write($bytes, 0, $bytes.Length)
        } else {
            $header = "HTTP/1.1 404 Not Found`r`nContent-Length: 0`r`nConnection: close`r`n`r`n"
            $headerBytes = [System.Text.Encoding]::UTF8.GetBytes($header)
            $stream.Write($headerBytes, 0, $headerBytes.Length)
        }

        $stream.Flush()
        $client.Close()
    } catch {
        # ignore client abort
    }
}
