#Include 'Totvs.ch'
#Include 'Protheus.ch'
#include 'restful.ch'

User Function zConsome()
    Local aArea := FWGetArea()
    Local aHeader  := {}
    Local oRestClient := FWRest():New("https://viacep.com.br/ws")
    Local cCep     := '13223050'

    //Adiciona os headers que são enviados via WS
    aAdd(aHeader,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
    aAdd(aHeader,'Content-Type: application/json; charset=utf-8')

    //Define a url conforme o CEP e aciona o metodo GET
    oRestClient:setPath("/"+cCep+"/json/")
    If oRestClient:Get(aHeader)

        //Exibe o resultado que veio do Ws
        ShowLog(oRestClient:cResult)
    
    //Se não pega os erros e exibe um Alert
    Else
        cLastError  := oRestClient:GetLastError()
        cErrorDetail := oRestClient:GetResult()
        Alert(cErrorDetail)
    EndIf

    FWRestArea(aArea)

Return
