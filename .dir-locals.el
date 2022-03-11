;; PLEASE DO NOT REMOVE THIS FILE. Its purpose is to setup
;; EMACS local file variables such, that VUnit and compilator can
;; setup correctly the compilation environment

;; note: to make all this working one has to install VUnit from this
;; submodule and link it to the /opt directory such, that the VUnit
;; verilog directory is correctly visible on the path below
;; note that in order to make flycheck correctly working the file
;; flycheck-verilog-modelsim.el has to be part of your emacs
;; configuration (as modelsim verilog linting is not core part of
;; emacs, it only uses verilator)

;; note: NIL portion generates a variable, which tells where the VUNIT
;; is stored. This variable is used later in verilog-mode settings to
;; setup proper emacs compilation environment.
;;
;; AS WELL: VERIFY PROPER INSTALLATION OF MODELSIM AND EVENTUALLY SETUP HERE
;; DIFFERENT WORKING DIRECTORY
((verilog-mode . ((eval . (progn
			    (pabbrev-mode t)
			    (auto-fill-mode t)
			    (shell-command
			     "python3 -c \"import os, vunit;print(os.path.join(os.path.split(vunit.__file__)[0], \\\"verilog\\\"))\""
			     "*vunit_dir*")
			    (setq cbuf (current-buffer))
			    (set-buffer "*vunit_dir*")
			    (setq vudir (replace-regexp-in-string "\n$" "" (buffer-string)))
			    (setq vuincl (concat (replace-regexp-in-string
						  "\n$" "" (buffer-string)) "/include"))
			    (message (concat "Found VUNIT directory: " vudir))
			    (message (concat "Found VUNIT include: " vuincl))
			    (require 'verilog-mode)
			    (set-fill-column 120)
			    (setq verilog-auto-wire-type "logic")
			    (setq verilog-library-extensions '(".v" ".h" ".sv" ".svh" ".vh"))
			    (setq flycheck-verilator-include-path `(,(concat
								      vuincl)))
			    (setq verilog-linter
				  (concat
				   "/opt/mentor-modelsim/modeltech/bin/vlog "
				   "-sv12compat "
				   "-work ~/work "
				   "+incdir+../modules "
				   "+incdir+" vuincl))
			    (setq verilog-auto-inst-interfaced-ports t)
			    (setq verilog-typedef-regexp "_t$")
			    (setq verilog-auto-read-includes t)
			    (setq direl-directory (file-name-directory
			    			   (let ((d (dir-locals-find-file ".")))
			    			     (if (stringp d) d (car d)))))
			    ;;(setq direl-directory "/home/belohrad/git/fmc_adc_perf/")
			    (message (concat "Found project root: " direl-directory))
			    (setq full-path-dirs (mapcar (lambda (x) (concat direl-directory x))
							 '("hdl/src/"
							   "hdl/tests/"
							   "hdl/src/diagnostics/"
							   "libs/BI_HDL_Cores/cores_for_simulation/"
							   "libs/BI_HDL_Cores/cores_for_synthesis/"
							   "libs/mcoi_hdl_library/modules/mko/"
							   "libs/mcoi_hdl_library/modules/tlc5920/"
							   "libs/mcoi_hdl_library/modules/get_edge/")))
			    (add-to-list 'full-path-dirs vuincl vudir)
			    (setq verilog-library-directories full-path-dirs)
			    ;; systemverilog projectile to switch between test and implementation
			    )))))
