'# MWS Version: Version 2024.0 - Sep 01 2023 - ACIS 33.0.1 -

'# length = mm
'# frequency = GHz
'# time = ns
'# frequency range: fmin = 1 fmax = 50
'# created = '[VERSION]2024.0|33.0.1|20230901[/VERSION]


'@ use template: Antenna - Planar_5.cfg

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
'set the units
With Units
    .SetUnit "Length", "mm"
    .SetUnit "Frequency", "GHz"
    .SetUnit "Voltage", "V"
    .SetUnit "Resistance", "Ohm"
    .SetUnit "Inductance", "nH"
    .SetUnit "Temperature",  "degC"
    .SetUnit "Time", "ns"
    .SetUnit "Current", "A"
    .SetUnit "Conductance", "S"
    .SetUnit "Capacitance", "pF"
End With

ThermalSolver.AmbientTemperature "0"

'----------------------------------------------------------------------------

'set the frequency range
Solver.FrequencyRange "20", "50"

'----------------------------------------------------------------------------

Plot.DrawBox True

With Background
     .Type "Normal"
     .Epsilon "1.0"
     .Mu "1.0"
     .XminSpace "0.0"
     .XmaxSpace "0.0"
     .YminSpace "0.0"
     .YmaxSpace "0.0"
     .ZminSpace "0.0"
     .ZmaxSpace "0.0"
End With

With Boundary
     .Xmin "expanded open"
     .Xmax "expanded open"
     .Ymin "expanded open"
     .Ymax "expanded open"
     .Zmin "expanded open"
     .Zmax "expanded open"
     .Xsymmetry "none"
     .Ysymmetry "none"
     .Zsymmetry "none"
End With

' optimize mesh settings for planar structures

With Mesh
     .MergeThinPECLayerFixpoints "True"
     .RatioLimit "20"
     .AutomeshRefineAtPecLines "True", "6"
     .FPBAAvoidNonRegUnite "True"
     .ConsiderSpaceForLowerMeshLimit "False"
     .MinimumStepNumber "5"
     .AnisotropicCurvatureRefinement "True"
     .AnisotropicCurvatureRefinementFSM "True"
End With

With MeshSettings
     .SetMeshType "Hex"
     .Set "RatioLimitGeometry", "20"
     .Set "EdgeRefinementOn", "1"
     .Set "EdgeRefinementRatio", "6"
End With

With MeshSettings
     .SetMeshType "HexTLM"
     .Set "RatioLimitGeometry", "20"
End With

With MeshSettings
     .SetMeshType "Tet"
     .Set "VolMeshGradation", "1.5"
     .Set "SrfMeshGradation", "1.5"
End With

' change mesh adaption scheme to energy
' 		(planar structures tend to store high energy
'     	 locally at edges rather than globally in volume)

MeshAdaption3D.SetAdaptionStrategy "Energy"

' switch on FD-TET setting for accurate farfields

FDSolver.ExtrudeOpenBC "True"

PostProcess1D.ActivateOperation "vswr", "true"
PostProcess1D.ActivateOperation "yz-matrices", "true"

With FarfieldPlot
	.ClearCuts ' lateral=phi, polar=theta
	.AddCut "lateral", "0", "1"
	.AddCut "lateral", "90", "1"
	.AddCut "polar", "90", "1"
End With

'----------------------------------------------------------------------------

Dim sDefineAt As String
sDefineAt = "28"
Dim sDefineAtName As String
sDefineAtName = "28"
Dim sDefineAtToken As String
sDefineAtToken = "f="
Dim aFreq() As String
aFreq = Split(sDefineAt, ";")
Dim aNames() As String
aNames = Split(sDefineAtName, ";")

Dim nIndex As Integer
For nIndex = LBound(aFreq) To UBound(aFreq)

Dim zz_val As String
zz_val = aFreq (nIndex)
Dim zz_name As String
zz_name = sDefineAtToken & aNames (nIndex)

' Define E-Field Monitors
With Monitor
    .Reset
    .Name "e-field ("& zz_name &")"
    .Dimension "Volume"
    .Domain "Frequency"
    .FieldType "Efield"
    .MonitorValue  zz_val
    .Create
End With

' Define H-Field Monitors
With Monitor
    .Reset
    .Name "h-field ("& zz_name &")"
    .Dimension "Volume"
    .Domain "Frequency"
    .FieldType "Hfield"
    .MonitorValue  zz_val
    .Create
End With

' Define Farfield Monitors
With Monitor
    .Reset
    .Name "farfield ("& zz_name &")"
    .Domain "Frequency"
    .FieldType "Farfield"
    .MonitorValue  zz_val
    .ExportFarfieldSource "False"
    .Create
End With

Next

'----------------------------------------------------------------------------

With MeshSettings
     .SetMeshType "Hex"
     .Set "Version", 1%
End With

With Mesh
     .MeshType "PBA"
End With

'set the solver type
ChangeSolverType("HF Time Domain")

'----------------------------------------------------------------------------

'@ activate local coordinates

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.ActivateWCS "local"

'@ define material: FR-4 (lossy)

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Material
     .Reset
     .Name "FR-4 (lossy)"
     .Folder ""
     .FrqType "all"
     .Type "Normal"
     .SetMaterialUnit "GHz", "mm"
     .Epsilon "4.3"
     .Mu "1.0"
     .Kappa "0.0"
     .TanD "0.025"
     .TanDFreq "10.0"
     .TanDGiven "True"
     .TanDModel "ConstTanD"
     .KappaM "0.0"
     .TanDM "0.0"
     .TanDMFreq "0.0"
     .TanDMGiven "False"
     .TanDMModel "ConstKappa"
     .DispModelEps "None"
     .DispModelMu "None"
     .DispersiveFittingSchemeEps "General 1st"
     .DispersiveFittingSchemeMu "General 1st"
     .UseGeneralDispersionEps "False"
     .UseGeneralDispersionMu "False"
     .Rho "0.0"
     .ThermalType "Normal"
     .ThermalConductivity "0.3"
     .SetActiveMaterial "all"
     .Colour "0.94", "0.82", "0.76"
     .Wireframe "False"
     .Transparency "0"
     .Create
End With

'@ new component: component1

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Component.New "component1"

'@ define brick: component1:SUNBSTRATE

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Brick
     .Reset 
     .Name "SUNBSTRATE" 
     .Component "component1" 
     .Material "FR-4 (lossy)" 
     .Xrange "-SL/2", "SL/2" 
     .Yrange "-SW/2", "SW/2" 
     .Zrange "-SH", "0" 
     .Create
End With

'@ move wcs

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.MoveWCS "local", "0.0", "0.0", "-SH"

'@ define material: Copper (annealed)

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Material
     .Reset
     .Name "Copper (annealed)"
     .Folder ""
     .FrqType "static"
     .Type "Normal"
     .SetMaterialUnit "Hz", "mm"
     .Epsilon "1"
     .Mu "1.0"
     .Kappa "5.8e+007"
     .TanD "0.0"
     .TanDFreq "0.0"
     .TanDGiven "False"
     .TanDModel "ConstTanD"
     .KappaM "0"
     .TanDM "0.0"
     .TanDMFreq "0.0"
     .TanDMGiven "False"
     .TanDMModel "ConstTanD"
     .DispModelEps "None"
     .DispModelMu "None"
     .DispersiveFittingSchemeEps "Nth Order"
     .DispersiveFittingSchemeMu "Nth Order"
     .UseGeneralDispersionEps "False"
     .UseGeneralDispersionMu "False"
     .FrqType "all"
     .Type "Lossy metal"
     .SetMaterialUnit "GHz", "mm"
     .Mu "1.0"
     .Kappa "5.8e+007"
     .Rho "8930.0"
     .ThermalType "Normal"
     .ThermalConductivity "401.0"
     .SpecificHeat "390", "J/K/kg"
     .MetabolicRate "0"
     .BloodFlow "0"
     .VoxelConvection "0"
     .MechanicsType "Isotropic"
     .YoungsModulus "120"
     .PoissonsRatio "0.33"
     .ThermalExpansionRate "17"
     .Colour "1", "1", "0"
     .Wireframe "False"
     .Reflection "False"
     .Allowoutline "True"
     .Transparentoutline "False"
     .Transparency "0"
     .Create
End With

'@ define brick: component1:GROUND

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Brick
     .Reset 
     .Name "GROUND" 
     .Component "component1" 
     .Material "Copper (annealed)" 
     .Xrange "-SL/2", "SL/2" 
     .Yrange "-SW/2", "SW/2" 
     .Zrange "-mt", "0" 
     .Create
End With

'@ pick face

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.PickFaceFromId "component1:SUNBSTRATE", "1"

'@ align wcs with face

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.AlignWCSWithSelected "Face"

'@ define brick: component1:PATCH

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Brick
     .Reset 
     .Name "PATCH" 
     .Component "component1" 
     .Material "Copper (annealed)" 
     .Xrange "-PL/2-ML", "PL/2" 
     .Yrange "-PW/2", "PW/2" 
     .Zrange "0", "mt" 
     .Create
End With

'@ pick end point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.PickEndpointFromId "component1:PATCH", "4"

'@ align wcs with point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.AlignWCSWithSelected "Point"

'@ define brick: component1:CUT1

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Brick
     .Reset 
     .Name "CUT1" 
     .Component "component1" 
     .Material "Vacuum" 
     .Xrange "0", "ML" 
     .Yrange "0", "PW/2-MW/2" 
     .Zrange "-mt", "0" 
     .Create
End With

'@ boolean subtract shapes: component1:PATCH, component1:CUT1

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Subtract "component1:PATCH", "component1:CUT1"

'@ pick end point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.PickEndpointFromId "component1:PATCH", "11"

'@ align wcs with point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.AlignWCSWithSelected "Point"

'@ define brick: component1:CUT2

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Brick
     .Reset 
     .Name "CUT2" 
     .Component "component1" 
     .Material "Vacuum" 
     .Xrange "0", "ML" 
     .Yrange "-PW/2+MW/2", "0" 
     .Zrange "-mt", "0" 
     .Create
End With

'@ boolean subtract shapes: component1:PATCH, component1:CUT2

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Subtract "component1:PATCH", "component1:CUT2"

'@ activate global coordinates

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.ActivateWCS "global"

'@ align wcs with face

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.ForceNextPick 
Pick.PickFaceFromId "component1:SUNBSTRATE", "1" 
WCS.AlignWCSWithSelected "Face"

'@ define extrude: component1:solid1

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Extrude 
     .Reset 
     .Name "solid1" 
     .Component "component1" 
     .Material "Vacuum" 
     .Mode "Pointlist" 
     .Height "0.0" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "0.0" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "-PL/2", "-PW/2" 
     .LineTo "-PL/2", "-PW/2+1.1" 
     .LineTo "0", "-PW/2" 
     .Create 
End With

'@ define extrude: component1:solid2

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Extrude 
     .Reset 
     .Name "solid2" 
     .Component "component1" 
     .Material "Vacuum" 
     .Mode "Pointlist" 
     .Height "0.025" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "-mt" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "-PL/2", "-PW/2" 
     .LineTo "-PL/2", "-PW/2+1.1" 
     .LineTo "0", "-PW/2" 
     .Create 
End With

'@ delete shape: component1:solid1

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Delete "component1:solid1"

'@ delete shape: component1:solid2

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Delete "component1:solid2"

'@ define extrude: component1:cut1

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Extrude 
     .Reset 
     .Name "cut1" 
     .Component "component1" 
     .Material "Vacuum" 
     .Mode "Pointlist" 
     .Height "mt" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "0.0" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "-PL/2", "-PW/2" 
     .LineTo "-PL/2", "-PW/2+1.1" 
     .LineTo "0", "-PW/2" 
     .Create 
End With

'@ boolean subtract shapes: component1:PATCH, component1:cut1

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Subtract "component1:PATCH", "component1:cut1"

'@ define extrude: component1:cut1

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Extrude 
     .Reset 
     .Name "cut1" 
     .Component "component1" 
     .Material "Vacuum" 
     .Mode "Pointlist" 
     .Height "mt" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "0.0" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "-PL/2", "PW/2" 
     .LineTo "-PL/2", "PW/2-1.1" 
     .LineTo "0", "PW/2" 
     .Create 
End With

'@ boolean subtract shapes: component1:PATCH, component1:cut1

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Subtract "component1:PATCH", "component1:cut1"

'@ define extrude: component1:cut1

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Extrude 
     .Reset 
     .Name "cut1" 
     .Component "component1" 
     .Material "Vacuum" 
     .Mode "Pointlist" 
     .Height "mt" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "0.0" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "PL/2", "-PW/2" 
     .LineTo "PL/2", "-PW/2+1.1" 
     .LineTo "0", "-PW/2" 
     .Create 
End With

'@ boolean subtract shapes: component1:PATCH, component1:cut1

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Subtract "component1:PATCH", "component1:cut1"

'@ define extrude: component1:CUT12

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Extrude 
     .Reset 
     .Name "CUT12" 
     .Component "component1" 
     .Material "Vacuum" 
     .Mode "Pointlist" 
     .Height "mt" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "0.0" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "PL/2", "PW/2" 
     .LineTo "PL/2", "PW/2-1.1" 
     .LineTo "0", "PW/2" 
     .Create 
End With

'@ boolean subtract shapes: component1:PATCH, component1:CUT12

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Subtract "component1:PATCH", "component1:CUT12"

'@ pick end point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.PickEndpointFromId "component1:PATCH", "50"

'@ align wcs with point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.AlignWCSWithSelected "Point"

'@ activate global coordinates

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.ActivateWCS "global"

'@ pick end point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.PickEndpointFromId "component1:PATCH", "50"

'@ align wcs with point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.AlignWCSWithSelected "Point"

'@ define brick: component1:CUT1

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Brick
     .Reset 
     .Name "CUT1" 
     .Component "component1" 
     .Material "Vacuum" 
     .Xrange "0", "INL" 
     .Yrange "0", "INW" 
     .Zrange "-mt", "0" 
     .Create
End With

'@ boolean subtract shapes: component1:PATCH, component1:CUT1

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Subtract "component1:PATCH", "component1:CUT1"

'@ pick end point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.PickEndpointFromId "component1:PATCH", "65"

'@ align wcs with point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.AlignWCSWithSelected "Point"

'@ define brick: component1:CUT1

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Brick
     .Reset 
     .Name "CUT1" 
     .Component "component1" 
     .Material "Vacuum" 
     .Xrange "0", "INL" 
     .Yrange "-INW", "0" 
     .Zrange "-mt", "0" 
     .Create
End With

'@ boolean subtract shapes: component1:PATCH, component1:CUT1

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Subtract "component1:PATCH", "component1:CUT1"

'@ pick face

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.PickFaceFromId "component1:SUNBSTRATE", "1"

'@ align wcs with face

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.AlignWCSWithSelected "Face"

'@ define cylinder: component1:solid1

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Cylinder 
     .Reset 
     .Name "solid1" 
     .Component "component1" 
     .Material "Vacuum" 
     .OuterRadius "R_out" 
     .InnerRadius "R_out-c" 
     .Axis "z" 
     .Zrange "-mt", "0" 
     .Xcenter "0" 
     .Ycenter "0" 
     .Segments "0" 
     .Create 
End With

'@ delete shape: component1:solid1

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Delete "component1:solid1"

'@ define cylinder: component1:solid1

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Cylinder 
     .Reset 
     .Name "solid1" 
     .Component "component1" 
     .Material "Vacuum" 
     .OuterRadius "R_out" 
     .InnerRadius "R_out-c" 
     .Axis "z" 
     .Zrange "0", "mt" 
     .Xcenter "0" 
     .Ycenter "0" 
     .Segments "0" 
     .Create 
End With

'@ define brick: component1:cut1

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Brick
     .Reset 
     .Name "cut1" 
     .Component "component1" 
     .Material "Vacuum" 
     .Xrange "-g/2", "g/2" 
     .Yrange "0", "R_out+1" 
     .Zrange "0", "mt" 
     .Create
End With

'@ boolean subtract shapes: component1:solid1, component1:cut1

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Subtract "component1:solid1", "component1:cut1"

'@ boolean subtract shapes: component1:PATCH, component1:solid1

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Subtract "component1:PATCH", "component1:solid1"

'@ activate global coordinates

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.ActivateWCS "global"

'@ pick face

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.PickFaceFromId "component1:PATCH", "67"

'@ define port:1

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
' Port constructed by macro Solver -> Ports -> Calculate port extension coefficient


With Port
  .Reset
  .PortNumber "1"
  .NumberOfModes "1"
  .AdjustPolarization False
  .PolarizationAngle "0.0"
  .ReferencePlaneDistance "0"
  .TextSize "50"
  .Coordinates "Picks"
  .Orientation "Positive"
  .PortOnBound "True"
  .ClipPickedPortToBound "False"
  .XrangeAdd "0", "0"
  .YrangeAdd "0.8*3.95", "0.8*3.95"
  .ZrangeAdd "0.8", "0.8*3.95"
  .Shield "PEC"
  .SingleEnded "False"
  .Create
End With

'@ define time domain solver parameters

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Mesh.SetCreator "High Frequency" 

With Solver 
     .Method "Hexahedral"
     .CalculationType "TD-S"
     .StimulationPort "All"
     .StimulationMode "All"
     .SteadyStateLimit "-40"
     .MeshAdaption "False"
     .AutoNormImpedance "True"
     .NormingImpedance "50"
     .CalculateModesOnly "False"
     .SParaSymmetry "False"
     .StoreTDResultsInCache  "False"
     .RunDiscretizerOnly "False"
     .FullDeembedding "False"
     .SuperimposePLWExcitation "False"
     .UseSensitivityAnalysis "False"
End With

''@ define cylinder: component1:inner_ring
'
''[VERSION]2024.0|33.0.1|20230901[/VERSION]
'With Cylinder 
'     .Reset 
'     .Name "inner_ring" 
'     .Component "component1" 
'     .Material "Vacuum" 
'     .OuterRadius "R_out-c-d-c" 
'     .InnerRadius "R_out-c-d-c-d" 
'     .Axis "z" 
'     .Zrange "0", "mt" 
'     .Xcenter "0" 
'     .Ycenter "0" 
'     .Segments "0" 
'     .Create 
'End With
'
''@ define brick: component1:cut1
'
''[VERSION]2024.0|33.0.1|20230901[/VERSION]
'With Brick
'     .Reset 
'     .Name "cut1" 
'     .Component "component1" 
'     .Material "Vacuum" 
'     .Xrange "-g/2", "g/2" 
'     .Yrange "-R_out-1", "0" 
'     .Zrange "0", "mt" 
'     .Create
'End With
'
''@ boolean subtract shapes: component1:inner_ring, component1:cut1
'
''[VERSION]2024.0|33.0.1|20230901[/VERSION]
'Solid.Subtract "component1:inner_ring", "component1:cut1"
'
''@ boolean subtract shapes: component1:PATCH, component1:inner_ring
'
''[VERSION]2024.0|33.0.1|20230901[/VERSION]
'Solid.Subtract "component1:PATCH", "component1:inner_ring"
'
''@ pick face
'
''[VERSION]2024.0|33.0.1|20230901[/VERSION]
'Pick.PickFaceFromId "component1:PATCH", "80"
'
''@ activate global coordinates
'
''[VERSION]2024.0|33.0.1|20230901[/VERSION]
'WCS.ActivateWCS "global"
'
''@ define port: 1
'
''[VERSION]2024.0|33.0.1|20230901[/VERSION]
'With Port 
'     .Reset 
'     .PortNumber "1" 
'     .Label ""
'     .Folder ""
'     .NumberOfModes "1"
'     .AdjustPolarization "False"
'     .PolarizationAngle "0.0"
'     .ReferencePlaneDistance "0"
'     .TextSize "50"
'     .TextMaxLimit "0"
'     .Coordinates "Picks"
'     .Orientation "positive"
'     .PortOnBound "False"
'     .ClipPickedPortToBound "False"
'     .Xrange "-3.49", "-3.49"
'     .Yrange "-0.5485", "0.5485"
'     .Zrange "-1.3877787807814e-17", "0.035"
'     .XrangeAdd "0.0", "0.0"
'     .YrangeAdd "k*SH", "k*SH"
'     .ZrangeAdd "SH", "k*SH"
'     .SingleEnded "False"
'     .WaveguideMonitor "False"
'     .Create 
'End With
'
''@ define time domain solver parameters
'
''[VERSION]2024.0|33.0.1|20230901[/VERSION]
'Mesh.SetCreator "High Frequency" 
'
'With Solver 
'     .Method "Hexahedral"
'     .CalculationType "TD-S"
'     .StimulationPort "All"
'     .StimulationMode "All"
'     .SteadyStateLimit "-40"
'     .MeshAdaption "True"
'     .AutoNormImpedance "True"
'     .NormingImpedance "50"
'     .CalculateModesOnly "False"
'     .SParaSymmetry "False"
'     .StoreTDResultsInCache  "False"
'     .RunDiscretizerOnly "False"
'     .FullDeembedding "False"
'     .SuperimposePLWExcitation "False"
'     .UseSensitivityAnalysis "False"
'End With
'
''@ set PBA version
'
''[VERSION]2024.0|33.0.1|20230901[/VERSION]
'Discretizer.PBAVersion "2023090124"
'
''@ activate global coordinates
'
''[VERSION]2024.0|33.0.1|20230901[/VERSION]
'WCS.ActivateWCS "global"
'
''@ pick face
'
''[VERSION]2024.0|33.0.1|20230901[/VERSION]
'Pick.PickFaceFromId "component1:GROUND", "2"
'
''@ align wcs with face
'
''[VERSION]2024.0|33.0.1|20230901[/VERSION]
'WCS.AlignWCSWithSelected "Face"
'
''@ move wcs
'
''[VERSION]2024.0|33.0.1|20230901[/VERSION]
'WCS.MoveWCS "local", "SL/4", "0.0", "0.0"
'
''@ define frequency range
'
''[VERSION]2024.0|33.0.1|20230901[/VERSION]
'Solver.FrequencyRange "20", "70"
'
''@ activate global coordinates
'
''[VERSION]2024.0|33.0.1|20230901[/VERSION]
'WCS.ActivateWCS "global"
'
''@ define frequency range
'
''[VERSION]2024.0|33.0.1|20230901[/VERSION]
'Solver.FrequencyRange "20", "80"
'
'@ define frequency range

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solver.FrequencyRange "30", "80"

'@ align wcs with edge and face

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.PickFaceFromId "component1:SUNBSTRATE", "1" 
Pick.PickEdgeFromId "component1:PATCH", "144", "96" 
WCS.AlignWCSWithSelected "EdgeAndFace"

'@ define brick: component1:Top square

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Brick
     .Reset 
     .Name "Top square" 
     .Component "component1" 
     .Material "Copper (annealed)" 
     .Xrange "-tw/2", "tw/2" 
     .Yrange "0", "mt" 
     .Zrange "0", "tl" 
     .Create
End With

'@ boolean add shapes: component1:PATCH, component1:Top square

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Add "component1:PATCH", "component1:Top square"

'@ activate global coordinates

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.ActivateWCS "global"

'@ define frequency range

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solver.FrequencyRange "1", "50"

'@ pick end point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.PickEndpointFromId "component1:PATCH", "94"

'@ align wcs with point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.AlignWCSWithSelected "Point"

'@ rotate wcs

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.RotateWCS "u", "90.0"

'@ rotate wcs

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.RotateWCS "u", "180"

'@ pick end point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.PickEndpointFromId "component1:PATCH", "112"

'@ align wcs with point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.AlignWCSWithSelected "Point"

'@ define brick: component1:cut567

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Brick
     .Reset 
     .Name "cut567" 
     .Component "component1" 
     .Material "Vacuum" 
     .Xrange "-0.15", "0.07" 
     .Yrange "0", "2.94" 
     .Zrange "-mt", "0" 
     .Create
End With

'@ boolean subtract shapes: component1:PATCH, component1:cut567

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Subtract "component1:PATCH", "component1:cut567"

'@ pick end point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.PickEndpointFromId "component1:PATCH", "123"

'@ align wcs with point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.AlignWCSWithSelected "Point"

'@ define brick: component1:CUT789

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Brick
     .Reset 
     .Name "CUT789" 
     .Component "component1" 
     .Material "Vacuum" 
     .Xrange "-0.07", "0.15" 
     .Yrange "0", "2.94" 
     .Zrange "-mt", "0" 
     .Create
End With

'@ boolean subtract shapes: component1:PATCH, component1:CUT789

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Subtract "component1:PATCH", "component1:CUT789"

'@ pick edge

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.PickEdgeFromId "component1:PATCH", "35", "19"

'@ activate global coordinates

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.ActivateWCS "global"

'@ activate local coordinates

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.ActivateWCS "local"

'@ align wcs with edge

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.AlignWCSWithSelected "EdgeCenter"

'@ move wcs

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.MoveWCS "local", "0.0", "tw/2", "0.0"

'@ define brick: component1:cut67

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Brick
     .Reset 
     .Name "cut67" 
     .Component "component1" 
     .Material "Vacuum" 
     .Xrange "-tl/4", "tl/4" 
     .Yrange "-tl/2", "tl/2" 
     .Zrange "-mt", "0" 
     .Create
End With

'@ boolean subtract shapes: component1:PATCH, component1:cut67

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Subtract "component1:PATCH", "component1:cut67"

'@ define extrude: component1:cut21

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Extrude 
     .Reset 
     .Name "cut21" 
     .Component "component1" 
     .Material "Vacuum" 
     .Mode "Pointlist" 
     .Height "0.035" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "-mt" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "-1.829682", "-1.648791" 
     .LineTo "-0.732682", "-0.549791" 
     .LineTo "-0.732682", "-0.528791" 
     .Create 
End With

'@ boolean subtract shapes: component1:PATCH, component1:cut21

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Subtract "component1:PATCH", "component1:cut21"

'@ define extrude: component1:cut45

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Extrude 
     .Reset 
     .Name "cut45" 
     .Component "component1" 
     .Material "Vacuum" 
     .Mode "Pointlist" 
     .Height "0.035" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "-mt" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "-1.829682", "1.648791" 
     .LineTo "-0.732682", "0.548791" 
     .LineTo "-0.732682", "0.528791" 
     .Create 
End With

'@ boolean subtract shapes: component1:PATCH, component1:cut45

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Subtract "component1:PATCH", "component1:cut45"

'@ define extrude: component1:add1

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Extrude 
     .Reset 
     .Name "add1" 
     .Component "component1" 
     .Material "Copper (annealed)" 
     .Mode "Pointlist" 
     .Height "0.035" 
     .Twist "0.0" 
     .Taper "0.0" 
     .Origin "0.0", "0.0", "-mt" 
     .Uvector "1.0", "0.0", "0.0" 
     .Vvector "0.0", "1.0", "0.0" 
     .Point "-0.366341", "-0.732682" 
     .LineTo "-0.366341", "0.732682" 
     .LineTo "0.366341", "0.732682" 
     .LineTo "0.366341", "-0.732682" 
     .Create 
End With

'@ boolean add shapes: component1:PATCH, component1:add1

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Add "component1:PATCH", "component1:add1"

'@ define cylinder: component1:cut85

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Cylinder 
     .Reset 
     .Name "cut85" 
     .Component "component1" 
     .Material "Vacuum" 
     .OuterRadius "R_out" 
     .InnerRadius "R_out-c" 
     .Axis "z" 
     .Zrange "-mt", "0" 
     .Xcenter "0" 
     .Ycenter "0" 
     .Segments "0" 
     .Create 
End With

'@ boolean subtract shapes: component1:PATCH, component1:cut85

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Subtract "component1:PATCH", "component1:cut85"

'@ define brick: component1:cut65

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Brick
     .Reset 
     .Name "cut65" 
     .Component "component1" 
     .Material "Vacuum" 
     .Xrange "-g/2", "g/2" 
     .Yrange "-R_out-1", "0" 
     .Zrange "-mt", "0" 
     .Create
End With

'@ boolean add shapes: component1:PATCH, component1:cut65

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Add "component1:PATCH", "component1:cut65"

'@ activate global coordinates

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.ActivateWCS "global"

'@ pick end point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.PickEndpointFromId "component1:PATCH", "64"

'@ align wcs with point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.AlignWCSWithSelected "Point"

'@ move wcs

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.MoveWCS "local", "0.2", "0.2", "0.0"

'@ define brick: component1:cut56

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Brick
     .Reset 
     .Name "cut56" 
     .Component "component1" 
     .Material "Vacuum" 
     .Xrange "-0.2", "0" 
     .Yrange "-0.2", "0" 
     .Zrange "-mt", "0" 
     .Create
End With

'@ boolean subtract shapes: component1:PATCH, component1:cut56

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Subtract "component1:PATCH", "component1:cut56"

'@ define cylinder: component1:add4

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Cylinder 
     .Reset 
     .Name "add4" 
     .Component "component1" 
     .Material "Vacuum" 
     .OuterRadius "0.2" 
     .InnerRadius "0.0" 
     .Axis "z" 
     .Zrange "-mt", "0" 
     .Xcenter "0" 
     .Ycenter "0" 
     .Segments "0" 
     .Create 
End With

'@ boolean add shapes: component1:PATCH, component1:add4

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Add "component1:PATCH", "component1:add4"

'@ pick end point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.PickEndpointFromId "component1:PATCH", "71"

'@ align wcs with point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.AlignWCSWithSelected "Point"

'@ define brick: component1:CUT76

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Brick
     .Reset 
     .Name "CUT76" 
     .Component "component1" 
     .Material "Vacuum" 
     .Xrange "0", "0.2" 
     .Yrange "-0.2", "0" 
     .Zrange "-mt", "0" 
     .Create
End With

'@ boolean subtract shapes: component1:PATCH, component1:CUT76

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Subtract "component1:PATCH", "component1:CUT76"

'@ pick end point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.PickEndpointFromId "component1:PATCH", "243"

'@ align wcs with point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.AlignWCSWithSelected "Point"

'@ define cylinder: component1:add5

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Cylinder 
     .Reset 
     .Name "add5" 
     .Component "component1" 
     .Material "Vacuum" 
     .OuterRadius ".2" 
     .InnerRadius "0.0" 
     .Axis "z" 
     .Zrange "-mt", "0" 
     .Xcenter "0" 
     .Ycenter "0" 
     .Segments "0" 
     .Create 
End With

'@ boolean add shapes: component1:PATCH, component1:add5

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Add "component1:PATCH", "component1:add5"

'@ pick end point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.PickEndpointFromId "component1:PATCH", "79"

'@ align wcs with point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.AlignWCSWithSelected "Point"

'@ define brick: component1:cut87

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Brick
     .Reset 
     .Name "cut87" 
     .Component "component1" 
     .Material "Vacuum" 
     .Xrange "-0.2", "0" 
     .Yrange "0", "0.2" 
     .Zrange "-mt", "0" 
     .Create
End With

'@ boolean subtract shapes: component1:PATCH, component1:cut87

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Subtract "component1:PATCH", "component1:cut87"

'@ pick end point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.PickEndpointFromId "component1:PATCH", "258"

'@ align wcs with point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.AlignWCSWithSelected "Point"

'@ define cylinder: component1:add87

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Cylinder 
     .Reset 
     .Name "add87" 
     .Component "component1" 
     .Material "Vacuum" 
     .OuterRadius "0.2" 
     .InnerRadius "0.0" 
     .Axis "z" 
     .Zrange "-mt", "0" 
     .Xcenter "0" 
     .Ycenter "0" 
     .Segments "0" 
     .Create 
End With

'@ boolean add shapes: component1:PATCH, component1:add87

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Add "component1:PATCH", "component1:add87"

'@ pick end point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.PickEndpointFromId "component1:PATCH", "87"

'@ activate global coordinates

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.ActivateWCS "global"

'@ activate local coordinates

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.ActivateWCS "local"

'@ align wcs with point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.AlignWCSWithSelected "Point"

'@ define brick: component1:CUT65

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Brick
     .Reset 
     .Name "CUT65" 
     .Component "component1" 
     .Material "Vacuum" 
     .Xrange "-0.2", "0" 
     .Yrange "-0.2", "0" 
     .Zrange "0", "mt" 
     .Create
End With

'@ boolean subtract shapes: component1:PATCH, component1:CUT65

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Subtract "component1:PATCH", "component1:CUT65"

'@ pick end point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.PickEndpointFromId "component1:PATCH", "274"

'@ align wcs with point

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.AlignWCSWithSelected "Point"

'@ define cylinder: component1:add87

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
With Cylinder 
     .Reset 
     .Name "add87" 
     .Component "component1" 
     .Material "Vacuum" 
     .OuterRadius "0.2" 
     .InnerRadius "0.0" 
     .Axis "z" 
     .Zrange "-mt", "0" 
     .Xcenter "0" 
     .Ycenter "0" 
     .Segments "0" 
     .Create 
End With

'@ boolean add shapes: component1:PATCH, component1:add87

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Solid.Add "component1:PATCH", "component1:add87"

'@ activate global coordinates

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.ActivateWCS "global"

'@ pick face

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.PickFaceFromId "component1:PATCH", "185"

'@ align wcs with face

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.AlignWCSWithSelected "Face"

'@ clear picks

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.ClearAllPicks

'@ pick face

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.PickFaceFromId "component1:PATCH", "185"

'@ align wcs with face

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.AlignWCSWithSelected "Face"

'@ pick face

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.PickFaceFromId "component1:PATCH", "185"

'@ align wcs with face

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.AlignWCSWithSelected "Face"

'@ pick face

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.PickFaceFromId "component1:PATCH", "185"

'@ align wcs with face

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.AlignWCSWithSelected "Face"

'@ clear picks

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.ClearAllPicks

'@ pick face

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.PickFaceFromId "component1:SUNBSTRATE", "1"

'@ align wcs with face

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.AlignWCSWithSelected "Face"

'@ clear picks

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
Pick.ClearAllPicks

'@ activate global coordinates

'[VERSION]2024.0|33.0.1|20230901[/VERSION]
WCS.ActivateWCS "global"

