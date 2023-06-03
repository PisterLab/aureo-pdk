
(defun soi_split ()
; Splits the SOI1 and SOI2 layers up by performing a NOT operation 
; between SOI1 and SOIHOLE1 and using the result as the new SOI1 layer.
    cv = geGetEditCellView()
    abeInit(cv)
    a2 = abeLayerFromCellView("SOI1")
    a3 = abeLayerFromCellView("SOIHOLE1")
    a4 = abeNewLayer()
    ;a4 = abeLayerFromCellView("SOI2")
    abeLayerAndNot(a2 a3 a4)
    foreach(object setof(shapes cv~>shapes shapes~>layerName == "SOI1")
        dbDeleteObject(object))
    abeLayerToCellView(a4 "SOI1")

    a5 = abeLayerFromCellView("SOI2")
    a6 = abeLayerFromCellView("SOIHOLE2")
    a7 = abeNewLayer()
    abeLayerAndNot(a5 a6 a7)
    foreach(object setof(shapes cv~>shapes shapes~>layerName == "SOI2")
        dbDeleteObject(object))
    abeLayerToCellView(a7 "SOI2")

    abeDone()    
)


