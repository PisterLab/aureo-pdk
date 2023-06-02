import gdspy

# Load the GDSII file
gdsii = gdspy.GdsLibrary()
gdsii.read_gds('test.gds')

# Loop over all cells in the library
for name, cell in gdsii.cells.items():
    print(f"Cell name: {name}")

    # Loop over all polygons in the cell
    for polygon in cell.get_polygons():
        print(f"  Polygon with {len(polygon)} vertices")

# Access other elements in a cell like paths, references and text:
for name, cell in gdsii.cells.items():
    print(f"Cell name: {name}")

    # For paths:
    for element in cell:
        if isinstance(element, gdspy.Path):
            print(f"  Path with {len(element.polygons)} polygons")

    # For references:
    for element in cell:
        if isinstance(element, (gdspy.CellReference, gdspy.CellArray)):
            print(f"  Reference to {element.ref_cell.name}")

    # For labels:
    for element in cell:
        if isinstance(element, gdspy.Label):
            print(f"  Label: {element.text}")

# Create a set to store all layer numbers
layers = set()

# Loop over all cells in the library
for name, cell in gdsii.cells.items():
    # Loop over all elements in the cell
    for element in cell:
        layers.add(element.layers[0])

# Print all layer numbers
print(f"All layers in the file: {layers}")