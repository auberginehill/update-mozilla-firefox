<#
Update-MozillaFirefox.ps1


Requires either (a) PowerShell v3 or later or (b) .NET 3.5 or later (at Step 8: JSON import and conversion).
Assumes that one instance (the latest non-beta version) of Mozilla Firefox is to be used. The script will exit at Step 15, if more than one instance of Firefox is detected.


Latest Firefox version numbers:
https://product-details.mozilla.org/
https://product-details.mozilla.org/1.0/firefox_versions.json
https://product-details.mozilla.org/1.0/thunderbird_versions.json

Languages:
https://product-details.mozilla.org/1.0/languages.json

Regions:
https://product-details.mozilla.org/1.0/regions/en-US.json

Release History:
https://product-details.mozilla.org/1.0/firefox_history_stability_releases.json

Download Latest Firefox Version URLs:
https://ftp.mozilla.org/pub/firefox/releases/latest/README.txt
https://download.mozilla.org/?product=firefox-latest&os=win&lang=en-US
http://www.mozilla.org/firefox/organizations/all/
https://www.mozilla.org/en-US/firefox/all/

Check if the installed version of Firefox is the latest:
https://www.mozilla.org/en-US/firefox/new/

Uninstall Firefox:
https://support.mozilla.org/en-US/kb/uninstall-firefox-from-your-computer
https://wiki.mozilla.org/Installer:Command_Line_Arguments


#>


# Step 1
# Establish the common parameters
$path = $env:temp
$computer = $env:COMPUTERNAME
$ErrorActionPreference = "Stop"
$start_time = Get-Date
$empty_line = ""
$quote ='"'
$unquote ='"'
$firefox_enumeration = @()
$latest_firefox = @()
$after_update_firefoxes = @()


# Function to check whether a program is installed or not
Function Check-InstalledSoftware ($display_name) {
    Return Get-ItemProperty $registry_paths -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like $display_name }
} # function




# Step 2
# Determine the architecture of a machine                                                     # Credit: Tobias Weltner: "PowerTips Monthly vol 8 January 2014"
If ([IntPtr]::Size -eq 8) {
    $empty_line | Out-String
    "Running in a 64-bit subsystem" | Out-String
    $64 = $true
    $bit_number = "64"
    $registry_paths = @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    $empty_line | Out-String
} Else {
    $empty_line | Out-String
    "Running in a 32-bit subsystem" | Out-String
    $64 = $false
    $bit_number = "32"
    $registry_paths = @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    $empty_line | Out-String
} # Else




# Step 3
# Determine whether Firefox is installed or not
$firefox_is_installed = $false
If ((Check-InstalledSoftware "*Firefox*") -ne $null) {
    $firefox_is_installed = $true
} Else {
    $continue = $true
} # Else




# Step 4
# Enumerate the existing installed Firefoxes
$32_bit_firefox_is_installed = $false
$64_bit_firefox_is_installed = $false
$registry_paths_selection = Get-ItemProperty $registry_paths -ErrorAction SilentlyContinue | Where-Object { ($_.DisplayName -like "*Firefox*" ) -and ($_.Publisher -like "Mozilla*" )}

If ($registry_paths_selection -ne $null) {

    ForEach ($item in $registry_paths_selection) {

        # Custom Values
        If (($item.DisplayName.Split(" ")[-1] -match "\(") -eq $false) {
            $locale = ($item.DisplayName.Split(" ")[-1]).Replace(")","")
        } Else {
            $continue = $true
        } # Else


        If (($item.DisplayName.Split(" ")[-1] -match "\(x") -eq $true) {

            If ($item.DisplayName.Split(" ")[-1] -like "(x86")  {
                $32_bit_firefox_is_installed = $true
                $type = "32-bit"
            } ElseIf ($item.DisplayName.Split(" ")[-1] -like "(x64")  {
                $64_bit_firefox_is_installed = $true
                $type = "64-bit"
            } Else {
                $continue = $true
            } # Else

        } ElseIf (($item.DisplayName.Split(" ")[-2] -match "\(x") -eq $true) {

            If ($item.DisplayName.Split(" ")[-2] -like "(x86")  {
                $32_bit_firefox_is_installed = $true
                $type = "32-bit"
            } ElseIf ($item.DisplayName.Split(" ")[-2] -like "(x64")  {
                $64_bit_firefox_is_installed = $true
                $type = "64-bit"
            } Else {
                $continue = $true
            } # Else

        } Else {
            $continue = $true
        } # Else

       # $product_version_enum = ((Get-ItemProperty -Path "C:\Program Files (x86)\Mozilla Firefox\Firefox.exe" -ErrorAction SilentlyContinue -Name VersionInfo).VersionInfo).ProductVersion
        $product_version_enum = ((Get-ItemProperty -Path "$($item.InstallLocation)\Firefox.exe" -ErrorAction SilentlyContinue -Name VersionInfo).VersionInfo).ProductVersion
        $test_stability = $product_version_enum -match "(\d+)\.(\d+)\.(\d+)"
        $test_major = $product_version_enum -match "(\d+)\.(\d+)"
        If (($product_version_enum -ne $null) -and ($test_stability -eq $true)) { $product_version_enum -match "(?<C1>\d+)\.(?<C2>\d+)\.(?<C3>\d+)" } Else { $continue = $true }
        If (($product_version_enum -ne $null) -and ($test_stability -eq $false) -and ($test_major -eq $true)) { $product_version_enum -match "(?<C1>\d+)\.(?<C2>\d+)" } Else { $continue = $true }


                            $firefox_enumeration += $obj_firefox = New-Object -TypeName PSCustomObject -Property @{
                                'Name'                          = $item.DisplayName.Replace("(TM)","")
                                'Publisher'                     = $item.Publisher
                                'Product'                       = $item.DisplayName.Split(" ")[1]
                                'Type'                          = $type
                                'Locale'                        = $locale
                                'Major Version'                 = If ($Matches.C1 -ne $null) { $Matches.C1 } Else { $continue = $true }
                                'Minor Version'                 = If ($Matches.C2 -ne $null) { $Matches.C2 } Else { $continue = $true }
                                'Build Number'                  = If ($Matches.C3 -ne $null) { $Matches.C3 } Else { "-" }
                                'Computer'                      = $computer
                                'Install Location'              = $item.InstallLocation
                                'Standard Uninstall String'     = $item.UninstallString.Trim('"')
                                'Release Notes'                 = $item.URLUpdateInfo
                                'Identifying Number'            = $item.PSChildName
                                'Version'                       = $item.DisplayVersion
                            } # New-Object
    } # foreach ($item)


        # Display the Firefox Version Enumeration in console
        If ($firefox_enumeration -ne $null) {
            $firefox_enumeration.PSObject.TypeNames.Insert(0,"Firefox Version Enumeration")
            $firefox_enumeration_selection = $firefox_enumeration | Select-Object 'Name','Publisher','Product','Type','Locale','Major Version','Minor Version','Build Number','Computer','Install Location','Standard Uninstall String','Release Notes','Version'
            $empty_line | Out-String
            $header_firefox_enumeration = "Enumeration of Firefox Versions Found on the System"
            $coline_firefox_enumeration = "---------------------------------------------------"
            Write-Output $header_firefox_enumeration
            $coline_firefox_enumeration | Out-String
            Write-Output $firefox_enumeration_selection
        } Else {
            $continue = $true
        } # Else

} Else {
    $continue = $true
} # Else (Step 4)




# Step 5
# Warn the user if more than one instance of Firefox is installed on the system
$multiple_firefoxes = $false
If ((($firefox_enumeration | Measure-Object Name).Count) -eq 0) {
    Write-Verbose "No Firefox seems to be installed on the system."
} ElseIf ((($firefox_enumeration | Measure-Object Name).Count) -eq 1) {
    # One instance of Firefox seems to be installed.
    $continue = $true
} ElseIf ((($firefox_enumeration | Measure-Object Name).Count) -ge 2) {
    $empty_line | Out-String
    Write-Warning "More than one instance of Firefox seems to be installed on the system."
    $multiple_firefoxes = $true
} Else {
    $continue = $true
} # Else




# Step 6
# Check if the computer is connected to the Internet                                          # Credit: ps1: "Test Internet connection"
If (([Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')).IsConnectedToInternet) -eq $false) {
    $empty_line | Out-String
    Return "The Internet connection doesn't seem to be working. Exiting without checking the latest Firefox version numbers or without updating Firefox (at Step 6)."
} Else {
    Write-Verbose 'Checking the most recent Firefox version numbers from the Mozilla website...'
} # Else




# Step 7
# Check the baseline Firefox version numbers by connecting to the Mozilla website and write it to a file (The Baseline). Also download three additional auxillary JSON files from Mozilla.
# Source: https://groups.google.com/forum/#!topic/mozilla.release.engineering/EOyvryJNq7A

$baseline_url = "https://product-details.mozilla.org/1.0/firefox_versions.json"
$baseline_file = "$path\firefox_current_versions.json"

        try
        {
            $download_baseline = New-Object System.Net.WebClient
            $download_baseline.DownloadFile($baseline_url, $baseline_file)
        }
        catch [System.Net.WebException]
        {
            Write-Warning "Failed to access $baseline_url"
            If (([Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')).IsConnectedToInternet) -eq $true) {
                $page_exception_text = "Please consider running this script again. Sometimes this Mozilla page just isn't queryable for no apparent reason. The success rate 'in the second go' usually seems to be a bit higher."
                $empty_line | Out-String
                Write-Output $page_exception_text
            } Else {
                $continue = $true
            } # Else
            $empty_line | Out-String
            Return "Exiting without checking the latest Firefox version numbers or without updating Firefox (at Step 7)."
        }




$history_url = "https://product-details.mozilla.org/1.0/firefox_history_stability_releases.json"
$history_file = "$path\firefox_release_history.json"

        try
        {
            $download_history = New-Object System.Net.WebClient
            $download_history.DownloadFile($history_url, $history_file)
        }
        catch [System.Net.WebException]
        {
            Write-Warning "Failed to access $history_url"
            If (([Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')).IsConnectedToInternet) -eq $true) {
                $empty_line | Out-String
                Write-Output $page_exception_text
            } Else {
                $continue = $true
            } # Else
            $empty_line | Out-String
            Return "Exiting without checking the latest Firefox version numbers or without updating Firefox (at Step 7 while trying to download the history file)."
        }




# https://product-details.mozilla.org/1.0/all.json
# https://product-details.mozilla.org/1.0/firefox.json
$major_url = "https://product-details.mozilla.org/1.0/firefox_history_major_releases.json"
$major_file = "$path\firefox_major_versions.json"

        try
        {
            $download_major = New-Object System.Net.WebClient
            $download_major.DownloadFile($major_url, $major_file)
        }
        catch [System.Net.WebException]
        {
            Write-Warning "Failed to access $major_url"
            If (([Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')).IsConnectedToInternet) -eq $true) {
                $empty_line | Out-String
                Write-Output $page_exception_text
            } Else {
                $continue = $true
            } # Else
            $empty_line | Out-String
            Return "Exiting without checking the latest Firefox version numbers or without updating Firefox (at Step 7 while trying to download a file containing the major version release dates)."
        }




$language_url = "https://product-details.mozilla.org/1.0/languages.json"
$language_file = "$path\firefox_languages.json"

        try
        {
            $download_language = New-Object System.Net.WebClient
            $download_language.DownloadFile($language_url, $language_file)
        }
        catch [System.Net.WebException]
        {
            Write-Warning "Failed to access $language_url"
            If (([Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')).IsConnectedToInternet) -eq $true) {
                $empty_line | Out-String
                Write-Output $page_exception_text
            } Else {
                $continue = $true
            } # Else
            $empty_line | Out-String
            Return "Exiting without checking the latest Firefox version numbers or without updating Firefox (at Step 7 while trying to download the languages file)."
        }




$region_url = "https://product-details.mozilla.org/1.0/regions/en-US.json"
$region_file = "$path\firefox_regions.json"

        try
        {
            $download_region = New-Object System.Net.WebClient
            $download_region.DownloadFile($region_url, $region_file)
        }
        catch [System.Net.WebException]
        {
            Write-Warning "Failed to access $region_url"
            If (([Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')).IsConnectedToInternet) -eq $true) {
                $empty_line | Out-String
                Write-Output $page_exception_text
            } Else {
                $continue = $true
            } # Else
            $empty_line | Out-String
            Return "Exiting without checking the latest Firefox version numbers or without updating Firefox (at Step 7 while trying to download the regions file)."
        }

Start-Sleep -Seconds 2




# Step 8
# Import the downloaded JSON files as objects
# Source: http://stackoverflow.com/questions/1825585/determine-installed-powershell-version?rq=1
# Source: https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/convertfrom-json
# Source: https://blogs.technet.microsoft.com/heyscriptingguy/2014/04/23/powertip-convert-json-file-to-powershell-object/
# Source: http://powershelldistrict.com/powershell-json/
# Source: https://technet.microsoft.com/en-us/library/ee692803.aspx
# Source: http://stackoverflow.com/questions/32887583/powershell-v2-converts-dictionary-to-array-when-returned-from-a-function
<#

    Update channels - Advanced

    Updates can be retrieved from a number of different update channels. To check which channel you are on, look in about:config at app.update.channel. This determines what kind of updates you will receive. The current update channels are:

        nightly: The nightly channel allows you to update to every nightly test build that is produced. There are nightly channels for the trunk (i.e., current release version plus 3 numbers); this is also a nightly channel for the remaining legacy branches (Firefox 3.6 & Thunderbird 3.1 builds).

        aurora: This is a new channel which has been introduced with the rapid-release scheme; these builds reflect changes which also went into beta for the next release, thus making them available immediately, or which were deemed unsuitable for beta but safe for the following release (and, in general don't contain any string changes).

        beta: The beta channel lets you receive every beta, release candidate, and release version of the product (e.g. Firefox 1.5 beta 1, Firefox 1.5 RC 1, Firefox 1.5, etc.). With the new rapid-release process (starting with Firefox/Thunderbird 5.0 and SeaMonkey 2.1), every beta is a release candidate for the next version now, and the actual release build is no longer provided on the beta channel.

        esr: This is a special release channel for extended-support releases which are mostly targeting enterprise users. Features are frozen with every 7th or so update cycle and only security updates provided (i.e., Firefox/Thunderbird 10.0 ESR updates to 10.0.1, 10.0.2, ..., 10.0.x, then 17.0 as the next ESR branch).

        default: This channel is used when there is no channel information, for example if you build Firefox or Thunderbird yourself. There are no updates on this channel. This channel is frequently used by Linux distributions, given that they provide own updates through their respective package-management system.

        release: The release channel will provide stable release versions, including security updates (e.g. Firefox 2.0, 2.0.0.4 etc.).

    Source: http://kb.mozillazine.org/Software_Update

#>

# Join the two files containing release dates
# Source: https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/convertfrom-stringdata
# Source: https://technet.microsoft.com/en-us/library/ee692803.aspx
$history_file_content = (Get-Content -Path $history_file)
$history_conversion = $history_file_content.Replace("}",", ")
$major_file_content = (Get-Content -Path $major_file)
$major_conversion = $major_file_content.Replace("{","")
$all_firefox = [string]$history_conversion + $major_conversion

If ((($PSVersionTable.PSVersion).Major -lt 3) -or (($PSVersionTable.PSVersion).Major -eq $null)) {

    # PowerShell v2 or earlier JSON import                                                    # Credit: Goyuix: "Read Json Object in Powershell 2.0"
    # Requires .NET 3.5 or later
    $powershell_v2_or_earlier = $true

            If (($PSVersionTable.PSVersion).Major -eq $null) {
                $powershell_v1 = $true
                # LoadWithPartialName is obsolete, source: https://msdn.microsoft.com/en-us/library/system.reflection.assembly(v=vs.110).aspx
                [System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")
            } ElseIf (($PSVersionTable.PSVersion).Major -lt 3) {
                $powershell_v2 = $true
                Add-Type -AssemblyName "System.Web.Extensions"
            } Else {
                $continue = $true
            } # Else

    $serializer = New-Object System.Web.Script.Serialization.JavaScriptSerializer
    $latest = $serializer.DeserializeObject((Get-Content -Path $baseline_file) -join "`n")
    $history = $serializer.DeserializeObject((Get-Content -Path $history_file) -join "`n")
    $major = $serializer.DeserializeObject((Get-Content -Path $major_file) -join "`n")
    $all_dates = $serializer.DeserializeObject(($all_firefox) -join "`n")    
    $language = $serializer.DeserializeObject((Get-Content -Path $language_file) -join "`n")
    $region = $serializer.DeserializeObject((Get-Content -Path $region_file) -join "`n")    
    try
    {
        $latest_release_date = (Get-Date ($all_dates.Get_Item("$($latest.LATEST_FIREFOX_VERSION)"))).ToShortDateString()
    }
    catch
    {
        $message = $error[0].Exception
        Write-Verbose $message
    }
} ElseIf (($PSVersionTable.PSVersion).Major -ge 3) {

    # PowerShell v3 or later JSON import
    $latest = (Get-Content -Raw -Path $baseline_file) | ConvertFrom-Json
    $history = (Get-Content -Raw -Path $history_file) | ConvertFrom-Json
    $major = (Get-Content -Raw -Path $major_file) | ConvertFrom-Json
    $all_dates = ($all_firefox) | ConvertFrom-Json      
    $language = (Get-Content -Raw -Path $language_file) | ConvertFrom-Json
    $region = (Get-Content -Raw -Path $region_file) | ConvertFrom-Json
    try
    {
        $latest_release_date = (Get-Date ($all_dates | Select-Object -ExpandProperty "$($latest.LATEST_FIREFOX_VERSION)")).ToShortDateString()
    }
    catch
    {
        $message = $error[0].Exception
        Write-Verbose $message
    }
} Else {
    $continue = $true
} # Else


    # Had the release date not yet been resolved, convert the .json formatted dates to a hash table and try to figure out the date
    # Source: https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/convertfrom-stringdata
    # Source: https://technet.microsoft.com/en-us/library/ee692803.aspx
    If ($latest_release_date -eq $null) {
        $raw_conversion = $all_firefox.Replace("{","").Replace(": "," = ").Replace(",","`r`n").Replace("}","`r`n").Replace('"','')
        $release_dates = ConvertFrom-StringData -StringData $raw_conversion
        $release_dates_list = $release_dates.GetEnumerator() | Sort-Object Value -Descending

            If ($release_dates.ContainsKey("$($latest.LATEST_FIREFOX_VERSION)")) {
                $latest_release_date = $release_dates.Get_Item("$($latest.LATEST_FIREFOX_VERSION)")
            } Else {
                $latest_release_date = "[unknown]"
            } # Else

    } Else {
        $continue = $true
    } # Else

                    $latest_firefox += $obj_latest = New-Object -TypeName PSCustomObject -Property @{
                        'Nightly'                               = $latest.FIREFOX_NIGHTLY
                        'Aurora'                                = $latest.FIREFOX_AURORA
                        'In Development'                        = $latest.LATEST_FIREFOX_DEVEL_VERSION
                        'Released Beta'                         = $latest.LATEST_FIREFOX_RELEASED_DEVEL_VERSION
                        'Extended-Support Release (ESR)'        = $latest.FIREFOX_ESR
                        'Extended-Support Release (ESR) Next'   = $latest.FIREFOX_ESR_NEXT
                        'Old'                                   = $latest.LATEST_FIREFOX_OLDER_VERSION
                        'Latest Release Date'                   = $latest_release_date
                        'Major Versions'                        = $major_url
                        'Release History'                       = $history_url
                        'History'                               = "https://www.mozilla.org/en-US/firefox/releases/"
                        'Info'                                  = [string]"https://www.mozilla.org/en-US/firefox/" + $latest.LATEST_FIREFOX_VERSION + "/releasenotes/"
                        'Current'                               = $latest.LATEST_FIREFOX_VERSION
                    } # New-Object
                $latest_firefox.PSObject.TypeNames.Insert(0,"Latest Firefox Versions")
                $most_recent_firefox_version = $latest_firefox | Select-Object -ExpandProperty Current

        # Display the most recent and extended support Firefox version numbers in console
        If ($latest_firefox -ne $null) {
            $latest_firefox_selection = $latest_firefox | Select-Object 'Nightly','Aurora','In Development','Released Beta','Extended-Support Release (ESR)','Old','Latest Release Date','Release History','History','Info','Current'
            $empty_line | Out-String
            $header_firefox_enumeration = "Latest Firefox Versions"
            $coline_firefox_enumeration = "-----------------------"
            Write-Output $header_firefox_enumeration
            $coline_firefox_enumeration | Out-String
            Write-Output $latest_firefox_selection
        } Else {
            $continue = $true
        } # Else




# Step 9
# Try to determine which Firefox versions, if any, are outdated and need to be updated.
$downloading_firefox_is_required = $false
$downloading_firefox_32_is_required = $false
$downloading_firefox_64_is_required = $false

If ($firefox_is_installed -eq $true) {

    $most_recent_firefox_already_exists = Check-InstalledSoftware "Mozilla Firefox $($most_recent_firefox_version)*"
    $most_recent_32_bit_firefox_already_exists = Check-InstalledSoftware "Mozilla Firefox $($most_recent_firefox_version) (x86*"
    $most_recent_64_bit_firefox_already_exists = Check-InstalledSoftware "Mozilla Firefox $($most_recent_firefox_version) (x64*"
    $all_32_bit_firefoxes = $firefox_enumeration | Where-Object { $_.Type -eq "32-bit" }
    $number_of_32_bit_firefoxes = ($all_32_bit_firefoxes | Measure-Object).Count
    $all_64_bit_firefoxes = $firefox_enumeration | Where-Object { $_.Type -eq "64-bit" }
    $number_of_64_bit_firefoxes = ($all_64_bit_firefoxes | Measure-Object).Count


    # 32-bit
    If ($32_bit_firefox_is_installed -eq $false) {
        $continue = $true

    } ElseIf (($32_bit_firefox_is_installed -eq $true) -and ($most_recent_32_bit_firefox_already_exists) -and ($number_of_32_bit_firefoxes -eq 1)) {

        # $downloading_firefox_32_is_required = $false
        $locale = If (($most_recent_32_bit_firefox_already_exists.DisplayName.Split(" ")[-1] -match "\(") -eq $false) {
                        If ($powershell_v2_or_earlier -eq $true) {
                            $language.Get_Item(($most_recent_32_bit_firefox_already_exists.DisplayName.Split(" ")[-1]).Replace(")",""))
                        } Else {
                            $language | Select-Object -ExpandProperty (($most_recent_32_bit_firefox_already_exists.DisplayName.Split(" ")[-1]).Replace(")",""))
                        } # Else

                    } Else {
                        $continue = $true
                    } # Else ($locale)

        If ($powershell_v2_or_earlier -eq $true) {
            try
            {
                $release_date = $all_dates.Get_Item($most_recent_32_bit_firefox_already_exists.DisplayVersion)
            }
            catch
            {
                $message = $error[0].Exception
                Write-Verbose $message
            }
        } Else {
            try
            {
                $release_date = $all_dates | Select-Object -ExpandProperty $most_recent_32_bit_firefox_already_exists.DisplayVersion
            }
            catch
            {
                $message = $error[0].Exception
                Write-Verbose $message
            }
        } # Else

                            $currently_installed_32 += New-Object -TypeName PSCustomObject -Property @{
                                'Name'                          = $most_recent_32_bit_firefox_already_exists.DisplayName.replace("(TM)","")
                                'Publisher'                     = $most_recent_32_bit_firefox_already_exists.Publisher
                                'Product'                       = $most_recent_32_bit_firefox_already_exists.DisplayName.Split(" ")[1]
                                'Type'                          = "32-bit"
                                'Locale'                        = $locale
                                'Computer'                      = $computer
                                'Install Location'              = $most_recent_32_bit_firefox_already_exists.InstallLocation
                                'Release Notes'                 = $most_recent_32_bit_firefox_already_exists.URLUpdateInfo
                                'Standard Uninstall String'     = $most_recent_32_bit_firefox_already_exists.UninstallString.Trim('"')
                                'Identifying Number'            = $most_recent_32_bit_firefox_already_exists.PSChildName
                                'Release_Date'                  = $release_date
                                'Version'                       = $most_recent_32_bit_firefox_already_exists.DisplayVersion

                            } # New-Object
                        $currently_installed_32.PSObject.TypeNames.Insert(0,"Existing Current Firefox 32-bit")

        $empty_line | Out-String
        Write-Output "Currently (until the next Firefox version is released) the $($($currently_installed_32.Locale).English) 32-bit $($currently_installed_32.Name) released on $((Get-Date ($currently_installed_32.Release_Date)).ToShortDateString()) doesn't need any further maintenance or care."

    } Else {
        $downloading_firefox_32_is_required = $true
        $downloading_firefox_is_required = $true

        ForEach ($32_bit_firefox in $all_32_bit_firefoxes) {

            If ($32_bit_firefox.Version -eq $most_recent_firefox_version) {

                        If ($powershell_v2_or_earlier -eq $true) {
                            try
                            {
                                $release_date = $all_dates.Get_Item($32_bit_firefox.Version)
                            }
                            catch
                            {
                                $message = $error[0].Exception
                                Write-Verbose $message
                            }
                        } Else {
                            try
                            {
                                $release_date_32 = $all_dates | Select-Object -ExpandProperty "$($32_bit_firefox.Version)"
                            }
                            catch
                            {
                                $message = $error[0].Exception
                                Write-Verbose $message
                            }
                        } # Else

                $empty_line | Out-String
                Write-Output "Currently (until the next Firefox version is released) the 32-bit $($32_bit_firefox.Name) released on $((Get-Date ($release_date_32)).ToShortDateString()) doesn't need any further maintenance or care."
            } Else {
                $empty_line | Out-String
                Write-Warning "$($32_bit_firefox.Name) seems to be outdated."
                $empty_line | Out-String
                Write-Output "The most recent non-beta Firefox version is $most_recent_firefox_version. The installed 32-bit Firefox version $($32_bit_firefox.Version) needs to be updated."
            } # Else


        } # ForEach
    } # Else


    # 64-bit
    If ($64_bit_firefox_is_installed -eq $false) {
        $continue = $true

    } ElseIf (($64_bit_firefox_is_installed -eq $true) -and ($most_recent_64_bit_firefox_already_exists) -and ($number_of_64_bit_firefoxes -eq 1)) {

        # $downloading_firefox_64_is_required = $false
        $locale = If (($most_recent_64_bit_firefox_already_exists.DisplayName.Split(" ")[-1] -match "\(") -eq $false) {
                        If ($powershell_v2_or_earlier -eq $true) {
                            $language.Get_Item(($most_recent_64_bit_firefox_already_exists.DisplayName.Split(" ")[-1]).Replace(")",""))
                        } Else {
                            $language | Select-Object -ExpandProperty (($most_recent_64_bit_firefox_already_exists.DisplayName.Split(" ")[-1]).Replace(")",""))
                        } # Else

                    } Else {
                        $continue = $true
                    } # Else ($locale)

        If ($powershell_v2_or_earlier -eq $true) {
            try
            {
                $release_date = $all_dates.Get_Item($most_recent_64_bit_firefox_already_exists.DisplayVersion)
            }
            catch
            {
                $message = $error[0].Exception
                Write-Verbose $message
            }
        } Else {
            try
            {
                $release_date = $all_dates | Select-Object -ExpandProperty $most_recent_64_bit_firefox_already_exists.DisplayVersion
            }
            catch
            {
                $message = $error[0].Exception
                Write-Verbose $message
            }
        } # Else

                            $currently_installed_64 += New-Object -TypeName PSCustomObject -Property @{
                                'Name'                          = $most_recent_64_bit_firefox_already_exists.DisplayName.replace("(TM)","")
                                'Publisher'                     = $most_recent_64_bit_firefox_already_exists.Publisher
                                'Product'                       = $most_recent_64_bit_firefox_already_exists.DisplayName.Split(" ")[1]
                                'Type'                          = "64-bit"
                                'Locale'                        = $locale
                                'Computer'                      = $computer
                                'Install Location'              = $most_recent_64_bit_firefox_already_exists.InstallLocation
                                'Release Notes'                 = $most_recent_64_bit_firefox_already_exists.URLUpdateInfo
                                'Standard Uninstall String'     = $most_recent_64_bit_firefox_already_exists.UninstallString.Trim('"')
                                'Identifying Number'            = $most_recent_64_bit_firefox_already_exists.PSChildName
                                'Release_Date'                  = $release_date
                                'Version'                       = $most_recent_64_bit_firefox_already_exists.DisplayVersion

                            } # New-Object
                        $currently_installed_64.PSObject.TypeNames.Insert(0,"Existing Current Firefox 64-bit")

        $empty_line | Out-String
        Write-Output "Currently (until the next Firefox version is released) the $($($currently_installed_64.Locale).English) 64-bit $($currently_installed_64.Name) released on $((Get-Date ($currently_installed_64.Release_Date)).ToShortDateString()) doesn't need any further maintenance or care."

    } Else {
        $downloading_firefox_64_is_required = $true
        $downloading_firefox_is_required = $true

        ForEach ($64_bit_firefox in $all_64_bit_firefoxes) {

            If ($64_bit_firefox.Version -eq $most_recent_firefox_version) {

                        If ($powershell_v2_or_earlier -eq $true) {
                            try
                            {
                                $release_date_64 = $all_dates.Get_Item($64_bit_firefox.Version)
                            }
                            catch
                            {
                                $message = $error[0].Exception
                                Write-Verbose $message
                            }
                        } Else {
                            try
                            {
                                $release_date_64 = $all_dates | Select-Object -ExpandProperty "$($64_bit_firefox.Version)"
                            }
                            catch
                            {
                                $message = $error[0].Exception
                                Write-Verbose $message
                            }
                        } # Else

                $empty_line | Out-String
                Write-Output "Currently (until the next Firefox version is released) the 64-bit $($64_bit_firefox.Name) released on $((Get-Date ($release_date_64)).ToShortDateString()) doesn't need any further maintenance or care."
            } Else {
                $empty_line | Out-String
                Write-Warning "$($64_bit_firefox.Name) seems to be outdated."
                $empty_line | Out-String
                Write-Output "The most recent non-beta Firefox version is $most_recent_firefox_version. The installed 64-bit Firefox version $($64_bit_firefox.Version) needs to be updated."
            } # Else

        } # ForEach
    } # Else

} Else {
    $continue = $true
} # Else




# Step 10
# Write the Maintenance info in console
If ($firefox_is_installed -eq $true) {

    $32_bit_uninstall_string = $all_32_bit_firefoxes | Select-Object -ExpandProperty 'Standard Uninstall String'
    $64_bit_uninstall_string = $all_64_bit_firefoxes | Select-Object -ExpandProperty 'Standard Uninstall String'

                $obj_maintenance += New-Object -TypeName PSCustomObject -Property @{
                    'Open the Firefox primary profile location'     = [string]'Invoke-Item ' + $quote + [Environment]::GetFolderPath("ApplicationData") + '\Mozilla\Firefox\Profiles' + $unquote
                    'Open the Firefox secondary profile location'   = [string]'Invoke-Item ' + $quote + [Environment]::GetFolderPath("LocalApplicationData") + '\Mozilla\Firefox\Profiles' + $unquote
                    'Open the updates.xml file location'            = [string]'Invoke-Item ' + $quote + [Environment]::GetFolderPath("LocalApplicationData") + '\Mozilla\updates\' + $unquote
                    'Uninstall the 32-bit Firefox'                  = If ($32_bit_firefox_is_installed -eq $true) { $32_bit_uninstall_string } Else { [string]'[not installed]' }
                    'Uninstall the 64-bit Firefox'                  = If ($64_bit_firefox_is_installed -eq $true) { $64_bit_uninstall_string } Else { [string]'[not installed]' }

                } # New-Object
            $obj_maintenance.PSObject.TypeNames.Insert(0,"Maintenance")
            $obj_maintenance_selection = $obj_maintenance | Select-Object 'Open the Firefox primary profile location','Open the Firefox secondary profile location','Open the updates.xml file location','Uninstall the 32-bit Firefox','Uninstall the 64-bit Firefox'


        # Display the Maintenance table in console
        $empty_line | Out-String
        $header_maintenance = "Maintenance"
        $coline_maintenance = "-----------"
        Write-Output $header_maintenance
        $coline_maintenance | Out-String
        Write-Output $obj_maintenance_selection




        $obj_downloading += New-Object -TypeName PSCustomObject -Property @{
            '32-bit Firefox'   = If ($32_bit_firefox_is_installed -eq $true) { $downloading_firefox_32_is_required } Else { [string]'-' }
            '64-bit Firefox'   = If ($64_bit_firefox_is_installed -eq $true) { $downloading_firefox_64_is_required } Else { [string]'-' }
        } # New-Object
    $obj_downloading.PSObject.TypeNames.Insert(0,"Maintenance Is Required for These Firefox Versions")
    $obj_downloading_selection = $obj_downloading | Select-Object '32-bit Firefox','64-bit Firefox'


    # Display in console which installers for Firefox need to be downloaded
    $empty_line | Out-String
    $header_downloading = "Maintenance Is Required for These Firefox Versions"
    $coline_downloading = "--------------------------------------------------"
    Write-Output $header_downloading
    $coline_downloading | Out-String
    Write-Output $obj_downloading_selection
    $empty_line | Out-String

} Else {
    $continue = $true
} # Else




# Step 11
# Determine if there is a real need to carry on with the rest of the script.
If ($firefox_is_installed -eq $true) {

    If (($downloading_firefox_is_required -eq $false) -and ($downloading_firefox_32_is_required -eq $false) -and ($downloading_firefox_64_is_required -eq $false)) {
        Return "The installed Firefox seems to be OK."
    } Else {
        $continue = $true
    } # Else
} Else {
    Write-Warning "No Firefox seems to be installed on the system."
    $empty_line | Out-String
    $no_firefox_text_1 = "This script didn't detect that any version of Firefox would have been installed."
    $no_firefox_text_2 = "Please consider installing Firefox by visiting"
    $no_firefox_text_3 = "https://www.mozilla.org/en-US/firefox/all/"
    $no_firefox_text_4 = "For URLs of the full installation files please, for example, see the page"
    $no_firefox_text_5 = "https://ftp.mozilla.org/pub/firefox/releases/latest/README.txt"
    $no_firefox_text_6 = "and for uninstalling Firefox, please visit"
    $no_firefox_text_7 = "https://support.mozilla.org/en-US/kb/uninstall-firefox-from-your-computer"
    Write-Output $no_firefox_text_1
    Write-Output $no_firefox_text_2
    Write-Output $no_firefox_text_3
    Write-Output $no_firefox_text_4
    Write-Output $no_firefox_text_5
    Write-Output $no_firefox_text_6
    Write-Output $no_firefox_text_7

    # Offer the option to install a specific version of Firefox, if no Firefox is detected and the script is run in an elevated window
    # Source: "Adding a Simple Menu to a Windows PowerShell Script": https://technet.microsoft.com/en-us/library/ff730939.aspx
    # Credit: lamaar75: "Creating a Menu": http://powershell.com/cs/forums/t/9685.aspx
    # Credit: alejandro5042: "How to run exe with/without elevated privileges from PowerShell"
    If (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator") -eq $true) {
        $empty_line | Out-String
        Write-Verbose "Welcome to the Admin Corner." -verbose
        $title_1 = "Install Firefox - The Fundamentals (Step 1/3)"
        $message_1 = "Would you like to install one of the Firefox versions (32-bit or 64-bit in a certain language) with this script?"

        $yes = New-Object System.Management.Automation.Host.ChoiceDescription    "&Yes",    "Yes:     tries to download and install one of the Firefox versions specified on the next two steps."
        $no = New-Object System.Management.Automation.Host.ChoiceDescription     "&No",     "No:      exits from this script (similar to Ctrl + C)."
        $exit = New-Object System.Management.Automation.Host.ChoiceDescription   "&Exit",   "Exit:    exits from this script (similar to Ctrl + C)."
        $abort = New-Object System.Management.Automation.Host.ChoiceDescription  "&Abort",  "Abort:   exits from this script (similar to Ctrl + C)."
        $cancel = New-Object System.Management.Automation.Host.ChoiceDescription "&Cancel", "Cancel:  exits from this script (similar to Ctrl + C)."

        $options_1 = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no, $exit, $abort, $cancel)
        $result_1 = $host.ui.PromptForChoice($title_1, $message_1, $options_1, 1)

            switch ($result_1)
                {
                    0 {
                    "Yes. Proceeding to the next step.";
                    $admin_corner = $true
                    $continue = $true
                    }
                    1 {
                    "No. Exiting from Install Firefox script.";
                    Exit
                    }
                    2 {
                    "Exit. Exiting from Install Firefox script.";
                    Exit
                    }
                    3 {
                    "Abort. Exiting from Install Firefox script.";
                    Exit
                    }
                    4 {
                    "Cancel. Exiting from Install Firefox script.";
                    Exit
                    } # 4
                } # switch

        $empty_line | Out-String
        $title_2 = "Install Firefox - The Bit Version (Step 2/3)"
        $message_2 = "Which bit version (32-bit or 64-bit) of Firefox would you like to install?"

        $32_bit = New-Object System.Management.Automation.Host.ChoiceDescription "&32-bit", "32-bit:    tries to download and install the 32-bit version of Firefox."
        $64_bit = New-Object System.Management.Automation.Host.ChoiceDescription "&64-bit", "64-bit:    tries to download and install the 64-bit version of Firefox."

        $options_2 = [System.Management.Automation.Host.ChoiceDescription[]]($32_bit, $64_bit, $exit, $abort, $cancel)
        $result_2 = $host.ui.PromptForChoice($title_2, $message_2, $options_2, 4)

            switch ($result_2)
                {
                    0 {
                    "32-bit selected.";
                    $firefox_is_installed = $true
                    $32_bit_firefox_is_installed = $true
                    $original_firefox_version = "[Nonexistent]"
                    $downloading_firefox_is_required = $true
                    $downloading_firefox_32_is_required = $true
                    $os = '&os=win'
                    $bit_number = "32"
                    $continue = $true
                    }
                    1 {
                    "64-bit selected.";
                    $firefox_is_installed = $true
                    $64_bit_firefox_is_installed = $true
                    $original_firefox_version = "[Nonexistent]"
                    $downloading_firefox_is_required = $true
                    $downloading_firefox_64_is_required = $true
                    $os = '&os=win64'
                    $bit_number = "64"
                    $continue = $true
                    }
                    2 {
                    "Exit. Exiting from Install Firefox script.";
                    Exit
                    }
                    3 {
                    "Abort. Exiting from Install Firefox script.";
                    Exit
                    }
                    4 {
                    "Cancel. Exiting from Install Firefox script.";
                    Exit
                    } # 4
                } # switch

        $empty_line | Out-String
        $title_3 = "Install Firefox - The Language (Step 3/3)"
        $message_3 = "Which language version of Firefox would you like to install?"

        $0 = New-Object System.Management.Automation.Host.ChoiceDescription "&0 English (US)", "English (US):  tries to download and install the English (US) version of Firefox."
        $1 = New-Object System.Management.Automation.Host.ChoiceDescription "&1 English (British)", "English (British):  tries to download and install the English (British) version of Firefox."
        $2 = New-Object System.Management.Automation.Host.ChoiceDescription "&2 Arabic",      "Arabic:      tries to download and install the Arabic version of Firefox."
        $3 = New-Object System.Management.Automation.Host.ChoiceDescription "&3 Chinese (Simplified)", "Chinese (Simplified):  tries to download and install the Chinese (Simplified) version of Firefox."
        $4 = New-Object System.Management.Automation.Host.ChoiceDescription "&4 Chinese (Traditional)", "Chinese (Traditional):  tries to download and install the Chinese (Traditional) version of Firefox."
        $5 = New-Object System.Management.Automation.Host.ChoiceDescription "&5 Dutch",       "Dutch:       tries to download and install the Dutch version of Firefox."
        $6 = New-Object System.Management.Automation.Host.ChoiceDescription "&6 French",      "French:      tries to download and install the French version of Firefox."
        $7 = New-Object System.Management.Automation.Host.ChoiceDescription "&7 German",      "German:      tries to download and install the German version of Firefox."
        $8 = New-Object System.Management.Automation.Host.ChoiceDescription "&8 Portuguese (Portugal)", "Portuguese (Portugal):  tries to download and install the Portuguese (Portugal) version of Firefox."
        $9 = New-Object System.Management.Automation.Host.ChoiceDescription "&9 Spanish (Spain)", "Spanish (Spain):  tries to download and install the Spanish (Spain) version of Firefox."
        $b = New-Object System.Management.Automation.Host.ChoiceDescription "&b Bengali (India)", "Bengali (India):  tries to download and install the Bengali (India) version of Firefox."
        $d = New-Object System.Management.Automation.Host.ChoiceDescription "&d Danish",      "Danish:      tries to download and install the Danish version of Firefox."
        $f = New-Object System.Management.Automation.Host.ChoiceDescription "&f Finnish",     "Finnish:     tries to download and install the Finnish version of Firefox."
        $g = New-Object System.Management.Automation.Host.ChoiceDescription "&g Greek",       "Greek:       tries to download and install the Greek version of Firefox."
        $h = New-Object System.Management.Automation.Host.ChoiceDescription "&h Hebrew",      "Hebrew:      tries to download and install the Hebrew version of Firefox."
        $i = New-Object System.Management.Automation.Host.ChoiceDescription "&i Italian",     "Italian:     tries to download and install the Italian version of Firefox."
        $j = New-Object System.Management.Automation.Host.ChoiceDescription "&j Indonesian",  "Indonesian:  tries to download and install the Indonesian version of Firefox."
        $k = New-Object System.Management.Automation.Host.ChoiceDescription "&k Korean",      "Korean:      tries to download and install the Korean version of Firefox."
        $l = New-Object System.Management.Automation.Host.ChoiceDescription "&l Latvian",     "Latvian:     tries to download and install the Latvian version of Firefox."
        $m = New-Object System.Management.Automation.Host.ChoiceDescription "&m Malay",       "Malay:       tries to download and install the Malay version of Firefox."
        $n = New-Object System.Management.Automation.Host.ChoiceDescription "&n Norwegian (Nynorsk)", "Norwegian (Nynorsk):  tries to download and install the Norwegian (Nynorsk) version of Firefox."
        $o = New-Object System.Management.Automation.Host.ChoiceDescription "&o Norwegian (Bokmal)", "Norwegian (Bokmal):  tries to download and install the Norwegian (Bokmal) version of Firefox."
        $p = New-Object System.Management.Automation.Host.ChoiceDescription "&p Punjabi (India)", "Punjabi (India):  tries to download and install the Punjabi (India) version of Firefox."
        $q = New-Object System.Management.Automation.Host.ChoiceDescription "&q Hindi (India)", "Hindi (India):  tries to download and install the Hindi (India) version of Firefox."
        $r = New-Object System.Management.Automation.Host.ChoiceDescription "&r Romanian",    "Romanian:    tries to download and install the Romanian version of Firefox."
        $s = New-Object System.Management.Automation.Host.ChoiceDescription "&s Swedish",     "Swedish:     tries to download and install the Swedish version of Firefox."
        $t = New-Object System.Management.Automation.Host.ChoiceDescription "&t Thai",        "Thai:        tries to download and install the Thai version of Firefox."
        $u = New-Object System.Management.Automation.Host.ChoiceDescription "&u Ukrainian",   "Ukrainian:   tries to download and install the Ukrainian version of Firefox."
        $v = New-Object System.Management.Automation.Host.ChoiceDescription "&v Vietnamese",  "Vietnamese:  tries to download and install the Vietnamese version of Firefox."
        $w = New-Object System.Management.Automation.Host.ChoiceDescription "&w Welsh",       "Welsh:       tries to download and install the Welsh version of Firefox."
        $x = New-Object System.Management.Automation.Host.ChoiceDescription "&x Xhosa",       "Xhosa:       tries to download and install the Xhosa version of Firefox."
        $y = New-Object System.Management.Automation.Host.ChoiceDescription "&y Gaelic (Scotland)", "Gaelic (Scotland):  tries to download and install the Gaelic (Scotland) version of Firefox."
        $z = New-Object System.Management.Automation.Host.ChoiceDescription "&z Uzbek",       "Uzbek:       tries to download and install the Uzbek version of Firefox."

        $options_3 = [System.Management.Automation.Host.ChoiceDescription[]]($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $b, $d, $f, $g, $h, $i, $j, $k, $l, $m, $n, $o, $p, $q, $r, $s, $t, $u, $v, $w, $x, $y, $z, $exit, $abort, $cancel)
        $result_3 = $host.ui.PromptForChoice($title_3, $message_3, $options_3, 35)

            switch ($result_3)
                {
                    0 {
                    "English (US) selected.";
                    $lang = '&lang=en-US'
                    $continue = $true
                    }
                    1 {
                    "English (British) selected.";
                    $lang = '&lang=en-GB'
                    $continue = $true
                    }
                    2 {
                    "Arabic selected.";
                    $lang = '&lang=ar'
                    $continue = $true
                    }
                    3 {
                    "Chinese (Simplified) selected.";
                    $lang = '&lang=zh-CN'
                    $continue = $true
                    }
                    4 {
                    "Chinese (Traditional) selected.";
                    $lang = '&lang=zh-TW'
                    $continue = $true
                    }
                    5 {
                    "Dutch selected.";
                    $lang = '&lang=nl'
                    $continue = $true
                    }
                    6 {
                    "French selected.";
                    $lang = '&lang=fr'
                    $continue = $true
                    }
                    7 {
                    "German selected.";
                    $lang = '&lang=de'
                    $continue = $true
                    }
                    8 {
                    "Portuguese (Portugal) selected.";
                    $lang = '&lang=pt-PT'
                    $continue = $true
                    }
                    9 {
                    "Spanish (Spain) selected.";
                    $lang = '&lang=es-ES'
                    $continue = $true
                    }
                    10 {
                    "Bengali (India) selected.";
                    $lang = '&lang=bn-IN'
                    $continue = $true
                    }
                    11 {
                    "Danish selected.";
                    $lang = '&lang=da'
                    $continue = $true
                    }
                    12 {
                    "Finnish selected.";
                    $lang = 'lang=fi'
                    $continue = $true
                    }
                    13 {
                    "Greek selected.";
                    $lang = '&lang=el'
                    $continue = $true
                    }
                    14 {
                    "Hebrew selected.";
                    $lang = '&lang=he'
                    $continue = $true
                    }
                    15 {
                    "Italian selected.";
                    $lang = '&lang=it'
                    $continue = $true
                    }
                    16 {
                    "Indonesian selected.";
                    $lang = '&lang=id'
                    $continue = $true
                    }
                    17 {
                    "Korean selected.";
                    $lang = '&lang=ko'
                    $continue = $true
                    }
                    18 {
                    "Latvian selected.";
                    $lang = '&lang=lv'
                    $continue = $true
                    }
                    19 {
                    "Malay selected.";
                    $lang = '&lang=ms'
                    $continue = $true
                    }
                    20 {
                    "Norwegian (Nynorsk) selected.";
                    $lang = '&lang=nn-NO'
                    $continue = $true
                    }
                    21 {
                    "Norwegian (Bokmal) selected.";
                    $lang = '&lang=nb-NO'
                    $continue = $true
                    }
                    22 {
                    "Punjabi (India) selected.";
                    $lang = '&lang=pa-IN'
                    $continue = $true
                    }
                    23 {
                    "Hindi (India) selected.";
                    $lang = '&lang=hi-IN'
                    $continue = $true
                    }
                    24 {
                    "Romanian selected.";
                    $lang = '&lang=ro'
                    $continue = $true
                    }
                    25 {
                    "Swedish selected.";
                    $lang = '&lang=sv-SE'
                    $continue = $true
                    }
                    26 {
                    "Thai selected.";
                    $lang = '&lang=th'
                    $continue = $true
                    }
                    27 {
                    "Ukrainian selected.";
                    $lang = '&lang=uk'
                    $continue = $true
                    }
                    28 {
                    "Vietnamese selected.";
                    $lang = '&lang=vi'
                    $continue = $true
                    }
                    29 {
                    "Welsh selected.";
                    $lang = '&lang=cy'
                    $continue = $true
                    }
                    30 {
                    "Xhosa selected.";
                    $lang = '&lang=xh'
                    $continue = $true
                    }
                    31 {
                    "Gaelic (Scotland) selected.";
                    $lang = '&lang=gd'
                    $continue = $true
                    }
                    32 {
                    "Uzbek selected.";
                    $lang = '&lang=uz'
                    $continue = $true
                    }
                    33 {
                    "Exit. Exiting from Install Firefox script.";
                    Exit
                    }
                    34 {
                    "Abort. Exiting from Install Firefox script.";
                    Exit
                    }
                    35 {
                    "Cancel. Exiting from Install Firefox script.";
                    Exit
                    } # 35
                } # switch

        # Determine the Download URL based on the selections made by the user.
        # Source: https://ftp.mozilla.org/pub/firefox/releases/latest/README.txt
        # https://download.mozilla.org/?product=firefox-latest&os=win&lang=en-US
        $download_url = [string]'https://download.mozilla.org/?product=firefox-latest' + $os + $lang

    } Else {
        Exit
    } # Else (Admin Corner)
} # Else (No Firefox )




# Step 12
# Check if the PowerShell session is elevated (has been run as an administrator)
If (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator") -eq $false) {
    Write-Warning "It seems that this script is run in a 'normal' PowerShell window."
    $empty_line | Out-String
    Write-Verbose "Please consider running this script in an elevated (administrator-level) PowerShell window." -verbose
    $empty_line | Out-String
    $admin_text = "For performing system altering procedures, such as installing Firefox the elevated rights are mandatory. An elevated PowerShell session can, for example, be initiated by starting PowerShell with the 'run as an administrator' option."
    Write-Output $admin_text
    $empty_line | Out-String
    # Write-Verbose "Even though it could also be possible to write a self elevating PowerShell script (https://blogs.msdn.microsoft.com/virtual_pc_guy/2010/09/23/a-self-elevating-powershell-script/) or run commands elevated in PowerShell (http://powershell.com/cs/blogs/tips/archive/2014/03/19/running-commands-elevated-in-powershell.aspx) with the UAC prompts, the new UAC pop-up window may come as a surprise to the end-user, who isn't neccesarily aware that this script needs the elevated rights to complete the intended actions."
    Return "Exiting without updating (at Step 12)."
} Else {
    $continue = $true
} # Else




# Step 13
# Initiate the update process
$empty_line | Out-String
$timestamp = Get-Date -Format HH:mm:ss
$update_text = "$timestamp - Initiating the Firefox Update Protocol..."
Write-Output $update_text

# Determine the current directory                                                             # Credit: JaredPar and Matthew Pirocchi "What's the best way to determine the location of the current PowerShell script?"
$script_path = Split-Path -parent $MyInvocation.MyCommand.Definition

# "Manual" progress bar variables
$activity             = "Updating Firefox"
$status               = "Status"
$id                   = 1 # For using more than one progress bar
$total_steps          = 19 # Total number of the steps or tasks, which will increment the progress bar
$task_number          = 0.2 # An increasing numerical value, which is set at the beginning of each of the steps that increments the progress bar (and the value should be less or equal to total_steps). In essence, this is the "progress" of the progress bar.
$task                 = "Setting Initial Variables" # A description of the current operation, which is set at the beginning of each of the steps that increments the progress bar.

# Start the progress bar
Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

    # Specify [Esc] and [q] as the Cancel-key                                                 # Credit: Jeff: "Powershell show elapsed time"
    If ($Host.UI.RawUI.KeyAvailable -and ("q" -eq $Host.UI.RawUI.ReadKey("IncludeKeyUp,NoEcho").Character)) {
        Write-Host " ...Stopping the Firefox Update Protocol...";
        Break;
    } ElseIf ($Host.UI.RawUI.KeyAvailable -and (([char]27) -eq $Host.UI.RawUI.ReadKey("IncludeKeyUp,NoEcho").Character)) {
        Write-Host " ...Stopping the Firefox Update Protocol..."; Break;
    } Else {
        $continue = $true
    } # Else




# Step 14
# Write the Firefox installation configuration ini file
# Description: Keep the default save location and the default shortcuts, but disable the Mozilla Maintenance service.
# Source: https://wiki.mozilla.org/Installer:Command_Line_Arguments

<#
            Silent install (always installs into the default location. Use the "Configuration ini file" option below to set the install location and other install options):
            <path to setup executable> -ms

            Silent uninstall:
            <path to setup executable> /S

            Configuration ini file (When specifying a configuration ini file the installer will always run silently):
            <path to setup executable> [/INI=<full path to configuration ini file>]

            The silent install applies only to the full installer and not the stub installer. If you want to perform a silent install you cannot do so with the stub installer and you must use the full installer.
            Full installers for Firefox can be found at http://www.mozilla.org/firefox/all/ (or for Firefox ESR at http://www.mozilla.org/firefox/organizations/all/ ).
#>

$task_number = 1
$task = "Writing the Firefox installation configuration ini file..."
Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

$ini_file = "firefox_configuration.ini"
$ini = New-Item -ItemType File -Path "$path\$ini_file" -Force
$ini
Add-Content $ini -Value ("[Install]
;
; Remove the semicolon (;) to un-comment a line.
;
; The name of the directory where the application will be installed in the
; system's program files directory. The security context the installer is
; running in must have write access to the installation directory. Also, the
; directory must not exist or if it exists it must be a directory and not a
; file. If any of these conditions are not met the installer will abort the
; installation with an error level of 2. If this value is specified
; then InstallDirectoryPath will be ignored.
; InstallDirectoryName=Mozilla Firefox

; The full path to the directory to install the application. The security
; context the installer is running in must have write access to the
; installation directory. Also, the directory must not exist or if it exists
; it must be a directory and not a file. If any of these conditions are not met
; the installer will abort the installation with an error level of 2.
; InstallDirectoryPath=c:\firefox\

; By default all of the following shortcuts are created. To prevent the
; creation of a shortcut specify false for the shortcut you don't want created.

; Create a shortcut for the application in the current user's QuickLaunch
; directory.
; QuickLaunchShortcut=false

; Create a shortcut for the application on the desktop. This will create the
; shortcut in the All Users Desktop directory and if that fails this will
; attempt to create the shortcuts in the current user's Start Menu directory.
; DesktopShortcut=false

; Create shortcuts for the application in the Start Menu. This will create the
; shortcuts in the All Users Start Menu directory and if that fails this will
; attempt to create the shortcuts in the current user's Start Menu directory.
; StartMenuShortcuts=false

; The directory name to use for the StartMenu folder (not available with
; Firefox 4.0 and above - see the note below).
; Note: if StartMenuShortcuts=false is specified then this will be ignored.
; StartMenuDirectoryName=Mozilla Firefox

; The MozillaMaintenance service is used for silent updates and may be used
; for other maintenance related tasks. It is an optional component. This
; option can be used in Firefox 16 or later to skip installing the service.
MaintenanceService=false")




# Step 15
# Determine the required language version and the correct download URL
# Source: https://ftp.mozilla.org/pub/firefox/releases/latest/README.txt
# Source: https://wiki.mozilla.org/Software_Update:Checking_For_Updates
# Source: http://kb.mozillazine.org/App.update.url

<#

                    # Download URL (clickable)
                    https://www.mozilla.org/en-US/firefox/all/

                    # Check if the installed version of Firefox is the latest:
                    https://www.mozilla.org/en-US/firefox/new/

                    # 32-bit English (US) Firefox for Windows:
                    https://download.mozilla.org/?product=firefox-latest&os=win&lang=en-US

                    # 64-bit English (US) Firefox for Windows:
                    https://download.mozilla.org/?product=firefox-latest&os=win64&lang=en-US

#>
<#

                    For other languages, please replace 'lang=en-US' with:
                    Acholi                     lang=ach
                    Afrikaans                  lang=af
                    Albanian                   lang=sq
                    Arabic                     lang=ar
                    Aragonese                  lang=an
                    Armenian                   lang=hy-AM
                    Assamese                   lang=as
                    Asturian                   lang=ast
                    Azerbaijani                lang=az
                    Basque                     lang=eu
                    Belarusian                 lang=be
                    Bengali (Bangladesh)       lang=bn-BD
                    Bengali (India)            lang=bn-IN
                    Bosnian                    lang=bs
                    Breton                     lang=br
                    Bulgarian                  lang=bg
                    Catalan                    lang=ca
                    Chinese (Simplified)       lang=zh-CN
                    Chinese (Traditional)      lang=zh-TW
                    Croatian                   lang=hr
                    Czech                      lang=cs
                    Danish                     lang=da
                    Dutch                      lang=nl
                    English (British)          lang=en-GB
                    English (South African)    lang=en-ZA
                    Esperanto                  lang=eo
                    Estonian                   lang=et
                    Finnish                    lang=fi
                    French                     lang=fr
                    Frisian                    lang=fy-NL
                    Fulah                      lang=ff
                    Gaelic (Scotland)          lang=gd
                    Galician                   lang=gl
                    German                     lang=de
                    Greek                      lang=el
                    Gujarati (India)           lang=gu-IN
                    Hebrew                     lang=he
                    Hindi (India)              lang=hi-IN
                    Hungarian                  lang=hu
                    Icelandic                  lang=is
                    Indonesian                 lang=id
                    Irish                      lang=ga-IE
                    Italian                    lang=it
                    Kannada                    lang=kn
                    Kazakh                     lang=kk
                    Khmer                      lang=km
                    Korean                     lang=ko
                    Latvian                    lang=lv
                    Ligurian                   lang=lij
                    Lithuanian                 lang=lt
                    Lower Sorbian              lang=dsb
                    Macedonian                 lang=mk
                    Maithili                   lang=mai
                    Malay                      lang=ms
                    Malayalam                  lang=ml
                    Marathi                    lang=mr
                    Norwegian (BokmÃ¥l)        lang=nb-NO
                    Norwegian (Nynorsk)        lang=nn-NO
                    Oriya                      lang=or
                    Persian                    lang=fa
                    Polish                     lang=pl
                    Portuguese (Brazilian)     lang=pt-BR
                    Portuguese (Portugal)      lang=pt-PT
                    Punjabi (India)            lang=pa-IN
                    Romanian                   lang=ro
                    Romansh                    lang=rm
                    Russian                    lang=ru
                    Serbian                    lang=sr
                    Sinhala                    lang=si
                    Slovak                     lang=sk
                    Slovenian                  lang=sl
                    Songhai                    lang=son
                    Spanish (Argentina)        lang=es-AR
                    Spanish (Chile)            lang=es-CL
                    Spanish (Mexico)           lang=es-MX
                    Spanish (Spain)            lang=es-ES
                    Swedish                    lang=sv-SE
                    Tamil                      lang=ta
                    Telugu                     lang=te
                    Thai                       lang=th
                    Turkish                    lang=tr
                    Ukrainian                  lang=uk
                    Upper Sorbian              lang=hsb
                    Uzbek                      lang=uz
                    Vietnamese                 lang=vi
                    Welsh                      lang=cy
                    Xhosa                      lang=xh

                    https://download.mozilla.org/?product=firefox-50.0.2-SSL&os=win&lang=en-US
                    https://download.mozilla.org/?product=firefox-50.0.2-complete&amp;os=win&amp;lang=en-US&amp;force=1
                    https://download-installer.cdn.mozilla.net/pub/firefox/releases/50.0.2/win32/en-US/Firefox%20Setup%2050.0.2.exe

                    https://download.mozilla.org/?product=firefox-50.0.2-SSL&os=win64&lang=en-US
                    https://download.mozilla.org/?product=firefox-50.0.2-complete&amp;os=win64&amp;lang=en-US&amp;force=1
                    https://download-installer.cdn.mozilla.net/pub/firefox/releases/50.0.2/win64/en-US/Firefox%20Setup%2050.0.2.exe

                    about:config and search for app.update.url
                    # Old Firefox:
                    https://aus2.mozilla.org/update/3/Firefox/3.0a8pre/2007083015/Darwin_x86-gcc3/en-US/default/Darwin%208.10.1/testpartner/1.0/update.xml?force=1
                    # Firefox (trunk builds since 2010):
                    https://aus3.mozilla.org/update/3/%PRODUCT%/%VERSION%/%BUILD_ID%/%BUILD_TARGET%/%LOCALE%/%CHANNEL%/%OS_VERSION%/%DISTRIBUTION%/%DISTRIBUTION_VERSION%/update.xml
                    # Firefox Current:
                    https://aus5.mozilla.org/update/6/%PRODUCT%/%VERSION%/%BUILD_ID%/%BUILD_TARGET%/%LOCALE%/%CHANNEL%/%OS_VERSION%/%SYSTEM_CAPABILITIES%/%DISTRIBUTION%/%DISTRIBUTION_VERSION%/update.xml

                        '3' is the schema version

                        PRODUCT:                App name                                    (e.g., 'Firefox')
                        VERSION:                App version                                 (e.g., '3.0a8pre')
                        BUILD_ID:               Build ID                                    (e.g., '2007083015')
                        BUILD_TARGET:           Build target                                (e.g., 'Darwin_x86-gcc3')
                        LOCALE:                 App locale                                  (e.g., 'en-US')
                        CHANNEL:                AUS channel                                 (e.g., 'default')
                        OS_VERSION:             Operating System version                    (e.g., 'Darwin%208.10.1')
                        DISTRIBUTION:           Name of customized distribution, if any     (e.g., 'testpartner')
                        DISTRIBUTION_VERSION:   Version of the customized distribution      (e.g., '1.0)

#>

$task_number = 2
$task = "Determining the required language version and the correct download URL..."
Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)


If (($multiple_firefoxes -ne $true) -and ($admin_corner -ne $true)) {


            If ($downloading_firefox_32_is_required -eq $true) {
                $os = '&os=win'
                $bit_number = "32"
            } ElseIf ($downloading_firefox_64_is_required -eq $true) {
                $os = '&os=win64'
                $bit_number = "64"
            } Else {
                $continue = $true
            } # Else


            # $system_language_and_region = (Get-Culture).Name
            # $system_language_abbreviation = (Get-Culture).TwoLetterISOLanguageName
            # $system_language = (Get-Culture).EnglishName
            If (($firefox_enumeration | select -ExpandProperty Locale) -ne $null) {
                $lang = [string]'&lang=' + ($firefox_enumeration | select -ExpandProperty Locale)
            } ElseIf (($firefox_enumeration | select -ExpandProperty Locale) -eq $null) {

                    If ((($language | Select-Object -ErrorAction SilentlyContinue -ExpandProperty "$($(Get-Culture).TwoLetterISOLanguageName)").English) -match ((Get-Culture).EnglishName.split(' (')[0]) ) {
                        $lang = [string]'&lang=' + $($(Get-Culture).TwoLetterISOLanguageName)
                    } ElseIf ((($language | Select-Object -ErrorAction SilentlyContinue -ExpandProperty "$($(Get-Culture).Name)").English) -match ((Get-Culture).EnglishName) ) {
                        $lang = [string]'&lang=' + $($(Get-Culture).Name)
                    } ElseIf ((($language | Select-Object -ErrorAction SilentlyContinue -ExpandProperty "$($(Get-Culture).Name)").English) -match ((Get-Culture).EnglishName.split(' (')[0]) ) {
                        $lang = [string]'&lang=' + $($(Get-Culture).Name)
                    } ElseIf ((($language | Select-Object -ErrorAction SilentlyContinue -ExpandProperty "$($(Get-Culture).TwoLetterISOLanguageName)").English) -match ((Get-Culture).EnglishName) ) {
                        $lang = [string]'&lang=' + $($(Get-Culture).TwoLetterISOLanguageName)
                    } Else {
                       $lang = [string]'&lang=' + (([Threading.Thread]::CurrentThread.CurrentUICulture).Name.Split("-")[0])
                     } # Else

            } Else {
                $continue = $true
            } # Else


    $download_url = [string]'https://download.mozilla.org/?product=firefox-latest' + $os + $lang


} ElseIf (($multiple_firefoxes -ne $true) -and ($admin_corner -eq $true)) {
    $continue = $true
} Else {
    Return "Multiple Firefox installations detected. Please update the relevant Firefox versions manually by visiting for example https://www.mozilla.org/en-US/firefox/all/ or run this script again after reducing the total number of Firefox installations to one. Exiting without updating (at Step 15)."
} # Else (If $multiple_firefoxes)




# Step 16
# Download the latest installation file for Firefox for Windows
If (($firefox_is_installed -eq $true) -and ($downloading_firefox_is_required -eq $true)) {

    $task_number = 4
    $task = "Downloading a full offline $bit_number-bit Firefox installer from $download_url"
    Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)


    $download_file = "Firefox_Setup.exe"
    $firefox_save_location = "$path\$download_file"
    $firefox_is_downloaded = $false

    # Purge existing old Firefox installation files
    If ((Test-Path $firefox_save_location) -eq $true) {
        Write-Verbose "Deleting $firefox_save_location"
        Remove-Item -Path "$firefox_save_location"
    } Else {
        $continue = $true
    } # Else

            try
            {
                $download_firefox = New-Object System.Net.WebClient
                $download_firefox.DownloadFile($download_url, $firefox_save_location)
            }
            catch [System.Net.WebException]
            {
                Write-Warning "Failed to access $download_url"
                $empty_line | Out-String
                Return "Exiting without installing a new Firefox version (at Step 16)."
            }

    Start-Sleep -s 2

    If ((Test-Path $firefox_save_location) -eq $true) {
        $firefox_is_downloaded = $true
    } Else {
        $firefox_is_downloaded = $false
    } # Else

} Else {
    $continue = $true
} # Else




# Step 17
# Exit all browsers
$task_number = 8
$task = "Stopping Firefox -related processes..."
Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

Stop-Process -ProcessName '*messenger*' -ErrorAction SilentlyContinue -Force
Stop-Process -ProcessName 'FlashPlayer*' -ErrorAction SilentlyContinue -Force
Stop-Process -ProcessName 'plugin-container*' -ErrorAction SilentlyContinue -Force
Stop-Process -ProcessName 'chrome*' -ErrorAction SilentlyContinue -Force
Stop-Process -ProcessName 'opera*' -ErrorAction SilentlyContinue -Force
Stop-Process -ProcessName 'firefox' -ErrorAction SilentlyContinue -Force
Stop-Process -ProcessName 'iexplore' -ErrorAction SilentlyContinue -Force
Start-Sleep -s 4




# Step 18
# Install Firefox silently on top of the existing Firefox installation
# For the Firefox installation configuration ini file, please see the Step 14.
# Source: https://wiki.mozilla.org/Installer:Command_Line_Arguments

<#
            Silent install (always installs into the default location. Use the "Configuration ini file" option below to set the install location and other install options):
            <path to setup executable> -ms

            Silent uninstall:
            <path to setup executable> /S

            Configuration ini file (When specifying a configuration ini file the installer will always run silently):
            <path to setup executable> [/INI=<full path to configuration ini file>]

            The silent install applies only to the full installer and not the stub installer. If you want to perform a silent install you cannot do so with the stub installer and you must use the full installer.
            Full installers for Firefox can be found at http://www.mozilla.org/firefox/all/ (or for Firefox ESR at http://www.mozilla.org/firefox/organizations/all/ ).
#>

$task_number = 11
$task = "Installing Firefox..."
Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

If ($firefox_is_downloaded -eq $true) {

    $task_number = 10
    $task = "Installing Firefox..."
    Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

    cd $path
    .\Firefox_Setup.exe /INI="$path\$ini_file" | Out-Null
    cd $script_path
    Start-Sleep -s 5
} Else {
    $continue = $true
} # Else




# Step 19
# Try to find out which Firefox versions, if any, are installed on the system after the update
$task_number = 15
$task = "Enumerating the Firefox versions found on the system after the update..."
Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)


# Determine whether Firefox is installed or not
$firefox_is_installed = $false
If ((Check-InstalledSoftware "*Firefox*") -ne $null) {
    $firefox_is_installed = $true
} Else {
    $continue = $true
} # Else


# Enumerate the installed Firefoxes after the update
$32_bit_firefox_is_installed = $false
$64_bit_firefox_is_installed = $false
$registry_paths_after_update = Get-ItemProperty $registry_paths -ErrorAction SilentlyContinue | Where-Object { ($_.DisplayName -like "*Firefox*" ) -and ($_.Publisher -like "Mozilla*" )}

If ($registry_paths_after_update -ne $null) {

    ForEach ($new_firefox in $registry_paths_after_update) {

        # Custom Values
        If (($new_firefox.DisplayName.Split(" ")[-1] -match "\(") -eq $false) {
            $locale_new = ($new_firefox.DisplayName.Split(" ")[-1]).Replace(")","")
        } Else {
            $continue = $true
        } # Else


        If (($new_firefox.DisplayName.Split(" ")[-1] -match "\(x") -eq $true) {

            If ($new_firefox.DisplayName.Split(" ")[-1] -like "(x86")  {
                $32_bit_firefox_is_installed = $true
                $type_new = "32-bit"
            } ElseIf ($new_firefox.DisplayName.Split(" ")[-1] -like "(x64")  {
                $64_bit_firefox_is_installed = $true
                $type_new = "64-bit"
            } Else {
                $continue = $true
            } # Else

        } ElseIf (($new_firefox.DisplayName.Split(" ")[-2] -match "\(x") -eq $true) {

            If ($new_firefox.DisplayName.Split(" ")[-2] -like "(x86")  {
                $32_bit_firefox_is_installed = $true
                $type_new = "32-bit"
            } ElseIf ($new_firefox.DisplayName.Split(" ")[-2] -like "(x64")  {
                $64_bit_firefox_is_installed = $true
                $type_new = "64-bit"
            } Else {
                $continue = $true
            } # Else

        } Else {
            $continue = $true
        } # Else


        $product_version_new = ((Get-ItemProperty -Path "$($new_firefox.InstallLocation)\Firefox.exe" -ErrorAction SilentlyContinue -Name VersionInfo).VersionInfo).ProductVersion
        $regex_stability = $product_version_new -match "(\d+)\.(\d+)\.(\d+)"
        $regex_major = $product_version_new -match "(\d+)\.(\d+)"  
        If (($product_version_new -ne $null) -and ($regex_stability -eq $true)) { $product_version_new -match "(?<B1>\d+)\.(?<B2>\d+)\.(?<B3>\d+)" } Else { $continue = $true }
        If (($product_version_new -ne $null) -and ($regex_stability -eq $false) -and ($regex_major -eq $true))  { $product_version_new -match "(?<B1>\d+)\.(?<B2>\d+)" } Else { $continue = $true }


                            $after_update_firefoxes += $obj_updated_firefox = New-Object -TypeName PSCustomObject -Property @{
                                'Name'                          = $new_firefox.DisplayName.Replace("(TM)","")
                                'Publisher'                     = $new_firefox.Publisher
                                'Product'                       = $new_firefox.DisplayName.Split(" ")[1]
                                'Type'                          = $type_new
                                'Locale'                        = $locale_new
                                'Major Version'                 = If ($Matches.B1 -ne $null) { $Matches.B1 } Else { $continue = $true }
                                'Minor Version'                 = If ($Matches.B2 -ne $null) { $Matches.B2 } Else { $continue = $true }
                                'Build Number'                  = If ($Matches.B3 -ne $null) { $Matches.B3 } Else { "-" }
                                'Computer'                      = $computer
                                'Install Location'              = $new_firefox.InstallLocation
                                'Standard Uninstall String'     = $new_firefox.UninstallString.Trim('"')
                                'Release Notes'                 = $new_firefox.URLUpdateInfo
                                'Identifying Number'            = $new_firefox.PSChildName
                                'Version'                       = $new_firefox.DisplayVersion
                            } # New-Object
    } # foreach ($new_firefox)


        # Display the Firefox Version Enumeration in console
        If ($after_update_firefoxes -ne $null) {
            $after_update_firefoxes.PSObject.TypeNames.Insert(0,"Firefox Versions After the Update")
            $after_update_firefoxes_selection = $after_update_firefoxes | Select-Object 'Name','Publisher','Product','Type','Locale','Major Version','Minor Version','Build Number','Computer','Install Location','Standard Uninstall String','Release Notes','Version'
            $empty_line | Out-String
            $header_new = "Firefox Versions Found on the System After the Update"
            $coline_new = "-----------------------------------------------------"
            Write-Output $header_new
            $coline_new | Out-String
            Write-Output $after_update_firefoxes_selection
        } Else {
            $continue = $true
        } # Else

} Else {
    $continue = $true
} # Else (Step 19)




# Step 20
# Determine the success rate of the update process.
$task_number = 16
$task = "Determining the success rate of the update process..."
Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)


$multiple_firefoxes_after_update = $false
If ((($after_update_firefoxes | Measure-Object Name).Count) -eq 0) {
    $success = $false
    $empty_line | Out-String
    Write-Warning "No Firefox seems to be installed on the system."
    $empty_line | Out-String
    Return "The most recent non-beta Firefox version is $most_recent_firefox_version. This script tried to update Firefox, but something went wrong with the installation. Instead of updating Firefox this script uninstalled all versions of Firefox. Exiting at Step 20."
} ElseIf ((($after_update_firefoxes | Measure-Object Name).Count) -eq 1) {
    # One instance of Firefox seems to be installed.
    $continue = $true
} ElseIf ((($after_update_firefoxes | Measure-Object Name).Count) -ge 2) {
    $success = $false
    $empty_line | Out-String
    Write-Warning "More than one instance of Firefox seems to be installed on the system."
    $multiple_firefoxes_after_update = $true
    $empty_line | Out-String
    Return "The most recent non-beta Firefox version is $most_recent_firefox_version. This script tried to update Firefox, but something went wrong with the installation. Instead of updating Firefox this script installed yet another version of Firefox. Currently the versions $($after_update_firefoxes.Version) are installed. Exiting at Step 20."
} Else {
    $continue = $true
} # Else


$most_recent_firefox_after_update = Check-InstalledSoftware "Mozilla Firefox $($most_recent_firefox_version)*"
If (($firefox_is_installed -eq $true) -and ($downloading_firefox_is_required -eq $true) -and ($after_update_firefoxes -ne $null) -and ($multiple_firefoxes_after_update -eq $false)) {

    If ($most_recent_firefox_after_update -eq $null) {
        $success = $false
        $empty_line | Out-String
        Write-Warning "Failed to update Mozilla Firefox"
        $empty_line | Out-String
        Return "$($after_update_firefoxes.Name) seems to be outdated. The most recent non-beta Firefox version is $most_recent_firefox_version. The installed Firefox version $($after_update_firefoxes.Version) needs to be updated. This script tried to update Firefox, but failed to do so."

    } ElseIf ($most_recent_firefox_after_update) {

        $success = $true
        $locale = If (($most_recent_firefox_after_update.DisplayName.Split(" ")[-1] -match "\(") -eq $false) {
                        If ($powershell_v2_or_earlier -eq $true) {
                            $language.Get_Item(($most_recent_firefox_after_update.DisplayName.Split(" ")[-1]).Replace(")",""))
                        } Else {
                            $language | Select-Object -ExpandProperty (($most_recent_firefox_after_update.DisplayName.Split(" ")[-1]).Replace(")",""))
                        } # Else

                    } Else {
                        $continue = $true
                    } # Else ($locale)

        If ($powershell_v2_or_earlier -eq $true) {
            try
            {
                $release_date = $all_dates.Get_Item($most_recent_firefox_after_update.DisplayVersion)
            }
            catch
            {
                $message = $error[0].Exception
                Write-Verbose $message
            }
        } Else {
            try
            {
                $release_date = $all_dates | Select-Object -ExpandProperty $most_recent_firefox_after_update.DisplayVersion
            }
            catch
            {
                $message = $error[0].Exception
                Write-Verbose $message
            }
       } # Else

                            $obj_success_firefox += New-Object -TypeName PSCustomObject -Property @{
                                'Name'                          = $most_recent_firefox_after_update.DisplayName.replace("(TM)","")
                                'Publisher'                     = $most_recent_firefox_after_update.Publisher
                                'Product'                       = $most_recent_firefox_after_update.DisplayName.Split(" ")[1]
                                'Type'                          = $after_update_firefoxes.Type
                                'Locale'                        = $locale
                                'Computer'                      = $computer
                                'Install_Location'              = $most_recent_firefox_after_update.InstallLocation
                                'Release Notes'                 = $most_recent_firefox_after_update.URLUpdateInfo
                                'Standard Uninstall String'     = $most_recent_firefox_after_update.UninstallString.Trim('"')
                                'Identifying Number'            = $most_recent_firefox_after_update.PSChildName
                                'Release_Date'                  = $release_date
                                'Version'                       = $most_recent_firefox_after_update.DisplayVersion

                            } # New-Object
                        $obj_success_firefox.PSObject.TypeNames.Insert(0,"Successfully Updated Firefox Version")

        $empty_line | Out-String
        Write-Output "Currently (until the next Firefox version is released) the $($($obj_success_firefox.Locale).English) $($obj_success_firefox.Type) $($obj_success_firefox.Name) released on $((Get-Date ($obj_success_firefox.Release_Date)).ToShortDateString()) doesn't need any further maintenance or care."
        $empty_line | Out-String
        Write-Output "The installed Firefox seems to be OK."

    } Else {
        $continue = $true
    } # Else

} Else {
    $continue = $true
} # Else




# Step 21
# Check if the installed version of Firefox is the latest by opening a web page in the default browser
# Congrats! You're using the latest version of Firefox.
$task_number = 17
$task = "Verifying that the Firefox has been installed by opening a web page in the default browser..."
Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100)

If ($obj_success_firefox -ne $null) {
    Start-Process -FilePath "$($obj_success_firefox.Install_Location)\firefox.exe" -ArgumentList "https://www.mozilla.org/en-US/firefox/new/"
} Else {
    $continue = $true
} # Else




# Step 22
# Close the progress bar
$task_number = 19
$task = "Finished updating Firefox."
Write-Progress -Id $id -Activity $activity -Status $status -CurrentOperation $task -PercentComplete (($task_number / $total_steps) * 100) -Completed


# Find out how long the script took to complete
$end_time = Get-Date
$runtime = ($end_time) - ($start_time)

    If ($runtime.Days -ge 2) {
        $runtime_result = [string]$runtime.Days + ' days ' + $runtime.Hours + ' h ' + $runtime.Minutes + ' min'
    } ElseIf ($runtime.Days -gt 0) {
        $runtime_result = [string]$runtime.Days + ' day ' + $runtime.Hours + ' h ' + $runtime.Minutes + ' min'
    } ElseIf ($runtime.Hours -gt 0) {
        $runtime_result = [string]$runtime.Hours + ' h ' + $runtime.Minutes + ' min'
    } ElseIf ($runtime.Minutes -gt 0) {
        $runtime_result = [string]$runtime.Minutes + ' min ' + $runtime.Seconds + ' sec'
    } ElseIf ($runtime.Seconds -gt 0) {
        $runtime_result = [string]$runtime.Seconds + ' sec'
    } ElseIf ($runtime.Milliseconds -gt 1) {
        $runtime_result = [string]$runtime.Milliseconds + ' milliseconds'
    } ElseIf ($runtime.Milliseconds -eq 1) {
        $runtime_result = [string]$runtime.Milliseconds + ' millisecond'
    } ElseIf (($runtime.Milliseconds -gt 0) -and ($runtime.Milliseconds -lt 1)) {
        $runtime_result = [string]$runtime.Milliseconds + ' milliseconds'
    } Else {
        $runtime_result = [string]''
    } # Else (if)

        If ($runtime_result.Contains(" 0 h")) {
            $runtime_result = $runtime_result.Replace(" 0 h"," ")
            } If ($runtime_result.Contains(" 0 min")) {
                $runtime_result = $runtime_result.Replace(" 0 min"," ")
                } If ($runtime_result.Contains(" 0 sec")) {
                $runtime_result = $runtime_result.Replace(" 0 sec"," ")
        } # if ($runtime_result: first)

# Display the runtime in console
$empty_line | Out-String
$timestamp_end = Get-Date -Format hh:mm:ss
$end_text = "$timestamp_end - The Firefox Update Protocol completed."
Write-Output $end_text
$empty_line | Out-String
$runtime_text = "The update took $runtime_result."
Write-Output $runtime_text
$empty_line | Out-String




# [End of Line]




<#

   _____
  / ____|
 | (___   ___  _   _ _ __ ___ ___
  \___ \ / _ \| | | | '__/ __/ _ \
  ____) | (_) | |_| | | | (_|  __/
 |_____/ \___/ \__,_|_|  \___\___|


http://powershell.com/cs/PowerTips_Monthly_Volume_8.pdf#IDERA-1702_PS-PowerShellMonthlyTipsVol8-jan2014             # Tobias Weltner: "PowerTips Monthly vol 8 January 2014"
http://powershell.com/cs/blogs/tips/archive/2011/05/04/test-internet-connection.aspx                                # ps1: "Test Internet connection"
http://stackoverflow.com/questions/17601528/read-json-object-in-powershell-2-0#17602226                             # Goyuix: "Read Json Object in Powershell 2.0"
http://powershell.com/cs/forums/t/9685.aspx                                                                         # lamaar75: "Creating a Menu"
http://stackoverflow.com/questions/29266622/how-to-run-exe-with-without-elevated-privileges-from-powershell?rq=1    # alejandro5042: "How to run exe with/without elevated privileges from PowerShell"
http://stackoverflow.com/questions/5466329/whats-the-best-way-to-determine-the-location-of-the-current-powershell-script?noredirect=1&lq=1      # JaredPar and Matthew Pirocchi "What's the best way to determine the location of the current PowerShell script?"
http://stackoverflow.com/questions/10941756/powershell-show-elapsed-time                                            # Jeff: "Powershell show elapsed time"


  _    _      _
 | |  | |    | |
 | |__| | ___| |_ __
 |  __  |/ _ \ | '_ \
 | |  | |  __/ | |_) |
 |_|  |_|\___|_| .__/
               | |
               |_|
#>

<#

.SYNOPSIS
Retrieves the latest Mozilla Firefox version numbers from the Internets, and looks
for the installed Firefox versions on the system. If an outdated Firefox version
is found, tries to update Firefox.

.DESCRIPTION
Update-MozillaFirefox downloads a list of the most recent Firefox version numbers
against which it compares the Firefox version numbers found on the system and
displays, whether a Firefox update is needed or not. Update-MozillaFirefox detects
the installed Firefoxes by querying the Windows registry for installed programs.
The keys from
HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ and
HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\ are read on 64-bit
computers, and on the 32-bit computers only the latter path is accessed. At Step 7
Update-MozillaFirefox downloads and writes several Firefox-related files, namely
"firefox_current_versions.json", "firefox_release_history.json",
"firefox_major_versions.json", "firefox_languages.json" and "firefox_regions.json",
which Update-MozillaFirefox uses as data sources. When run in a 'normal' PowerShell
window, and all the detected Firefox versions seem to be up-to-date,
Update-MozillaFirefox will just check that everything is OK and leave without
further ceremony at Step 11.

If Update-MozillaFirefox is run without elevated rights (but with a working Internet
connection) in a machine with an old Firefox version, it will be shown that
a Firefox update is needed, but Update-MozillaFirefox will exit at Step 12 before
downloading any files. To perform an update with Update-MozillaFirefox, PowerShell
has to be run in an elevated window (run as an administrator). If
Update-MozillaFirefox is run in an elevated PowerShell window and no Firefox is
detected, the script offers the option to install Firefox in the "Admin Corner"
(step 11), where, in contrary to the main autonomous nature of Update-MozillaFirefox,
an end-user input is required for selecting the bit-version and the language. In
the "Admin Corner", one instance of either 32-bit or 64-bit version in one of the
available languages is installable with Update-MozillaFirefox – the language
selection covers over 30 languages.

In the update procedure itself Update-MozillaFirefox downloads a full Firefox
installer from Mozilla, which is equal to the type that is already installed on
the system (same bit version and language). After writing the Install Configuration
File (firefox_configuration.ini to $path at Step 14, where, for instance,
the automatic Mozilla Maintenance service is disabled and the default shortcuts
are enabled) and stopping several Firefox-related processes, Update-MozillaFirefox
installs the downloaded Firefox on top of the existing Firefox installation,
which triggers the in-built Firefox update procedure.

.OUTPUTS
Displays Firefox related information in console. Tries to update an outdated Firefox
to its latest version, if an old Firefox installation is found, and if
Update-MozillaFirefox is run in an elevated Powershell window. In addition to that...


At Step 7 the baseline Firefox version numbers are written to a file
(firefox_current_versions.json) and also four additional auxillary JSON files
are created, namely:


    Firefox JSON Files (at Step 7):


        firefox_current_versions.json       %TEMP%\firefox_current_versions.json
        firefox_release_history.json        %TEMP%\firefox_release_history.json
        firefox_major_versions.json         %TEMP%\firefox_major_versions.json
        firefox_languages.json              %TEMP%\firefox_languages.json
        firefox_regions.json                %TEMP%\firefox_regions.json


    The %TEMP% location represents the current Windows temporary file folder.
    In PowerShell, for instance the the command $env:temp displays the temp-folder
    path.


If the actual update procedure including the installation file downloading
is initiated, a Firefox Install Configuration File (firefox_configuration.ini) is
created with one active parameter (other parameters inside the file are commented
out):


    Install Configuration File (at Step 14):


        firefox_configuration.ini           %TEMP%\firefox_configuration.ini


    The %TEMP% location represents the current Windows temporary file folder.
    In PowerShell, for instance the the command $env:temp displays the temp-folder
    path.


To see the actual values that are being written, please see the Step 14 above,
where the following value is written: (altering the duplicated value below won't
affect the script in any meaningful way)


    MaintenanceService=false    The MozillaMaintenance service is used for silent
                                updates and may be used for other maintenance
                                related tasks. It is an optional component. This
                                option can be used in Firefox 16 or later to skip
                                installing the service.


For a comprehensive list of available settings and a more detailed description
of the value above, please see the "Installer:Command Line Arguments" at
https://wiki.mozilla.org/Installer:Command_Line_Arguments


To open these file locations in a Resource Manager Window, for instance a command


    Invoke-Item $env:temp


may be used at the PowerShell prompt window [PS>].

.NOTES
Requires either (a) PowerShell v3 or later or (b) .NET 3.5 or later for importing
and converting JSON-files (at Step 8).

Requires a working Internet connection for downloading a list of the most recent
Firefox version numbers and for downloading a complete Firefox installer from
Mozilla (but the latter procedure is not initiated, if the system is deemed
up-to-date).

For performing any actual updates with Update-MozillaFirefox, it's mandatory to
run this script in an elevated PowerShell window (where PowerShell has been started
with the 'run as an administrator' option). The elevated rights are needed for
installing Firefox on top of the exising Firefox installation.

Update-MozillaFirefox is designed to update only one instance of Firefox. If more
than one instances of Firefox are detected, the script will notify the user in
Step 5, and furthermore, if old Firefox(es) are detected, the script will exit
before downloading the installation file at Step 15.

Please note that the Firefox installation configuration file written at Step 14
disables the Mozilla Maintenance service so that the Mozilla Maintenance service
will not be installed during the Firefox update. The values set with the Install
Configuration File (firefox_configuration.ini) are altering the system files and
seemingly are written somewhere deeper to the innards of Mozilla Firefox
semi-permanently.

Please also notice that when run in an elevated PowerShell window and an old
Firefox version is detected, Update-MozillaFirefox will automatically try to
download files from the Internet without prompting the end-user beforehand or
without asking any confirmations (at Step 16 and onwards) and at Step 17 closes
a bunch of processes without any further notice.

Please note that the downloaded files are placed in a directory, which is specified
with the $path variable (at line 42). The $env:temp variable points to the current
temp folder. The default value of the $env:temp variable is
C:\Users\<username>\AppData\Local\Temp (i.e. each user account has their own
separate temp folder at path %USERPROFILE%\AppData\Local\Temp). To see the current
temp path, for instance a command

    [System.IO.Path]::GetTempPath()

may be used at the PowerShell prompt window [PS>]. To change the temp folder for instance
to C:\Temp, please, for example, follow the instructions at
http://www.eightforums.com/tutorials/23500-temporary-files-folder-change-location-windows.html

    Homepage:           https://github.com/auberginehill/update-mozilla-firefox
    Short URL:          http://tinyurl.com/gr75tjx
    Version:            1.4

.EXAMPLE
./Update-MozillaFirefox
Runs the script. Please notice to insert ./ or .\ before the script name.

.EXAMPLE
help ./Update-MozillaFirefox -Full
Displays the help file.

.EXAMPLE
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
This command is altering the Windows PowerShell rights to enable script execution
in the default (LocalMachine) scope, and defines the conditions under which Windows
PowerShell loads configuration files and runs scripts in general. In Windows Vista
and later versions of Windows, for running commands that change the execution policy
of the LocalMachine scope, Windows PowerShell has to be run with elevated rights
(Run as Administrator). The default policy of the default (LocalMachine) scope is
"Restricted", and a command "Set-ExecutionPolicy Restricted" will "undo" the changes
made with the original example above (had the policy not been changed before...).
Execution policies for the local computer (LocalMachine) and for the current user
(CurrentUser) are stored in the registry (at for instance the
HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ExecutionPolicy key), and remain
effective until they are changed again. The execution policy for a particular session
(Process) is stored only in memory, and is discarded when the session is closed.


    Parameters:

    Restricted      Does not load configuration files or run scripts, but permits
                    individual commands. Restricted is the default execution policy.

    AllSigned       Scripts can run. Requires that all scripts and configuration
                    files be signed by a trusted publisher, including the scripts
                    that have been written on the local computer. Risks running
                    signed, but malicious, scripts.

    RemoteSigned    Requires a digital signature from a trusted publisher on scripts
                    and configuration files that are downloaded from the Internet
                    (including e-mail and instant messaging programs). Does not
                    require digital signatures on scripts that have been written on
                    the local computer. Permits running unsigned scripts that are
                    downloaded from the Internet, if the scripts are unblocked by
                    using the Unblock-File cmdlet. Risks running unsigned scripts
                    from sources other than the Internet and signed, but malicious,
                    scripts.

    Unrestricted    Loads all configuration files and runs all scripts.
                    Warns the user before running scripts and configuration files
                    that are downloaded from the Internet. Not only risks, but
                    actually permits, eventually, running any unsigned scripts from
                    any source. Risks running malicious scripts.

    Bypass          Nothing is blocked and there are no warnings or prompts.
                    Not only risks, but actually permits running any unsigned scripts
                    from any source. Risks running malicious scripts.

    Undefined       Removes the currently assigned execution policy from the current
                    scope. If the execution policy in all scopes is set to Undefined,
                    the effective execution policy is Restricted, which is the
                    default execution policy. This parameter will not alter or
                    remove the ("master") execution policy that is set with a Group
                    Policy setting.
    __________
    Notes: 	      - Please note that the Group Policy setting "Turn on Script Execution"
                    overrides the execution policies set in Windows PowerShell in all
                    scopes. To find this ("master") setting, please, for example, open
                    the Local Group Policy Editor (gpedit.msc) and navigate to
                    Computer Configuration > Administrative Templates >
                    Windows Components > Windows PowerShell.

                  - The Local Group Policy Editor (gpedit.msc) is not available in any
                    Home or Starter edition of Windows.

                  - Group Policy setting "Turn on Script Execution":

               	    Not configured                                          : No effect, the default
                                                                               value of this setting
                    Disabled                                                : Restricted
                    Enabled - Allow only signed scripts                     : AllSigned
                    Enabled - Allow local scripts and remote signed scripts : RemoteSigned
                    Enabled - Allow all scripts                             : Unrestricted


For more information, please type "Get-ExecutionPolicy -List", "help Set-ExecutionPolicy -Full",
"help about_Execution_Policies" or visit https://technet.microsoft.com/en-us/library/hh849812.aspx
or http://go.microsoft.com/fwlink/?LinkID=135170.

.EXAMPLE
New-Item -ItemType File -Path C:\Temp\Update-MozillaFirefox.ps1
Creates an empty ps1-file to the C:\Temp directory. The New-Item cmdlet has an inherent
-NoClobber mode built into it, so that the procedure will halt, if overwriting (replacing
the contents) of an existing file is about to happen. Overwriting a file with the New-Item
cmdlet requires using the Force. If the path name and/or the filename includes space
characters, please enclose the whole -Path parameter value in quotation marks (single or
double):

    New-Item -ItemType File -Path "C:\Folder Name\Update-MozillaFirefox.ps1"

For more information, please type "help New-Item -Full".

.LINK
http://powershell.com/cs/PowerTips_Monthly_Volume_8.pdf#IDERA-1702_PS-PowerShellMonthlyTipsVol8-jan2014
http://powershell.com/cs/blogs/tips/archive/2011/05/04/test-internet-connection.aspx
http://stackoverflow.com/questions/17601528/read-json-object-in-powershell-2-0#17602226
http://powershell.com/cs/forums/t/9685.aspx
http://stackoverflow.com/questions/29266622/how-to-run-exe-with-without-elevated-privileges-from-powershell?rq=1
http://stackoverflow.com/questions/5466329/whats-the-best-way-to-determine-the-location-of-the-current-powershell-script?noredirect=1&lq=1
http://stackoverflow.com/questions/10941756/powershell-show-elapsed-time
http://stackoverflow.com/questions/1825585/determine-installed-powershell-version?rq=1
https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/convertfrom-json
https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/convertfrom-stringdata
https://blogs.technet.microsoft.com/heyscriptingguy/2014/04/23/powertip-convert-json-file-to-powershell-object/
http://stackoverflow.com/questions/32887583/powershell-v2-converts-dictionary-to-array-when-returned-from-a-function
http://powershelldistrict.com/powershell-json/
https://technet.microsoft.com/en-us/library/ff730939.aspx
https://technet.microsoft.com/en-us/library/ee692803.aspx
https://www.credera.com/blog/technology-insights/perfect-progress-bars-for-powershell/
http://kb.mozillazine.org/Software_Update
https://wiki.mozilla.org/Installer:Command_Line_Arguments
https://wiki.mozilla.org/Software_Update:Checking_For_Updates
https://ftp.mozilla.org/pub/firefox/releases/latest/README.txt
http://kb.mozillazine.org/App.update.url

#>
