
(defun split_soi ()
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


(defun merge_soi ()
; Merges the SOI1 and SOI2 layers by performing an OR operation on the layers
; and using the result as the new SOI1 and SOI2 layers
    cv = geGetEditCellView()
    abeInit(cv)
    a2 = abeLayerFromCellView("SOI1")
    a3 = abeNewLayer()
    abeLayerOr(a2 a3)
    foreach(object setof(shapes cv~>shapes shapes~>layerName == "SOI1")
        dbDeleteObject(object))
    abeLayerToCellView(a3 "SOI1")

    a4 = abeLayerFromCellView("SOI2")
    a5 = abeNewLayer()
    abeLayerOr(a4 a5)
    foreach(object setof(shapes cv~>shapes shapes~>layerName == "SOI2")
        dbDeleteObject(object))
    abeLayerToCellView(a5 "SOI2")

    abeDone()    
)


procedure( pcCFfingerl( )
  prog(()
    if( (cdfgData->maskLayoutViewName->value == 
            cdfgData->maskLayoutViewName->defValue) 
                 ; Do this only if maskLayoutViewName is 
                 ; layout. Otherwise, mosLayout sets it.
    then
        tmp = cdfgData->Finger_Length->value
        if( (tmp < cdfgData->Finger_Length->defValue)
        then
            error("Finger length value is less than 
                 minimum (4u). Set to default." )
            cdfgData->Finger_Length->value = cdfgData->Finger_Length->defValue
            return(nil)
        )
        
        grid = round(tmp/0.1)
        newwidth = grid*0.10
        if( (newwidth != tmp)
        then
                error("Finger Length is set to nearest value 
                    on 0.10 micron pitch.")
                cdfgData->Finger_Length->value = (newwidth * 1e-6)
        )
        c_float = cdfgData->Multiplier->value * ((((tmp * 1e-6) - (2 * cdfgData->End_Gap->value * 1e-6)) * 40e-6) / (cdfgData->Finger_Gap->value * 1e-6)) * 8.85e-12
        cdfgData->C->value = sprintf(s "%g" c_float)
    )
  )
)

procedure( pcCFmult( )
  prog(()
    if( (cdfgData->maskLayoutViewName->value == 
            cdfgData->maskLayoutViewName->defValue) 
                 ; Do this only if maskLayoutViewName is 
                 ; layout. Otherwise, mosLayout sets it.
    then
        tmp = cdfgData->Multiplier->value
        if( (tmp < cdfgData->Multiplier->defValue)
        then
            error("Multiplier value is less than 
                 minimum (1). Set to default." )
            cdfgData->Multiplier->value = cdfgData->Multiplier->defValue
            return(nil)
        )
        
        
        c_float = tmp * ((((cdfgData->Finger_Length->value * 1e-6) - (2 * cdfgData->End_Gap->value * 1e-6)) * 40e-6) / (cdfgData->Finger_Gap->value * 1e-6)) * 8.85e-12
        cdfgData->C->value = sprintf(s "%g" c_float)
    )
  )
)


procedure( pcSpringL( )
  prog(()

    k_float = 170e9 * cdfgData->Width->value * cdfgData->Width->value * cdfgData->Width->value * 40e-6 / (4* cdfgData->Length->value * cdfgData->Length->value * cdfgData->Length->value)

    cdfgData->K->value = sprintf(s "%g" k_float)

  )

)

 

procedure( pcSpringW( )
  prog(()

    k_float = 170e9 * cdfgData->Width->value * cdfgData->Width->value * cdfgData->Width->value * 40e-6 / (4* cdfgData->Length->value * cdfgData->Length->value * cdfgData->Length->value)

        cdfgData->K->value = sprintf(s "%g" k_float)

  )

)


procedure( pcSerpSpringL( )
  prog(()

    k_float = 170e9 * cdfgData->Width->value * cdfgData->Width->value * cdfgData->Width->value * 40e-6 / (4 * 4 * cdfgData->Length->value * cdfgData->Length->value * cdfgData->Length->value)

    cdfgData->K->value = sprintf(s "%g" k_float)

  )

)

 

procedure( pcSerpSpringW( )
  prog(()

    k_float = 170e9 * cdfgData->Width->value * cdfgData->Width->value * cdfgData->Width->value * 40e-6 / (4 * 4 * cdfgData->Length->value * cdfgData->Length->value * cdfgData->Length->value)

        cdfgData->K->value = sprintf(s "%g" k_float)

  )

)

procedure( pcInchFlip( )
  prog(()
    if( (cdfgData->flip->value == t)
	then 
           cdfgData->SOI1?->value = sprintf(s "%s" "SOI2")
           cdfgData->SOI2?->value = sprintf(s "%s" "SOI1")
           
		   ;cdfgData->POLY1?->value = "POLY2"
           ;cdfgData->POLY2?->value = "POLY1"
           ;cdfgData->HM1?->value = "HM2"
           ;cdfgData->HM2?->value = "HM1"
           ;cdfgData->LM1?->value = "LM2"
           ;cdfgData->LM2?->value = "LM1"  
    )
	if( (cdfgData->flip->value == nil)
	then 
           cdfgData->SOI1?->value = "SOI1"
           cdfgData->SOI2?->value = "SOI2"
	)
  )
)

procedure( pcContactFlip( )
  prog(()
    if( (cdfgData->flip->value == t)
	then 
           cdfgData->SOI1?->value = sprintf(s "%s" "SOI2")
           cdfgData->SOI2?->value = sprintf(s "%s" "SOI1")
		   cdfgData->POLY1?->value = sprintf(s "%s" "POLY2")
           cdfgData->POLY2?->value = sprintf(s "%s" "POLY1")
           cdfgData->HM1?->value = sprintf(s "%s" "HM2")
           cdfgData->HM2?->value = sprintf(s "%s" "HM1")
    )
	if( (cdfgData->flip->value == nil)
	then 
           cdfgData->SOI1?->value = "SOI1"
           cdfgData->SOI2?->value = "SOI2"
           cdfgData->POLY1?->value = "POLY1"
           cdfgData->POLY2?->value = "POLY2"
           cdfgData->HM1?->value = "HM1"
           cdfgData->HM2?->value = "HM2"
         
	)
  )
)




