[Mesh]
  [./file]
    type = FileMeshGenerator
    file = reservoir.msh
  [../]
[]

[GlobalParams]
  PorousFlowDictator = dictator
  multiply_by_density = true
  porepressure = porepressure
  temperature = temperature
  gravity = '-9.81 0 0'
[]

[FluidProperties]
  [water_uo]
    type = SimpleFluidProperties
    bulk_modulus = 2E9
    viscosity = 1.0e-3
    density0 = 1000.0
    thermal_expansion = 0.0
  []
[]

[UserObjects]
  [./dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'porepressure temperature'
    number_fluid_phases = 1
    number_fluid_components = 1
  [../]
[]

[Materials]
  [temperature]
    type = PorousFlowTemperature
  []
  [ppss]
    type = PorousFlow1PhaseFullySaturated
  []
  [./simple_fluid]
    type = PorousFlowSingleComponentFluid
    fp = water_uo
    phase = 0
  [../]
  [diff1]
    type = PorousFlowDiffusivityConst
    diffusion_coeff = '0'
    tortuosity = 1
  []
  [porosity]
    type = PorousFlowPorosityConst
    porosity = 0.1
  []
  [permeability_aquifer]
    type = PorousFlowPermeabilityConst
    permeability = '1.1973e-12 0 0   0 1.1973e-12 0   0 0 1.1973e-12'
  []
  [relp]
    type = PorousFlowRelativePermeabilityConst
    phase = 0
  []
  [rock_heat]
    type = PorousFlowMatrixInternalEnergy
    specific_heat_capacity = 950
    density = 2500
  []
  [./thermal_conductivity]
    type = PorousFlowThermalConductivityIdeal
    dry_thermal_conductivity = '1.986 0 0 0 1.986 0 0 0 1.986'
  [../]
  [massfrac]
    type = PorousFlowMassFraction
  []
[]

[BCs]
  [./inj_bottom_T]
    type = FunctionDirichletBC
    variable = temperature
    boundary = inj_bottom
    function = thermalgradient
  [../]
[]

[ICs]
  [./hydrostatic_ic]
   type = FunctionIC
   variable = porepressure
   function = hydrostatic
  [../]
  [./T_ic]
    type = FunctionIC
    variable = temperature
    function = thermalgradient
   [../]
[]

[Functions]
  [./hydrostatic]
    type = ParsedFunction
    value = '10*1e5-1000*9.81*x'
  [../]
  [./thermalgradient]
    type = ParsedFunction
    value = '293.15-0.03*x'
  [../]
[]

[Variables]
  [porepressure]
    scaling = 1e-2
  []
  [temperature]
    scaling = 1e-7
  []
[]

[Kernels]
  [mass]
    type = PorousFlowMassTimeDerivative
    fluid_component = 0
    variable = porepressure
  []
  [adv]
    type = PorousFlowAdvectiveFlux
    fluid_component = 0
    variable = porepressure
  []
  [diff]
    type = PorousFlowDispersiveFlux
    fluid_component = 0
    variable = porepressure
    disp_trans = 0
    disp_long = 0
  []
  [EnergyTransient]
    type = PorousFlowEnergyTimeDerivative
    variable = temperature
  []
  [./EnergyConduciton]
    type = PorousFlowHeatConduction
    variable = temperature
  [../]
  [./EnergyAdvection]
    type = PorousFlowHeatAdvection
    variable = temperature
  [../]
[]

[Preconditioning]
  active = 'smp'
  [smp]
  type = SMP
  full = true
  petsc_options_iname = '-ksp_type -pc_type -sub_pc_type -sub_pc_factor_shift_type -pc_asm_overlap'
  petsc_options_value = 'gmres      asm      lu           NONZERO                   2             '
[]
[]

[Executioner]
  type = Transient
  dt = 1000
  end_time = 3e+6
  l_tol = 1e-8
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-7
  l_max_its = 50
  nl_max_its = 50
  fixed_point_max_its = 10
  fixed_point_abs_tol = 1e-9
  solve_type = NEWTON
 []

 [Postprocessors]
   [./inj_bottom_p_master]
     type = PointValue
     point = '-2000 1000 500'
     variable = porepressure
   [../]
 []

[MultiApps]
  [./pipe_sub]
    type = TransientMultiApp
    input_files = pipe_sub.i
    positions = '0 1000 500'
    library_path = /home/kit/agw/qz9211/projects/moskito-master/lib
    app_type = MoskitoApp
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  [../]
[]

[Transfers]
  [./inj_bottom_p_transfer]
    type = MultiAppPostprocessorTransfer
    to_multiapp = pipe_sub
    from_postprocessor = inj_bottom_p_master
    to_postprocessor = inj_bottom_p_from_master
    reduction_type = average
    execute_on = SAME_AS_MULTIAPP
  [../]
[]

[Outputs]
  exodus = true
  print_linear_residuals = true
[]

[Debug]
  show_var_residual_norms = true
[]
