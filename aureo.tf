
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
;( PropName               Layer1 [ Layer2 ]            PropValue )
)


) ;layerDefinitions


