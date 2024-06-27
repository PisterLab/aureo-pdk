
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
  ( pin                       251        pin          )
  ( net                       253        net          )
  ( derivedCut                13         dcut         )
  ( resMarker                 14         resID        )
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
  ( PIMPLANT                  19         PIMP         )
  ( NIMPLANT                  20         NIMP         )
  ( BOUNDARY                  43         BOUND        )
 ) ;techLayers

 techDerivedLayers(
  ;( t_derivedLayerName       x_derivedLayerNum   (tx_layer1 s_op tx_layer2) )
  ;( -------------------      -----------------   ------------------------ )
  ;( D1                        100                 (SOI1 'and METAL1) )
  ;( SOI1Stopped  10001  ("SOI1" 'not "SOIHOLE1" ) )
  ;( SOI2Stopped  10002  ("SOI2" 'not "SOIHOLE2" ) )
  ; End examples
 )

 techLayerPurposePriorities(
 ;layers are ordered from lowest to highest priority
 ;( LayerName                 Purpose    )
 ;( ---------                 -------    )
  ( SOI1                      drawing    ) 
  ( POLY1                     drawing    )
  ( LOWMETAL1                 drawing    )
  ( HIGHMETAL1                drawing    )
  ( SOI2                      drawing    )
  ( POLY2                     drawing    )
  ( LOWMETAL2                 drawing    )
  ( HIGHMETAL2                drawing    )
  ( PIMPLANT                  drawing    )
  ( NIMPLANT                  drawing    )
  ( BOUNDARY                  drawing    )
  ( POLY1                     net        )
  ( POLY2                     net        )
  ( LOWMETAL1                 net        )
  ( LOWMETAL2                 net        )
  ( HIGHMETAL1                net        )
  ( HIGHMETAL2                net        )
  ( SOI1                      net        )
  ( SOI2                      net        )
  ( POLY1                     pin        )
  ( POLY2                     pin        )
  ( LOWMETAL1                 pin        )
  ( LOWMETAL2                 pin        )
  ( HIGHMETAL1                pin        )
  ( HIGHMETAL2                pin        )
  ( SOI1                      pin        )
  ( SOI2                      pin        )
  ( POLY1                     resMarker  )
  ( POLY2                     resMarker  )
  ( LOWMETAL1                 resMarker  )
  ( LOWMETAL2                 resMarker  )
  ( HIGHMETAL1                resMarker  )
  ( HIGHMETAL2                resMarker  )
  ( SOI1                      resMarker  )
  ( SOI2                      resMarker  )
 ) ;techLayerPurposePriorities


 techDisplays(
 ;( LayerName    Purpose      Packet          Vis Sel Con2ChgLy DrgEnbl Valid)
 ;( ---------    -------      ------          --- --- --------- ------- -----)
  ( SOI1         drawing      whiteSolidSp     t t t t t )
  ( POLY1        drawing      redSolidDe       t t t t t )
  ( LOWMETAL1    drawing      cyanSolid        t t t t t )
  ( HIGHMETAL1   drawing      yellowSolid      t t t t t )
  ( HIGHMETAL2   drawing      greenSolid       t t t t t )
  ( LOWMETAL2    drawing      blueSolid        t t t t t )
  ( POLY2        drawing      orangeSolidDe    t t t t t )
  ( SOI2         drawing      magentaSolidSp   t t t t t )
  ( PIMPLANT     drawing      purpleSolid    t t t t t )
  ( NIMPLANT     drawing      tanSolid  t t t t t )

  ( POLY1        net          yellowDashed     t t t t nil )
  ( POLY2        net          blueDashed       t t t t nil )
  ( LOWMETAL1    net          redDashed        t t t t nil )
  ( HIGHMETAL1   net          greenDashed      t t t t nil )
  ( LOWMETAL2    net          blueDashed       t t t t nil )
  ( HIGHMETAL2   net          purpleDashed     t t t t nil )
  ( SOI1         net          whiteDashed      t t t t nil )
  ( SOI2         net          magentaDashed    t t t t nil )

  ( POLY1        pin          yellowDashed     t t t t t )
  ( POLY2        pin          blueDashed       t t t t t )
  ( LOWMETAL1    pin          redDashed        t t t t t )
  ( HIGHMETAL1   pin          greenDashed      t t t t t )
  ( LOWMETAL2    pin          blueDashed       t t t t t )
  ( HIGHMETAL2   pin          purpleDashed     t t t t t )
  ( SOI1         pin          whiteDashed      t t t t t )
  ( SOI2         pin          magentaDashed    t t t t t )

  ( SOI1         resMarker    whiteSolidSp     t t t t t )
  ( POLY1        resMarker    redSolidDe       t t t t t )
  ( LOWMETAL1    resMarker    cyanSolid        t t t t t )
  ( HIGHMETAL1   resMarker    yellowSolid      t t t t t )
  ( HIGHMETAL2   resMarker    greenSolid       t t t t t )
  ( LOWMETAL2    resMarker    blueSolid        t t t t t )
  ( POLY2        resMarker    orangeSolidDe    t t t t t )
  ( SOI2         resMarker    magentaSolidSp   t t t t t )
  
 ) ;techDisplays

techLayerProperties(
;( PropName               Layer1 [ Layer2 ]       PropValue )
  ( sheetResistance       LOWMETAL1               0.0244  )
  ( sheetResistance       LOWMETAL2               0.0244  )
  ( sheetResistance       HIGHMETAL1              0.0244  )
  ( sheetResistance       HIGHMETAL2              0.0244  )
  ( sheetResistance       SOI1                    2.5     )
  ( sheetResistance       SOI2                    2.5     )
  ( sheetResistance       POLY1                   30      )
  ( sheetResistance       POLY2                   30      )
  ( sheetResistance       PIMPLANT                2.5     )
  ( sheetResistance       NIMPLANT                2.5     )
)


) ;layerDefinitions


;********************************
; LAYER RULES
;********************************

layerRules(
  functions(
    ;( layer          function         [maskNumber] )
    ;( -----          --------          ----------  )
    ( SOI1          "substrate"         1          )
    ( LOWMETAL1     "li"                3          )
    ( POLY1         "li"                4          )
    ( HIGHMETAL1    "li"                5          )
    ( HIGHMETAL2    "li"                6          )
    ( POLY2         "li"                8          )
    ( LOWMETAL2     "li"                9          )
    ( SOI2          "li"                10         )
    ( NIMPLANT      "li"                11         )
    ( PIMPLANT      "li"                12         )
    
    
  ) ;functions

  
  
  mfgResolutions(
    ( "LOWMETAL1" 0.05 )
    ( "LOWMETAL2" 0.05 )
    ( "HIGHMETAL1" 0.05 )
    ( "HIGHMETAL2" 0.05 )
    ( "POLY1"  0.01 )
    ( "POLY2"  0.01 )
    ( "SOI1"   0.01 )
    ( "SOI2"   0.01 )
    ;( "SOIHOLE1" 0.01 )
    ;( "SOIHOLE2" 0.01 )
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

      ( validLayers ( "SOI1" "POLY1" "LOWMETAL1" "HIGHMETAL1" "SOI2" "POLY2" "LOWMETAL2" "HIGHMETAL2")   )
      ( validVias ( "POLY1xHM1" "SOI1xLM1" "LM1xHM1" "HM1xHM2" "HM2xLM2" "LM2xSOI2" "HM2xPOLY2" ) )
      ( validPurposes 'include ("drawing" "net" "pin" "derivedCut") )
    );interconnect
  );virtuosoDefaultExtractorSetup
  ( "foundry"
      ; physical constraints
      spacings(
        ;( constraint     layer1     layer2     value )
        ;( ----------     ------     ------     ----- )
        ( minWidth       "LOWMETAL1"            2 )
        ( minWidth       "HIGHMETAL1"           2 )
        ( minWidth       "SOI1"                 2 )
        ( minWidth       "POLY1"                2 )
        ( minWidth       "LOWMETAL2"            2 )
        ( minWidth       "HIGHMETAL2"           2 )
        ( minWidth       "SOI2"                 2 )
        ( minWidth       "POLY2"                2 )

        ( minSpacing     "LOWMETAL1"            4 )
        ( minSpacing     "HIGHMETAL1"           4 )
        ( minSpacing     "SOI1"                 2 )
        ( minSpacing     "POLY1"                2 )
        ( minSpacing     "LOWMETAL2"            4 )
        ( minSpacing     "HIGHMETAL2"           4 )
        ( minSpacing     "SOI2"                 2 )
        ( minSpacing     "POLY2"                2 )

        ( minSpacing     "LOWMETAL1" "SOI1"      5 )
        ( minSpacing     "HIGHMETAL1" "SOI1"     5 )
        ( minSpacing     "LOWMETAL2" "SOI2"      5 )
        ( minSpacing     "HIGHMETAL2" "SOI2"     5 )
        
      );spacings

      orderedSpacings(
        ( minExtensionDistance "SOI1" "LOWMETAL1" 5 )
        ( minExtensionDistance "SOI1" "HIGHMETAL1" 5 )
        ( minExtensionDistance "SOI2" "LOWMETAL2" 5 )
        ( minExtensionDistance "SOI2" "HIGHMETAL2" 5 )

        ;( minSideSpacing "LOWMETAL1" "SOI1"     5 )
      );orderedSpacings
  );foundry
);constraintGroups
