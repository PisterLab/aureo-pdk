
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
  ( resID                     14         resID        )
  ( dummy                     15         dummy        )
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
  ( SOIHOLE1                  drawing    )
  ( NIMPLANT                  drawing    )
  ( PIMPLANT                  drawing    )
  ( POLY1                     drawing    )
  ( LOWMETAL1                 drawing    )
  ( HIGHMETAL1                drawing    )
  ( SOI2                      drawing    )
  ( SOIHOLE2                  drawing    )
  ( POLY2                     drawing    )
  ( LOWMETAL2                 drawing    )
  ( HIGHMETAL2                drawing    )
  ( BOUNDARY                  drawing    )

  ( SOI1                      net        )
  ( NIMPLANT                  net        )
  ( PIMPLANT                  net        )
  ( POLY1                     net        )
  ( LOWMETAL1                 net        )
  ( HIGHMETAL1                net        )
  ( SOI2                      net        )
  ( POLY2                     net        )
  ( LOWMETAL2                 net        )
  ( HIGHMETAL2                net        )
  ( BOUNDARY                  net        )

  ( SOI1                      pin        )
  ( NIMPLANT                  pin        )
  ( PIMPLANT                  pin        )
  ( POLY1                     pin        )
  ( LOWMETAL1                 pin        )
  ( HIGHMETAL1                pin        )
  ( SOI2                      pin        )
  ( POLY2                     pin        )
  ( LOWMETAL2                 pin        )
  ( HIGHMETAL2                pin        )
  ( BOUNDARY                  pin        )

  ( SOI1                      resID      )
  ( NIMPLANT                  resID      )
  ( PIMPLANT                  resID      )
  ( POLY1                     resID      )
  ( LOWMETAL1                 resID      )
  ( HIGHMETAL1                resID      )
  ( SOI2                      resID      )
  ( POLY2                     resID      )
  ( LOWMETAL2                 resID      )
  ( HIGHMETAL2                resID      )
  ( BOUNDARY                  resID      )

  ( SOI1                      dummy      )
  ( NIMPLANT                  dummy      )
  ( PIMPLANT                  dummy      )
  ( POLY1                     dummy      )
  ( LOWMETAL1                 dummy      )
  ( HIGHMETAL1                dummy      )
  ( SOI2                      dummy      )
  ( POLY2                     dummy      )
  ( LOWMETAL2                 dummy      )
  ( HIGHMETAL2                dummy      )
  ( BOUNDARY                  dummy      )

  ( SOI1                      fill       )
  ( NIMPLANT                  fill       )
  ( PIMPLANT                  fill       )
  ( POLY1                     fill       )
  ( LOWMETAL1                 fill       )
  ( HIGHMETAL1                fill       )
  ( SOI2                      fill       )
  ( POLY2                     fill       )
  ( LOWMETAL2                 fill       )
  ( HIGHMETAL2                fill       )
  ( BOUNDARY                  fill       )
 ) ;techLayerPurposePriorities


 techDisplays(
 ;( LayerName    Purpose      Packet          Vis Sel Con2ChgLy DrgEnbl Valid)
 ;( ---------    -------      ------          --- --- --------- ------- -----)

  ( SOI1         drawing      whiteSolid     t t t t t )
  ( SOIHOLE1     drawing      graySolid      t t t t t )
  ( NIMPLANT     drawing      tanSolid       t t t t t )
  ( PIMPLANT     drawing      purpleSolid    t t t t t )
  ( POLY1        drawing      redSolid       t t t t t )
  ( LOWMETAL1    drawing      cyanSolidSp    t t t t t )
  ( HIGHMETAL1   drawing      yellowSolidSp  t t t t t )
  ( LOWMETAL2    drawing      blueSolidSp    t t t t t )
  ( HIGHMETAL2   drawing      greenSolidSp   t t t t t )
  ( POLY2        drawing      orangeSolid    t t t t t )
  ( SOI2         drawing      skyBlueSolid   t t t t t )
  ( SOIHOLE2     drawing      brownSolid     t t t t t )

  ( SOI1         fill         whiteSolid     t t t t t )
  ( NIMPLANT     fill         tanSolid       t t t t t )
  ( PIMPLANT     fill         purpleSolid    t t t t t )
  ( POLY1        fill         redSolid       t t t t t )
  ( LOWMETAL1    fill         cyanSolidSp    t t t t t )
  ( HIGHMETAL1   fill         yellowSolidSp  t t t t t )
  ( LOWMETAL2    fill         blueSolidSp    t t t t t )
  ( HIGHMETAL2   fill         greenSolidSp   t t t t t )
  ( POLY2        fill         orangeSolid    t t t t t )
  ( SOI2         fill         skyBlueSolid   t t t t t )

  ( SOI1         dummy        whiteSolid     t t t t t )
  ( NIMPLANT     dummy        tanSolid       t t t t t )
  ( PIMPLANT     dummy        purpleSolid    t t t t t )
  ( POLY1        dummy        redSolid       t t t t t )
  ( LOWMETAL1    dummy        cyanSolidSp    t t t t t )
  ( HIGHMETAL1   dummy        yellowSolidSp  t t t t t )
  ( LOWMETAL2    dummy        blueSolidSp    t t t t t )
  ( HIGHMETAL2   dummy        greenSolidSp   t t t t t )
  ( POLY2        dummy        orangeSolid    t t t t t )
  ( SOI2         dummy        skyBlueSolid   t t t t t )

  ( SOI1         net          whiteDashed     t t t t nil )
  ( NIMPLANT     net          tanDashed       t t t t nil )
  ( PIMPLANT     net          purpleDashed    t t t t nil )
  ( POLY1        net          redDashed       t t t t nil )
  ( LOWMETAL1    net          cyanDashed      t t t t nil )
  ( HIGHMETAL1   net          yellowDashed    t t t t nil )
  ( LOWMETAL2    net          blueDashed      t t t t nil )
  ( HIGHMETAL2   net          greenDashed     t t t t nil )
  ( POLY2        net          orangeDashed    t t t t nil )
  ( SOI2         net          skyBlueDashed   t t t t nil )

  ( SOI1         pin          whiteSolid3Sp    t t t t t )
  ( NIMPLANT     pin          tanSolid3Sp       t t t t t )
  ( PIMPLANT     pin          purpleSolid3Sp    t t t t t )
  ( POLY1        pin          redSolid3       t t t t t )
  ( LOWMETAL1    pin          cyanSolid3Sp      t t t t t )
  ( HIGHMETAL1   pin          yellowSolid3Sp    t t t t t )
  ( LOWMETAL2    pin          blueSolid3Sp     t t t t t )
  ( HIGHMETAL2   pin          greenSolid3Sp     t t t t t )
  ( POLY2        pin          orangeSolid3Sp    t t t t t )
  ( SOI2         pin          skyBlueSolid3Sp  t t t t t )

  ( SOI1         resID        whiteSolid       t t t t t )
  ( NIMPLANT     resID        tanSolid         t t t t t )
  ( PIMPLANT     resID        purpleSolid      t t t t t )
  ( POLY1        resID        redSolid         t t t t t )
  ( LOWMETAL1    resID        cyanSolidSp      t t t t t )
  ( HIGHMETAL1   resID        yellowSolidSp    t t t t t )
  ( LOWMETAL2    resID        blueSolidSp      t t t t t )
  ( HIGHMETAL2   resID        greenSolidSp     t t t t t )
  ( POLY2        resID        orangeSolid      t t t t t )
  ( SOI2         resID        skyBlueSolid     t t t t t )
  
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
