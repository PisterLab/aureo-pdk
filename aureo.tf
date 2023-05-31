
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
  ( SOI1                      1          S1           )
  ( POLY1                     2          P1           )
  ( METAL1                    3          M1           )
  ( METAL2                    6          M2           )
  ( POLY2                     9          P2           )
  ( SOI2                      10         S2           )
 ) ;techLayers

 techDerivedLayers(
  ;( t_derivedLayerName       x_derivedLayerNum   (tx_layer1 s_op tx_layer2) )
  ( SOI1_POLY1                100                 (SOI1 'and POLY1) )
  ( POLY1_METAL1              101                 (POLY1 'and METAL1) )
  ( METAL1_METAL2             102                 (METAL1 'and METAL2) )
  ( METAL2_POLY2              103                 (METAL2 'and POLY2) )
  ( POLY2_SOI2                104                 (POLY2 'and SOI2) )
 )

 techLayerPurposePriorities(
 ;layers are ordered from lowest to highest priority
 ;( LayerName                 Purpose    )
 ;( ---------                 -------    )
  ( SOI1                      drawing    ) 
  ( POLY1                     drawing    )
  ( METAL1                    drawing    )
  ( METAL2                    drawing    )
  ( POLY2                     drawing    )
  ( SOI2                      drawing    )
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
    ( POLY1         "li"               2          )
    ( METAL1        "padmetal"         3          )
    ( METAL2        "padmetal"         4          )
    ( POLY2         "li"               5          )
    ( SOI2          "substrate"        6          )
    
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
; VIA DEFINITIONS
;********************************

viaDefs(
  standardViaDefs(
    ;(t_viaDefName    tx_layer1   tx_layer2 cutLayer )
    ( SOI1xPOLY1      SOI1        POLY1     ( "POLY1"   1.0   1.0 ) 
      ( 1 1 ( 0.0 0.0 ) )
      ( 0.5 0.5 ) ( 0.5 0.5 )  ( 0.0 0.0 ) ( 0.0 0.0 ) ( 0.0 0.0 )
    )
    ( POLY1xMETAL1    POLY1       METAL1    ( "METAL1" 1.0   1.0 )
      ( 1 1 ( 0.0 0.0 ) )
      ( 0.5 0.5 ) ( 0.5 0.5 )  ( 0.0 0.0 ) ( 0.0 0.0 ) ( 0.0 0.0 )
    )
    ( METAL1xMETAL2   METAL1      METAL2    ( "METAL2" 1.0   1.0 )
      ( 1 1 ( 0.0 0.0 ) )
      ( 0.5 0.5 ) ( 0.5 0.5 )  ( 0.0 0.0 ) ( 0.0 0.0 ) ( 0.0 0.0 )
    )
    ( METAL2xPOLY2    METAL2      POLY2     ( "METAL2" 1.0   1.0 )
      ( 1 1 ( 0.0 0.0 ) )
      ( 0.5 0.5 ) ( 0.5 0.5 )  ( 0.0 0.0 ) ( 0.0 0.0 ) ( 0.0 0.0 )
    )
    ( POLY2xSOI2      POLY2       SOI2      ( "POLY2" 1.0   1.0 )
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
      ( validLayers ( "SOI1" "POLY1" "METAL1" "SOI2" "POLY2" "METAL2" )   )
      ( validVias ( "SOI1xPOLY1" "POLY1xMETAL1" "METAL1xMETAL2" "METAL2xPOLY2" "POLY2xSOI2" ) )
      ( validPurposes 'include ("drawing" "net" "derivedCut") )
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