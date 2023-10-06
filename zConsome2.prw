#Include 'Totvs.ch'
#Include 'Protheus.ch'
#Include 'restful.ch'

User Function zCons()
    Local aArea := FWGetArea()
    Local cUserLogin := Alltrim(SuperGetMV("MV_X_WSUSR", .F., 'matheus.monteiro'))
    Local cUsrSenha  := Alltrim(SuperGetMV("MV_X_WSPAS", .F., '1234'))
    Local cBasicAuth := Encode64(cUserLogin + ":" + cUsrSenha)
    Local aHeader    := {}
    Local cURL       := "http://localhost:8400/rest/zConsulta"
    Local oRestClient := FWRest():New(cURL)

    //Adiciona os headers que serão enviados do WS
    aAdd(aHeader,'Authorization: Basic' + cBasicAuth)

    oRestClient:setPath("/get_id?id=F001")
    If oRestClient:Get(aHeader)

        //Exibe o resultado que veio do WS
        ShowLog(oRestClient:cResult)

    //Senão, pega os erros, e exibe um alert
    Else
        cLastError := oRestClient:GetLastError()
        cErrorDetail := oRestClient:GetResult()
        Alert(cErrorDetail)
    EndIf 

    FWRestArea(aArea)

Return
