[Mesh]
  type = GeneratedMesh
  dim = 1
  xmin = -2000
  xmax = 0
  nx = 1000
[]

[GlobalParams]
  temperature = T
  pressure = p
  flowrate = q
[]

[UserObjects]
  [./eos]
    type = MoskitoEOS1P_Const
  [../]
  [./viscosity]
    type = MoskitoViscosityConst
  [../]
[]

[Materials]
  [./well_inj]
    type = MoskitoFluidWell_1p1c
    well_type = injection
    well_direction = -x
    eos_uo = eos
    viscosity_uo = viscosity
    well_diameter = 0.08
    manual_friction_factor = 0
    roughness_type = smooth
    gravity = '-9.81 0 0'
    output_properties = 'density well_velocity'
    outputs = exodus
  [../]
[]

[BCs]
  [./inj_top_qbc]
    type = FunctionDirichletBC
    variable = q
    boundary = right
    function = flowrateic_inj
  [../]
  [./inj_top_Tbc]
    type = FunctionDirichletBC
    variable = T
    boundary = right
    function = temperature_ini
  [../]
  [./wellbore_inj_pbc_set]
    type = FunctionDirichletBC
    variable = p
    boundary = left
    function = hydrostatic
  [../]
[]

[ICs]
  [./flowrate_ic_inj]
    type = FunctionIC
    variable = q
    function = flowrateic_inj
  [../]
  [./pressure_ic]
    type = FunctionIC
    variable = p
    function = hydrostatic
  [../]
  [./temperature_ic]
    type = FunctionIC
    variable = T
    function = temperature_ini
  [../]
[]

[Functions]
  [./hydrostatic]
    type = ParsedFunction
    value = '10*1e5-1000*9.81*x'
  [../]
  [./temperature_ini]
    type = ParsedFunction
    value = '293.15-0.03*x'
  [../]
  [./flowrateic_inj]
    type = ParsedFunction
    vars = 'v'
    vals = '4e-2'
    value = '4e-2'
  [../]
[]

[Variables]
  [./q]
    scaling = 1e-4
  [../]
  [./p]
    scaling = 1e+1
  [../]
  [./T]
    scaling = 1e-14
  [../]
[]

[Kernels]
  [./pkernel]
    type = MoskitoMass_1p1c
    variable = p
  [../]
  [./ptimekernel]
    type = MoskitoTimeMass_1p1c
    variable = p
  [../]
  [./qkernel]
    type = MoskitoMomentum_1p1c
    variable = q
  [../]
  [./qtimekernel]
    type = MoskitoTimeMomentum_1p1c
    variable = q
  [../]
  [./Tkernel]
    type = MoskitoEnergy_1p1c
    variable = T
    gravity_energy = true
  [../]
  [./Ttimekernel]
    type = MoskitoTimeEnergy_1p1c
    variable = T
  [../]
[]

[Preconditioning]
  active = pn1
  [./pn1]
  type = SMP
  full = true
  petsc_options_iname = '-pc_type -sub_pc_type -sub_pc_factor_shift_type -snes_type -snes_linesearch_type'
  petsc_options_value = ' bjacobi ilu NONZERO newtonls basic'
  [../]
[]

[Executioner]
  type = Transient
  dt = 1000
  end_time = 3e+6
  l_tol = 1e-10
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-7
  nl_max_its = 50
  l_max_its = 50
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
[]

[Postprocessors]
  [./inj_bottom_p_from_master]
    type = Receiver
  [../]
[]

[Outputs]
  exodus = true
  print_linear_residuals = true
[]

[Debug]
  show_var_residual_norms = true
[]
