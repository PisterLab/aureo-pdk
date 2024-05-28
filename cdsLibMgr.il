
let( (MEMSplusInstallDir MEMSplusCdsLibMgr)
  MEMSplusInstallDir = getShellEnvVar("MEMSPLUS_HOME")
  ;; Check MEMS+ menu customization can be found
  if( MEMSplusInstallDir
  then
    MEMSplusCdsLibMgr = strcat(MEMSplusInstallDir "/runtime/cadence/skill/cdsLibMgr_impl.il")

    if( !isFile(MEMSplusCdsLibMgr)
    then
      error(strcat("[MEMS+] Customizations for Library Manager could not be found at " MEMSplusCdsLibMgr ".\n[MEMS+] Please make sure the MEMSPLUS_HOME environment variable is properly defined."))
    else
      ;; Library Manager Customizations for MEMS+, directly loaded from MEMS+ installation
      load( MEMSplusCdsLibMgr )
    ) ; fi
  else
    error("[MEMS+] The MEMSPLUS_HOME environment variable is not defined.\n[MEMS+] Please check the documentation on how to integrate MEMS+ to Cadence Virtuoso.")
  ) ; fi
  
) ; let
