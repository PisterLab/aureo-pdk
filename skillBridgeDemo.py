from skillbridge import Workspace

ws = Workspace.open()

cell_view = ws.ge.get_edit_cell_view()

print(cell_view.b_box)

cv = cell_view

for n in range(40):
    ws.rod.create_path(cv_id=cv, layer=["SOI1", "drawing"], width=0.08, pts=[[0.125 * n, 0], [0.125 * n, 5]])
    ws.rod.create_path(cv_id=cv, layer=["SOI1", "drawing"], width=0.08, pts=[[0, 0.125 * n], [5, 0.125 * n]])

# Redraw the layout window
ws.hi.redraw()