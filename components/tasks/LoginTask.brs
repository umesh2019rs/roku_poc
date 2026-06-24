sub init()
    m.top.functionName = "PerformLogin"
end sub

sub PerformLogin()
    url = "https://dummyjson.com/auth/login"
    print "username" m.top.username
    print "password" m.top.password
    username =  m.top.username 'emilys
    password =  m.top.password 'emilyspass

    if username = "" or password = "" then
        print "Error: Missing username or password"
        m.top.loginError = "Missing credentials"
        return
    end if

    ' Prepare HTTP Request
    request = CreateObject("roUrlTransfer")
    port = CreateObject("roMessagePort")
    
    request.SetUrl(url)
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    request.InitClientCertificates()
    request.EnablePeerVerification(true)
    request.SetPort(port)
    request.SetRequest("POST")
    request.AddHeader("Content-Type", "application/json")

    jsonBody = "{""username"": """ + username + """, ""password"": """ + password + """}"
    request.EnableEncodings(true)
    request.AsyncPostFromString(jsonBody)

    while true
        msg = wait(0, port)
        if type(msg) = "roUrlEvent"
            response = msg.GetString()
            HandleLoginResponse(response)
            exit while
        end if
    end while
end sub

sub HandleLoginResponse(response as String)
    if response = invalid or response = "" then
        print "API Error: Response is invalid or empty!"
        return
    end if

    json = ParseJson(response)
    
    if json = invalid or not json.DoesExist("accessToken") or json.accessToken = "" then
        print "Login Failed: Invalid credentials"
        return
    end if

    print "Login Successful: "; json
    StoreLoginToken(json)
    m.top.loginSuccess = true
end sub

sub StoreLoginToken(json as Object)
    if json = invalid then return

    reg = CreateObject("roRegistrySection", "UserAuth")

    ' Store login data safely
    reg.Write("loggedInStatus", "true")
    
    if json.DoesExist("email") then reg.Write("email", json.email)
    if json.DoesExist("firstName") then reg.Write("firstName", json.firstName)
    if json.DoesExist("lastName") then reg.Write("lastName", json.lastName)
    if json.DoesExist("image") then reg.Write("image", json.image)

    reg.Flush()
    print "User login details stored successfully!"
end sub

