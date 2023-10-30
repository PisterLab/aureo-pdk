from skillbridge import Workspace
from collections import Counter
from matplotlib.pyplot import pie,figure,title


# Workspace.fix_completion() #use this function for correct tab completion in jupyter-notebook

ws = Workspace.open()
cv = ws.ge.get_edit_cell_view()

def bbox_to_area(b_box):
    return (b_box[1][0]- b_box[0][0]) * (b_box[1][1] - b_box[0][1])

# Get a tuple of instance cellname and area
insts = [(inst.cell_name,bbox_to_area(inst.b_box)) for inst in cv.instances]

# Get a dictionary of cell_name and occurences
counts = Counter(name for name, _ in insts)

# create dictionary of cell_name and area
areas = {}

for name,area in insts:
    areas.setdefault(name,0)
    areas[name] += area

# plot the pie chart
f = figure(figsize=(12, 12))
sub1 = f.add_subplot(121)
sub1.set_title("Number of instances")
pie(counts.values(), labels = counts.keys())
sub1.set_title("Accumulated Area of each Cell")
pie(areas.values(), labels = areas.keys())
f.savefig('a_02_00.png')
print('DONE')
