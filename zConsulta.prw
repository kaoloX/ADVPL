#include 'totvs.ch'
#include 'protheus.ch'
#include 'restful.ch'

WSRESTFUL zConsulta DESCRIPTION 'Webservice cadastro de Produto'
    //Atributos
    WSDATA id AS STRING
    WSDATA updated_at as STRING
    WSDATA limit as INTEGER
    WSDATA page as INTEGER

    //Métodos
    WSMETHOD GET  ID  DESCRIPTION 'Retorna o registro pesquisado'   WSSYNTAX '/zConsulta/get_id?{id}'                     PATH 'get_id'         PRODUCES APPLICATION_JSON
    WSMETHOD GET  ALL  DESCRIPTION 'Retorna todos os registros'       WSSYNTAX '/zConsulta/get_all{update_at,limit,page}'   PATH 'get_all'        PRODUCES APPLICATION_JSON
    WSMETHOD POST NEW DESCRIPTION 'Inclusão de registro'            WSSYNTAX '/zConsulta/new'                             PATH 'new'            PRODUCES APPLICATION_JSON
END WSRESTFUL


WSMETHOD GET ID WSRECEIVE id WSSERVICE zConsulta 
    Local lRet      := .T.
    Local jResponse := JsonObject():New()
    Local cAliasWS  := 'SB1'

    //Se o id estiver vazio
    If Empty(::id)
        //SetRestFault(500, 'Falha ao consultar o registro), caso queira usar este comando, você não poderá usar outros retornos,como os abaixo
        Self:setStatus(500)
        jResponse['errorId']  := 'ID001'
        jResponse['error']    := 'ID vazio'
        jResponse['solution'] := 'Informe o ID'
    Else 
        DbSelectArea(cAliasWS)
        (cAliasWS)->(DbSetOrder(1))

        //Se não encontrar o registro
        If ! (cAliasWS)->(MsSeek(FWxFilial(cAliasWS) + ::id))
            //SetRestFault(500, 'Falha ao consultar o id'), caso queira usar este comando, você não poderá usar outros retornos,como os abaixo
            Self:setStatus(500)
            jResponse['errorId'] := 'ID002'
            jResponse['error']   := 'ID não encontrado1
            JResponse['solution'] := 'Código não encontrado na tabela' + cAliasWS
        Else 
            //Define o retorno
            jResponse['cod']  := (cAliasWS)->B1_COD
            jResponse['desc'] := (cAliasWS)->B1_DESC
            jResponse['tipo'] := (cAliasWS)->B1_TIPO
            jResponse['um']   := (cAliasWS)->B1_UM
            jResponse['locpad'] :=(cAliasWS)->B1_LOCPAD
            jResponse['grupo'] := (cAliasWS)->B1_GRUPO  
        EndIf 
    EndIf 



    //Define o retorno
    Self:SetContentType('application/json')
    Self:SetResponse(jResponse:toJSON())
Return lRet

WSMETHOD POST NEW WSRECEIVE WSSERVICE zConsulta
    Local lRet         := .T.
    Local aDados       := {}
    Local jJson        := NIL
    Local cJson        := Self:GetContent()
    Local cError       := ''
    Local nLinha       := 0
    Local cDirLog      := '\x_logs\'
    Local cArqLog      := ''
    Local cErrorLog    := ''
    Local aLogAuto     := {}
    Local nCampo       := 0
    Local jResponse    := JsonObject():New()
    Local cAliasWS     := 'SB1'
    Private lMsErroAuto := .F.
    Private lMsHelpAuto := .T.
    Private lAutoErrNoFile := .T.

    //Se não existir a pasta de logs, cria.
    If ! ExistDir(cDirLog)
        MakeDir(cDirLog)
    EndIf

    //Definindo o conteúdo como JSON, e pegando o content e dando um parse para ver se a estrutura está ok.
    Self:SetContentType('application/json')
    jJson   := JsonObject():New()
    cError  := jJson:FromJson(cJson)

    //Se tiver algum erro no parse, encerra a execução
    If ! Empty(cError)
        //SetRestFault(500, 'Falha ao obter JSON') caso queira usar este comando, você não poderá usar outros retornos, como os abaixo
        jResponse['errorId'] := 'NEW004'
        jResponse['error'] := 'Parse do JSON'
        jResponse['solution'] := 'Erro ao fazer o parse do JSON'

    else
        DbSelectArea(cAliasWS)

        //Adiciona os dados do ExecAuto
        aAdd(aDados, {'B1_COD', jJson:GetJsonObject('cod'), NIL})
        aAdd(aDados, {'B1_DESC', jJson:GetJsonObject('desc'), NIL})
        aAdd(aDados, {'B1_TIPO', jJson:GetJsonObject('tipo'), NIL})
        aAdd(aDados, {'B1_UM', jJson:GetJsonObject('um'), NIL})
        aAdd(aDados, {'B1_LOCPAD', jJson:GetJsonObject('locpad'), NIL})
        aAdd(aDados, {'B1_GRUPO', jJson:GetJsonObject('grupo'), NIL})

        //Percorre os dados do execauto
        For nCampo   := 1 To Len(aDados)
            //Se o campo for data, retira os hifens e faz a conversão
            If GetSX3Cache(aDados[nCampo][1], 'X3_TIPO') == 'D'
                aDados[nCampo][2] := StrTran(aDados[nCampo][2], '-', '')
                aDados[nCampo][2] := sTod(aDados[nCampo][2])
            EndIf
        Next

        //Chamando a inclusão automática
        MsExecAuto({|x,y| MATA010(x,y)}, aDados, 3)

        //Se houve erro, gera um arquivo de log dentro do diretorio da protheus data
        If lMsErroAuto
            //Monta o texto do error log que será salvo
            cErrorLog    := ''
            aLogAuto     := GetAutoGrLog()
            For  nLinha  := 1 To Len(aLogAuto)
                cErrorLog += aLogAuto[nLinha] + CRLF
            Next nLinha

            //Grava o arquivo de log
            cArqLog   := 'zConsulta_New' + dToS(Date()) + '_' + StrTran(Time(), ':', '-') + '.log'
            MemoWrite(cDirLog + cArqLog, cErrorLog)

            //Define o retorno para o webservice
            //SetRestFault(500, 'Falha ao obter JSON') caso queira usar este comando, você não poderá usar outros retornos, como os abaixo
            Self:setStatus(500)
            jResponse['errorId']   := 'NEW005'
            jResponse['error']     := 'Erro na inclusão do registro'
            jResponse['solution']  := 'Não foi possível incluir o registro, foi gerado um arquivo de log em' + cDirLog + cArqLog + ''
            lRet := .F.

        //Se nao define o retorno
        Else 
            jResponse['note']     := 'Registro incluido com sucesso'
        EndIf
    EndIf

    //Define o retorno
    Self:SetResponse(jResponse:toJson())
Return lRet
