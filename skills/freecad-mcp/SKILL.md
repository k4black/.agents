---
name: freecad-mcp
description: >
  Create, edit, inspect, and export FreeCAD models through MCP or Python macros.
  Use for FreeCAD documents, CAD mechanisms, geometry failures, and mesh exports for 3D printing.
---

# FreeCAD MCP

## Select the source

- Inspect open documents, `FileName`, body names, `Body.Tip`, and placements before edits or exports.
- Use the user's edited document and final body features. An earlier generator cannot reproduce later manual edits.
- After a file move or rename, update the open document's `FileName`. Preserve unsaved edits and existing destination files.
- Record measurement references: mouth width, maximum body width, edge distance, and clearance are different dimensions.

## Execute safely

- Use `execute_code` for ordinary document and GUI changes. Keep intermediate calls free of screenshots unless visual feedback helps.
- Put automation inside named functions. MCP calls share persistent variables, so unrelated calls can overwrite global names.
- Use `execute_code_headless` for expensive or unstable booleans, sweeps, and fillets that can block or crash FreeCAD.
- Async workers must use `commit()` for document or GUI access. Independent geometry computation can run outside the GUI thread.
- On timeout, inspect `get_rpc_status` before retrying. A queued timeout cancels that call. A started operation can continue.
- For blocked navigation, ask the user to release mouse buttons or close the reported dialog. Do not restart a healthy GUI.

## Build and verify

- Keep one generation macro for generated models. A rerun must not overwrite the user's edited document.
- Use sketches and constraints when the user expects dimension edits. Label descriptive properties when they do not drive geometry.
- Keep assembly placements separate from each part's local geometry. Move wall holes, fasteners, and mating holes together.
- Check `Shape.isValid()` and the expected solid count after structural changes.
- Check wall thickness, support connections, and material around fastener recesses. A valid solid does not prove structural strength.
- Constrain relief cutters to the intended region. A rear-wall cut can also split adjacent side walls.
- Check both solid intersections and minimum distances. Sample the requested motion, including closed position, opening extremes, and the stop.
- Distinguish intended thread engagement or stop contact from unwanted interference. Zero overlap alone does not prove positive clearance.
- Compare regenerated parts with the reference geometry before claiming that a consolidated macro reproduces the model.
- Recalculate measuring cavities after inner-edge changes. Fillets and chamfers can change capacity.
- Apply edge treatments after the mechanism works. If the user requests removal, inspect inherited features from earlier revisions too.

## Export for printing

- Export the finished `Body.Tip.Shape`, including the user's latest pads, fillets, and chamfers.
- Copy the shape before export. Remove assembly orientation only when the task requires a separate print orientation.
- Mesh with `MeshPart.meshFromShape`. Tested starting values are `LinearDeflection=0.05`, `AngularDeflection=math.radians(10)`, and `Relative=False`.
- Check `mesh.isSolid()`. Compare mesh volume with CAD volume using a tolerance appropriate to the part.
- Center the mesh in XY and place its lowest vertex at Z=0 when the user requests separate printable parts.
- Use the resulting mesh bounds for placement. CAD bounds can differ from tessellated bounds, especially after fillets.
- OBJ coordinates do not declare units. Export millimeter coordinates and identify the units in the handoff or file comments.
- Save the edited FCStd to the agreed path. Export only the requested parts and filenames.

## Primary references

- [MCP execution modes and timeout recovery](https://github.com/neka-nat/freecad-mcp/blob/main/docs/execution.md)
- [MCP tool reference](https://github.com/neka-nat/freecad-mcp/blob/main/docs/tools.md)
- [FreeCAD MeshPart signatures](https://github.com/FreeCAD/FreeCAD/blob/main/src/Mod/MeshPart/App/AppMeshPartPy.cpp)
- [FreeCAD source and Python API](https://github.com/FreeCAD/FreeCAD)

Check the installed FreeCAD and addon versions against the linked documentation before using unfamiliar APIs.
