cls

amesdir = LEAP.ActiveArea.Directory & "AMES\"
amesfile = "AMES-run.jl"

function GetJuliaPath()
	Dim shell
	Dim PathEV
	Dim PathArray, LocalAppDataPath
	Dim i

	Set shell = CreateObject("WScript.Shell")
	waitTillComplete = False
	style = 1

	GetJuliaPath = Null

	Set re = New RegExp
	With re
		.Pattern    = "julia"
		.IgnoreCase = True
		.Global     = False
	End With

	' First check in the PATH environment variable
	PathEV = shell.ExpandEnvironmentStrings( "%PATH%" )
	PathArray = Split(PathEV,";")
	For i = 0 to UBound(PathArray)
		If re.Test(PathArray(i)) Then
			GetJuliaPath = PathArray(i) & "\julia.exe"
			Exit For
		End If
	Next

	' Then check in C:\USER\AppData\Local\Programs
	if IsNull(GetJuliaPath) Then
		LocalAppDataPath = shell.ExpandEnvironmentStrings("%localappdata%")
		Set FSO = CreateObject("Scripting.FileSystemObject")
		For Each LocalProgramsFolder In FSO.GetFolder(LocalAppDataPath & "\Programs").SubFolders
			If re.Test(LocalProgramsFolder) Then
				GetJuliaPath =  LocalProgramsFolder & "\bin\julia.exe"
			End If
		Next
	End If
	
	' Then check for registry keys created during NEMO/Julia installation
	on error resume next

	' JuliaPath recorded during NEMO installation
	If IsNull(GetJuliaPath) Then
		GetJuliaPath = shell.RegRead("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{4EEC991C-8D33-4773-84D3-7FE4162EEF82}\JuliaPath")
	End If
	
	' Keys created during Julia installation (some common versions)
	If IsNull(GetJuliaPath) Then
		GetJuliaPath = shell.RegRead("HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\Julia-1.7.2_is1\DisplayIcon")
	End If

	If IsNull(GetJuliaPath) Then
		GetJuliaPath = shell.RegRead("HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Julia-1.7.2_is1\DisplayIcon")
	End If

	If IsNull(GetJuliaPath) Then
		GetJuliaPath = shell.RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\Julia-1.7.2_is1\DisplayIcon")
	End If

	If IsNull(GetJuliaPath) Then
		GetJuliaPath = shell.RegRead("HKCU\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Julia-1.7.2_is1\DisplayIcon")
	End If

	If IsNull(GetJuliaPath) Then
		GetJuliaPath = shell.RegRead("HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\{054B4BC6-BD30-45C8-A623-8F5BA6EBD55D}_is1\DisplayIcon")
	End If

	If IsNull(GetJuliaPath) Then
		GetJuliaPath = shell.RegRead("HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{054B4BC6-BD30-45C8-A623-8F5BA6EBD55D}_is1\DisplayIcon")
	End If

	If IsNull(GetJuliaPath) Then
		GetJuliaPath = shell.RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\{054B4BC6-BD30-45C8-A623-8F5BA6EBD55D}_is1\DisplayIcon")
	End If

	If IsNull(GetJuliaPath) Then
		GetJuliaPath = shell.RegRead("HKCU\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{054B4BC6-BD30-45C8-A623-8F5BA6EBD55D}_is1\DisplayIcon")
	End If

	on error goto 0

End Function

Dim shell
Dim juliapath

Set shell = CreateObject("WScript.Shell")
waitTillComplete = False
style = 1

' Find Julia
juliapath = GetJuliaPath()

' If Julia found, then execute
If IsNull(juliapath) Then
	' Wscript.echo doesn't work when using LEAP 64-bit
	msgbox("Could not locate the Julia executable. Try adding the path to the executable to the Windows environment variable named 'Path'.")
Else
	' Path to precompiled image
	sopath = amesdir & "AMES-sysimage.so"
	Set FSO = CreateObject("Scripting.FileSystemObject")
	If FSO.FileExists(sopath) Then
		path = Chr(34) & juliapath & Chr(34) & " --sysimage=" & Chr(34) & sopath & Chr(34) & " " & Chr(34) & amesdir & amesfile & Chr(34)
	Else
		path = Chr(34) & juliapath & Chr(34) & " " & Chr(34) & amesdir & amesfile & Chr(34)
	End If

	errorcode = shell.Run(path, style, waitTillComplete)
End If

'' SIG '' Begin signature block
'' SIG '' MIIpEQYJKoZIhvcNAQcCoIIpAjCCKP4CAQExDzANBglg
'' SIG '' hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
'' SIG '' BgEEAYI3AgEeMCQCAQEEEE7wKRaZJ7VNj+Ws4Q8X66sC
'' SIG '' AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' O/oHH7VLXXg/PQKq2FYXx+Y5yiL2fCkowFkXXzc0A4ag
'' SIG '' ghIGMIIFbzCCBFegAwIBAgIQSPyTtGBVlI02p8mKidaU
'' SIG '' FjANBgkqhkiG9w0BAQwFADB7MQswCQYDVQQGEwJHQjEb
'' SIG '' MBkGA1UECAwSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYD
'' SIG '' VQQHDAdTYWxmb3JkMRowGAYDVQQKDBFDb21vZG8gQ0Eg
'' SIG '' TGltaXRlZDEhMB8GA1UEAwwYQUFBIENlcnRpZmljYXRl
'' SIG '' IFNlcnZpY2VzMB4XDTIxMDUyNTAwMDAwMFoXDTI4MTIz
'' SIG '' MTIzNTk1OVowVjELMAkGA1UEBhMCR0IxGDAWBgNVBAoT
'' SIG '' D1NlY3RpZ28gTGltaXRlZDEtMCsGA1UEAxMkU2VjdGln
'' SIG '' byBQdWJsaWMgQ29kZSBTaWduaW5nIFJvb3QgUjQ2MIIC
'' SIG '' IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAjeeU
'' SIG '' EiIEJHQu/xYjApKKtq42haxH1CORKz7cfeIxoFFvrISR
'' SIG '' 41KKteKW3tCHYySJiv/vEpM7fbu2ir29BX8nm2tl06UM
'' SIG '' abG8STma8W1uquSggyfamg0rUOlLW7O4ZDakfko9qXGr
'' SIG '' YbNzszwLDO/bM1flvjQ345cbXf0fEj2CA3bm+z9m0pQx
'' SIG '' afptszSswXp43JJQ8mTHqi0Eq8Nq6uAvp6fcbtfo/9oh
'' SIG '' q0C/ue4NnsbZnpnvxt4fqQx2sycgoda6/YDnAdLv64Ip
'' SIG '' lXCN/7sVz/7RDzaiLk8ykHRGa0c1E3cFM09jLrgt4b9l
'' SIG '' pwRrGNhx+swI8m2JmRCxrds+LOSqGLDGBwF1Z95t6WNj
'' SIG '' HjZ/aYm+qkU+blpfj6Fby50whjDoA7NAxg0POM1nqFOI
'' SIG '' +rgwZfpvx+cdsYN0aT6sxGg7seZnM5q2COCABUhA7vaC
'' SIG '' ZEao9XOwBpXybGWfv1VbHJxXGsd4RnxwqpQbghesh+m2
'' SIG '' yQ6BHEDWFhcp/FycGCvqRfXvvdVnTyheBe6QTHrnxvTQ
'' SIG '' /PrNPjJGEyA2igTqt6oHRpwNkzoJZplYXCmjuQymMDg8
'' SIG '' 0EY2NXycuu7D1fkKdvp+BRtAypI16dV60bV/AK6pkKrF
'' SIG '' fwGcELEW/MxuGNxvYv6mUKe4e7idFT/+IAx1yCJaE5UZ
'' SIG '' kADpGtXChvHjjuxf9OUCAwEAAaOCARIwggEOMB8GA1Ud
'' SIG '' IwQYMBaAFKARCiM+lvEH7OKvKe+CpX/QMKS0MB0GA1Ud
'' SIG '' DgQWBBQy65Ka/zWWSC8oQEJwIDaRXBeF5jAOBgNVHQ8B
'' SIG '' Af8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zATBgNVHSUE
'' SIG '' DDAKBggrBgEFBQcDAzAbBgNVHSAEFDASMAYGBFUdIAAw
'' SIG '' CAYGZ4EMAQQBMEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6
'' SIG '' Ly9jcmwuY29tb2RvY2EuY29tL0FBQUNlcnRpZmljYXRl
'' SIG '' U2VydmljZXMuY3JsMDQGCCsGAQUFBwEBBCgwJjAkBggr
'' SIG '' BgEFBQcwAYYYaHR0cDovL29jc3AuY29tb2RvY2EuY29t
'' SIG '' MA0GCSqGSIb3DQEBDAUAA4IBAQASv6Hvi3SamES4aUa1
'' SIG '' qyQKDKSKZ7g6gb9Fin1SB6iNH04hhTmja14tIIa/ELiu
'' SIG '' eTtTzbT72ES+BtlcY2fUQBaHRIZyKtYyFfUSg8L54V0R
'' SIG '' QGf2QidyxSPiAjgaTCDi2wH3zUZPJqJ8ZsBRNraJAlTH
'' SIG '' /Fj7bADu/pimLpWhDFMpH2/YGaZPnvesCepdgsaLr4Cn
'' SIG '' vYFIUoQx2jLsFeSmTD1sOXPUC4U5IOCFGmjhp0g4qdE2
'' SIG '' JXfBjRkWxYhMZn0vY86Y6GnfrDyoXZ3JHFuu2PMvdM+4
'' SIG '' fvbXg50RlmKarkUT2n/cR/vfw1Kf5gZV6Z2M8jpiUbzs
'' SIG '' JA8p1FiAhORFe1rYMIIGGjCCBAKgAwIBAgIQYh1tDFIB
'' SIG '' njuQeRUgiSEcCjANBgkqhkiG9w0BAQwFADBWMQswCQYD
'' SIG '' VQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVk
'' SIG '' MS0wKwYDVQQDEyRTZWN0aWdvIFB1YmxpYyBDb2RlIFNp
'' SIG '' Z25pbmcgUm9vdCBSNDYwHhcNMjEwMzIyMDAwMDAwWhcN
'' SIG '' MzYwMzIxMjM1OTU5WjBUMQswCQYDVQQGEwJHQjEYMBYG
'' SIG '' A1UEChMPU2VjdGlnbyBMaW1pdGVkMSswKQYDVQQDEyJT
'' SIG '' ZWN0aWdvIFB1YmxpYyBDb2RlIFNpZ25pbmcgQ0EgUjM2
'' SIG '' MIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEA
'' SIG '' myudU/o1P45gBkNqwM/1f/bIU1MYyM7TbH78WAeVF3ll
'' SIG '' MwsRHgBGRmxDeEDIArCS2VCoVk4Y/8j6stIkmYV5Gej4
'' SIG '' NgNjVQ4BYoDjGMwdjioXan1hlaGFt4Wk9vT0k2oWJMJj
'' SIG '' L9G//N523hAm4jF4UjrW2pvv9+hdPX8tbbAfI3v0VdJi
'' SIG '' JPFy/7XwiunD7mBxNtecM6ytIdUlh08T2z7mJEXZD9OW
'' SIG '' cJkZk5wDuf2q52PN43jc4T9OkoXZ0arWZVeffvMr/iiI
'' SIG '' ROSCzKoDmWABDRzV/UiQ5vqsaeFaqQdzFf4ed8peNWh1
'' SIG '' OaZXnYvZQgWx/SXiJDRSAolRzZEZquE6cbcH747FHncs
'' SIG '' /Kzcn0Ccv2jrOW+LPmnOyB+tAfiWu01TPhCr9VrkxsHC
'' SIG '' 5qFNxaThTG5j4/Kc+ODD2dX/fmBECELcvzUHf9shoFvr
'' SIG '' n35XGf2RPaNTO2uSZ6n9otv7jElspkfK9qEATHZcodp+
'' SIG '' R4q2OIypxR//YEb3fkDn3UayWW9bAgMBAAGjggFkMIIB
'' SIG '' YDAfBgNVHSMEGDAWgBQy65Ka/zWWSC8oQEJwIDaRXBeF
'' SIG '' 5jAdBgNVHQ4EFgQUDyrLIIcouOxvSK4rVKYpqhekzQww
'' SIG '' DgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQIMAYBAf8C
'' SIG '' AQAwEwYDVR0lBAwwCgYIKwYBBQUHAwMwGwYDVR0gBBQw
'' SIG '' EjAGBgRVHSAAMAgGBmeBDAEEATBLBgNVHR8ERDBCMECg
'' SIG '' PqA8hjpodHRwOi8vY3JsLnNlY3RpZ28uY29tL1NlY3Rp
'' SIG '' Z29QdWJsaWNDb2RlU2lnbmluZ1Jvb3RSNDYuY3JsMHsG
'' SIG '' CCsGAQUFBwEBBG8wbTBGBggrBgEFBQcwAoY6aHR0cDov
'' SIG '' L2NydC5zZWN0aWdvLmNvbS9TZWN0aWdvUHVibGljQ29k
'' SIG '' ZVNpZ25pbmdSb290UjQ2LnA3YzAjBggrBgEFBQcwAYYX
'' SIG '' aHR0cDovL29jc3Auc2VjdGlnby5jb20wDQYJKoZIhvcN
'' SIG '' AQEMBQADggIBAAb/guF3YzZue6EVIJsT/wT+mHVEYcNW
'' SIG '' lXHRkT+FoetAQLHI1uBy/YXKZDk8+Y1LoNqHrp22AKMG
'' SIG '' xQtgCivnDHFyAQ9GXTmlk7MjcgQbDCx6mn7yIawsppWk
'' SIG '' vfPkKaAQsiqaT9DnMWBHVNIabGqgQSGTrQWo43MOfsPy
'' SIG '' nhbz2Hyxf5XWKZpRvr3dMapandPfYgoZ8iDL2OR3sYzt
'' SIG '' gJrbG6VZ9DoTXFm1g0Rf97Aaen1l4c+w3DC+IkwFkvjF
'' SIG '' V3jS49ZSc4lShKK6BrPTJYs4NG1DGzmpToTnwoqZ8fAm
'' SIG '' i2XlZnuchC4NPSZaPATHvNIzt+z1PHo35D/f7j2pO1S8
'' SIG '' BCysQDHCbM5Mnomnq5aYcKCsdbh0czchOm8bkinLrYrK
'' SIG '' pii+Tk7pwL7TjRKLXkomm5D1Umds++pip8wH2cQpf93a
'' SIG '' t3VDcOK4N7EwoIJB0kak6pSzEu4I64U6gZs7tS/dGNSl
'' SIG '' jf2OSSnRr7KWzq03zl8l75jy+hOds9TWSenLbjBQUGR9
'' SIG '' 6cFr6lEUfAIEHVC1L68Y1GGxx4/eRI82ut83axHMViw1
'' SIG '' +sVpbPxg51Tbnio1lB93079WPFnYaOvfGAA0e0zcfF/M
'' SIG '' 9gXr+korwQTh2Prqooq2bYNMvUoUKD85gnJ+t0smrWrb
'' SIG '' 8dee2CvYZXD5laGtaAxOfy/VKNmwuWuAh9kcMIIGcTCC
'' SIG '' BNmgAwIBAgIQRBgitWK089NdKhHPRt0jQTANBgkqhkiG
'' SIG '' 9w0BAQwFADBUMQswCQYDVQQGEwJHQjEYMBYGA1UEChMP
'' SIG '' U2VjdGlnbyBMaW1pdGVkMSswKQYDVQQDEyJTZWN0aWdv
'' SIG '' IFB1YmxpYyBDb2RlIFNpZ25pbmcgQ0EgUjM2MB4XDTIz
'' SIG '' MDIwNjAwMDAwMFoXDTI2MDIwNTIzNTk1OVowgYcxCzAJ
'' SIG '' BgNVBAYTAlVTMRYwFAYDVQQIDA1NYXNzYWNodXNldHRz
'' SIG '' MS8wLQYDVQQKDCZTdG9ja2hvbG0gRW52aXJvbm1lbnQg
'' SIG '' SW5zdGl0dXRlIFVTIElOQzEvMC0GA1UEAwwmU3RvY2to
'' SIG '' b2xtIEVudmlyb25tZW50IEluc3RpdHV0ZSBVUyBJTkMw
'' SIG '' ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDA
'' SIG '' z+ZFy1RGH88wnT1+PngQsSxCH940SN2ib56yLGOxd3i2
'' SIG '' szJXOBBetjykFUat/yFYJVkYtPi6ZFQJ0prM/UJKbrN+
'' SIG '' Ku+LMyb73Ce3B36ehy0sAAw4dxemIXrPdui8IX9HVUB8
'' SIG '' 1oMXp8d38ohUmgK/t3ZU7KdUSwIJJuWG4cXhI5P7UwKK
'' SIG '' iRr6sIEtFpLDk2YAXaSqs5KUpZsLgSJfNSTzlb4lqOK6
'' SIG '' olvLio9xIXCuruArOpS+hoWzl70aZ4soB2qNHcmWOMWd
'' SIG '' k8K+4L5X6k2Cwi3KeeScev9ZOuHqf9gJcdm6HqABppWs
'' SIG '' e1g7x3GPq3RhbHjg6lYydDP+Gm4bHwMUI/BWZkRSRoSF
'' SIG '' d/Hv8jijo6x5KlagjojunZIteP0dsmiGkKYB3VRgrhMC
'' SIG '' fn7+7ImFthhXgAkQDO2HYrqqAhQcVdwoTwNj0sYwB78g
'' SIG '' kRhPa3q7e8NBYZCjtPFIkf8SM5SFOrrTbzAvVWXoGPTZ
'' SIG '' 38wSAGfw+v03Tqp0+H2lKzFAC5NVQC61ejHCatXGoXze
'' SIG '' 2U+CUUHNXPLvaG6aOORXwGW3OgZ67nfN5+Vv24ve9eN2
'' SIG '' 8b3OJgCUQBA2umzS7Z8GhQOmqn46tB3llw8LW/lFNvpt
'' SIG '' xhXNaWfe9cpAhJ79CDyVhBpSMpw9WKvXIziX6cz1/2pe
'' SIG '' qRuuKBQSb+beK+Bii5/1AQIDAQABo4IBiTCCAYUwHwYD
'' SIG '' VR0jBBgwFoAUDyrLIIcouOxvSK4rVKYpqhekzQwwHQYD
'' SIG '' VR0OBBYEFFeG5oHU1pRgrlOCQptwPyNDqwXdMA4GA1Ud
'' SIG '' DwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQM
'' SIG '' MAoGCCsGAQUFBwMDMEoGA1UdIARDMEEwNQYMKwYBBAGy
'' SIG '' MQECAQMCMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8vc2Vj
'' SIG '' dGlnby5jb20vQ1BTMAgGBmeBDAEEATBJBgNVHR8EQjBA
'' SIG '' MD6gPKA6hjhodHRwOi8vY3JsLnNlY3RpZ28uY29tL1Nl
'' SIG '' Y3RpZ29QdWJsaWNDb2RlU2lnbmluZ0NBUjM2LmNybDB5
'' SIG '' BggrBgEFBQcBAQRtMGswRAYIKwYBBQUHMAKGOGh0dHA6
'' SIG '' Ly9jcnQuc2VjdGlnby5jb20vU2VjdGlnb1B1YmxpY0Nv
'' SIG '' ZGVTaWduaW5nQ0FSMzYuY3J0MCMGCCsGAQUFBzABhhdo
'' SIG '' dHRwOi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0B
'' SIG '' AQwFAAOCAYEADW0tparCSQVp0S7e3YQiVFWbrgbrhOsd
'' SIG '' fsASuZyWx0c/reA88+FmoCIS61ILM5W8OYUNoVUmV6dg
'' SIG '' LIEiAVY7Z8cWAcreYi3oDOTvg00yXUENIB80Qc7ajW+x
'' SIG '' BR2NYrUYlp+1hrS4vP72oDjGDJHwe1Me68hSXm4Qtn8m
'' SIG '' uCwqt03FqJ2EUG2Zqohg2EYbgK36jGcm2fJx8KT7YZmO
'' SIG '' XFgi27PSp+Y5cERWk1r8c6a1P6wb9iRY/VqxAmZgawZE
'' SIG '' OP+RBDsJKzj2zEwbdHuDp5oCvySBTwUI1nFZSBq8mK1B
'' SIG '' 7UgSWTo/XuM9HJnk+lepKPOphM79N6d6z9Ssrdth95fK
'' SIG '' ZxfbGAgoJe5bAU+sXULCbOKWL7jOGI9CZ2d8Tu1igcRa
'' SIG '' VAjV+JyPbnCxKQJGXY6FzTrBpwcy2exqnIUwgbmAiWu7
'' SIG '' sCG+zCrdKccC9kkdLR68AczE4wSc2dtqzrXBzmjwlpm9
'' SIG '' I4EHNuVh/m3CHtaEA8Rb7wt5oTYcjM534JfotCsVMYIW
'' SIG '' YzCCFl8CAQEwaDBUMQswCQYDVQQGEwJHQjEYMBYGA1UE
'' SIG '' ChMPU2VjdGlnbyBMaW1pdGVkMSswKQYDVQQDEyJTZWN0
'' SIG '' aWdvIFB1YmxpYyBDb2RlIFNpZ25pbmcgQ0EgUjM2AhBE
'' SIG '' GCK1YrTz010qEc9G3SNBMA0GCWCGSAFlAwQCAQUAoHww
'' SIG '' EAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwG
'' SIG '' CisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisG
'' SIG '' AQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIFDB0yx7dtPq
'' SIG '' WO7roPJKNaTjtccEwrgwvLGEYIrP2IpqMA0GCSqGSIb3
'' SIG '' DQEBAQUABIICAGTu5XLZg1APUeH+gJZmMVl5QObid9Sj
'' SIG '' r/f6Zl3yLB3ILNhVVkNY2kEsN8Xg50BrlGlD1Eg2Jx3c
'' SIG '' BFpnljiweIg38T+whKd0FBmMfISLVhsdIEFhZsh74AwE
'' SIG '' 73x/+PqRoGM7010Gs3CYEFcpYX2ahU5vuXKilo069ijE
'' SIG '' 8HSQk4xP0syyyY4KIYU6kfYe9qqoX7/iZN2HIlmW0Hh5
'' SIG '' 2m1U4qoUSBWdbiodE69UemmTZuwRmho00GKZmvd94PaF
'' SIG '' Db0zRWT99rgOfryBy3cOxDTjaU1avHYr84PTSq9z8+ZO
'' SIG '' t4rEQ05iVnuXi0upkcPzJpmK6XE3TEKkekL7aFiv/Ism
'' SIG '' E8nrvQg4dSHuLGN6JLcqT1DX+cb35r1xdIqJjPH9wdov
'' SIG '' QpxgP0KfjUwEddEACpkFKbsMFK94vdrOyiOMUfk6Fw1G
'' SIG '' yItGHFRqJmboZHnXNO00XUZW1d9Si/FhYjCKfkQIG10D
'' SIG '' AqcVakZUSI60iDc7JlH29q0th/HUW2lHvlIUNVZDtrbn
'' SIG '' G2r06Waf04NDmshgp2QV097PJfCDzkQ4HVMJdS+sifD0
'' SIG '' qjbhErD1QWgMekuitp+R5erbTEF+Po+GUwtUGgzir8ld
'' SIG '' xzJLZlCGmKYTdneeWv2ENNynyYcPgd24wZtq2kaqA7gV
'' SIG '' aRfTaYcWmocod1NuVfKnNgBm1venIWpWnFb9oYITTjCC
'' SIG '' E0oGCisGAQQBgjcDAwExghM6MIITNgYJKoZIhvcNAQcC
'' SIG '' oIITJzCCEyMCAQMxDzANBglghkgBZQMEAgIFADCB7wYL
'' SIG '' KoZIhvcNAQkQAQSggd8EgdwwgdkCAQEGCisGAQQBsjEC
'' SIG '' AQEwMTANBglghkgBZQMEAgEFAAQgFyLmRp02U1UglFm3
'' SIG '' LNhCY9Zg107LCFMokkTK0LomAxgCFD4L+12Y/te8WmAH
'' SIG '' tyKPTbhU7+kPGA8yMDIzMDkwNTEzNDQwOVqgbqRsMGox
'' SIG '' CzAJBgNVBAYTAkdCMRMwEQYDVQQIEwpNYW5jaGVzdGVy
'' SIG '' MRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLDAqBgNV
'' SIG '' BAMMI1NlY3RpZ28gUlNBIFRpbWUgU3RhbXBpbmcgU2ln
'' SIG '' bmVyICM0oIIN6TCCBvUwggTdoAMCAQICEDlMJeF8oG0n
'' SIG '' qGXiO9kdItQwDQYJKoZIhvcNAQEMBQAwfTELMAkGA1UE
'' SIG '' BhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3Rl
'' SIG '' cjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UEChMPU2Vj
'' SIG '' dGlnbyBMaW1pdGVkMSUwIwYDVQQDExxTZWN0aWdvIFJT
'' SIG '' QSBUaW1lIFN0YW1waW5nIENBMB4XDTIzMDUwMzAwMDAw
'' SIG '' MFoXDTM0MDgwMjIzNTk1OVowajELMAkGA1UEBhMCR0Ix
'' SIG '' EzARBgNVBAgTCk1hbmNoZXN0ZXIxGDAWBgNVBAoTD1Nl
'' SIG '' Y3RpZ28gTGltaXRlZDEsMCoGA1UEAwwjU2VjdGlnbyBS
'' SIG '' U0EgVGltZSBTdGFtcGluZyBTaWduZXIgIzQwggIiMA0G
'' SIG '' CSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCkkyhSS88n
'' SIG '' h3akKRyZOMDnDtTRHOxoywFk5IrNd7BxZYK8n/yLu7uV
'' SIG '' mPslEY5aiAlmERRYsroiW+b2MvFdLcB6og7g4FZk7aHl
'' SIG '' gSByIGRBbMfDCPrzfV3vIZrCftcsw7oRmB780yAIQrNf
'' SIG '' v3+IWDKrMLPYjHqWShkTXKz856vpHBYusLA4lUrPhVCr
'' SIG '' ZwMlobs46Q9vqVqakSgTNbkf8z3hJMhrsZnoDe+7TeU9
'' SIG '' jFQDkdD8Lc9VMzh6CRwH0SLgY4anvv3Sg3MSFJuaTAlG
'' SIG '' vTS84UtQe3LgW/0Zux88ahl7brstRCq+PEzMrIoEk8ZX
'' SIG '' hqBzNiuBl/obm36Ih9hSeYn+bnc317tQn/oYJU8T8l58
'' SIG '' qbEgWimro0KHd+D0TAJI3VilU6ajoO0ZlmUVKcXtMzAl
'' SIG '' 5paDgZr2YGaQWAeAzUJ1rPu0kdDF3QFAaraoEO72jXq3
'' SIG '' nnWv06VLGKEMn1ewXiVHkXTNdRLRnG/kXg2b7HUm7v7T
'' SIG '' 9ZIvUoXo2kRRKqLMAMqHZkOjGwDvorWWnWKtJwvyG0rJ
'' SIG '' w5RCN4gghKiHrsO6I3J7+FTv+GsnsIX1p0OF2Cs5dNta
'' SIG '' dwLRpPr1zZw9zB+uUdB7bNgdLRFCU3F0wuU1qi1SEtkl
'' SIG '' z/DT0JFDEtcyfZhs43dByP8fJFTvbq3GPlV78VyHOmTx
'' SIG '' YEsFT++5L+wJEwIDAQABo4IBgjCCAX4wHwYDVR0jBBgw
'' SIG '' FoAUGqH4YRkgD8NBd0UojtE1XwYSBFUwHQYDVR0OBBYE
'' SIG '' FAMPMciRKpO9Y/PRXU2kNA/SlQEYMA4GA1UdDwEB/wQE
'' SIG '' AwIGwDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoG
'' SIG '' CCsGAQUFBwMIMEoGA1UdIARDMEEwNQYMKwYBBAGyMQEC
'' SIG '' AQMIMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8vc2VjdGln
'' SIG '' by5jb20vQ1BTMAgGBmeBDAEEAjBEBgNVHR8EPTA7MDmg
'' SIG '' N6A1hjNodHRwOi8vY3JsLnNlY3RpZ28uY29tL1NlY3Rp
'' SIG '' Z29SU0FUaW1lU3RhbXBpbmdDQS5jcmwwdAYIKwYBBQUH
'' SIG '' AQEEaDBmMD8GCCsGAQUFBzAChjNodHRwOi8vY3J0LnNl
'' SIG '' Y3RpZ28uY29tL1NlY3RpZ29SU0FUaW1lU3RhbXBpbmdD
'' SIG '' QS5jcnQwIwYIKwYBBQUHMAGGF2h0dHA6Ly9vY3NwLnNl
'' SIG '' Y3RpZ28uY29tMA0GCSqGSIb3DQEBDAUAA4ICAQBMm2VY
'' SIG '' +uB5z+8VwzJt3jOR63dY4uu9y0o8dd5+lG3DIscEld9l
'' SIG '' aWETDPYMnvWJIF7Bh8cDJMrHpfAm3/j4MWUN4OttUVem
'' SIG '' jIRSCEYcKsLe8tqKRfO+9/YuxH7t+O1ov3pWSOlh5Zo5
'' SIG '' d7y+upFkiHX/XYUWNCfSKcv/7S3a/76TDOxtog3Mw/Fu
'' SIG '' vSGRGiMAUq2X1GJ4KoR5qNc9rCGPcMMkeTqX8Q2jo1tT
'' SIG '' 2KsAulj7NYBPXyhxbBlewoNykK7gxtjymfvqtJJlfAd8
'' SIG '' NUQdrVgYa2L73mzECqls0yFGcNwvjXVMI8JB0HqWO8NL
'' SIG '' 3c2SJnR2XDegmiSeTl9O048P5RNPWURlS0Nkz0j4Z2e5
'' SIG '' Tb/MDbE6MNChPUitemXk7N/gAfCzKko5rMGk+al9NdAy
'' SIG '' QKCxGSoYIbLIfQVxGksnNqrgmByDdefHfkuEQ81D+5CX
'' SIG '' dioSrEDBcFuZCkD6gG2UYXvIbrnIZ2ckXFCNASDeB/cB
'' SIG '' 1PguEc2dg+X4yiUcRD0n5bCGRyoLG4R2fXtoT4239xO0
'' SIG '' 7aAt7nMP2RC6nZksfNd1H48QxJTmfiTllUqIjCfWhWYd
'' SIG '' +a5kdpHoSP7IVQrtKcMf3jimwBT7Mj34qYNiNsjDvgCH
'' SIG '' HKv6SkIciQPc9Vx8cNldeE7un14g5glqfCsIo0j1FfwE
'' SIG '' T9/NIRx65fWOGtS5QDCCBuwwggTUoAMCAQICEDAPb6zd
'' SIG '' Zph0fKlGNqd4LbkwDQYJKoZIhvcNAQEMBQAwgYgxCzAJ
'' SIG '' BgNVBAYTAlVTMRMwEQYDVQQIEwpOZXcgSmVyc2V5MRQw
'' SIG '' EgYDVQQHEwtKZXJzZXkgQ2l0eTEeMBwGA1UEChMVVGhl
'' SIG '' IFVTRVJUUlVTVCBOZXR3b3JrMS4wLAYDVQQDEyVVU0VS
'' SIG '' VHJ1c3QgUlNBIENlcnRpZmljYXRpb24gQXV0aG9yaXR5
'' SIG '' MB4XDTE5MDUwMjAwMDAwMFoXDTM4MDExODIzNTk1OVow
'' SIG '' fTELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIg
'' SIG '' TWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYG
'' SIG '' A1UEChMPU2VjdGlnbyBMaW1pdGVkMSUwIwYDVQQDExxT
'' SIG '' ZWN0aWdvIFJTQSBUaW1lIFN0YW1waW5nIENBMIICIjAN
'' SIG '' BgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAyBsBr9ks
'' SIG '' foiZfQGYPyCQvZyAIVSTuc+gPlPvs1rAdtYaBKXOR4O1
'' SIG '' 68TMSTTL80VlufmnZBYmCfvVMlJ5LsljwhObtoY/AQWS
'' SIG '' Zm8hq9VxEHmH9EYqzcRaydvXXUlNclYP3MnjU5g6Kh78
'' SIG '' zlhJ07/zObu5pCNCrNAVw3+eolzXOPEWsnDTo8Tfs8Vy
'' SIG '' rC4Kd/wNlFK3/B+VcyQ9ASi8Dw1Ps5EBjm6dJ3VV0Rc7
'' SIG '' NCF7lwGUr3+Az9ERCleEyX9W4L1GnIK+lJ2/tCCwYH64
'' SIG '' TfUNP9vQ6oWMilZx0S2UTMiMPNMUopy9Jv/TUyDHYGmb
'' SIG '' WApU9AXn/TGs+ciFF8e4KRmkKS9G493bkV+fPzY+DjBn
'' SIG '' K0a3Na+WvtpMYMyou58NFNQYxDCYdIIhz2JWtSFzEh79
'' SIG '' qsoIWId3pBXrGVX/0DlULSbuRRo6b83XhPDX8CjFT2SD
'' SIG '' AtT74t7xvAIo9G3aJ4oG0paH3uhrDvBbfel2aZMgHEqX
'' SIG '' LHcZK5OVmJyXnuuOwXhWxkQl3wYSmgYtnwNe/YOiU2fK
'' SIG '' sfqNoWTJiJJZy6hGwMnypv99V9sSdvqKQSTUG/xypRSi
'' SIG '' 1K1DHKRJi0E5FAMeKfobpSKupcNNgtCN2mu32/cYQFdz
'' SIG '' 8HGj+0p9RTbB942C+rnJDVOAffq2OVgy728YUInXT50z
'' SIG '' vRq1naHelUF6p4MCAwEAAaOCAVowggFWMB8GA1UdIwQY
'' SIG '' MBaAFFN5v1qqK0rPVIDh2JvAnfKyA2bLMB0GA1UdDgQW
'' SIG '' BBQaofhhGSAPw0F3RSiO0TVfBhIEVTAOBgNVHQ8BAf8E
'' SIG '' BAMCAYYwEgYDVR0TAQH/BAgwBgEB/wIBADATBgNVHSUE
'' SIG '' DDAKBggrBgEFBQcDCDARBgNVHSAECjAIMAYGBFUdIAAw
'' SIG '' UAYDVR0fBEkwRzBFoEOgQYY/aHR0cDovL2NybC51c2Vy
'' SIG '' dHJ1c3QuY29tL1VTRVJUcnVzdFJTQUNlcnRpZmljYXRp
'' SIG '' b25BdXRob3JpdHkuY3JsMHYGCCsGAQUFBwEBBGowaDA/
'' SIG '' BggrBgEFBQcwAoYzaHR0cDovL2NydC51c2VydHJ1c3Qu
'' SIG '' Y29tL1VTRVJUcnVzdFJTQUFkZFRydXN0Q0EuY3J0MCUG
'' SIG '' CCsGAQUFBzABhhlodHRwOi8vb2NzcC51c2VydHJ1c3Qu
'' SIG '' Y29tMA0GCSqGSIb3DQEBDAUAA4ICAQBtVIGlM10W4bVT
'' SIG '' gZF13wN6MgstJYQRsrDbKn0qBfW8Oyf0WqC5SVmQKWxh
'' SIG '' y7VQ2+J9+Z8A70DDrdPi5Fb5WEHP8ULlEH3/sHQfj8Zc
'' SIG '' CfkzXuqgHCZYXPO0EQ/V1cPivNVYeL9IduFEZ22PsEMQ
'' SIG '' D43k+ThivxMBxYWjTMXMslMwlaTW9JZWCLjNXH8Blr5y
'' SIG '' Umo7Qjd8Fng5k5OUm7Hcsm1BbWfNyW+QPX9FcsEbI9bC
'' SIG '' VYRm5LPFZgb289ZLXq2jK0KKIZL+qG9aJXBigXNjXqC7
'' SIG '' 2NzXStM9r4MGOBIdJIct5PwC1j53BLwENrXnd8ucLo0j
'' SIG '' GLmjwkcd8F3WoXNXBWiap8k3ZR2+6rzYQoNDBaWLpgn/
'' SIG '' 0aGUpk6qPQn1BWy30mRa2Coiwkud8TleTN5IPZs0lpoJ
'' SIG '' X47997FSkc4/ifYcobWpdR9xv1tDXWU9UIFuq/DQ0/yy
'' SIG '' sx+2mZYm9Dx5i1xkzM3uJ5rloMAMcofBbk1a0x7q8ETm
'' SIG '' Mm8c6xdOlMN4ZSA7D0GqH+mhQZ3+sbigZSo04N6o+Tzm
'' SIG '' wTC7wKBjLPxcFgCo0MR/6hGdHgbGpm0yXbQ4CStJB6r9
'' SIG '' 7DDa8acvz7f9+tCjhNknnvsBZne5VhDhIG7GrrH5trrI
'' SIG '' NV0zdo7xfCAMKneutaIChrop7rRaALGMq+P5CslUXdS5
'' SIG '' anSevUiumDGCBCwwggQoAgEBMIGRMH0xCzAJBgNVBAYT
'' SIG '' AkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIx
'' SIG '' EDAOBgNVBAcTB1NhbGZvcmQxGDAWBgNVBAoTD1NlY3Rp
'' SIG '' Z28gTGltaXRlZDElMCMGA1UEAxMcU2VjdGlnbyBSU0Eg
'' SIG '' VGltZSBTdGFtcGluZyBDQQIQOUwl4XygbSeoZeI72R0i
'' SIG '' 1DANBglghkgBZQMEAgIFAKCCAWswGgYJKoZIhvcNAQkD
'' SIG '' MQ0GCyqGSIb3DQEJEAEEMBwGCSqGSIb3DQEJBTEPFw0y
'' SIG '' MzA5MDUxMzQ0MDlaMD8GCSqGSIb3DQEJBDEyBDAdGrkN
'' SIG '' m0c7Dx8uYkMWok91+VNYJxaKqSGDpEvMxzTb22LBfajI
'' SIG '' bXphe6T8hvPrbUwwge0GCyqGSIb3DQEJEAIMMYHdMIHa
'' SIG '' MIHXMBYEFK5ir3UKDL1H1kYfdWjivIznyk+UMIG8BBQC
'' SIG '' 1luV4oNwwVcAlfqI+SPdk3+tjzCBozCBjqSBizCBiDEL
'' SIG '' MAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBKZXJzZXkx
'' SIG '' FDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVU
'' SIG '' aGUgVVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVT
'' SIG '' RVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBBdXRob3Jp
'' SIG '' dHkCEDAPb6zdZph0fKlGNqd4LbkwDQYJKoZIhvcNAQEB
'' SIG '' BQAEggIAV2EPVJG1FIL7gjz0T2r7zbNDwvtE5RKIgpDV
'' SIG '' tQBO/48nMJ+g2DQ07pZYPexQ2kHrjBwogTlX8usjcm+0
'' SIG '' DtG7g368oGFKCp+UZ1o4chITkPOIIOPeynhb/Xz8TYN3
'' SIG '' 81sIQXpvuV4vjUg6co737J+tmyTBHnL+eoy7ofbh9Xpi
'' SIG '' GCGwYNfgxDFDjq2wqsnuRwJj5gSbI29lU4fBeBCXDSye
'' SIG '' cNNRh6JAxbEPPelLVjFM8bjsRkNhTKBllKv9i49U+dWr
'' SIG '' nUUoeIn7xYL4R2iMJp3Cq6YrAIWnjNlgabB6x4CZXn/a
'' SIG '' GLqCuodhneV99v5p5pl5ameTVelpB5UGKL2XsBLjLEMc
'' SIG '' Q7R/Y+yHxcCed5WHHyM3CjhX0RmmEO9/MNFhJVxBXIcb
'' SIG '' 9hcfgm+nkxD0hedAe2B3yJVneQmR+qfWxxHncR15sjqN
'' SIG '' IUvIthJgaggpd4mZmSqpYZ3/7/mL5WKDU7s06zQsy571
'' SIG '' jONqgm0gC9fw9vGMPlI/rdviPPOTHUJs3M/tVfg++3PG
'' SIG '' gWp7Z1skAvWMrE+2xBokBW3xZFVS+tVdAKlWs4vBjE7B
'' SIG '' FzYFeOz54u2gDsIQccktAhHGJnc3/YF3Sh2I98nZ01w2
'' SIG '' nkGZrHJvgYxc7SNrHRMu07tqQeHQideOSzLfLi9PWhgP
'' SIG '' nOloZlVbbGQ9HW4NFh0Su/fsI3qM7xU=
'' SIG '' End signature block
