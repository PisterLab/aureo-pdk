
procedure( show_adjacent_layers( bot_layer )
    let( (layer_1_name layer_2_name layer_3_name layer_4_name)
        cond(
            (bot_layer == 0
                layer_1_name = "PIMPLANT"
                layer_2_name = "NIMPLANT"
                layer_3_name = "SOI1"
                layer_4_name = "SOI1" ; Repeated intentionally
            )
            (bot_layer == 1
                layer_1_name = "SOI1"
                layer_2_name = "POLY1"
                layer_3_name = "LOWMETAL1"
                layer_4_name = "HIGHMETAL1"
            )
            (bot_layer == 2
                layer_1_name = "POLY1"
                layer_2_name = "HIGHMETAL1"
                layer_3_name = "HIGHMETAL2"
                layer_4_name = "POLY2"
            )
            (bot_layer == 3
                layer_1_name = "SOI2"
                layer_2_name = "POLY2"
                layer_3_name = "LOWMETAL2"
                layer_4_name = "HIGHMETAL2"
            )
        )
        
        leSetEntryLayer(list(layer_1_name "drawing"))
        leSetAllLayerVisible(nil)
        leSetLayerVisible(list(layer_1_name "drawing") t)
        leSetLayerVisible(list(layer_1_name "pin") t)
        leSetLayerVisible(list(layer_1_name "resID") t)
        leSetLayerVisible(list(layer_1_name "dummy") t)
        leSetLayerVisible(list(layer_1_name "fill") t)

        leSetLayerVisible(list(layer_2_name "drawing") t)
        leSetLayerVisible(list(layer_2_name "pin") t)
        leSetLayerVisible(list(layer_2_name "resID") t)
        leSetLayerVisible(list(layer_2_name "dummy") t)
        leSetLayerVisible(list(layer_2_name "fill") t)

        leSetLayerVisible(list(layer_3_name "drawing") t)
        leSetLayerVisible(list(layer_3_name "pin") t)
        leSetLayerVisible(list(layer_3_name "resID") t)
        leSetLayerVisible(list(layer_3_name "dummy") t)
        leSetLayerVisible(list(layer_3_name "fill") t)

        leSetLayerVisible(list(layer_4_name "drawing") t)
        leSetLayerVisible(list(layer_4_name "pin") t)
        leSetLayerVisible(list(layer_4_name "resID") t)
        leSetLayerVisible(list(layer_4_name "dummy") t)
        leSetLayerVisible(list(layer_4_name "fill") t)
        hiRedraw()
    )
)

procedure( toggle_implant_layer(  )
        
    layer_1_name = "PIMPLANT"
    layer_2_name = "NIMPLANT"

    leSetEntryLayer(list(layer_1_name "drawing"))
    leSetAllLayerVisible(nil)
    
    leSetLayerVisible(list(layer_1_name "drawing") t)
    leSetLayerVisible(list(layer_1_name "pin") t)
    leSetLayerVisible(list(layer_1_name "resID") t)
    leSetLayerVisible(list(layer_1_name "dummy") t)
    leSetLayerVisible(list(layer_1_name "fill") t)

    leSetLayerVisible(list(layer_2_name "drawing") t)
    leSetLayerVisible(list(layer_2_name "pin") t)
    leSetLayerVisible(list(layer_2_name "resID") t)
    leSetLayerVisible(list(layer_2_name "dummy") t)
    leSetLayerVisible(list(layer_2_name "fill") t)

    hiRedraw()
)


procedure( toggle_layer( layer_id )
    let( (layer_name )
        cond(
            (layer_id == 1
                layer_name = "SOI1"
            )
            (layer_id == 2
                layer_name = "POLY1"
            )
            (layer_id == 3
                layer_name = "LOWMETAL1"
            )
            (layer_id == 4
                layer_name = "HIGHMETAL1"
            )
            (layer_id == 5
                layer_name = "HIGHMETAL2"
            )
            (layer_id == 6
                layer_name = "LOWMETAL2"
            )
            (layer_id == 7
                layer_name = "POLY2"
            )
            (layer_id == 8
                layer_name = "SOI2"
            )
        )
        leSetEntryLayer(list(layer_name "drawing"))
        leSetAllLayerVisible(nil)

        res_layer = list(layer_name "resID")
        fl_layer = list(layer_name "fill")
        drw_layer = list(layer_name "drawing")
        pn_layer = list(layer_name "pin")
        dm_layer = list(layer_name "dummy")
        leSetLayerVisible(res_layer t)
        leSetLayerVisible(fl_layer t)
        leSetLayerVisible(drw_layer t)
        leSetLayerVisible(pn_layer t)
        leSetLayerVisible(dm_layer t)
        hiRedraw()
    )
)


hiSetBindKeys( "Layout" list(
    list("Ctrl<Key>q" "leSetAllLayerVisible(t) hiRedraw()")
    list("<Key>`" "show_adjacent_layers(0)")
    list("<Key>1" "show_adjacent_layers(1)")
    list("<Key>2" "show_adjacent_layers(2)")
    list("<Key>3" "show_adjacent_layers(3)")
    list("<Key>4" "show_adjacent_layers(4)")
    list("<Key>5" "show_adjacent_layers(5)")
    list("<Key>6" "show_adjacent_layers(6)")
    list("<Key>7" "show_adjacent_layers(7)")
    list("<Key>8" "show_adjacent_layers(8)")
    list("Ctrl<Key>`" "toggle_implant_layer()")
    list("Ctrl<Key>1" "toggle_layer(1)")
    list("Ctrl<Key>2" "toggle_layer(2)")
    list("Ctrl<Key>3" "toggle_layer(3)")
    list("Ctrl<Key>4" "toggle_layer(4)")
    list("Ctrl<Key>5" "toggle_layer(5)")
    list("Ctrl<Key>6" "toggle_layer(6)")
    list("Ctrl<Key>7" "toggle_layer(7)")
    list("Ctrl<Key>8" "toggle_layer(8)")
    list("Ctrl<Key>9" "toggle_layer(9)")
))
