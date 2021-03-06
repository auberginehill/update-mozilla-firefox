<!-- Visual Studio Code: For a more comfortable reading experience, use the key combination Ctrl + Shift + V
     Visual Studio Code: To crop the tailing end space characters out, please use the key combination Ctrl + A Ctrl + K Ctrl + X (Formerly Ctrl + Shift + X)
     Visual Studio Code: To improve the formatting of HTML code, press Shift + Alt + F and the selected area will be reformatted in a html file.
     Visual Studio Code shortcuts: http://code.visualstudio.com/docs/customization/keybindings (or https://aka.ms/vscodekeybindings)
     Visual Studio Code shortcut PDF (Windows): https://code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf


  _    _           _       _              __  __          _ _ _       ______ _           __
 | |  | |         | |     | |            |  \/  |        (_) | |     |  ____(_)         / _|
 | |  | |_ __   __| | __ _| |_ ___ ______| \  / | ___ _____| | | __ _| |__   _ _ __ ___| |_ _____  __
 | |  | | '_ \ / _` |/ _` | __/ _ \______| |\/| |/ _ \_  / | | |/ _` |  __| | | '__/ _ \  _/ _ \ \/ /
 | |__| | |_) | (_| | (_| | ||  __/      | |  | | (_) / /| | | | (_| | |    | | | |  __/ || (_) >  <
  \____/| .__/ \__,_|\__,_|\__\___|      |_|  |_|\___/___|_|_|_|\__,_|_|    |_|_|  \___|_| \___/_/\_\
        | |
        |_|                                                                                                      -->


## Update-MozillaFirefox.ps1

<table>
    <tr>
        <td style="padding:6px"><strong>OS:</strong></td>
        <td colspan="2" style="padding:6px">Windows</td>
    </tr>
    <tr>
        <td style="padding:6px"><strong>Type:</strong></td>
        <td colspan="2" style="padding:6px">A Windows PowerShell script</td>
    </tr>
    <tr>
        <td style="padding:6px"><strong>Language:</strong></td>
        <td colspan="2" style="padding:6px">Windows PowerShell</td>
    </tr>
    <tr>
        <td style="padding:6px"><strong>Description:</strong></td>
        <td colspan="2" style="padding:6px">
            <p>
                Update-MozillaFirefox downloads a list of the most recent Firefox version numbers against which it compares the Firefox version numbers found on the system and displays, whether a Firefox update is needed or not. Update-MozillaFirefox detects the installed Firefoxes by querying the Windows registry for installed programs. The keys from <code>HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\</code> and <code>HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\</code> are read on 64-bit computers, and on the 32-bit computers only the latter path is accessed. At Step 7 Update-MozillaFirefox downloads and writes several Firefox-related files, namely "<code>firefox_current_versions.json</code>", "<code>firefox_release_history.json</code>", "<code>firefox_major_versions.json</code>", "<code>firefox_languages.json</code>" and "<code>firefox_regions.json</code>", which Update-MozillaFirefox uses as data sources. When run in a 'normal' PowerShell window, and all the detected Firefox versions seem to be up-to-date, Update-MozillaFirefox will just check that everything is OK and leave without further ceremony at Step 11.</p>
            <p>
                If Update-MozillaFirefox is run without elevated rights (but with a working Internet connection) in a machine with an old Firefox version, it will be shown that a Firefox update is needed, but Update-MozillaFirefox will exit at Step 12 before downloading any files. To perform an update with Update-MozillaFirefox, PowerShell has to be run in an elevated window (run as an administrator). If Update-MozillaFirefox is run in an elevated PowerShell window and no Firefox is detected, the script offers the option to install Firefox in the "<strong>Admin Corner</strong>" (step 11), where, in contrary to the main autonomous nature of Update-MozillaFirefox, an end-user input is required for selecting the bit-version and the language. In the "Admin Corner", one instance of either 32-bit or 64-bit version in one of the available languages is installable with Update-MozillaFirefox – the language selection covers over 30 languages.</p>
            <p>
                In the update procedure itself Update-MozillaFirefox downloads a full Firefox installer from Mozilla, which is equal to the type that is already installed on the system (same bit version and language). After writing the Install Configuration File (<code>firefox_configuration.ini</code> to <code>$path</code> at Step 14, where, for instance, the automatic Mozilla Maintenance service is disabled and the default shortcuts are enabled) and stopping several Firefox-related processes, Update-MozillaFirefox installs the downloaded Firefox on top of the existing Firefox installation, which triggers the in-built Firefox update procedure.</p>
        </td>
    </tr>
    <tr>
        <td style="padding:6px"><strong>Homepage:</strong></td>
        <td colspan="2" style="padding:6px"><a href="https://github.com/auberginehill/update-mozilla-firefox">https://github.com/auberginehill/update-mozilla-firefox</a>
            <br />Short URL: <a href="http://tinyurl.com/gr75tjx">http://tinyurl.com/gr75tjx</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><strong>Version:</strong></td>
        <td colspan="2" style="padding:6px">1.6</td>
    </tr>
    <tr>
        <td rowspan="9" style="padding:6px"><strong>Sources:</strong></td>
        <td style="padding:6px">Emojis:</td>
        <td style="padding:6px"><a href="https://github.com/auberginehill/emoji-table">Emoji Table</a></td>
    </tr>
    <tr>
        <td style="padding:6px">Tobias Weltner:</td>
        <td style="padding:6px"><a href="http://powershell.com/cs/PowerTips_Monthly_Volume_8.pdf#IDERA-1702_PS-PowerShellMonthlyTipsVol8-jan2014">PowerTips Monthly vol 8 January 2014</a>                (or one of the <a href="https://web.archive.org/web/20150110213108/http://powershell.com/cs/media/p/30542.aspx">archive.org versions</a>)</td>
    </tr>
    <tr>
        <td style="padding:6px">ps1:</td>
        <td style="padding:6px"><a href="http://powershell.com/cs/blogs/tips/archive/2011/05/04/test-internet-connection.aspx">Test Internet connection</a>                (or one of the <a href="https://web.archive.org/web/20110612212629/http://powershell.com/cs/blogs/tips/archive/2011/05/04/test-internet-connection.aspx">archive.org versions</a>)</td>
    </tr>
    <tr>
        <td style="padding:6px">Goyuix:</td>
        <td style="padding:6px"><a href="http://stackoverflow.com/questions/17601528/read-json-object-in-powershell-2-0#17602226 ">Read Json Object in Powershell 2.0</a></td>
    </tr>
    <tr>
        <td style="padding:6px">lamaar75:</td>
        <td style="padding:6px"><a href="http://powershell.com/cs/forums/t/9685.aspx">Creating a Menu</a> (or one of the <a href="https://web.archive.org/web/20150910111758/http://powershell.com/cs/forums/t/9685.aspx">archive.org versions</a>)</td>
    </tr>
    <tr>
        <td style="padding:6px">alejandro5042:</td>
        <td style="padding:6px"><a href="http://stackoverflow.com/questions/29266622/how-to-run-exe-with-without-elevated-privileges-from-powershell?rq=1">How to run exe with/without elevated privileges from PowerShell</a></td>
    </tr>
    <tr>
        <td style="padding:6px">JaredPar and Matthew Pirocchi:</td>
        <td style="padding:6px"><a href="http://stackoverflow.com/questions/5466329/whats-the-best-way-to-determine-the-location-of-the-current-powershell-script?noredirect=1&lq=1">What's the best way to determine the location of the current PowerShell script?</a></td>
    </tr>
    <tr>
        <td style="padding:6px">Jeff:</td>
        <td style="padding:6px"><a href="http://stackoverflow.com/questions/10941756/powershell-show-elapsed-time">Powershell show elapsed time</a></td>
    </tr>
    <tr>
        <td style="padding:6px">Microsoft TechNet:</td>
        <td style="padding:6px"><a href="https://technet.microsoft.com/en-us/library/ff730939.aspx">Adding a Simple Menu to a Windows PowerShell Script</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><strong>Downloads:</strong></td>
        <td colspan="2" style="padding:6px">For instance <a href="https://raw.githubusercontent.com/auberginehill/update-mozilla-firefox/master/Update-MozillaFirefox.ps1">Update-MozillaFirefox.ps1</a>.
            Or <a href="https://github.com/auberginehill/update-mozilla-firefox/archive/master.zip">everything as a .zip-file</a>.</td>
    </tr>
</table>




### Screenshot

<ol><ol><ol><ol><ol>
<img class="screenshot" title="screenshot" alt="screenshot" height="80%" width="80%" src="https://raw.githubusercontent.com/auberginehill/update-mozilla-firefox/master/Update-MozillaFirefox.png">
</ol></ol></ol></ol></ol>




### Outputs

<table>
    <tr>
        <th>:arrow_right:</th>
        <td style="padding:6px">
            <ul>
                <li>Displays Firefox related information in console. Tries to update an outdated Firefox to its latest version, if an old Firefox installation is found, and if Update-MozillaFirefox is run in an elevated Powershell window. In addition to that...</li>
            </ul>
        </td>
    </tr>
    <tr>
        <th></th>
        <td style="padding:6px">
            <ul>
                <p>
                    <li>At Step 7 the baseline Firefox version numbers are written to a file (<code>firefox_current_versions.json</code>) and also four additional auxillary JSON files are created, namely:</li>
                </p>
                <ol>
                    <p><strong>Firefox JSON Files</strong> (at Step 7):</p>
                    <p>
                        <table>
                            <tr>
                                <td style="padding:6px"><strong>File</strong></td>
                                <td style="padding:6px"><strong>Path</strong></td>
                            </tr>
                            <tr>
                                <td style="padding:6px"><code>firefox_current_versions.json</code></td>
                                <td style="padding:6px"><code>%TEMP%\firefox_current_versions.json</code></td>
                            </tr>
                            <tr>
                                <td style="padding:6px"><code>firefox_release_history.json</code></td>
                                <td style="padding:6px"><code>%TEMP%\firefox_release_history.json</code></td>
                            </tr>
                            <tr>
                                <td style="padding:6px"><code>firefox_major_versions.json</code></td>
                                <td style="padding:6px"><code>%TEMP%\firefox_major_versions.json</code></td>
                            </tr>                       
                            <tr>
                                <td style="padding:6px"><code>firefox_languages.json</code></td>
                                <td style="padding:6px"><code>%TEMP%\firefox_languages.json</code></td>
                            </tr>
                            <tr>
                                <td style="padding:6px"><code>firefox_regions.json</code></td>
                                <td style="padding:6px"><code>%TEMP%\firefox_regions.json</code></td>
                            </tr>
                        </table>
                    </p>
                    <p>The <code>%TEMP%</code> location represents the current Windows temporary file folder. In PowerShell, for instance the command <code>$env:temp</code> displays the temp-folder path.</p>
                </ol>
                <p>
                    <li>If the actual update procedure including the installation file downloading is initiated, a Firefox Install Configuration File (<code>firefox_configuration.ini</code>) is created with one active parameter (other parameters inside the file are commented out), and after Firefox has been updated, a web page displaying the latest version is opened in the default browser.</li>
                </p>
                <ol>
                    <p><strong>Install Configuration File</strong> (at Step 14):</p>
                    <p>
                        <table>
                            <tr>
                                <td style="padding:6px"><strong>File</strong></td>
                                <td style="padding:6px"><strong>Path</strong></td>
                            </tr>
                            <tr>
                                <td style="padding:6px"><code>firefox_configuration.ini</code></td>
                                <td style="padding:6px"><code>%TEMP%\firefox_configuration.ini</code></td>
                            </tr>
                        </table>
                    </p>
                    <p>The <code>%TEMP%</code> location represents the current Windows temporary file folder. In PowerShell, for instance the command <code>$env:temp</code> displays the temp-folder path.</p>
                </ol>
                <p>
                    <li>To see the actual values that are being written to the Install Configuration File (<code>firefox_configuration.ini</code>), please see the Step 14 in the <a href="https://raw.githubusercontent.com/auberginehill/update-mozilla-firefox/master/Update-MozillaFirefox.ps1">script</a> itself, where the following value is written:</li>
                </p>
                <ol>
                    <p>
                        <table>
                            <tr>
                                <td style="padding:6px"><strong>Value</strong></td>
                                <td style="padding:6px"><strong>Description</strong></td>
                            </tr>
                            <tr>
                                <td style="padding:6px"><code>MaintenanceService=false</code></td>
                                <td style="padding:6px">The MozillaMaintenance service is used for silent updates and may be used for other maintenance related tasks. It is an optional component. This option can be used in Firefox 16 or later to skip installing the service.</td>
                            </tr>
                        </table>
                    </p>
                    <p>For a comprehensive list of available settings and a more detailed description of the value above, please see the "<a href="https://wiki.mozilla.org/Installer:Command_Line_Arguments">Installer:Command Line Arguments</a>" page.</p>
                </ol>
                <p>
                    <li>To open these file locations in a Resource Manager Window, for instance a command
                        <br />
                        <br /><code>Invoke-Item $env:temp</code>
                        <br />
                        <br />may be used at the PowerShell prompt window <code>[PS&gt;]</code>.
                    </li>
                </p>
            </ul>
        </td>
    </tr>
</table>




### Notes

<table>
    <tr>
        <th>:warning:</th>
        <td style="padding:6px">
            <ul>
                <li>Requires either (a) PowerShell v3 or later or (b) .NET 3.5 or later for importing and converting JSON-files (at Step 8).</li>
            </ul>
        </td>
    </tr>
    <tr>
        <th></th>
        <td style="padding:6px">
            <ul>
                <p>
                    <li>Requires a working Internet connection for downloading a list of the most recent Firefox version numbers and for downloading a complete Firefox installer from Mozilla (but the latter procedure is not initiated, if the system is deemed up-to-date).</li>
                </p>
                <p>
                    <li>For performing any actual updates with Update-MozillaFirefox, it's mandatory to run this script in an elevated PowerShell window (where PowerShell has been started with the 'run as an administrator' option). The elevated rights are needed for installing Firefox on top of the existing Firefox installation.</li>
                </p>
                <p>
                    <li>Update-MozillaFirefox is designed to update only one instance of Firefox. If more than one instances of Firefox are detected, the script will notify the user at Step 5, and furthermore, if old Firefox(es) are detected, the script will exit before downloading the installation file at Step 15.</li>
                </p>
                <p>
                    <li>Please note that the Firefox installation configuration file written at Step 14 disables the Mozilla Maintenance service so that the Mozilla Maintenance service will not be installed during the Firefox update. The values set with the Install Configuration File (<code>firefox_configuration.ini</code>) are altering the system files and seemingly are written somewhere deeper to the innards of Mozilla Firefox semi-permanently.</li>
                </p>
                <p>
                    <li>Please also notice that when run in an elevated PowerShell window and an old Firefox version is detected, Update-MozillaFirefox will automatically try to download files from the Internet without prompting the end-user beforehand or without asking any confirmations (at Step 16 and onwards) and at Step 17 closes a bunch of processes without any further notice. </li>
                </p>
                <p>
                    <li>Please note that the downloaded files are placed in a directory, which is specified with the <code>$path</code> variable (at line 42). The <code>$env:temp</code> variable points to the current temp folder. The default value of the <code>$env:temp</code> variable is <code>C:\Users\&lt;username&gt;\AppData\Local\Temp</code> (i.e. each user account has their own separate temp folder at path <code>%USERPROFILE%\AppData\Local\Temp</code>). To see the current temp path, for instance a command
                    <br />
                    <br /><code>[System.IO.Path]::GetTempPath()</code>
                    <br />
                    <br />may be used at the PowerShell prompt window <code>[PS&gt;]</code>. To change the temp folder for instance to <code>C:\Temp</code>, please, for example, follow the instructions at <a href="http://www.eightforums.com/tutorials/23500-temporary-files-folder-change-location-windows.html">Temporary Files Folder - Change Location in Windows</a>, which in essence are something along the lines:
                        <ol>
                           <li>Right click Computer icon and select Properties (or select Start → Control Panel → System. On Windows 10 this instance may also be found by right clicking Start and selecting Control Panel → System... or by pressing <code>[Win-key]</code> + X and selecting Control Panel → System). On the window with basic information about the computer...</li>
                           <li>Click on Advanced system settings on the left panel and select Advanced tab on the "System Properties" pop-up window.</li>
                           <li>Click on the button near the bottom labeled Environment Variables.</li>
                           <li>In the topmost section, which lists the User variables, both TMP and TEMP may be seen. Each different login account is assigned its own temporary locations. These values can be changed by double clicking a value or by highlighting a value and selecting Edit. The specified path will be used by Windows and many other programs for temporary files. It's advisable to set the same value (a directory path) for both TMP and TEMP.</li>
                           <li>Any running programs need to be restarted for the new values to take effect. In fact, probably Windows itself needs to be restarted for it to begin using the new values for its own temporary files.</li>
                        </ol>
                    </li>
                </p>
            </ul>
        </td>
    </tr>
</table>




### Examples

<table>
    <tr>
        <th>:book:</th>
        <td style="padding:6px">To open this code in Windows PowerShell, for instance:</td>
   </tr>
   <tr>
        <th></th>
        <td style="padding:6px">
            <ol>
                <p>
                    <li><code>./Update-MozillaFirefox</code><br />
                    Runs the script. Please notice to insert <code>./</code> or <code>.\</code> before the script name.</li>
                </p>
                <p>
                    <li><code>help ./Update-MozillaFirefox -Full</code><br />
                    Displays the help file.</li>
                </p>
                <p>
                    <li><p><code>Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine</code><br />
                    This command is altering the Windows PowerShell rights to enable script execution in the default (<code>LocalMachine</code>) scope, and defines the conditions under which Windows PowerShell loads configuration files and runs scripts in general. In Windows Vista and later versions of Windows, for running commands that change the execution policy of the <code>LocalMachine</code> scope, Windows PowerShell has to be run with elevated rights (<dfn>Run as Administrator</dfn>). The default policy of the default (<code>LocalMachine</code>) scope is "<code>Restricted</code>", and a command "<code>Set-ExecutionPolicy Restricted</code>" will "<dfn>undo</dfn>" the changes made with the original example above (had the policy not been changed before...). Execution policies for the local computer (<code>LocalMachine</code>) and for the current user (<code>CurrentUser</code>) are stored in the registry (at for instance the <code>HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ExecutionPolicy</code> key), and remain effective until they are changed again. The execution policy for a particular session (<code>Process</code>) is stored only in memory, and is discarded when the session is closed.</p>
                        <p>Parameters:
                            <ul>
                                <table>
                                    <tr>
                                        <td style="padding:6px"><code>Restricted</code></td>
                                        <td colspan="2" style="padding:6px">Does not load configuration files or run scripts, but permits individual commands. <code>Restricted</code> is the default execution policy.</td>
                                    </tr>
                                    <tr>
                                        <td style="padding:6px"><code>AllSigned</code></td>
                                        <td colspan="2" style="padding:6px">Scripts can run. Requires that all scripts and configuration files be signed by a trusted publisher, including the scripts that have been written on the local computer. Risks running signed, but malicious, scripts.</td>
                                    </tr>
                                    <tr>
                                        <td style="padding:6px"><code>RemoteSigned</code></td>
                                        <td colspan="2" style="padding:6px">Requires a digital signature from a trusted publisher on scripts and configuration files that are downloaded from the Internet (including e-mail and instant messaging programs). Does not require digital signatures on scripts that have been written on the local computer. Permits running unsigned scripts that are downloaded from the Internet, if the scripts are unblocked by using the <code>Unblock-File</code> cmdlet. Risks running unsigned scripts from sources other than the Internet and signed, but malicious, scripts.</td>
                                    </tr>
                                    <tr>
                                        <td style="padding:6px"><code>Unrestricted</code></td>
                                        <td colspan="2" style="padding:6px">Loads all configuration files and runs all scripts. Warns the user before running scripts and configuration files that are downloaded from the Internet. Not only risks, but actually permits, eventually, running any unsigned scripts from any source. Risks running malicious scripts.</td>
                                    </tr>
                                    <tr>
                                        <td style="padding:6px"><code>Bypass</code></td>
                                        <td colspan="2" style="padding:6px">Nothing is blocked and there are no warnings or prompts. Not only risks, but actually permits running any unsigned scripts from any source. Risks running malicious scripts.</td>
                                    </tr>
                                    <tr>
                                        <td style="padding:6px"><code>Undefined</code></td>
                                        <td colspan="2" style="padding:6px">Removes the currently assigned execution policy from the current scope. If the execution policy in all scopes is set to <code>Undefined</code>, the effective execution policy is <code>Restricted</code>, which is the default execution policy. This parameter will not alter or remove the ("<dfn>master</dfn>") execution policy that is set with a Group Policy setting.</td>
                                    </tr>
                                    <tr>
                                        <td style="padding:6px; border-top-width:1px; border-top-style:solid;"><span style="font-size: 95%">Notes:</span></td>
                                        <td colspan="2" style="padding:6px">
                                            <ul>
                                                <li><span style="font-size: 95%">Please note that the Group Policy setting "<code>Turn on Script Execution</code>" overrides the execution policies set in Windows PowerShell in all scopes. To find this ("<dfn>master</dfn>") setting, please, for example, open the Local Group Policy Editor (<code>gpedit.msc</code>) and navigate to Computer Configuration → Administrative Templates → Windows Components → Windows PowerShell.</span></li>
                                            </ul>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th></th>
                                        <td colspan="2" style="padding:6px">
                                            <ul>
                                                <li><span style="font-size: 95%">The Local Group Policy Editor (<code>gpedit.msc</code>) is not available in any Home or Starter edition of Windows.</span></li>
                                                <ol>
                                                    <p>
                                                        <table>
                                                            <tr>
                                                                <td style="padding:6px; font-size: 85%"><strong>Group Policy Setting</strong> "<code>Turn&nbsp;on&nbsp;Script&nbsp;Execution</code>"</td>
                                                                <td style="padding:6px; font-size: 85%"><strong>PowerShell Equivalent</strong> (concerning all scopes)</td>
                                                            </tr>
                                                            <tr>
                                                                <td style="padding:6px; font-size: 85%"><code>Not configured</code></td>
                                                                <td style="padding:6px; font-size: 85%">No effect, the default value of this setting</td>
                                                            </tr>
                                                            <tr>
                                                                <td style="padding:6px; font-size: 85%"><code>Disabled</code></td>
                                                                <td style="padding:6px; font-size: 85%"><code>Restricted</code></td>
                                                            </tr>
                                                            <tr>
                                                                <td style="padding:6px; font-size: 85%"><code>Enabled</code> – Allow only signed scripts</td>
                                                                <td style="padding:6px; font-size: 85%"><code>AllSigned</code></td>
                                                            </tr>
                                                            <tr>
                                                                <td style="padding:6px; font-size: 85%"><code>Enabled</code> – Allow local scripts and remote signed scripts</td>
                                                                <td style="padding:6px; font-size: 85%"><code>RemoteSigned</code></td>
                                                            </tr>
                                                            <tr>
                                                                <td style="padding:6px; font-size: 85%"><code>Enabled</code> – Allow all scripts</td>
                                                                <td style="padding:6px; font-size: 85%"><code>Unrestricted</code></td>
                                                            </tr>
                                                        </table>
                                                    </p>
                                                </ol>
                                            </ul>
                                        </td>
                                    </tr>
                                </table>
                            </ul>
                        </p>
                    <p>For more information, please type "<code>Get-ExecutionPolicy -List</code>", "<code>help Set-ExecutionPolicy -Full</code>", "<code>help about_Execution_Policies</code>" or visit <a href="https://technet.microsoft.com/en-us/library/hh849812.aspx">Set-ExecutionPolicy</a> or <a href="http://go.microsoft.com/fwlink/?LinkID=135170">about_Execution_Policies</a>.</p>
                    </li>
                </p>
                <p>
                    <li><code>New-Item -ItemType File -Path C:\Temp\Update-MozillaFirefox.ps1</code><br />
                    Creates an empty ps1-file to the <code>C:\Temp</code> directory. The <code>New-Item</code> cmdlet has an inherent <code>-NoClobber</code> mode built into it, so that the procedure will halt, if overwriting (replacing the contents) of an existing file is about to happen. Overwriting a file with the <code>New-Item</code> cmdlet requires using the <code>Force</code>. If the path name and/or the filename includes space characters, please enclose the whole <code>-Path</code> parameter value in quotation marks (single or double):
                        <ol>
                            <br /><code>New-Item -ItemType File -Path "C:\Folder Name\Update-MozillaFirefox.ps1"</code>
                        </ol>
                    <br />For more information, please type "<code>help New-Item -Full</code>".</li>
                </p>
            </ol>
        </td>
    </tr>
</table>




### Contributing

<table>
    <tr>
        <th><img class="emoji" title="contributing" alt="contributing" height="28" width="28" align="absmiddle" src="https://assets-cdn.github.com/images/icons/emoji/unicode/1f33f.png"></th>
        <td style="padding:6px"><strong>Bugs:</strong></td>
        <td style="padding:6px">Bugs can be reported by creating a new <a href="https://github.com/auberginehill/update-mozilla-firefox/issues">issue</a>.</td>
    </tr>
    <tr>
        <th rowspan="2"></th>
        <td style="padding:6px"><strong>Feature Requests:</strong></td>
        <td style="padding:6px">Feature request can be submitted by creating a new <a href="https://github.com/auberginehill/update-mozilla-firefox/issues">issue</a>.</td>
    </tr>
    <tr>
        <td style="padding:6px"><strong>Editing Source Files:</strong></td>
        <td style="padding:6px">New features, fixes and other potential changes can be discussed in further detail by opening a <a href="https://github.com/auberginehill/update-mozilla-firefox/pulls">pull request</a>.</td>
    </tr>
</table>




### www

<table>
    <tr>
        <th>:globe_with_meridians:</th>
        <td style="padding:6px"><a href="https://github.com/auberginehill/update-mozilla-firefox">Script Homepage</a></td>
    </tr>
    <tr>
        <th rowspan="22"></th>
        <td style="padding:6px">Tobias Weltner: <a href="http://powershell.com/cs/PowerTips_Monthly_Volume_8.pdf#IDERA-1702_PS-PowerShellMonthlyTipsVol8-jan2014">PowerTips Monthly vol 8 January 2014</a> (or one of the <a href="https://web.archive.org/web/20150110213108/http://powershell.com/cs/media/p/30542.aspx">archive.org versions</a>)</td>
    </tr>
    <tr>
        <td style="padding:6px">ps1: <a href="http://powershell.com/cs/blogs/tips/archive/2011/05/04/test-internet-connection.aspx">Test Internet connection</a> (or one of the <a href="https://web.archive.org/web/20110612212629/http://powershell.com/cs/blogs/tips/archive/2011/05/04/test-internet-connection.aspx">archive.org versions</a>)</td>
    </tr>
    <tr>
        <td style="padding:6px">Goyuix: <a href="http://stackoverflow.com/questions/17601528/read-json-object-in-powershell-2-0#17602226 ">Read Json Object in Powershell 2.0</a></td>
    </tr>
    <tr>
        <td style="padding:6px">lamaar75: <a href="http://powershell.com/cs/forums/t/9685.aspx">Creating a Menu</a> (or one of the <a href="https://web.archive.org/web/20150910111758/http://powershell.com/cs/forums/t/9685.aspx">archive.org versions</a>)</td>
    </tr>
    <tr>
        <td style="padding:6px">alejandro5042: <a href="http://stackoverflow.com/questions/29266622/how-to-run-exe-with-without-elevated-privileges-from-powershell?rq=1">How to run exe with/without elevated privileges from PowerShell</a></td>
    </tr>
    <tr>
        <td style="padding:6px">JaredPar and Matthew Pirocchi: <a href="http://stackoverflow.com/questions/5466329/whats-the-best-way-to-determine-the-location-of-the-current-powershell-script?noredirect=1&lq=1">What's the best way to determine the location of the current PowerShell script?</a></td>
    </tr>
    <tr>
        <td style="padding:6px">Jeff: <a href="http://stackoverflow.com/questions/10941756/powershell-show-elapsed-time">Powershell show elapsed time</a></td>
    </tr>
    <tr>
        <td style="padding:6px">Microsoft TechNet: <a href="https://technet.microsoft.com/en-us/library/ff730939.aspx">Adding a Simple Menu to a Windows PowerShell Script</a></td>
    </tr>
    <tr>
        <td style="padding:6px">Microsoft TechNet: <a href="https://technet.microsoft.com/en-us/library/ee692803.aspx">Working with Hash Tables</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="http://stackoverflow.com/questions/1825585/determine-installed-powershell-version?rq=1">Determine installed PowerShell version</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/convertfrom-json">ConvertFrom-Json</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/convertfrom-stringdata">ConvertFrom-StringData</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://blogs.technet.microsoft.com/heyscriptingguy/2014/04/23/powertip-convert-json-file-to-powershell-object/">PowerTip: Convert JSON File to PowerShell Object</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="http://stackoverflow.com/questions/32887583/powershell-v2-converts-dictionary-to-array-when-returned-from-a-function">PowerShell v2 Converts Dictionary to Array when returned from a function</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="http://powershelldistrict.com/powershell-json/">Working with JSON and PowerShell</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://www.credera.com/blog/technology-insights/perfect-progress-bars-for-powershell/">Perfect Progress Bars for PowerShell</a></td>
    </tr>
    <tr>
        <td style="padding:6px">MozillaZine: <a href="http://kb.mozillazine.org/Software_Update">Software Update</a></td>
    </tr>
    <tr>
        <td style="padding:6px">Mozilla Wiki: <a href="https://wiki.mozilla.org/Installer:Command_Line_Arguments">Installer:Command Line Arguments</a></td>
    </tr>
    <tr>
        <td style="padding:6px">Mozilla Wiki: <a href="https://wiki.mozilla.org/Software_Update:Checking_For_Updates">Software Update:Checking For Updates</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://ftp.mozilla.org/pub/firefox/releases/latest/README.txt">Mozilla Release Engineering</a></td>
    </tr>
    <tr>
        <td style="padding:6px">MozillaZine: <a href="http://kb.mozillazine.org/App.update.url">App.update.url</a></td>
    </tr>
    <tr>
        <td style="padding:6px">ASCII Art: <a href="http://www.figlet.org/">http://www.figlet.org/</a> and <a href="http://www.network-science.de/ascii/">ASCII Art Text Generator</a></td>
    </tr>
</table>




### Related scripts

 <table>
    <tr>
        <th><img class="emoji" title="www" alt="www" height="28" width="28" align="absmiddle" src="https://assets-cdn.github.com/images/icons/emoji/unicode/0023-20e3.png"></th>
        <td style="padding:6px"><a href="https://gist.github.com/auberginehill/aa812bfa79fa19fbd880b97bdc22e2c1">Disable-Defrag</a></td>
    </tr>
    <tr>
        <th rowspan="26"></th>
        <td style="padding:6px"><a href="https://github.com/auberginehill/emoji-table">Emoji Table</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/firefox-customization-files">Firefox Customization Files</a></td>        
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-ascii-table">Get-AsciiTable</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-battery-info">Get-BatteryInfo</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-computer-info">Get-ComputerInfo</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-culture-tables">Get-CultureTables</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-directory-size">Get-DirectorySize</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-hash-value">Get-HashValue</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-installed-programs">Get-InstalledPrograms</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-installed-windows-updates">Get-InstalledWindowsUpdates</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-powershell-aliases-table">Get-PowerShellAliasesTable</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://gist.github.com/auberginehill/9c2f26146a0c9d3d1f30ef0395b6e6f5">Get-PowerShellSpecialFolders</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-ram-info">Get-RAMInfo</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://gist.github.com/auberginehill/eb07d0c781c09ea868123bf519374ee8">Get-TimeDifference</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-time-zone-table">Get-TimeZoneTable</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-unused-drive-letters">Get-UnusedDriveLetters</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-windows-10-lock-screen-wallpapers">Get-Windows10LockScreenWallpapers</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/java-update">Java-Update</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/remove-duplicate-files">Remove-DuplicateFiles</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/remove-empty-folders">Remove-EmptyFolders</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://gist.github.com/auberginehill/13bb9f56dc0882bf5e85a8f88ccd4610">Remove-EmptyFoldersLite</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://gist.github.com/auberginehill/176774de38ebb3234b633c5fbc6f9e41">Rename-Files</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/rock-paper-scissors">Rock-Paper-Scissors</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/toss-a-coin">Toss-a-Coin</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/unzip-silently">Unzip-Silently</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/update-adobe-flash-player">Update-AdobeFlashPlayer</a></td>
    </tr>
</table>
