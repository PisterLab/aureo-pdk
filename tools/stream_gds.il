elib = getShellEnvVar("GDS_LIB")
ecell = getShellEnvVar("GDS_CELL")
efile = getShellEnvVar("GDS_FILE")
xstSetField( "library" elib )
xstSetField( "topCell" ecell )
; Export gds is arg2 concatenated with _preprocess.gds
xstSetField( "strmFile" efile )
xstSetField( "showCompletionMsgBox" "false")
xstSetField( "enableColoring" "false")
xstSetField( "flattenPcells" "true")
xstSetField( "higherDepth" "32767")

printf("Exporting GDS...\n")
procedure( xstOutOnCompletion( status ) 
    if( status == 0  then
        printf("Exported GDS.\n")
    else
        printf("Export GDS failed.\n")
    ); if
    exit()
)
xstOutDoTranslate()
