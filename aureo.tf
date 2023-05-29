
;********************************
; LAYER DEFINITION
;********************************
layerDefinitions(

 techPurposes(
 ;( PurposeName               Purpose#   Abbreviation )
 ;( -----------               --------   ------------ )
  ( drawing                   252        drw          )
  ( net                       253        net          )
 ) ;techPurposes

 techLayers(
 ;( LayerName                 Layer#     Abbreviation )
 ;( ---------                 ------     ------------ )
 ;User-Defined Layers:
  ( S1                        1          S1           )
  ( P1                        2          P1           )
  ( M1                        3          M1           )
  ( M2                        6          M2           )
  ( P2                        9          P2           )
  ( S2                        10         S2           )
 ) ;techLayers

 techLayerPurposePriorities(
 ;layers are ordered from lowest to highest priority
 ;( LayerName                 Purpose    )
 ;( ---------                 -------    )
  ( S2                        drawing    )
  ( P2                        drawing    )
  ( M2                        drawing    )
  ( M1                        drawing    )
  ( P1                        drawing    )
  ( S1                        drawing    )
  ( P1                        net        )
  ( P2                        net        )
  ( M1                        net        )
  ( M2                        net        )
 ) ;techLayerPurposePriorities

 techDisplays(
 ;( LayerName    Purpose      Packet          Vis Sel Con2ChgLy DrgEnbl Valid)
 ;( ---------    -------      ------          --- --- --------- ------- -----)
  ( S1           drawing      S1               t t t t t )
  ( P1           drawing      P1               t t t t t )
  ( M1           drawing      M1               t t t t t )
  ( M2           drawing      M2               t t t t t )
  ( P2           drawing      P2               t t t t t )
  ( S2           drawing      S2               t t t t t )
  ( P1           net          P1net            t t t t nil )
  ( P2           net          P2net            t t t t nil )
  ( M1           net          M1net            t t t t nil )
  ( M2           net          M2net            t t t t nil )
 ) ;techDisplays

techLayerProperties(
;( PropName               Layer1 [ Layer2 ]            PropValue )
)

) ;layerDefinitions


