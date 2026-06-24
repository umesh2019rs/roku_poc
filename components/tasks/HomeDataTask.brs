sub init()
    print "Home data task"
    m.top.functionName = "fetchData" 
    m.top.observeField("fetchComplete", "onFetchComplete")
end sub

sub fetchData()
    url = m.top.url
    if url = "" then return

    urlTransfer = CreateObject("roUrlTransfer")
    urlTransfer.SetUrl(url)
    urlTransfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    urlTransfer.InitClientCertificates()
    urlTransfer.EnablePeerVerification(true)

    response = urlTransfer.GetToString()

    if response <> invalid
        m.top.responseData = response  ' Send raw JSON to HomeScreen
        m.top.fetchComplete = true
    else
        print "Error: API request failed"
    end if
end sub

sub onFetchComplete()
    print "HomeDataTask: Data fetch completed!"
end sub