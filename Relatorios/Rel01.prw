//Bibliotecas
#Include "Totvs.ch"

User Function Rel01()
    Local aArea    := FWGetArea()
    Local oReport 
    Local aPergs   := {}
    Local cProdDe  := Space(TamSX3('B1_COD')[1])
    Local cProdAte := StrTran(cProdDe, ' ', 'Z')
    Local cTipoDe  := Space(TamSX3('B1_TIPO')[1])
    Local cTipoAte := StrTran(cTipoDe, ' ', 'Z')
    Local nOrdem   := 1 

    //Adicionandoos parametros do Parambox
    aAdd(aPergs, {1, "Produto De", cProdDe, "", ".T.", "SB1", ".T.", 80, .F.})//MV_PAR01
    aAdd(aPergs, {1, "Produto Ate", cProdAte, "", ".T.", "SB1", ".T.", 80, .T.})//MV_PAR02
    aAdd(aPergs, {1, "Tipo De", cTipoDe, "", ".T.", "02", ".T.", 40, .F.})//MV_PAR03
    aAdd(aPergs, {1, "Tipo Ate", cTipoAte, "", ".T.", "02", ".T.", 40, .T.})//MV_PAR04
    aAdd(aPergs, {2, "Ordenar por", nOrdem, {"1=C�digo do Produto", "2=Descri��o do Produto", "3=Unidade de Medida",}, 100, ".T.", .T.})//MV_PAR05

    //Se a pergunta for confirma, cria as defini��es do relat�rio
    If ParamBox(aPergs, "Informe os parametros", , , , , , , , , .F.,.F.)
        MV_PAR05 := Val(cValToChar(MV_PAR05))

        oReport := fReportDef()
        oReport:PrintDialog()
    EndIf 

    FWRestArea(aArea)

Return

Static Function fReportDef()
    Local oReport
    Local oSection := Nil 

    //Cria��o do componente de impress�o
    oReport := TReport():New("Rel01",;
        "Relat�rio de Produto",;
        ,;
        {|oReport| fRepPrint(oReport),};
        )
    oReport: SetTotalInLine(.F.)
    oReport:lParamPage := .F. 
    oReport:oPage:SetPaperSize(9)


    //Orienta��o do Relat�rio
    oReport:SetPortrait()

    //Defini��es de fonte utilizada
    oReport:SetLineHeight(50)
    oReport:nFontBody := 12

    //Criando a sess�o de dados
    oSection := TRSection():New(oReport,;
        "Dados",;
        {"QRY_REP"})
    oSection:SetTotalInLine(.F.)

Return oReport
