USER Function aTest19()

Local aCores := { {0,"Preto"}, {1,"Azul"} , {2,"Verde"} }
Local nBusca, nPos

nBusca := 2
nPos := ascan( aCores , {|x| x[1] == nBusca })

If nPos > 0 
	MsgInfo("A cor pesquisada "+cValToChar(nBusca) + ;
 " foi encontrada na posição "+ cValToChaR(nPos), "Atenção!")
Else
	MsgStop("Cor nao encontrada.")
Endif
Return
