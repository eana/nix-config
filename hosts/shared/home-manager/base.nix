{
  inputs,
  modulesFromDir,
  modulesDir,
}:
[
  inputs.nixvim.homeModules.nixvim
]
++ builtins.attrValues (modulesFromDir modulesDir)
