
;********************************
; CONTROLS
;********************************

controls(
  viewTypeUnits(
    ( maskLayout          "micron"        1000 )
    ( schematic           "inch"          160  )
    ( schematicSymbol     "inch"          160  )
    ( netlist             "inch"          160  )
    ( hierDesign          "_def_"         1000 )
  ) ;viewTypeUnits

  mfgGridResolution(
    (0.01000)
  ) ;mfgGridResolution
)

;********************************
; LAYER DEFINITION
;********************************

layerDefinitions(

 techPurposes(
 ;( PurposeName               Purpose#   Abbreviation )
 ;( -----------               --------   ------------ )
  ( drawing                   -1         drw          )
  ( net                       253        net          )
 ) ;techPurposes

 techLayers(
 ;( LayerName                 Layer#     Abbreviation )
 ;( ---------                 ------     ------------ )
 ;User-Defined Layers:
  ( SOI1                      1          S1           )
  ( POLY1                     2          P1           )
  ( METAL1                    3          M1           )
  ( METAL2                    6          M2           )
  ( POLY2                     9          P2           )
  ( SOI2                      10         S2           )
 ) ;techLayers

 techLayerPurposePriorities(
 ;layers are ordered from lowest to highest priority
 ;( LayerName                 Purpose    )
 ;( ---------                 -------    )
  ( SOI2                      drawing    )
  ( POLY2                     drawing    )
  ( METAL2                    drawing    )
  ( METAL1                    drawing    )
  ( POLY1                     drawing    )
  ( SOI1                      drawing    )
  ( POLY1                     net        )
  ( POLY2                     net        )
  ( METAL1                    net        )
  ( METAL2                    net        )
 ) ;techLayerPurposePriorities

 techDisplays(
 ;( LayerName    Purpose      Packet          Vis Sel Con2ChgLy DrgEnbl Valid)
 ;( ---------    -------      ------          --- --- --------- ------- -----)
  ( SOI1         drawing      whiteSolid       t t t t t )
  ( POLY1        drawing      yellowSolid      t t t t t )
  ( METAL1       drawing      redSolid         t t t t t )
  ( METAL2       drawing      greenSolid       t t t t t )
  ( POLY2        drawing      blueSolid        t t t t t )
  ( SOI2         drawing      magentaSolid     t t t t t )
  ( POLY1        net          yellowDashed     t t t t nil )
  ( POLY2        net          blueDashed       t t t t nil )
  ( METAL1       net          redDashed        t t t t nil )
  ( METAL2       net          greenDashed      t t t t nil )
 ) ;techDisplays

techLayerProperties(
;( PropName               Layer1 [ Layer2 ]       PropValue )
  ( sheetResistance       METAL1                  0.0244  )
  ( sheetResistance       METAL2                  0.0244  )
  ( sheetResistance       SOI1                    100     )
  ( sheetResistance       SOI2                    100     )
  ( sheetResistance       POLY1                   100     )
  ( sheetResistance       POLY2                   100     )

)


) ;layerDefinitions


;********************************
; LAYER RULES
;********************************

layerRules(

  functions(
    ;( layer          function         [maskNumber] )
    ;( -----          --------          ----------  )
    ( SOI1          "substrate"        1          )
    ( POLY1         "poly"             2          )
    ( METAL1        "metal"            3          )
    ( SOI2          "substrate"        6          )
    ( POLY2         "poly"             7          )
    ( METAL2        "metal"            8          )
  ) ;functions

  
  
  mfgResolutions(
    ( "METAL1" 0.05 )
    ( "METAL2" 0.05 )
    ( "POLY1"  0.05 )
    ( "POLY2"  0.05 )
    ( "SOI1"   0.01 )
    ( "SOI2"   0.01 )
  ) ;mfgResolutions
) ;layerRules


;********************************
; CONSTRAINT GROUPS
;********************************
constraintGroups(
  ; ( group                             [override] )
  ; ( -----                              --------  )
  ( "virtuosoDefaultExtractorSetup"    nil
  ;  layer constraints
    interconnect(
      ( validLayers    ( SOI1 POLY1 METAL1 SOI2 POLY2 METAL2 )   )
    );interconnect
  );virtuosoDefaultExtractorSetup
  ( "foundry"
      ; physical constraints
      spacings(
        ;( constraint     layer1     layer2     value )
        ;( ----------     ------     ------     ----- )
        ( minWidth       "METAL1"               1 )
        ( minWidth       "SOI1"                 1 )
        ( minWidth       "POLY1"                1 )
        ( minWidth       "METAL2"               1 )
        ( minWidth       "SOI2"                 1 )
        ( minWidth       "POLY2"                1 )

        ( minSpacing     "METAL1"               1 )
        ( minSpacing     "SOI1"                 1 )
        ( minSpacing     "POLY1"                1 )
        ( minSpacing     "METAL2"               1 )
        ( minSpacing     "SOI2"                 1 )
        ( minSpacing     "POLY2"                1 )
      );spacings
  );foundry
);constraintGroups