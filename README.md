# Stopwatch PowerShell Module

## Overview
The Stopwatch PowerShell Module provides tools to manage and monitor timers within a script or session. It is designed for scenarios where precise measurement of time intervals is essential. Features include creating, retrieving, stopping, resetting, and removing named stopwatches, all managed within a thread-safe global collection.

## Features
- **Create Stopwatches**: Start one or more named stopwatches.
- **Retrieve Stopwatches**: View the status and elapsed time of active or stopped stopwatches.
- **Stop Stopwatches**: Halt running stopwatches and retrieve elapsed time.
- **Remove Stopwatches**: Delete named stopwatches from the collection.
- **Reset Stopwatches**: Reset existing stopwatches to zero.
- **Thread-Safe Operations**: Built on `ConcurrentDictionary` for robust concurrency management.

## Functions

### 1. `Start-Stopwatch`
Starts one or more named stopwatches.

#### Parameters:
- `-Name` (Required): Name(s) of the stopwatch(es).
- `-Force` (Optional): Overwrites existing stopwatches with the same name.
- `-TimeoutInSeconds` (Optional): Sets a timeout duration for the stopwatch.

#### Examples:
```powershell
Start-Stopwatch -Name 'Timer1'
Start-Stopwatch -Name 'Timer1', 'Timer2' -Force
```

---

### 2. `Get-Stopwatch`
Retrieves information about one or more stopwatches.

#### Parameters:
- `-Name` (Optional): Name(s) of the stopwatch(es).

#### Examples:
```powershell
Get-Stopwatch -Name 'Timer1'

Name   ElapsedTime  IsRunning
----   -----------  ---------
Timer1 00:00:04.650      True
```

---

### 3. `Stop-Stopwatch`
Stops one or more running stopwatches and retrieves their elapsed time.

#### Parameters:
- `-Name` (Required): Name(s) of the stopwatch(es).

#### Examples:
```powershell
Stop-Stopwatch -Name 'Timer1'

Name   ElapsedTime  IsRunning
----   -----------  ---------
Timer1 00:01:08.521     False
```

---

### 4. `Remove-Stopwatch`
Removes one or more stopwatches from the collection.

#### Parameters:
- `-Name` (Required): Name(s) of the stopwatch(es).
- `-Force` (Optional): Forces removal even if the stopwatch is running.

#### Examples:
```powershell
Remove-Stopwatch -Name 'Timer1'
Stopwatch with name 'Timer1' has been removed.

Remove-Stopwatch -Name 'Timer1' -Force
Stopwatch with name 'Timer1' has been removed.
```

---

### 5. `Reset-Stopwatch`
Resets one or more stopwatches to zero.

#### Parameters:
- `-Name` (Required): Name(s) of the stopwatch(es).

#### Examples:
```powershell
Reset-Stopwatch -Name 'Timer1'
Stopwatch 'Timer1' has been reset.
```

---
