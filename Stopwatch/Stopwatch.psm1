using namespace System.Collections.Concurrent
function Start-Stopwatch {
    <#
    .SYNOPSIS
    Starts a new stopwatch.

    .DESCRIPTION
    Starts a new stopwatch. If a stopwatch with the same name already exists, an error is returned.

    .PARAMETER Name
    The name of the stopwatch to start.

    .PARAMETER Force
    Forces the creation of a stopwatch with the same name.

    .EXAMPLE
    Start-Stopwatch -Name 'Timer1'
    Starts a new stopwatch with the name 'Timer1'.

    .EXAMPLE
    Start-Stopwatch -Name 'Timer1' -Force
    Starts a new stopwatch with the name 'Timer1' even if a stopwatch with the same name already exists.
    #>
    param (
        [Parameter(Mandatory)]
        [string[]]$Name,
        [Parameter()]
        [switch]$Force
    )

    if (-not $script:Stopwatches) {
        $script:Stopwatches = [ConcurrentDictionary[string, System.Diagnostics.Stopwatch]]::new()
    }

    foreach ($Timer in $Name) {
        if ($script:Stopwatches.ContainsKey($Timer) -and -not $Force) {
            Write-Error "Stopwatch with name '$Timer' already exists."
        }
        else {
            $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            $script:Stopwatches[$Timer] = $Stopwatch
        }
    }
}

function Get-Stopwatch {
    <#
    .SYNOPSIS
    Retrieves the current state of one or more stopwatches.

    .DESCRIPTION
    Retrieves the current state of a stopwatch by name or all stopwatches if no name is specified. 
    Returns stopwatches with their elapsed time.

    .PARAMETER Name
    The name(s) of the stopwatch(es) to retrieve.

    .EXAMPLE
    Get-Stopwatch -Name 'Timer1'
    Retrieves the current state of the stopwatch named 'Timer1'.

    .EXAMPLE
    Get-Stopwatch
    Retrieves the state of all stopwatches.

    #>
    param (
        [Parameter(
            ValueFromPipelineByPropertyName,
            ValueFromPipeline)]
        [string[]]$Name
    )

    process {
        if (-not $script:Stopwatches) {
            Write-Error "No stopwatches are currently running."
            return
        }

        if ($Name) {
            foreach ($Timer in $Name) {
                if ($script:Stopwatches.ContainsKey($Timer)) {
                    $Stopwatch = $script:Stopwatches[$Timer]
                    [pscustomobject]@{
                        Name        = $Timer
                        ElapsedTime = "{0:00}:{1:00}:{2:00}.{3:00}" -f $Stopwatch.Elapsed.Hours, $Stopwatch.Elapsed.Minutes, $Stopwatch.Elapsed.Seconds, $Stopwatch.Elapsed.Milliseconds
                        IsRunning   = $Stopwatch.IsRunning
                    }
                }
                else {
                    Write-Error "Stopwatch with name '$Timer' does not exist."
                }
            }
        }
        else {
            $script:Stopwatches.Keys | ForEach-Object {
                $Timer = $_
                $Stopwatch = $script:Stopwatches[$Timer]
                [pscustomobject]@{
                    Name        = $Timer
                    ElapsedTime = "{0:00}:{1:00}:{2:00}.{3:00}" -f $Stopwatch.Elapsed.Hours, $Stopwatch.Elapsed.Minutes, $Stopwatch.Elapsed.Seconds, $Stopwatch.Elapsed.Milliseconds
                    IsRunning   = $Stopwatch.IsRunning
                }
            }
        }
    }
}

function Stop-Stopwatch {
    <#
    .SYNOPSIS
    Stops one or more stopwatches and returns the elapsed time.

    .DESCRIPTION
    Stops the specified stopwatches by name and returns their elapsed time. 
    If a stopwatch does not exist, an error is returned.

    .PARAMETER Name
    The name(s) of the stopwatch(es) to stop.

    .EXAMPLE
    Stop-Stopwatch -Name 'Timer1'
    Stops the stopwatch named 'Timer1' and returns its elapsed time.

    .EXAMPLE
    Stop-Stopwatch -Name 'Timer1', 'Timer2'
    Stops multiple stopwatches and returns their elapsed times.

    #>
    param (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ValueFromPipeline)]
        [string[]]$Name
    )

    process {
        if (-not $script:Stopwatches) {
            Write-Error "No stopwatches are currently running."
            return
        }

        foreach ($Timer in $Name) {
            if ($script:Stopwatches.ContainsKey($Timer)) {
                $Stopwatch = $script:Stopwatches[$Timer]
                $Stopwatch.Stop()
                [pscustomobject]@{
                    Name        = $Timer
                    ElapsedTime = "{0:00}:{1:00}:{2:00}.{3:00}" -f $Stopwatch.Elapsed.Hours, $Stopwatch.Elapsed.Minutes, $Stopwatch.Elapsed.Seconds, $Stopwatch.Elapsed.Milliseconds
                    IsRunning   = $Stopwatch.IsRunning
                }
            }
            else {
                Write-Error "Stopwatch with name '$Timer' does not exist."
            }
        }
    }
}

function Reset-Stopwatch {
    <#
    .SYNOPSIS
    Resets one or more stopwatches.

    .DESCRIPTION
    Resets the specified stopwatches by name. If a stopwatch does not exist, an error is returned.

    .PARAMETER Name
    The name(s) of the stopwatch(es) to reset.

    .EXAMPLE
    Reset-Stopwatch -Name 'Timer1'
    Resets the stopwatch named 'Timer1'.

    .EXAMPLE
    Reset-Stopwatch -Name 'Timer1', 'Timer2'
    Resets multiple stopwatches.

    #>
    param (
        [Parameter(Mandatory)]
        [string[]]$Name
    )
    foreach ($Timer in $Name) {
        if ($script:Stopwatches.ContainsKey($Timer)) {
            $script:Stopwatches[$Timer].Reset()
            $script:Stopwatches[$Timer].Start()
            Write-Output "Stopwatch '$Timer' has been reset."
        }
        else {
            Write-Error "Stopwatch with name '$Timer' does not exist."
        }
    }
}


function Remove-Stopwatch {
    <#
    .SYNOPSIS
    Removes one or more stopwatches from the collection.

    .DESCRIPTION
    Removes the specified stopwatches from the collection. If a stopwatch is running, the removal will fail unless the `-Force` parameter is used.

    .PARAMETER Name
    The name(s) of the stopwatch(es) to remove.

    .PARAMETER Force
    Forces the removal of a running stopwatch.

    .EXAMPLE
    Remove-Stopwatch -Name 'Timer1'
    Removes the stopwatch named 'Timer1'.

    .EXAMPLE
    Remove-Stopwatch -Name 'Timer1' -Force
    Removes the running stopwatch named 'Timer1'.

    .EXAMPLE
    Remove-Stopwatch -Name 'Timer1', 'Timer2'
    Removes multiple stopwatches.

    #>
    param (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ValueFromPipeline)]
        [string[]]$Name,
        [Parameter()]
        [switch]$Force
    )

    process {
        if (-not $script:Stopwatches) {
            Write-Error "No stopwatches are currently defined."
            return
        }

        foreach ($Timer in $Name) {
            if ($script:Stopwatches.ContainsKey($Timer)) {
                $Stopwatch = $script:Stopwatches[$Timer]
                if ($Stopwatch.IsRunning -and -not $Force) {
                    Write-Error "Stopwatch with name '$Timer' is still running and cannot be removed. Use -Force to override."
                }
                else {
                    if ($script:Stopwatches.TryRemove($Timer, [ref]$null)) {
                        Write-Output "Stopwatch with name '$Timer' has been removed."
                    }
                    else {
                        Write-Error "Failed to remove stopwatch with name '$Timer'."
                    }
                }
            }
            else {
                Write-Error "Stopwatch with name '$Timer' does not exist."
            }
        }
    }
}
