
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
  ( derivedCut                13         dcut         )
 ) ;techPurposes

 techLayers(
 ;( LayerName                 Layer#     Abbreviation )
 ;( ---------                 ------     ------------ )
 ;User-Defined Layers:
  ( SOIFAB                    0          SOI          )
  ( POLYFAB                   1          POLY         )
  ( METALFAB                  2          METAL        )
  ( SOI1FAB                   3          S1FAB        )
  ( POLY1FAB                  4          P1FAB        )
  ( METAL1FAB                 5          M1FAB        )
  ( METAL2FAB                 6          M1FAB        )
  ( POLY2FAB                  7          P2FAB        )
  ( SOI2FAB                   8          S2FAB        )
  ( SOI1                      9          S1           )
  ( SOIHOLE1                  10         S1HOLE       )
  ( POLY1                     11         P1           )
  ( LOWMETAL1                 12         LM1          )
  ( HIGHMETAL1                13         HM1          )
  ( HIGHMETAL2                14         HM2          )
  ( LOWMETAL2                 15         LM2          )
  ( POLY2                     16         P2           )
  ( SOI2                      17         S2           )
  ( SOIHOLE2                  18         S2HOLE       )
 ) ;techLayers

 techDerivedLayers(
  ;( t_derivedLayerName       x_derivedLayerNum   (tx_layer1 s_op tx_layer2) )
  ;( D1                        100                 (SOI1 'and METAL1) )
  ( SOI1Stopped  10001  ("SOI1" 'not "SOIHOLE1" ) )
  ( SOI2Stopped  10002  ("SOI2" 'not "SOIHOLE2" ) )
 )

 techLayerPurposePriorities(
 ;layers are ordered from lowest to highest priority
 ;( LayerName                 Purpose    )
 ;( ---------                 -------    )
  ( SOI1                      drawing    ) 
  ( SOIHOLE1                  drawing    ) 
  ( POLY1                     drawing    )
  ( LOWMETAL1                 drawing    )
  ( HIGHMETAL1                drawing    )
  ( SOI2                      drawing    )
  ( SOIHOLE2                  drawing    )
  ( POLY2                     drawing    )
  ( LOWMETAL2                 drawing    )
  ( HIGHMETAL2                drawing    )
  ( POLY1                     net        )
  ( POLY2                     net        )
  ( LOWMETAL1                 net        )
  ( LOWMETAL2                 net        )
  ( HIGHMETAL1                net        )
  ( HIGHMETAL2                net        )
 ) ;techLayerPurposePriorities


 techDisplays(
 ;( LayerName    Purpose      Packet          Vis Sel Con2ChgLy DrgEnbl Valid)
 ;( ---------    -------      ------          --- --- --------- ------- -----)
  ( SOI1         drawing      whiteSolidSp     t t t t t )
  ( SOIHOLE1     drawing      whiteDiag        t t t t t )
  ( POLY1        drawing      redSolidDe       t t t t t )
  ( LOWMETAL1    drawing      cyanSolid        t t t t t )
  ( HIGHMETAL1   drawing      yellowSolid      t t t t t )
  ( HIGHMETAL2   drawing      greenSolid       t t t t t )
  ( LOWMETAL2    drawing      blueSolid        t t t t t )
  ( POLY2        drawing      orangeSolidDe    t t t t t )
  ( SOI2         drawing      magentaSolidSp   t t t t t )
  ( SOIHOLE2     drawing      magentaDiag      t t t t t )
  ( POLY1        net          yellowDashed     t t t t nil )
  ( POLY2        net          blueDashed       t t t t nil )
  ( LOWMETAL1    net          redDashed        t t t t nil )
  ( HIGHMETAL1   net          greenDashed      t t t t nil )
  ( LOWMETAL2    net          blueDashed       t t t t nil )
  ( HIGHMETAL2   net          purpleDashed     t t t t nil )
  
  
 ) ;techDisplays

techLayerProperties(
;( PropName               Layer1 [ Layer2 ]       PropValue )
  ( sheetResistance       LOWMETAL1               0.0244  )
  ( sheetResistance       LOWMETAL2               0.0244  )
  ( sheetResistance       HIGHMETAL1              0.0244  )
  ( sheetResistance       HIGHMETAL2              0.0244  )
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
    ( SOI1          "li"                1          )
    ( SOIHOLE1      "li"                2          )
    ( LOWMETAL1     "li"                3          )
    ( POLY1         "li"                4          )
    ( HIGHMETAL1    "li"                5          )
    ( HIGHMETAL2    "li"         6          )
    ( POLY2         "li"               8          )
    ( LOWMETAL2     "li"               9          )
    ( SOI2          "li"        10         )
    ( SOIHOLE2      "li"        10         )
    
    
  ) ;functions

  
  
  mfgResolutions(
    ( "LOWMETAL1" 0.05 )
    ( "LOWMETAL2" 0.05 )
    ( "HIGHMETAL1" 0.05 )
    ( "HIGHMETAL2" 0.05 )
    ( "POLY1"  0.05 )
    ( "POLY2"  0.05 )
    ( "SOI1"   0.01 )
    ( "SOI2"   0.01 )
    ( "SOIHOLE1" 0.01 )
    ( "SOIHOLE2" 0.01 )
  ) ;mfgResolutions
) ;layerRules


;********************************
; VIA DEFINITIONS
;********************************

viaDefs(
  standardViaDefs(
    ;standardViaDefs(
    ;  ( t_viaDefName tx_layer1 tx_layer2 
    ;    ( tx_cutLayer n_cutWidth n_cutHeight [n_resistancePerCut] ) 
    ;    ( x_cutRows x_cutCols ( l_cutSpace ) [(l_cutPattern)])
    ;    (l_layer1Enc) (l_layer2Enc) 
    ;    ( l_layer1Offset ) ( l_layer2Offset ) ( l_origOffset )
    ;    [tx_implant1 ( l_implant1Enc ) 
    ;    [tx_implant2 ( l_implant2Enc )  [ tx_wellSubstrate ] ] 
    ;    ] 
    ;  )
    ;) ;standardViaDefs
 
    ;(t_viaDefName    tx_layer1   tx_layer2 cutLayer )
    ( POLY1xHM1       POLY1       HIGHMETAL1     ( "HIGHMETAL1" 1.0   1.0 )
      ( 1 1 ( 0.0 0.0 ) )
      ( 0.5 0.5 ) ( 0.5 0.5 )  ( 0.0 0.0 ) ( 0.0 0.0 ) ( 0.0 0.0 )
    )
    ( SOI1xLM1        SOI1        LOWMETAL1      ( "LOWMETAL1"  1.0   1.0 )
      ( 1 1 ( 0.0 0.0 ) )
      ( 0.5 0.5 ) ( 0.5 0.5 )  ( 0.0 0.0 ) ( 0.0 0.0 ) ( 0.0 0.0 )
    )
    ( LM1xHM1         LOWMETAL1   HIGHMETAL1    ( "HIGHMETAL1"  1.0   1.0 )
      ( 1 1 ( 0.0 0.0 ) )
      ( 0.5 0.5 ) ( 0.5 0.5 )  ( 0.0 0.0 ) ( 0.0 0.0 ) ( 0.0 0.0 )
    )
    ( HM1xHM2         HIGHMETAL1  HIGHMETAL2   ( "HIGHMETAL2" 1.0   1.0 )
      ( 1 1 ( 0.0 0.0 ) )
      ( 0.5 0.5 ) ( 0.5 0.5 )  ( 0.0 0.0 ) ( 0.0 0.0 ) ( 0.0 0.0 )
    )
    ( HM2xLM2         HIGHMETAL2   LOWMETAL2   ( "LOWMETAL2" 1.0   1.0 )
      ( 1 1 ( 0.0 0.0 ) )
      ( 0.5 0.5 ) ( 0.5 0.5 )  ( 0.0 0.0 ) ( 0.0 0.0 ) ( 0.0 0.0 )
    )
    ( LM2xSOI2        LOWMETAL2      SOI2      ( "LOWMETAL2" 1.0   1.0 )
      ( 1 1 ( 0.0 0.0 ) )
      ( 0.5 0.5 ) ( 0.5 0.5 )  ( 0.0 0.0 ) ( 0.0 0.0 ) ( 0.0 0.0 )
    )
    ( HM2xPOLY2       HIGHMETAL2   POLY2   ( "HIGHMETAL2" 1.0   1.0 )
      ( 1 1 ( 0.0 0.0 ) )
      ( 0.5 0.5 ) ( 0.5 0.5 )  ( 0.0 0.0 ) ( 0.0 0.0 ) ( 0.0 0.0 )
    )
  );standardViaDefs
) ;viaDefs

;********************************
; CONSTRAINT GROUPS
;********************************
constraintGroups(
  ; ( group                             [override] )
  ; ( -----                              --------  )
  ( "virtuosoDefaultExtractorSetup"    nil
  ;  layer constraints
    interconnect(

      ( validLayers ( "SOI1Stopped" "POLY1" "LOWMETAL1" "HIGHMETAL1" "SOI2Stopped" "POLY2" "LOWMETAL2" "HIGHMETAL2")   )
      ( validVias ( "POLY1xHM1" "SOI1xLM1" "LM1xHM1" "HM1xHM2" "HM2xLM2" "LM2xSOI2" "HM2xPOLY2" ) )
      ( validPurposes 'include ("drawing" "net" "derivedCut") )
    );interconnect
  );virtuosoDefaultExtractorSetup
  ( "foundry"
      ; physical constraints
      spacings(
        ;( constraint     layer1     layer2     value )
        ;( ----------     ------     ------     ----- )
        ( minWidth       "LOWMETAL1"            1 )
        ( minWidth       "HIGHMETAL1"           1 )
        ( minWidth       "SOI1"                 1 )
        ( minWidth       "SOIHOLE1"             1 )
        ( minWidth       "POLY1"                1 )
        ( minWidth       "LOWMETAL2"            1 )
        ( minWidth       "HIGHMETAL2"           1 )
        ( minWidth       "SOI2"                 1 )
        ( minWidth       "SOIHOLE2"             1 )
        ( minWidth       "POLY2"                1 )

        ( minSpacing     "LOWMETAL1"            1 )
        ( minSpacing     "HIGHMETAL1"           1 )
        ( minSpacing     "SOI1"                 1 )
        ( minSpacing     "SOIHOLE1"             1 )
        ( minSpacing     "POLY1"                1 )
        ( minSpacing     "LOWMETAL2"            1 )
        ( minSpacing     "HIGHMETAL2"           1 )
        ( minSpacing     "SOI2"                 1 )
        ( minSpacing     "SOIHOLE2"             1 )
        ( minSpacing     "POLY2"                1 )
      );spacings
  );foundry
);constraintGroups