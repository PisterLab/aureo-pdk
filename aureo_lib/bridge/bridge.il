strLibName = "aureo_lib"
strCellName = "bridge"

pcDefinePCell(
    list( ddGetObj(strLibName) strCellName "layout")
    ; parameters and their optional default values:
    list( 
        ( width      float    30)
        ( length     float    50)
    ) ;end of parameter list

    let((techfile_lib techFileID master inst),
        techfile_lib = techGetTechLibName(pcCellView~>lib)
        techFileID = techGetTechFile(ddGetObj(techfile_lib))
        master = dbOpenCellView
    
    
    )
)