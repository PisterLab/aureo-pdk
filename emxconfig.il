; EMX_interface_path tells where you've installed the interface.  This
; file (emxconfig.il) is in EMX_interface_path/emxskill/
EMX_interface_path=(strcat (getShellEnvVar "EMX_HOME") "/share/emx/virtuoso_ui/emxinterface")

; Variables marked with *TF* can depend on the technology library.  To
; use this feature, make the variable an association list like
; (("techlib1" "value1") ("techlib2" "value2") ...).  If the tech
; library is "techlib1", the variable will have value "value1", etc.
; Use t for the tech library if you want a default value.  Example

; EMX_layer_table (*TF*) has the layer table for streaming out GDSII
; (needed if the technology file does not have this information)
; EMX_layer_table=(strcat EMX_interface_path "/emxskill/layers.txt")
EMX_layer_table=""

; EMX_EMX_opts (*TF*) sets the default command-line options for EMX on
; the advanced options form. EMX_GDSview_opts (*TF*) is for GDSview;
; it defaults to the same value as EMX_EMX_opts.
;EMX_EMX_opts=""
;EMX_GDSview_opts=""

; EMX_process_path (*TF*) tells where you keep EMX process files
; EMX_process_path=(strcat (getShellEnvVar "BAG_TECH_CONFIG_DIR") "/emx_setup")
EMX_process_path=(getShellEnvVar "PWD")

; EMX_process_name (*TF*) is the process file name (sans path).  Nil
; means take the first .proc file in the EMX_process_path directory
EMX_process_name="aureo.proc"

; If you want to run EMX on a remote machine, set this to the machine
; name (or IP address).  You must be able to execute a command on the
; remote machine via "ssh machine command" without requiring a
; password.  See the ssh man page for authentication options.  If you
; want to run EMX locally, set this to the empty string ("").  If your
; organization uses the bsub facility, you can set this to a string of
; the form "bsub ..." to invoke EMX via bsub.  Specify default options
; for things like the queue as part of the "...".  (You can also use
; qsub in the same way as bsub.)
;EMX_remote_machine="bsub -q desired_queue"
;EMX_remote_machine="qsub -q desired_queue"
EMX_remote_machine=""

; EMX_path tells where you've installed the EMX executables (emx,
; modelgen, gdsview)
EMX_path=(strcat (getShellEnvVar "EMX_HOME") "/bin")

; EMX_ps_viewer and EMX_pdf_viewer are the applications used for
; viewing PostScript or PDF files (EMX versions prior to 2.13 can only
; produce PostScript files).  Common alternatives include gv, ggv,
; evince, okular, konqueror, and acroread
EMX_ps_viewer="evince"
;EMX_pdf_viewer="evince"  ; when unset, defaults to EMX_ps_viewer

; Setting EMX_log_displayer to a string makes the interface spawn an
; external process to display the log file.  The string should contain
; a %s where the name of the log file should go.  Nil means use the
; internal Cadence viewer.
EMX_log_displayer=nil
;EMX_log_displayer="xterm -title 'EMX output' -e tail -f %s"

; By default, the interface puts all of the EMX files associated with
; a particular library and cell in the subdirectory lib_cell.work of
; the current directory, where lib and cell are the Cadence library
; and cell names.  If you want to put all of these lib_cell.work
; directories in a different place, set EMX_working_dir to that place.
EMX_working_dir="./EMX_work"
;EMX_working_dir="."
;EMX_working_dir="/where/I/want/the/interface/to/put/EMX/files"

; This option is a command for starting a documentation viewer.  When
; nil, the documentation button is not shown.
;EMX_documentation=nil  ; default if variable is unset
;EMX_documentation=(sprintf nil "dolphin %s > /dev/null 2>&1 < /dev/null"
;                           (sprintf nil "%s/EMX_documentation" EMX_interface_path))
EMX_documentation=(sprintf nil "nautilus %s > /dev/null 2>&1 < /dev/null"
                           (sprintf nil "%s/EMX_documentation" EMX_interface_path))

; Set view_name to a string like "sparam" to make a new view that
; holds the S-parameters for n-port models.  If there's a shell
; variable that holds a prefix of the library directory and you want
; the n-port to be relative to that directory, then set view_prefix to
; the name of the shell variable.
;EMX_nport_sparam_view_name=nil   ; view name, e.g., "sparam"
;EMX_nport_sparam_view_prefix=nil ; name of shell var, e.g., "PROJ_ROOT"

; Variables marked as *AC* are set automatically according to the
; installed version of EMX and ModelGen.  Use EMX_auto_config=nil to
; disable this.
EMX_auto_config=t

; EMX_pole_zero_models (*AC*) enables general state-space model
; creation.  EMX must support the --model-file option.
EMX_pole_zero_models=t

; EMX_black_box (*AC*) enables black box support in the interface.  It
; requires a version of EMX that supports --device-cells-file.
EMX_black_box=nil

; EMX_connectivity (*AC*) enables DC connectivity (LVS) support.  EMX
; must support the --dump-connectivity option.
EMX_connectivity=nil

; EMX_frequency_indep (*AC*) enables frequency-independent Green's
; function support.  EMX must support --frequency-independent.
EMX_frequency_indep=nil

; Set EMX_cadence_dev_info (*AC*) if EMX and GDSview recognize Cadence
; information for black-boxed devices
EMX_cadence_dev_info=nil

; EMX_dynamic_frequencies (*AC*) indicates whether EMX can dynamically
; set the maximum number of sweep frequencies (i.e., whether
; --simultaneous-frequencies=0 is allowed)
EMX_dynamic_frequencies=nil

; EMX_mg_global_interp (*AC*) if ModelGen recognizes the
; --global-interp option
EMX_mg_global_interp=nil

; These are the original style extracted view names (and defaults)
;EMX_symbol_name="symbol"
;EMX_symbol_nport_name="symbol_nport"
;EMX_schematic_name="schematic"
;EMX_schematic_nport_name="schematic_nport"
;EMX_schematic_pz_name="schematic"
;EMX_schematic_dc_name="EMX_dc"
; These are the new style extracted view names
;EMX_symbol_name="symbol"
;EMX_symbol_nport_name="symbol"
;EMX_schematic_name="EMX_model"
;EMX_schematic_nport_name="EMX_spar"
;EMX_schematic_pz_name="EMX_pz"
;EMX_schematic_dc_name="EMX_dc"
; Optional views produced with symbol and symbol_nport
;EMX_aucdl_name="auCdl"  ; string, or nil to not generate
;EMX_aulvs_name="auLvs"  ; string, or nil to not generate
; Miscellaneous
;EMX_bsub_default=nil  ; t => default "Use bsub" field to selected
;EMX_viewproc_local=t  ; nil => emx --print-proc via bsub instead of locally
;EMX_spectre_local=t   ; nil => run spectre via bsub instead of locally
;EMX_modelgen_local=t  ; nil => to run modelgen via bsub instead of locally
;EMX_spectre_command="spectre"  ; maybe "PATH=/path/to/cadence/bin: spectre"
;EMX_modelgen_path=EMX_path  ; if modelgen is in a different place
;EMX_internal_PSF_reader=nil  ; probably not needed anymore
;EMX_xsection_opts=""  ; use --generate-pdf for PDF instead of PostScript
;EMX_specialized_models=t  ; nil => modelgen models use generic model form
;EMX_RLCK_model_schematics=t  ; nil => non-generic modelgen models have an
			      ; instance reference, t => use an RLCK schematic
;EMX_new_style_menu_trigger=t  ; probably not needed anymore
;EMX_fixed_cell_name=t ; nil => use [@cellName] in black box symbol
;EMX_global_ref_ground=nil ; t => implicit references can use gnd!
;EMX_dialog_msgs=0 ; 0 => warn and info use dialog box
		   ; 1 => warn uses dbox; info goes to CIW
		   ; 2 => warn and info go to CIW
;EMX_form_init_proc=nil ; symbol = function to call after form creation
 			; arguments are basic form and advanced form
; The following are hooks that are called after view creation
; arguments are (open) cellview; names of lib, cell, and view; and
; a final argument indicating what was just created.  Each hook can
; be either a symbol (the name of a function) or a function.
;EMX_schematic_creation_hook=nil ; called after schematic view creation
				 ; type is either a string (= model type)
				 ; or a symbol (= 'nport for S-param view,
				 ; 'generic for other schematic)
;EMX_LVS_creation_hook=nil ; called after LVS view creation
			   ; type is either 'assura (for auLvs)
			   ; or 'calibre (for auCdl)
;EMX_symbol_creation_hook=nil ; called after symbol view creation
			      ; type is either a string (= model type)
			      ; or the symbol 'nport
;views_for_EMX_menu='(("maskLayout" nil) ("maskLayoutXL" nil))
; views_for_EMX_menu is a list of views where the EMX menu should be
; installed.  Each element is a pair of a view name and either nil for
; a layout view or t for a schematic view.

;; To make the interface set temperature coefficients for built-in
;; models:
; EMX_default_tcr1="1e-3" ; Set EMX_default_tcr1 and _tcr2 as desired
; EMX_default_tcr2="2e-3"
; EMX_schematic_creation_hook='EMX_set_model_temp_coeffs

; Now actually load the interface
(load (strcat EMX_interface_path "/emxskill/emxform.ils"))
