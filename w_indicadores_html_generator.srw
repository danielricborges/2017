$PBExportHeader$w_indicadores_html_generator.srw
forward
global type w_indicadores_html_generator from window
end type
type ddlb_funcao from dropdownlistbox within w_indicadores_html_generator
end type
type sle_periodo_ini from singlelineedit within w_indicadores_html_generator
end type
type sle_periodo_fim from singlelineedit within w_indicadores_html_generator
end type
type sle_cnpj_raiz from singlelineedit within w_indicadores_html_generator
end type
type sle_top_empresas from singlelineedit within w_indicadores_html_generator
end type
type sle_top_pares from singlelineedit within w_indicadores_html_generator
end type
type cb_gerar from commandbutton within w_indicadores_html_generator
end type
type cb_fechar from commandbutton within w_indicadores_html_generator
end type
type st_funcao from statictext within w_indicadores_html_generator
end type
type st_periodo_ini from statictext within w_indicadores_html_generator
end type
type st_periodo_fim from statictext within w_indicadores_html_generator
end type
type st_cnpj_raiz from statictext within w_indicadores_html_generator
end type
type st_top_empresas from statictext within w_indicadores_html_generator
end type
type st_top_pares from statictext within w_indicadores_html_generator
end type
type gb_parametros from groupbox within w_indicadores_html_generator
end type
type gb_funcao from groupbox within w_indicadores_html_generator
end type
end forward

global type w_indicadores_html_generator from window
integer width = 3200
integer height = 2100
string title = "Gerador de Indicadores HTML"
boolean controlmenu = true
boolean minbox = true
boolean maxbox = true
boolean resizable = true
windowtype windowtype = main!
long backcolor = 67108864
ddlb_funcao ddlb_funcao
sle_periodo_ini sle_periodo_ini
sle_periodo_fim sle_periodo_fim
sle_cnpj_raiz sle_cnpj_raiz
sle_top_empresas sle_top_empresas
sle_top_pares sle_top_pares
cb_gerar cb_gerar
cb_fechar cb_fechar
st_funcao st_funcao
st_periodo_ini st_periodo_ini
st_periodo_fim st_periodo_fim
st_cnpj_raiz st_cnpj_raiz
st_top_empresas st_top_empresas
st_top_pares st_top_pares
gb_parametros gb_parametros
gb_funcao gb_funcao
end type
global w_indicadores_html_generator w_indicadores_html_generator

type variables
// Variáveis de instância
string is_temp_folder
string is_temp_file
Blob   ib_html_blob

// Constantes para as funções
constant string FUNC_QTD_FRACIONADA = "Quantidade Fracionada"
constant string FUNC_DUE_AVERBADA = "DUE Averbada"
constant string FUNC_RECOF_SEM_CONTAB = "RECOF sem Contabilidade"
constant string FUNC_RECOF_RETIFICACOES = "RECOF Retificações"
constant string FUNC_TROCA_NCM = "Troca de NCM"
constant string FUNC_DI_VENCIDA_ANTES_DUE = "DI Vencida Antes da DUE"
constant string FUNC_CFOP_IMPORTACAO = "CFOP Importação"
constant string FUNC_RECOF_INTERMEDIARIO = "RECOF Intermediário"
constant string FUNC_SALDO_VENCIDO = "Saldo Vencido"
end variables

forward prototypes
public function integer of_gerar_relatorio ()
public function integer of_open_in_browser ()
public function boolean of_validate_inputs ()
public subroutine of_clean_temp_file ()
public subroutine of_configurar_campos ()
public function string of_get_function_name ()
end prototypes

public function integer of_gerar_relatorio ();// Função para gerar o relatório do indicador selecionado
string ls_funcao_pkg, ls_periodo_ini, ls_periodo_fim, ls_cnpj_raiz
integer li_top_empresas, li_top_pares
string ls_statement

// Validar entradas
IF NOT of_validate_inputs() THEN
    RETURN -1
END IF

// Obter valores dos campos
ls_periodo_ini = Trim(sle_periodo_ini.text)
ls_periodo_fim = Trim(sle_periodo_fim.text)
ls_cnpj_raiz = Trim(sle_cnpj_raiz.text)
IF ls_cnpj_raiz = "" THEN ls_cnpj_raiz = "%"

li_top_empresas = Integer(sle_top_empresas.text)
li_top_pares = Integer(sle_top_pares.text)

// Obter nome da função package
ls_funcao_pkg = of_get_function_name()
IF ls_funcao_pkg = "" THEN
    MessageBox("Erro", "Função não identificada.", StopSign!)
    RETURN -1
END IF

// Mostrar cursor de espera
SetPointer(HourGlass!)

setNull(ib_html_blob)

DECLARE cur_indicador DYNAMIC CURSOR FOR SQLSA;

// Montar statement conforme a função selecionada
CHOOSE CASE ddlb_funcao.text
    CASE FUNC_QTD_FRACIONADA, FUNC_DUE_AVERBADA, FUNC_RECOF_SEM_CONTAB, &
         FUNC_DI_VENCIDA_ANTES_DUE, FUNC_CFOP_IMPORTACAO
        // Funções com parâmetros: periodo_ini, periodo_fim, cnpj_raiz, top_empresas
        ls_statement = "SELECT " + ls_funcao_pkg + &
                      "(p_periodo_ini => ?, p_periodo_fim => ?, " + &
                      "p_cnpj_raiz_opcional => ?, p_top_empresas => ?) FROM DUAL"

        PREPARE SQLSA FROM :ls_statement;
        IF SQLCA.SQLCode <> 0 THEN
            MessageBox("Erro de Preparação", "Erro ao preparar a chamada da procedure:~r~n~r~n" + SQLCA.SQLErrText)
            SetPointer(Arrow!)
            RETURN -1
        END IF

        OPEN DYNAMIC cur_indicador USING :ls_periodo_ini, :ls_periodo_fim, :ls_cnpj_raiz, :li_top_empresas;

    CASE FUNC_RECOF_RETIFICACOES
        // Função sem cnpj_raiz: periodo_ini, periodo_fim, top_empresas
        ls_statement = "SELECT " + ls_funcao_pkg + &
                      "(p_periodo_ini => ?, p_periodo_fim => ?, " + &
                      "p_top_empresas => ?) FROM DUAL"

        PREPARE SQLSA FROM :ls_statement;
        IF SQLCA.SQLCode <> 0 THEN
            MessageBox("Erro de Preparação", "Erro ao preparar a chamada da procedure:~r~n~r~n" + SQLCA.SQLErrText)
            SetPointer(Arrow!)
            RETURN -1
        END IF

        OPEN DYNAMIC cur_indicador USING :ls_periodo_ini, :ls_periodo_fim, :li_top_empresas;

    CASE FUNC_TROCA_NCM
        // Função com top_pares: periodo_ini, periodo_fim, cnpj_raiz, top_empresas, top_pares
        ls_statement = "SELECT " + ls_funcao_pkg + &
                      "(p_periodo_ini => ?, p_periodo_fim => ?, " + &
                      "p_cnpj_raiz_opcional => ?, p_top_empresas => ?, p_top_pares => ?) FROM DUAL"

        PREPARE SQLSA FROM :ls_statement;
        IF SQLCA.SQLCode <> 0 THEN
            MessageBox("Erro de Preparação", "Erro ao preparar a chamada da procedure:~r~n~r~n" + SQLCA.SQLErrText)
            SetPointer(Arrow!)
            RETURN -1
        END IF

        OPEN DYNAMIC cur_indicador USING :ls_periodo_ini, :ls_periodo_fim, :ls_cnpj_raiz, :li_top_empresas, :li_top_pares;

    CASE FUNC_RECOF_INTERMEDIARIO, FUNC_SALDO_VENCIDO
        // Funções com parâmetros: periodo_ini, periodo_fim, cnpj_raiz, top_empresas
        ls_statement = "SELECT " + ls_funcao_pkg + &
                      "(p_periodo_ini => ?, p_periodo_fim => ?, " + &
                      "p_cnpj_raiz_opcional => ?, p_top_empresas => ?) FROM DUAL"

        PREPARE SQLSA FROM :ls_statement;
        IF SQLCA.SQLCode <> 0 THEN
            MessageBox("Erro de Preparação", "Erro ao preparar a chamada da procedure:~r~n~r~n" + SQLCA.SQLErrText)
            SetPointer(Arrow!)
            RETURN -1
        END IF

        OPEN DYNAMIC cur_indicador USING :ls_periodo_ini, :ls_periodo_fim, :ls_cnpj_raiz, :li_top_empresas;

END CHOOSE

IF SQLCA.SQLCode <> 0 THEN
    MessageBox("Erro ao Abrir Cursor", "Erro ao abrir o cursor com os parâmetros:~r~n~r~n" + SQLCA.SQLErrText)
    SetPointer(Arrow!)
    RETURN -1
END IF

FETCH cur_indicador INTO :ib_html_blob;

IF SQLCA.SQLCode <> 0 THEN
    MessageBox("Erro de Banco de Dados", "Erro ao buscar o resultado do relatório:~r~n~r~n" + &
               SQLCA.SQLErrText, StopSign!)
    CLOSE cur_indicador;
    SetPointer(Arrow!)
    RETURN -1
END IF

CLOSE cur_indicador;

IF IsNull(ib_html_blob) OR Len(ib_html_blob) = 0 THEN
    MessageBox("Aviso", "A consulta não retornou nenhum dado para o relatório.")
    SetPointer(Arrow!)
    RETURN -1
END IF

// Abrir HTML no navegador
integer li_ret
li_ret = of_open_in_browser()

// Restaurar cursor
SetPointer(Arrow!)

IF li_ret < 0 THEN
    MessageBox("Erro", "Erro ao abrir o relatório no navegador.", StopSign!)
    RETURN -1
END IF

MessageBox("Sucesso", "Relatório gerado e aberto no navegador com sucesso!", Information!)

RETURN 1
end function

public function integer of_open_in_browser ();// Função para salvar HTML em arquivo temporário e abrir no navegador
string ls_temp_path
int li_FileID
longlong lRet

// Obter diretório temporário
ls_temp_path = GetEnvironment("TEMP")
IF IsNull(ls_temp_path) OR ls_temp_path = "" THEN
    ls_temp_path = GetEnvironment("TMP")
END IF
IF IsNull(ls_temp_path) OR ls_temp_path = "" THEN
    ls_temp_path = "C:\Temp"
END IF

is_temp_folder = ls_temp_path
is_temp_file = is_temp_folder + "\indicador_" + String(Today(), "yyyymmdd") + "_" + &
               String(Now(), "hhmmss") + ".html"

// Escrever arquivo HTML
li_FileID = FileOpen(is_temp_file, StreamMode!, Write!, LockWrite!, Replace!, EncodingUTF8!)

IF li_FileID < 0 THEN
    MessageBox("Erro", "Não foi possível criar o arquivo temporário.~r~n" + &
               "Arquivo: " + is_temp_file, StopSign!)
    RETURN -1
END IF

lRet = FileWriteEx(li_FileID, ib_html_blob)

IF lRet < 0 THEN
    FileClose(li_FileID)
    MessageBox("Erro", "Erro ao escrever o arquivo HTML.", StopSign!)
    RETURN -1
END IF

FileClose(li_FileID)

// Abrir arquivo no navegador padrão
Run(is_temp_file)

RETURN 1
end function

public function boolean of_validate_inputs ();// Função para validar as entradas do usuário
string ls_periodo_ini, ls_periodo_fim, ls_cnpj_raiz
string ls_top_empresas, ls_top_pares

// Verificar se função foi selecionada
IF ddlb_funcao.text = "" OR ddlb_funcao.SelectedIndex() <= 0 THEN
    MessageBox("Validação", "Por favor, selecione uma função geradora de indicador.", Information!)
    ddlb_funcao.SetFocus()
    RETURN FALSE
END IF

// Verificar período inicial
ls_periodo_ini = Trim(sle_periodo_ini.text)
IF IsNull(ls_periodo_ini) OR ls_periodo_ini = "" THEN
    MessageBox("Validação", "Por favor, informe o período inicial (formato: YYYYMM ou YYYY-MM).", Information!)
    sle_periodo_ini.SetFocus()
    RETURN FALSE
END IF

// Verificar período final
ls_periodo_fim = Trim(sle_periodo_fim.text)
IF IsNull(ls_periodo_fim) OR ls_periodo_fim = "" THEN
    MessageBox("Validação", "Por favor, informe o período final (formato: YYYYMM ou YYYY-MM).", Information!)
    sle_periodo_fim.SetFocus()
    RETURN FALSE
END IF

// CNPJ é opcional, mas validar formato se informado
ls_cnpj_raiz = Trim(sle_cnpj_raiz.text)
// Se estiver habilitado e vazio, será usado '%' como default

// Verificar top empresas
ls_top_empresas = Trim(sle_top_empresas.text)
IF IsNull(ls_top_empresas) OR ls_top_empresas = "" THEN
    MessageBox("Validação", "Por favor, informe a quantidade de top empresas.", Information!)
    sle_top_empresas.SetFocus()
    RETURN FALSE
END IF

IF NOT IsNumber(ls_top_empresas) THEN
    MessageBox("Validação", "Top empresas deve ser um número inteiro.", Information!)
    sle_top_empresas.SetFocus()
    RETURN FALSE
END IF

// Verificar top pares se estiver habilitado
IF sle_top_pares.Enabled THEN
    ls_top_pares = Trim(sle_top_pares.text)
    IF IsNull(ls_top_pares) OR ls_top_pares = "" THEN
        MessageBox("Validação", "Por favor, informe a quantidade de top pares para esta função.", Information!)
        sle_top_pares.SetFocus()
        RETURN FALSE
    END IF

    IF NOT IsNumber(ls_top_pares) THEN
        MessageBox("Validação", "Top pares deve ser um número inteiro.", Information!)
        sle_top_pares.SetFocus()
        RETURN FALSE
    END IF
END IF

RETURN TRUE
end function

public subroutine of_clean_temp_file ();// Procedimento para excluir o arquivo temporário
IF is_temp_file <> "" THEN
    IF FileExists(is_temp_file) THEN
        FileDelete(is_temp_file)
    END IF
    is_temp_file = ""
END IF
end subroutine

public subroutine of_configurar_campos ();// Configura habilitar/desabilitar campos conforme a função selecionada
string ls_funcao

ls_funcao = ddlb_funcao.text

// Por padrão, todos os campos habilitados
sle_periodo_ini.Enabled = TRUE
sle_periodo_fim.Enabled = TRUE
sle_top_empresas.Enabled = TRUE

// CNPJ Raiz e Top Pares dependem da função
CHOOSE CASE ls_funcao
    CASE FUNC_RECOF_RETIFICACOES
        // Esta função não usa CNPJ Raiz
        sle_cnpj_raiz.Enabled = FALSE
        sle_cnpj_raiz.text = ""
        sle_cnpj_raiz.BackColor = RGB(240, 240, 240)
        sle_top_pares.Enabled = FALSE
        sle_top_pares.text = ""
        sle_top_pares.BackColor = RGB(240, 240, 240)

    CASE FUNC_TROCA_NCM
        // Esta função usa CNPJ Raiz e Top Pares
        sle_cnpj_raiz.Enabled = TRUE
        sle_cnpj_raiz.BackColor = RGB(255, 255, 255)
        sle_top_pares.Enabled = TRUE
        sle_top_pares.BackColor = RGB(255, 255, 255)
        IF sle_top_pares.text = "" THEN sle_top_pares.text = "10"

    CASE ELSE
        // Outras funções usam CNPJ Raiz mas não Top Pares
        sle_cnpj_raiz.Enabled = TRUE
        sle_cnpj_raiz.BackColor = RGB(255, 255, 255)
        sle_top_pares.Enabled = FALSE
        sle_top_pares.text = ""
        sle_top_pares.BackColor = RGB(240, 240, 240)

END CHOOSE
end subroutine

public function string of_get_function_name ();// Retorna o nome da função package conforme seleção
string ls_funcao

ls_funcao = ddlb_funcao.text

CHOOSE CASE ls_funcao
    CASE FUNC_QTD_FRACIONADA
        RETURN "PKG_INDICADORES.gerar_html_qtd_fracionada"
    CASE FUNC_DUE_AVERBADA
        RETURN "PKG_INDICADORES.gerar_html_due_averbada"
    CASE FUNC_RECOF_SEM_CONTAB
        RETURN "PKG_INDICADORES.gerar_html_recof_sem_contab"
    CASE FUNC_RECOF_RETIFICACOES
        RETURN "PKG_INDICADORES.gerar_html_recof_retificacoes"
    CASE FUNC_TROCA_NCM
        RETURN "PKG_INDICADORES.gerar_html_troca_ncm"
    CASE FUNC_DI_VENCIDA_ANTES_DUE
        RETURN "PKG_INDICADORES.gerar_html_di_vencida_antes_due"
    CASE FUNC_CFOP_IMPORTACAO
        RETURN "PKG_INDICADORES.gerar_html_cfop_importacao"
    CASE FUNC_RECOF_INTERMEDIARIO
        RETURN "PKG_INDICADORES.gerar_html_recof_intermediario"
    CASE FUNC_SALDO_VENCIDO
        RETURN "PKG_INDICADORES.gerar_html_saldo_vencido"
    CASE ELSE
        RETURN ""
END CHOOSE
end function

on w_indicadores_html_generator.create
this.ddlb_funcao=create ddlb_funcao
this.sle_periodo_ini=create sle_periodo_ini
this.sle_periodo_fim=create sle_periodo_fim
this.sle_cnpj_raiz=create sle_cnpj_raiz
this.sle_top_empresas=create sle_top_empresas
this.sle_top_pares=create sle_top_pares
this.cb_gerar=create cb_gerar
this.cb_fechar=create cb_fechar
this.st_funcao=create st_funcao
this.st_periodo_ini=create st_periodo_ini
this.st_periodo_fim=create st_periodo_fim
this.st_cnpj_raiz=create st_cnpj_raiz
this.st_top_empresas=create st_top_empresas
this.st_top_pares=create st_top_pares
this.gb_parametros=create gb_parametros
this.gb_funcao=create gb_funcao
this.Control[]={this.ddlb_funcao,&
this.sle_periodo_ini,&
this.sle_periodo_fim,&
this.sle_cnpj_raiz,&
this.sle_top_empresas,&
this.sle_top_pares,&
this.cb_gerar,&
this.cb_fechar,&
this.st_funcao,&
this.st_periodo_ini,&
this.st_periodo_fim,&
this.st_cnpj_raiz,&
this.st_top_empresas,&
this.st_top_pares,&
this.gb_parametros,&
this.gb_funcao}
end on

on w_indicadores_html_generator.destroy
destroy(this.ddlb_funcao)
destroy(this.sle_periodo_ini)
destroy(this.sle_periodo_fim)
destroy(this.sle_cnpj_raiz)
destroy(this.sle_top_empresas)
destroy(this.sle_top_pares)
destroy(this.cb_gerar)
destroy(this.cb_fechar)
destroy(this.st_funcao)
destroy(this.st_periodo_ini)
destroy(this.st_periodo_fim)
destroy(this.st_cnpj_raiz)
destroy(this.st_top_empresas)
destroy(this.st_top_pares)
destroy(this.gb_parametros)
destroy(this.gb_funcao)
end on

event open;// Inicializar variáveis
is_temp_file = ""
is_temp_folder = ""

// Adicionar funções ao dropdownlistbox
ddlb_funcao.AddItem(FUNC_QTD_FRACIONADA)
ddlb_funcao.AddItem(FUNC_DUE_AVERBADA)
ddlb_funcao.AddItem(FUNC_RECOF_SEM_CONTAB)
ddlb_funcao.AddItem(FUNC_RECOF_RETIFICACOES)
ddlb_funcao.AddItem(FUNC_TROCA_NCM)
ddlb_funcao.AddItem(FUNC_DI_VENCIDA_ANTES_DUE)
ddlb_funcao.AddItem(FUNC_CFOP_IMPORTACAO)
ddlb_funcao.AddItem(FUNC_RECOF_INTERMEDIARIO)
ddlb_funcao.AddItem(FUNC_SALDO_VENCIDO)

// Valores padrão
sle_cnpj_raiz.text = "%"
sle_top_empresas.text = "10"

// Configurar foco inicial
ddlb_funcao.SetFocus()
end event

event close;// Limpar arquivo temporário se existir
of_clean_temp_file()
end event

type ddlb_funcao from dropdownlistbox within w_indicadores_html_generator
integer x = 110
integer y = 140
integer width = 2880
integer height = 400
integer taborder = 10
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean sorted = false
boolean vscrollbar = true
borderstyle borderstyle = stylelowered!
end type

event selectionchanged;// Ao mudar a seleção, configurar campos
Parent.of_configurar_campos()
end event

type sle_periodo_ini from singlelineedit within w_indicadores_html_generator
integer x = 110
integer y = 720
integer width = 640
integer height = 92
integer taborder = 20
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type

type sle_periodo_fim from singlelineedit within w_indicadores_html_generator
integer x = 850
integer y = 720
integer width = 640
integer height = 92
integer taborder = 30
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type

type sle_cnpj_raiz from singlelineedit within w_indicadores_html_generator
integer x = 1590
integer y = 720
integer width = 640
integer height = 92
integer taborder = 40
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type

type sle_top_empresas from singlelineedit within w_indicadores_html_generator
integer x = 110
integer y = 980
integer width = 400
integer height = 92
integer taborder = 50
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type

type sle_top_pares from singlelineedit within w_indicadores_html_generator
integer x = 610
integer y = 980
integer width = 400
integer height = 92
integer taborder = 60
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean enabled = false
borderstyle borderstyle = stylelowered!
end type

type cb_gerar from commandbutton within w_indicadores_html_generator
integer x = 1253
integer y = 1280
integer width = 471
integer height = 112
integer taborder = 70
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
string text = "&Gerar Relatório"
boolean default = true
end type

event clicked;// Gerar relatório
integer li_ret

li_ret = Parent.of_gerar_relatorio()

// Mensagem de sucesso já é exibida na função of_gerar_relatorio
end event

type cb_fechar from commandbutton within w_indicadores_html_generator
integer x = 1801
integer y = 1280
integer width = 471
integer height = 112
integer taborder = 80
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
string text = "&Fechar"
boolean cancel = true
end type

event clicked;// Fechar janela
Close(Parent)
end event

type st_funcao from statictext within w_indicadores_html_generator
integer x = 110
integer y = 72
integer width = 650
integer height = 64
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "Função Geradora:"
boolean focusrectangle = false
end type

type st_periodo_ini from statictext within w_indicadores_html_generator
integer x = 110
integer y = 652
integer width = 640
integer height = 64
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "Período Inicial (YYYYMM):"
boolean focusrectangle = false
end type

type st_periodo_fim from statictext within w_indicadores_html_generator
integer x = 850
integer y = 652
integer width = 640
integer height = 64
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "Período Final (YYYYMM):"
boolean focusrectangle = false
end type

type st_cnpj_raiz from statictext within w_indicadores_html_generator
integer x = 1590
integer y = 652
integer width = 640
integer height = 64
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "CNPJ Raiz (opcional):"
boolean focusrectangle = false
end type

type st_top_empresas from statictext within w_indicadores_html_generator
integer x = 110
integer y = 912
integer width = 400
integer height = 64
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "Top Empresas:"
boolean focusrectangle = false
end type

type st_top_pares from statictext within w_indicadores_html_generator
integer x = 610
integer y = 912
integer width = 400
integer height = 64
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "Top Pares NCM:"
boolean focusrectangle = false
end type

type gb_parametros from groupbox within w_indicadores_html_generator
integer x = 41
integer y = 560
integer width = 3086
integer height = 600
integer taborder = 90
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "Parâmetros"
end type

type gb_funcao from groupbox within w_indicadores_html_generator
integer x = 41
integer width = 3086
integer height = 540
integer taborder = 100
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "Seleção de Indicador"
end type

